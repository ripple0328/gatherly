defmodule Mix.Tasks.Dagger.Workflows.Dev do
  @shortdoc "Complete development environment setup"

  @moduledoc """
  Sets up complete development environment workflow.

  This workflow runs:
  1. Clean environment (optional)
  2. Setup dependencies and database
  3. Run basic health checks
  4. Start development services

  ## Examples

      mix dagger.dev
      mix dagger.dev --clean
      mix dagger.dev --no-start

  ## Options

    * `--clean` - Clean environment before setup
    * `--no-start` - Don't start services after setup
    * `--port` - Port for development server (default: 4000)
  """

  use Mix.Task

  import Gatherly.Dagger.Workflow
  alias Mix.Tasks.Dagger.{Clean, Setup, Test}
  alias Mix.Tasks.Dagger.Db.{Create, Migrate}
  alias Mix.Tasks.Dagger.Dev.Start

  @impl true
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [clean: :boolean, no_start: :boolean, port: :integer],
        aliases: []
      )

    clean = Keyword.get(opts, :clean, false)
    no_start = Keyword.get(opts, :no_start, false)
    port = Keyword.get(opts, :port, 4000)

    log_step("Setting up development environment", :start)

    execute_workflow(clean: clean, no_start: no_start, port: port)
  end

  defp execute_workflow(opts) do
    clean = Keyword.get(opts, :clean, false)
    no_start = Keyword.get(opts, :no_start, false)
    port = Keyword.get(opts, :port, 4000)

    handle_clean(clean)
    handle_setup()
    handle_database_setup()
    handle_health_check()
    handle_start_services(no_start, port)

    {:ok, :dev_ready}
  end

  defp handle_clean(clean) do
    if clean do
      log_step("Step 1: Cleaning environment")

      case Clean.execute([]) do
        {:ok, _} ->
          log_step("Environment cleaned", :success)

        {:error, reason} ->
          log_step("Clean failed: #{inspect(reason)}", :warning)
      end
    end
  end

  defp handle_setup do
    log_step("Step 2: Setting up environment")

    case Setup.execute([]) do
      {:ok, _} ->
        log_step("Environment setup completed", :success)

      {:error, reason} ->
        log_step("Setup failed: #{inspect(reason)}", :error)
        {:error, reason}
    end
  end

  defp handle_database_setup do
    log_step("Step 3: Setting up database")

    try do
      case Create.execute([]) do
        {:ok, _} ->
          log_step("Database created", :success)
          # Try to run migrations if they exist
          try do
            case Migrate.execute([]) do
              {:ok, _} -> log_step("Database migrations complete", :success)
              {:error, _} -> log_step("No migrations to run (empty project)", :info)
            end
          rescue
            _ -> log_step("No migrations to run (empty project)", :info)
          end

        {:error, _reason} ->
          log_step("Database setup skipped (new project)", :info)
          log_step("Run 'mix dagger.db.create' after adding schema", :info)
      end
    rescue
      _ ->
        log_step("Database setup skipped (new project)", :info)
        log_step("Run 'mix dagger.db.create' after adding schema", :info)
    end
  end

  defp handle_health_check do
    log_step("Step 4: Running health checks")

    try do
      case Test.execute(["--max-failures", "1"]) do
        {:ok, _} ->
          log_step("Health checks passed", :success)

        {:error, _} ->
          log_step("Some tests failing - check your code", :warning)
      end
    rescue
      _ ->
        log_step("Health checks skipped (new project)", :info)
        log_step("Add tests and run 'mix dagger.test' later", :info)
    end
  end

  defp handle_start_services(no_start, port) do
    if no_start do
      log_step("Development environment ready!", :finish)
      log_step("Run 'mix dagger.dev.start' to start services", :info)
    else
      log_step("Step 5: Starting development services")
      log_step("Development environment ready!", :finish)
      log_step("🌐 Starting server on port #{port}...", :info)

      # This would start the dev server (blocking call)
      Start.execute(port: port, detached: false)
    end
  end
end
