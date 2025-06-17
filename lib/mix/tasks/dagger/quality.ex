defmodule Mix.Tasks.Dagger.Quality do
  @moduledoc """
  Run code quality checks using Dagger containerized environment.

  This task runs:
  - Code formatting checks (`mix format --check-formatted`)
  - Static analysis with Credo (`mix credo --strict`)
  - Type checking with Dialyzer (`mix dialyzer`)

  ## Examples

      mix dagger.quality

  ## Options

      --skip-dialyzer    Skip Dialyzer type checking (faster for quick checks)

  The quality checks run in a containerized environment to ensure consistent
  results across different development machines and match CI exactly.
  """
  use Mix.Task

  @shortdoc "Run code quality checks in Dagger container"

  @impl Mix.Task
  def run(args) do
    {_opts, _} = OptionParser.parse!(args, strict: [skip_dialyzer: :boolean])

    Mix.shell().info("🔍 Running code quality checks in Dagger container...")

    try do
      result = call_dagger_quality()
      Mix.shell().info("✅ All quality checks passed")
      Mix.shell().info(result)
    rescue
      error ->
        Mix.shell().error("❌ Quality checks failed: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp call_dagger_quality do
    {result, exit_code} =
      System.cmd("dagger", ["call", "quality", "--source=."],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    if exit_code != 0 do
      raise "Dagger quality checks failed with exit code #{exit_code}: #{result}"
    end

    result
  end
end
