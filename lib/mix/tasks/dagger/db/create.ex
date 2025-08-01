defmodule Mix.Tasks.Dagger.Db.Create do
  @shortdoc "Create database using containerized Phoenix task"

  @moduledoc """
  Runs `mix ecto.create` inside a containerized environment with PostgreSQL.

  This task:
  - Starts PostgreSQL container 
  - Runs Phoenix's `mix ecto.create` task inside Elixir container
  - Uses container networking to connect services

  ## Examples

      mix dagger.db.create
      mix dagger.db.create --env=test

  ## Options

    * `--env` - Environment (dev/test, default: dev)
  """

  use Mix.Task

  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.DbHelper

  @impl true
  def run(args) do
    {opts, remaining_args, _} =
      OptionParser.parse(args,
        switches: [env: :string],
        aliases: [e: :env]
      )

    env = Keyword.get(opts, :env, "dev")
    phoenix_args = remaining_args

    log_step("Creating #{env} database in containers", :start)

    execute_create(env: env, phoenix_args: phoenix_args)
  end

  def execute(opts \\ []), do: execute_create(opts)

  defp execute_create(opts) do
    env = Keyword.get(opts, :env, "dev")
    phoenix_args = Keyword.get(opts, :phoenix_args, [])

    case DbHelper.run_phoenix_db_task("ecto.create", env, phoenix_args) do
      {:ok, _output} -> {:ok, :database_created}
      error -> error
    end
  end
end
