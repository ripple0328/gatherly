defmodule Mix.Tasks.Dagger.Db.Reset do
  @shortdoc "Reset database using containerized Phoenix tasks"
  
  @moduledoc """
  Runs Phoenix database reset tasks inside a containerized environment.
  
  This task runs the equivalent of:
  - mix ecto.drop
  - mix ecto.create  
  - mix ecto.migrate
  - mix run priv/repo/seeds.exs (unless --skip-seed)
  
  ## Examples
  
      mix dagger.db.reset
      mix dagger.db.reset --env=test
      mix dagger.db.reset --skip-seed
  
  ## Options
  
    * `--env` - Environment (dev/test, default: dev)
    * `--skip-seed` - Skip running seeds
  """
  
  use Mix.Task
  
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl Mix.Task
  def run(args) do
    {opts, _remaining_args, _} = 
      OptionParser.parse(args, 
        switches: [env: :string, skip_seed: :boolean],
        aliases: [e: :env]
      )
    
    env = Keyword.get(opts, :env, "dev")
    skip_seed = Keyword.get(opts, :skip_seed, false)
    
    log_step("Resetting #{env} database", :start)
    
    execute_reset(env: env, skip_seed: skip_seed)
  end

  def execute(opts \\ []), do: execute_reset(opts)

  defp execute_reset(opts) do
    env = Keyword.get(opts, :env, "dev")
    skip_seed = Keyword.get(opts, :skip_seed, false)
    
    # Build task sequence
    tasks = [
      {"ecto.drop", []},
      {"ecto.create", []},
      {"ecto.migrate", []}
    ]
    
    tasks = if skip_seed do
      tasks
    else
      tasks ++ [{"run", ["priv/repo/seeds.exs"]}]
    end
    
    case Gatherly.Dagger.DbHelper.run_phoenix_db_tasks(tasks, env) do
      {:ok, _outputs} -> 
        log_step("Database reset completed!", :finish)
        {:ok, :database_reset}
      error -> error
    end
  end
end