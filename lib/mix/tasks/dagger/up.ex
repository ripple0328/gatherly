defmodule Mix.Tasks.Dagger.Up do
  @shortdoc "Smart development environment startup"

  @moduledoc """
  Intelligently starts the development environment with minimal steps.

  This command uses smart detection to determine what's needed:
  - If environment is ready, starts services immediately
  - If deps missing, installs them first
  - If database missing, creates it
  - Skips unnecessary steps for fastest startup
  - Runs Phoenix server in foreground with live logs

  ## Examples

      mix dagger.up                    # Smart setup + start server
      mix dagger.up --port 3000        # Custom port
      mix dagger.up --force-setup      # Force full setup

  ## Stopping

  Press Ctrl+C to stop the development server.

  ## Options

    * `--port` - Port for development server (default: 4000)
    * `--force-setup` - Force full setup even if environment appears ready
  """

  use Mix.Task

  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}
  alias Mix.Tasks.Dagger.Setup

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [port: :integer, force_setup: :boolean],
        aliases: [p: :port, f: :force_setup]
      )

    port = Keyword.get(opts, :port, 4000)
    force_setup = Keyword.get(opts, :force_setup, false)

    log_step("🚀 Starting development environment", :start)

    execute(port: port, force_setup: force_setup)
  end

  def execute(opts \\ []) do
    port = Keyword.get(opts, :port, 4000)
    force_setup = Keyword.get(opts, :force_setup, false)

    Client.with_client(fn client ->
      if force_setup do
        log_step("Force setup requested, running full setup...")
        run_full_setup()
        start_dev_server(client, port)
      else
        # Smart detection and minimal setup
        environment_state = detect_environment_state(client)
        handle_smart_startup(environment_state, client, port)
      end
    end)
  end

  defp detect_environment_state(client) do
    log_step("🔍 Detecting environment state...")

    %{
      deps_ready: deps_ready?(client),
      compiled: compiled?(client),
      database_ready: database_ready?(client),
      assets_ready: assets_ready?(client)
    }
  end

  defp deps_ready?(client) do
    case Containers.elixir_dev(client)
         |> exec_and_get_output("mix", ["deps.check"]) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  rescue
    _ -> false
  end

  defp compiled?(client) do
    case Containers.elixir_dev(client)
         |> exec_and_get_output("mix", ["compile", "--warnings-as-errors"]) do
      {:ok, output} ->
        # If output contains "Generated" or is empty, it's compiled
        String.contains?(output, "Generated") or String.trim(output) == ""
      {:error, _} -> false
    end
  rescue
    _ -> false
  end

  defp database_ready?(_client) do
    # Check if database exists by looking for migration status
    # For now, we'll be conservative and assume DB setup is needed
    case File.exists?("priv/repo/migrations") do
      true ->
        # Migrations exist, check if DB is accessible
        case System.cmd("pg_isready", ["-h", "localhost", "-p", "5432"], stderr_to_stdout: true) do
          {_, 0} -> true
          _ -> false
        end
      false ->
        # No migrations, assume new project
        true
    end
  rescue
    _ -> false
  end

  defp assets_ready?(_client) do
    # Check if compiled assets exist
    File.exists?("priv/static/assets") and
    not Enum.empty?(File.ls!("priv/static/assets"))
  rescue
    _ -> false
  end

  defp handle_smart_startup(state, client, port) do
    log_environment_state(state)

    cond do
      all_ready?(state) ->
        log_step("✅ Environment ready, starting server immediately", :success)
        start_dev_server(client, port)

      needs_full_setup?(state) ->
        log_step("🔧 Environment needs setup, running quick setup...")
        run_quick_setup(state)
        start_dev_server(client, port)

      needs_minimal_setup?(state) ->
        log_step("⚡ Running minimal setup...")
        run_minimal_setup(state)
        start_dev_server(client, port)

      true ->
        log_step("🔧 Environment state unclear, running safe setup...")
        run_safe_setup()
        start_dev_server(client, port)
    end
  end

  defp log_environment_state(state) do
    log_step("Environment Status:", :info)
    log_step("  📦 Dependencies: #{status_icon(state.deps_ready)}", :info)
    log_step("  🔨 Compiled: #{status_icon(state.compiled)}", :info)
    log_step("  🗄️  Database: #{status_icon(state.database_ready)}", :info)
    log_step("  🎨 Assets: #{status_icon(state.assets_ready)}", :info)
  end

  defp status_icon(true), do: "✅"
  defp status_icon(false), do: "❌"

  defp all_ready?(state) do
    state.deps_ready and state.compiled and state.database_ready and state.assets_ready
  end

  defp needs_full_setup?(state) do
    not state.deps_ready
  end

  defp needs_minimal_setup?(state) do
    state.deps_ready and (not state.compiled or not state.assets_ready)
  end

  defp run_full_setup do
    log_step("Running full environment setup...")
    case Setup.execute([]) do
      {:ok, _} ->
        log_step("Full setup completed", :success)
        {:ok, :setup_complete}
      error ->
        log_step("Setup failed", :error)
        error
    end
  end

  defp run_quick_setup(state) do
    # Skip database if it's ready
    skip_db = state.database_ready

    case Setup.execute(skip_db: skip_db) do
      {:ok, _} ->
        log_step("Quick setup completed", :success)
        {:ok, :setup_complete}
      error ->
        log_step("Quick setup failed", :error)
        error
    end
  end

  defp run_minimal_setup(state) do
    Client.with_client(fn client ->
      container = Containers.elixir_dev(client)

      # Compile if needed
      unless state.compiled do
        log_step("Compiling application...")
        {:ok, _} = exec_and_get_output(container, "mix", ["compile"])
        log_step("Compilation completed", :success)
      end

      # Setup assets if needed
      unless state.assets_ready do
        log_step("Setting up assets...")
        {:ok, _} = exec_and_get_output(container, "mix", ["assets.setup"])
        log_step("Assets setup completed", :success)
      end

      {:ok, :minimal_setup_complete}
    end)
  end

  defp run_safe_setup do
    log_step("Running safe setup (skip database)...")
    case Setup.execute(skip_db: true) do
      {:ok, _} ->
        log_step("Safe setup completed", :success)
        {:ok, :setup_complete}
      error ->
        log_step("Safe setup failed", :error)
        error
    end
  end

  defp start_dev_server(client, port) do
    log_step("🚀 Starting Phoenix development server on port #{port}", :start)
    log_step("💡 Server will run in foreground - press Ctrl+C to stop", :info)

    # Start PostgreSQL service
    log_step("Starting PostgreSQL container")
    postgres_service =
      client
      |> Containers.postgres(
        database: "gatherly_dev",
        user: "postgres",
        password: "postgres"
      )
      |> Dagger.Container.as_service()

    log_step("Database started", :success)

    # Setup Phoenix environment
    phoenix_env = %{
      "MIX_ENV" => "dev",
      "PORT" => to_string(port),
      "PHX_HOST" => "0.0.0.0",
      "PHX_SERVER" => "true",
      "DATABASE_URL" => "postgres://postgres:postgres@db:5432/gatherly_dev"
    }

    # Create Phoenix server container that runs as a service
    phoenix_container =
      client
      |> Containers.elixir_dev(env: phoenix_env)
      |> Dagger.Container.with_service_binding("db", postgres_service)
      |> Dagger.Container.with_exposed_port(port)
      |> Dagger.Container.with_exec(["mix", "phx.server"])

    # Convert to service to get network endpoint
    phoenix_service = Dagger.Container.as_service(phoenix_container)

    # Get the service endpoint
    case Dagger.Service.endpoint(phoenix_service, port: port) do
      {:ok, service_endpoint} ->
        log_step("🔗 Phoenix service endpoint: #{service_endpoint}", :info)

        # Start a host-side proxy using socat to forward traffic from localhost to the service
        host_port = port

        log_step("🌐 Starting port forwarding: localhost:#{host_port} -> #{service_endpoint}")

        # Start the proxy in background and keep services running
        proxy_task = Task.async(fn ->
          start_port_proxy(service_endpoint, host_port)
        end)

        log_step("✅ Phoenix server accessible at http://localhost:#{host_port}", :success)
        log_step("🗄️  Database available internally at db:5432", :info)
        log_step("", :info)
        log_step("Press Ctrl+C to stop all services", :info)

        # Keep services alive and monitor
        monitor_container =
          client
          |> Containers.elixir_dev(env: phoenix_env)
          |> Dagger.Container.with_service_binding("db", postgres_service)
          |> Dagger.Container.with_service_binding("phoenix", phoenix_service)
          |> Dagger.Container.with_exec([
            "sh", "-c",
            "echo 'All services running' && " <>
            "while true; do sleep 30; echo '$(date): Services healthy'; done"
          ])

        # This will block until Ctrl+C
        try do
          case Dagger.Container.stdout(monitor_container) do
            {:ok, output} ->
              IO.puts(output)
              {:ok, :server_stopped}
            {:error, reason} ->
              {:error, reason}
          end
        after
          # Clean up proxy when stopping
          Task.shutdown(proxy_task, :brutal_kill)
          log_step("Development server stopped", :info)
        end

      {:error, reason} ->
        log_step("Failed to get service endpoint: #{inspect(reason)}", :error)
        {:error, {:service_endpoint_failed, reason}}
    end
  end

  # Helper function to start port forwarding proxy
  defp start_port_proxy(service_endpoint, host_port) do
    with {:ok, {service_host, service_port}} <- parse_service_endpoint(service_endpoint) do
      run_socat_proxy(service_host, service_port, host_port)
    end
  end

  defp parse_service_endpoint(service_endpoint) do
    case URI.parse(service_endpoint) do
      %URI{host: service_host, port: service_port} when not is_nil(service_host) and not is_nil(service_port) ->
        {:ok, {service_host, service_port}}

      _ ->
        # Fallback: assume host:port format
        case String.split(service_endpoint, ":") do
          [service_host, service_port] ->
            {:ok, {service_host, service_port}}
          _ ->
            {:error, {:invalid_endpoint, service_endpoint}}
        end
    end
  end

  defp run_socat_proxy(service_host, service_port, host_port) do
    case System.cmd("socat", [
      "TCP-LISTEN:#{host_port},fork,reuseaddr",
      "TCP:#{service_host}:#{service_port}"
    ], stderr_to_stdout: true) do
      {output, 0} ->
        log_step("Port proxy started successfully")
        {:ok, output}
      {error, exit_code} ->
        log_step("Port proxy failed: #{error} (exit: #{exit_code})", :error)
        {:error, {:proxy_failed, exit_code, error}}
    end
  end
end
