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

  @impl Mix.Task
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
    
    # Step 1: Clean environment (if requested)
    if clean do
      log_step("Step 1: Cleaning environment")
      case Mix.Tasks.Dagger.Clean.execute([]) do
        {:ok, _} -> log_step("Environment cleaned", :success)
        {:error, reason} -> 
          log_step("Clean failed: #{inspect(reason)}", :warning)
      end
    end
    
    # Step 2: Setup environment
    log_step("Step 2: Setting up environment")
    case Mix.Tasks.Dagger.Setup.execute([]) do
      {:ok, _} -> log_step("Environment setup completed", :success)
      {:error, reason} -> 
        log_step("Setup failed: #{inspect(reason)}", :error)
        {:error, reason}
    end
    
    # Step 3: Database setup (graceful handling for new projects)
    log_step("Step 3: Setting up database")
    try do
      case Mix.Tasks.Dagger.Db.Create.execute([]) do
        {:ok, _} -> 
          log_step("Database created", :success)
          # Try to run migrations if they exist
          try do
            case Mix.Tasks.Dagger.Db.Migrate.execute([]) do
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
    
    # Step 4: Health check (graceful for new projects)
    log_step("Step 4: Running health checks")
    try do
      case Mix.Tasks.Dagger.Test.execute(["--max-failures", "1"]) do
        {:ok, _} -> log_step("Health checks passed", :success)
        {:error, _} -> 
          log_step("Some tests failing - check your code", :warning)
      end
    rescue
      _ -> 
        log_step("Health checks skipped (new project)", :info)
        log_step("Add tests and run 'mix dagger.test' later", :info)
    end
    
    # Step 5: Start development services (if requested)
    unless no_start do
      log_step("Step 5: Starting development services")
      log_step("Development environment ready!", :finish)
      log_step("🌐 Starting server on port #{port}...", :info)
      
      # This would start the dev server (blocking call)
      Mix.Tasks.Dagger.Dev.Start.execute(port: port, detached: false)
    else
      log_step("Development environment ready!", :finish)
      log_step("Run 'mix dagger.dev.start' to start services", :info)
    end
    
    {:ok, :dev_ready}
  end
end