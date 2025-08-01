defmodule Mix.Tasks.Dagger.Test do
  @shortdoc "Run tests using containerized Phoenix task"
  
  @moduledoc """
  Runs `mix test` inside a containerized environment with test database.
  
  This task:
  - Starts PostgreSQL test container
  - Sets up test database  
  - Runs Phoenix's `mix test` task inside Elixir container
  - Passes through all Phoenix test options
  
  ## Examples
  
      mix dagger.test
      mix dagger.test --cover
      mix dagger.test test/gatherly_web/
      mix dagger.test test/specific_test.exs:42
  
  ## Options
  
    * All options are passed through to `mix test`
  """
  
  use Mix.Task
  
  import Gatherly.Dagger.Workflow

  @impl Mix.Task
  def run(args) do
    log_step("Running tests in containerized environment", :start)
    
    execute_test(phoenix_args: args)
  end

  def execute(opts \\ []), do: execute_test(opts)

  defp execute_test(opts) do
    phoenix_args = Keyword.get(opts, :phoenix_args, [])
    
    # Use test environment and helper
    case Gatherly.Dagger.DbHelper.run_phoenix_db_task("test", "test", phoenix_args) do
      {:ok, _output} -> {:ok, :tests_completed}
      error -> error
    end
  end
end