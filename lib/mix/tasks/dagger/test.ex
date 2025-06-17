defmodule Mix.Tasks.Dagger.Test do
  @moduledoc """
  Run tests using Dagger containerized environment with PostgreSQL.

  This task runs the full test suite in a containerized environment with:
  - PostgreSQL database automatically provisioned
  - Database migrations run automatically  
  - Clean, isolated test environment

  ## Examples

      mix dagger.test

  ## Options

      --local    Run tests locally instead of containerized (faster for development)

  The containerized tests match the CI environment exactly, ensuring no
  "works on my machine" issues.
  """
  use Mix.Task

  @shortdoc "Run tests in Dagger container with database"

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [local: :boolean])

    if opts[:local] do
      run_local_tests()
    else
      run_containerized_tests()
    end
  end

  defp run_local_tests do
    Mix.shell().info("🧪 Running tests locally...")
    Mix.Task.run("test")
  end

  defp run_containerized_tests do
    Mix.shell().info("🐋 Running tests in Dagger container with PostgreSQL...")

    try do
      result = call_dagger_test()
      Mix.shell().info("✅ All tests passed")
      Mix.shell().info(result)
    rescue
      error ->
        Mix.shell().error("❌ Tests failed: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp call_dagger_test do
    {result, exit_code} =
      System.cmd("dagger", ["call", "test", "--source=."],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    if exit_code != 0 do
      raise "Dagger tests failed with exit code #{exit_code}: #{result}"
    end

    result
  end
end
