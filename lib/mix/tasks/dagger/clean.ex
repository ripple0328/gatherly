defmodule Mix.Tasks.Dagger.Clean do
  @shortdoc "Clean build artifacts and containers"
  
  @moduledoc """
  Cleans build artifacts and Dagger containers.
  
  This task:
  - Cleans Elixir build artifacts
  - Removes compiled assets
  - Cleans Docker containers and images used by Dagger
  - Optionally resets the development database
  
  ## Examples
  
      mix dagger.clean
      mix dagger.clean --all
      mix dagger.clean --db-only
  
  ## Options
  
    * `--all` - Clean everything including database and dependencies
    * `--db-only` - Only clean database
    * `--containers` - Clean Docker containers and images
  """
  
  use Mix.Task
  
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl Mix.Task
  def run(args) do
    {opts, _, _} = 
      OptionParser.parse(args, 
        switches: [all: :boolean, db_only: :boolean, containers: :boolean],
        aliases: [a: :all]
      )
    
    log_step("Starting cleanup", :start)
    
    execute_clean(opts)
  end

  def execute(opts \\ []), do: execute_clean(opts)

  defp execute_clean(opts) do
    all = Keyword.get(opts, :all, false)
    db_only = Keyword.get(opts, :db_only, false)
    containers = Keyword.get(opts, :containers, false)
    
    Client.with_client(fn client ->
      cond do
        db_only ->
          clean_database(client)
          
        all ->
          clean_everything(client)
          
        containers ->
          clean_containers()
          
        true ->
          clean_build_artifacts(client)
      end
      
      log_step("Cleanup completed!", :finish)
      {:ok, :cleanup_complete}
    end)
  end

  defp clean_build_artifacts(client) do
    log_step("Cleaning build artifacts")
    
    container = Containers.elixir_dev(client)
    
    # Clean Elixir build
    {:ok, _} = exec_and_get_output(container, "mix", ["clean"])
    
    # Clean assets
    {:ok, _} = exec_and_get_output(container, "rm", ["-rf", "priv/static/assets"])
    
    log_step("Build artifacts cleaned", :success)
  end

  defp clean_database(client) do
    log_step("Cleaning database")
    
    container = Containers.elixir_dev(client)
    
    # Drop and recreate database
    {:ok, _} = exec_and_get_output(container, "mix", ["ecto.drop"])
    {:ok, _} = exec_and_get_output(container, "mix", ["ecto.create"])
    
    log_step("Database cleaned", :success)
  end

  defp clean_everything(client) do
    log_step("Performing full cleanup")
    
    container = Containers.elixir_dev(client)
    
    # Clean everything
    {:ok, _} = exec_and_get_output(container, "mix", ["clean"])
    {:ok, _} = exec_and_get_output(container, "mix", ["deps.clean", "--all"])
    {:ok, _} = exec_and_get_output(container, "rm", ["-rf", "_build"])
    {:ok, _} = exec_and_get_output(container, "rm", ["-rf", "deps"])
    {:ok, _} = exec_and_get_output(container, "rm", ["-rf", "priv/static/assets"])
    
    # Clean database
    clean_database(client)
    
    # Clean containers
    clean_containers()
    
    log_step("Full cleanup completed", :success)
  end

  defp clean_containers do
    log_step("Cleaning Docker containers and images")
    
    # This would typically involve Docker commands to clean up
    # Dagger-created containers and images
    System.cmd("docker", ["system", "prune", "-f"], stderr_to_stdout: true)
    
    log_step("Containers cleaned", :success)
  end
end