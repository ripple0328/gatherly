defmodule Mix.Tasks.Dagger.Reset do
  @shortdoc "Complete environment reset"
  
  @moduledoc """
  Performs a complete reset of the development environment.
  
  This task combines cleaning and setup operations:
  - Cleans all build artifacts
  - Resets the database
  - Reinstalls dependencies
  - Recompiles the application
  - Rebuilds assets
  
  Equivalent to running:
  - mix dagger.clean --all
  - mix dagger.setup
  
  ## Examples
  
      mix dagger.reset
      mix dagger.reset --env=test
  
  ## Options
  
    * `--env` - Environment to reset (default: dev)
  """
  
  use Mix.Task
  use Gatherly.Dagger.Workflow

  @impl true
  def run(args) do
    {opts, _, _} = 
      OptionParser.parse(args, 
        switches: [env: :string],
        aliases: [e: :env]
      )
    
    env = Keyword.get(opts, :env, "dev")
    
    log_step("Resetting #{env} environment", :start)
    
    execute(env: env)
  end

  @impl true
  def run(opts) do
    env = Keyword.get(opts, :env, "dev")
    
    # First, clean everything
    log_step("Phase 1: Cleaning everything")
    case Mix.Tasks.Dagger.Clean.execute(all: true) do
      {:ok, _} -> log_step("Cleanup completed", :success)
      {:error, reason} -> 
        log_step("Cleanup failed: #{inspect(reason)}", :error)
        {:error, reason}
    end
    
    # Wait a moment for cleanup to complete
    Process.sleep(1000)
    
    # Then, setup everything fresh
    log_step("Phase 2: Setting up fresh environment")
    case Mix.Tasks.Dagger.Setup.execute(env: env) do
      {:ok, _} -> 
        log_step("Reset completed successfully!", :finish)
        {:ok, :reset_complete}
      {:error, reason} -> 
        log_step("Setup failed: #{inspect(reason)}", :error)
        {:error, reason}
    end
  end
end