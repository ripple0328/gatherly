defmodule Mix.Tasks.Dagger.Db.Seed do
  @shortdoc "Run database seeds using containerized Phoenix task"
  
  @moduledoc """
  Runs `mix run priv/repo/seeds.exs` inside a containerized environment with PostgreSQL.
  
  This task:
  - Starts PostgreSQL container
  - Runs Phoenix's seed script inside Elixir container
  - Can run custom seed files
  
  ## Examples
  
      mix dagger.db.seed
      mix dagger.db.seed --env=test
      mix dagger.db.seed priv/repo/custom_seeds.exs
  
  ## Options
  
    * `--env` - Environment (dev/test, default: dev)
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
    seed_file = case remaining_args do
      [file] -> file
      [] -> "priv/repo/seeds.exs"
      _ -> 
        log_step("Error: Only one seed file can be specified", :error)
        System.halt(1)
    end
    
    log_step("Running seeds for #{env} environment", :start)
    
    execute_seed(env: env, seed_file: seed_file)
  end

  def execute(opts \\ []), do: execute_seed(opts)

  defp execute_seed(opts) do
    env = Keyword.get(opts, :env, "dev")
    seed_file = Keyword.get(opts, :seed_file, "priv/repo/seeds.exs")
    
    case Gatherly.Dagger.DbHelper.run_phoenix_db_task("run", env, [seed_file]) do
      {:ok, _output} -> {:ok, :seeds_completed}
      error -> error
    end
  end
end