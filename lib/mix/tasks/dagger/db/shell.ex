defmodule Mix.Tasks.Dagger.Db.Shell do
  @shortdoc "Connect to containerized database shell"

  @moduledoc """
  Opens a PostgreSQL shell connection to the containerized database.

  This task:
  - Starts PostgreSQL container
  - Opens psql interactive shell
  - Connects with proper credentials

  ## Examples

      mix dagger.db.shell
      mix dagger.db.shell --env=test
      mix dagger.db.shell --command="SELECT * FROM users;"

  ## Options

    * `--env` - Environment (dev/test, default: dev)
    * `--command` - Run specific SQL command instead of interactive shell
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl true
  def run(args) do
    {opts, remaining_args, _} =
      OptionParser.parse(args,
        switches: [env: :string, command: :string],
        aliases: [e: :env]
      )

    env = Keyword.get(opts, :env, "dev")
    sql_command = Keyword.get(opts, :command)
    extra_args = remaining_args

    log_step("Connecting to #{env} database", :start)

    execute(env: env, sql_command: sql_command, extra_args: extra_args)
  end

  def execute(opts) do
    env = Keyword.get(opts, :env, "dev")
    sql_command = Keyword.get(opts, :sql_command)
    extra_args = Keyword.get(opts, :extra_args, [])

    database_name = "gatherly_#{env}"

    Client.with_client(fn client ->
      # Start PostgreSQL container
      log_step("Starting PostgreSQL container")

      _postgres_service =
        client
        |> Containers.postgres(database: database_name)
        |> Dagger.Container.as_service()

      log_step("PostgreSQL service ready", :success)

      # Prepare psql command
      database_url = "postgres://postgres:postgres@postgres:5432/#{database_name}"

      psql_args =
        if sql_command do
          log_step("Running SQL command: #{sql_command}")
          ["psql", database_url, "-c", sql_command] ++ extra_args
        else
          log_step("Opening interactive database shell")
          log_step("Use \\q to exit", :info)
          ["psql", database_url] ++ extra_args
        end

      # Run psql in Elixir container (which has postgresql-client)
      {:ok, output} =
        client
        |> Containers.elixir_dev(env: %{"MIX_ENV" => env})
        |> exec_and_get_output(List.first(psql_args), List.delete_at(psql_args, 0))

      IO.puts(output)
      log_step("Database session completed!", :finish)

      {:ok, :shell_completed}
    end)
  end
end
