defmodule Mix.Tasks.Dagger.Db.Migrate do
  @shortdoc "Run database migrations using containerized Phoenix task"
  
  @moduledoc """
  Runs `mix ecto.migrate` inside a containerized environment with PostgreSQL.
  
  This task:
  - Starts PostgreSQL container
  - Runs Phoenix's `mix ecto.migrate` task inside Elixir container
  - Passes through all Phoenix ecto.migrate options
  
  ## Examples
  
      mix dagger.db.migrate
      mix dagger.db.migrate --env=test
      mix dagger.db.migrate --to=20240101000000
      mix dagger.db.migrate --step=1
  
  ## Options
  
    * `--env` - Environment (dev/test, default: dev)
    * All other options are passed through to `mix ecto.migrate`
  """
  
  use Mix.Task
  
  import Gatherly.Dagger.Workflow

  @impl Mix.Task
  def run(args) do
    {opts, remaining_args, _} = 
      OptionParser.parse(args, 
        switches: [env: :string],
        aliases: [e: :env]
      )
    
    env = Keyword.get(opts, :env, "dev")
    phoenix_args = remaining_args
    
    log_step("Running migrations for #{env} environment", :start)
    
    execute_migrate(env: env, phoenix_args: phoenix_args)
  end

  def execute(opts \\ []), do: execute_migrate(opts)

  defp execute_migrate(opts) do
    env = Keyword.get(opts, :env, "dev")
    phoenix_args = Keyword.get(opts, :phoenix_args, [])
    
    case Gatherly.Dagger.DbHelper.run_phoenix_db_task("ecto.migrate", env, phoenix_args) do
      {:ok, _output} -> {:ok, :migrations_completed}
      error -> error
    end
  end
end