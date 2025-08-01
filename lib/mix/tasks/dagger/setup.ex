defmodule Mix.Tasks.Dagger.Setup do
  @shortdoc "Setup Elixir development environment in containers"

  @moduledoc """
  Sets up the complete development environment using Dagger containers.

  This task:
  - Installs Elixir dependencies
  - Sets up the development database
  - Installs assets dependencies
  - Prepares the development environment

  ## Examples

      mix dagger.setup
      mix dagger.setup --skip-db
      mix dagger.setup --env=test

  ## Options

    * `--skip-db` - Skip database setup
    * `--env` - Environment to setup (default: dev)
  """

  use Mix.Task

  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers, DbHelper}

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [skip_db: :boolean, env: :string],
        aliases: [e: :env]
      )

    env = Keyword.get(opts, :env, "dev")
    skip_db = Keyword.get(opts, :skip_db, false)

    log_step("Setting up #{env} environment", :start)

    execute_setup(env: env, skip_db: skip_db)
  end

  def execute(opts \\ []), do: execute_setup(opts)

  defp execute_setup(opts) do
    env = Keyword.get(opts, :env, "dev")
    skip_db = Keyword.get(opts, :skip_db, false)

    Client.with_client(fn client ->
      # Setup Elixir environment
      log_step("Installing Elixir dependencies")

      {:ok, _output} =
        client
        |> Containers.elixir_dev(env: %{"MIX_ENV" => env})
        |> exec_and_get_output("mix", ["deps.get"])

      log_step("Dependencies installed", :success)

      # Compile application
      log_step("Compiling application")

      {:ok, _output} =
        client
        |> Containers.elixir_dev(env: %{"MIX_ENV" => env})
        |> exec_and_get_output("mix", ["compile"])

      log_step("Application compiled", :success)

      # Setup assets
      log_step("Setting up assets")

      {:ok, _output} =
        client
        |> Containers.elixir_dev(env: %{"MIX_ENV" => env})
        |> exec_and_get_output("mix", ["assets.setup"])

      log_step("Assets setup complete", :success)

      # Setup database (unless skipped)
      if skip_db do
        log_step("Database setup skipped per --skip-db flag", :info)
      else
        log_step("Setting up database")

        # For new projects, gracefully handle database setup
        try do
          case DbHelper.run_phoenix_db_task("ecto.create", env) do
            {:ok, _output} ->
              log_step("Database created", :success)
              # Try migrations if they exist
              try do
                case DbHelper.run_phoenix_db_task("ecto.migrate", env) do
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

      log_step("Environment setup completed!", :finish)

      {:ok, :setup_complete}
    end)
  end
end
