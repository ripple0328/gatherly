defmodule Mix.Tasks.Dagger.Deps do
  @moduledoc """
  Install and compile dependencies using Dagger containerized environment.

  ## Examples

      mix dagger.deps

  This task runs the dependency installation in a containerized Alpine Linux
  environment with Elixir, ensuring consistent dependency resolution across
  different development machines.
  """
  use Mix.Task

  @shortdoc "Install dependencies in Dagger container"

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("🐋 Running dependency installation in Dagger container...")

    try do
      result = call_dagger_deps()
      Mix.shell().info("✅ Dependencies installed successfully")
      Mix.shell().info(result)
    rescue
      error ->
        Mix.shell().error("❌ Dependency installation failed: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp call_dagger_deps do
    {result, exit_code} =
      System.cmd("dagger", ["call", "deps", "--source=.", "sync"],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    if exit_code != 0 do
      raise "Dagger deps failed with exit code #{exit_code}: #{result}"
    end

    result
  end
end
