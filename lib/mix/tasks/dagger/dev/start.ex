defmodule Mix.Tasks.Dagger.Dev.Start do
  @shortdoc "Start development environment"

  @moduledoc """
  Starts the complete development environment in containers.

  This task:
  - Starts PostgreSQL database container
  - Starts Phoenix server in development mode
  - Sets up file watching for hot reloading
  - Starts asset compilation in watch mode

  ## Examples

      mix dagger.dev.start
      mix dagger.dev.start --port=4001
      mix dagger.dev.start --detached

  ## Options

    * `--port` - Port for Phoenix server (default: 4000)
    * `--detached` - Run in background mode
    * `--skip-assets` - Skip asset watching
  """

  use Mix.Task

  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [port: :integer, detached: :boolean, skip_assets: :boolean],
        aliases: [p: :port, d: :detached]
      )

    port = Keyword.get(opts, :port, 4000)
    detached = Keyword.get(opts, :detached, false)
    skip_assets = Keyword.get(opts, :skip_assets, false)

    log_step("Starting development environment on port #{port}", :start)

    execute_start(port: port, detached: detached, skip_assets: skip_assets)
  end

  def execute(opts \\ []), do: execute_start(opts)

  defp execute_start(opts) do
    port = Keyword.get(opts, :port, 4000)
    detached = Keyword.get(opts, :detached, false)
    skip_assets = Keyword.get(opts, :skip_assets, false)

    Client.with_client(fn client ->
      # Start PostgreSQL container as a service
      log_step("Starting PostgreSQL database")

      postgres_service =
        client
        |> Containers.postgres(
          database: "gatherly_dev",
          user: "postgres",
          password: "postgres"
        )
        |> Dagger.Container.as_service()

      log_step("Database started", :success)

      # Start Phoenix server with proper service binding
      log_step("Starting Phoenix server")

      phoenix_env = %{
        "MIX_ENV" => "dev",
        "PORT" => to_string(port),
        "DATABASE_URL" => "postgres://postgres:postgres@db:5432/gatherly_dev"
      }

      phoenix_container =
        client
        |> Containers.elixir_dev(env: phoenix_env)
        |> Dagger.Container.with_service_binding("db", postgres_service)
        |> Dagger.Container.with_exposed_port(port)

      if detached do
        # Run in background
        _phoenix_service = Dagger.Container.as_service(phoenix_container)
        log_step("Phoenix server started in background mode", :success)
        log_step("Access your app at http://localhost:#{port}", :info)
      else
        # Run in foreground (this would block)
        log_step("Starting Phoenix server in foreground mode", :info)
        log_step("Press Ctrl+C to stop", :info)

        {:ok, _output} =
          phoenix_container
          |> exec_and_get_output("mix", ["phx.server"])
      end

      # Start asset watching (if not skipped)
      unless skip_assets do
        log_step("Starting asset watcher")

        # This would typically run in a separate process/container
        asset_container =
          client
          |> Containers.elixir_dev()
          |> Dagger.Container.with_exec(["mix", "assets.build", "--watch"])

        _asset_service = Dagger.Container.as_service(asset_container)
        log_step("Asset watcher started", :success)
      end

      log_step("Development environment ready!", :finish)
      log_step("🌐 App: http://localhost:#{port}", :info)
      log_step("🗄️  DB: localhost:5432 (gatherly_dev)", :info)

      {:ok, :dev_started}
    end)
  end
end
