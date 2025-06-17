defmodule Mix.Tasks.Dagger.Security do
  @moduledoc """
  Run security vulnerability checks using Dagger containerized environment.

  This task runs:
  - Dependency vulnerability scanning (`mix deps.audit`)
  - Hex package retirement checks (`mix hex.audit`)

  ## Examples

      mix dagger.security

  The security checks run in a containerized environment to ensure consistent
  scanning with the latest security databases.
  """
  use Mix.Task

  @shortdoc "Run security checks in Dagger container"

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("🔒 Running security checks in Dagger container...")

    try do
      result = call_dagger_security()
      Mix.shell().info("✅ No security vulnerabilities found")
      Mix.shell().info(result)
    rescue
      error ->
        Mix.shell().error("❌ Security checks failed: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp call_dagger_security do
    {result, exit_code} =
      System.cmd("dagger", ["call", "security", "--source=."],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    if exit_code != 0 do
      raise "Dagger security checks failed with exit code #{exit_code}: #{result}"
    end

    result
  end
end
