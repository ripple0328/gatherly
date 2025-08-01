defmodule Mix.Tasks.Dagger.Db.Rollback do
  @shortdoc "Rollback database migrations using containerized Phoenix task"

  @moduledoc """
  Runs `mix ecto.rollback` inside a containerized environment with PostgreSQL.

  This task:
  - Starts PostgreSQL container
  - Runs Phoenix's `mix ecto.rollback` task inside Elixir container  
  - Passes through all Phoenix ecto.rollback options

  ## Examples

      mix dagger.db.rollback
      mix dagger.db.rollback --env=test
      mix dagger.db.rollback --step=2
      mix dagger.db.rollback --to=20240101000000

  ## Options

    * `--env` - Environment (dev/test, default: dev)
    * All other options are passed through to `mix ecto.rollback`
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

    log_step("Rolling back migrations for #{env} environment", :start)

    execute(env: env, phoenix_args: phoenix_args)
  end

  def execute(opts) do
    env = Keyword.get(opts, :env, "dev")
    phoenix_args = Keyword.get(opts, :phoenix_args, [])

    case DbHelper.run_phoenix_db_task("ecto.rollback", env, phoenix_args) do
      {:ok, _output} -> {:ok, :rollback_completed}
      error -> error
    end
  end
end
