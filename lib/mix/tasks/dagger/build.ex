defmodule Mix.Tasks.Dagger.Build do
  @moduledoc """
  Build production release using Dagger containerized environment.

  This task creates a production release with:
  - Production dependencies installed
  - Assets compiled and minified
  - Elixir application compiled for production
  - Release created with embedded runtime

  ## Examples

      mix dagger.build
      mix dagger.build --export ./release

  ## Options

      --export PATH    Export the built release to specified local path

  The containerized build ensures consistent production builds regardless
  of the local development environment.
  """
  use Mix.Task

  @shortdoc "Build production release in Dagger container"

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [export: :string])

    Mix.shell().info("🏗️  Building production release in Dagger container...")

    try do
      result = call_dagger_build()
      Mix.shell().info("✅ Production release built successfully")

      if export_path = opts[:export] do
        export_artifacts(export_path)
      end

      Mix.shell().info(result)
    rescue
      error ->
        Mix.shell().error("❌ Build failed: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp call_dagger_build do
    {result, exit_code} =
      System.cmd("dagger", ["call", "build", "--source=.", "sync"],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    if exit_code != 0 do
      raise "Dagger build failed with exit code #{exit_code}: #{result}"
    end

    result
  end

  defp export_artifacts(export_path) do
    Mix.shell().info("📦 Exporting release artifacts to #{export_path}...")

    File.mkdir_p!(export_path)

    {result, exit_code} =
      System.cmd(
        "dagger",
        [
          "call",
          "artifacts",
          "--source=.",
          "export",
          "--path=#{export_path}"
        ],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    if exit_code != 0 do
      raise "Dagger export failed with exit code #{exit_code}: #{result}"
    end

    Mix.shell().info("✅ Release exported to #{export_path}")
  end
end
