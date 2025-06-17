defmodule Mix.Tasks.Dagger.Ci do
  @moduledoc """
  Run the complete CI pipeline using Dagger containerized environment.

  This task runs all CI steps in sequence:
  1. Dependencies installation
  2. Code quality checks (formatting, Credo, Dialyzer)
  3. Security vulnerability scanning
  4. Test suite with PostgreSQL database
  5. Production release build

  ## Examples

      mix dagger.ci
      mix dagger.ci --fast     # Skip slower checks for quick validation
      mix dagger.ci --export ./release

  ## Options

      --fast           Skip Dialyzer and build steps for faster feedback
      --export PATH    Export built release artifacts to specified path
      --parallel       Run independent steps in parallel (experimental)

  This provides the exact same CI pipeline that runs in GitHub Actions,
  allowing developers to catch issues locally before pushing.
  """
  use Mix.Task

  @shortdoc "Run complete CI pipeline in Dagger containers"

  @impl Mix.Task
  def run(args) do
    {opts, _} =
      OptionParser.parse!(args,
        strict: [
          fast: :boolean,
          export: :string,
          parallel: :boolean
        ]
      )

    Mix.shell().info("🚀 Running complete CI pipeline in Dagger containers...")
    start_time = System.monotonic_time(:millisecond)

    try do
      if opts[:parallel] do
        run_parallel_pipeline(opts)
      else
        run_sequential_pipeline(opts)
      end

      end_time = System.monotonic_time(:millisecond)
      duration = div(end_time - start_time, 1000)

      Mix.shell().info("🎉 CI pipeline completed successfully in #{duration}s")

      if export_path = opts[:export] do
        Mix.Task.run("dagger.build", ["--export", export_path])
      end
    rescue
      error ->
        Mix.shell().error("❌ CI pipeline failed: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp run_sequential_pipeline(opts) do
    # Dependencies first (required by all other steps)
    Mix.shell().info("📦 Step 1/5: Installing dependencies...")
    Mix.Task.run("dagger.deps")

    # Quality checks
    if opts[:fast] do
      Mix.shell().info("⚡ Skipping quality checks (--fast mode)")
    else
      Mix.shell().info("🔍 Step 2/5: Running quality checks...")
      Mix.Task.run("dagger.quality")
    end

    # Security checks
    Mix.shell().info("🔒 Step 3/5: Running security checks...")
    Mix.Task.run("dagger.security")

    # Tests
    Mix.shell().info("🧪 Step 4/5: Running tests...")
    Mix.Task.run("dagger.test")

    # Build (unless fast mode)
    if opts[:fast] do
      Mix.shell().info("⚡ Skipping build step (--fast mode)")
    else
      Mix.shell().info("🏗️  Step 5/5: Building release...")
      Mix.Task.run("dagger.build")
    end
  end

  defp run_parallel_pipeline(_opts) do
    Mix.shell().info("⚠️  Parallel pipeline execution is experimental")
    # For now, fall back to sequential
    # Future: Implement parallel execution using Task.async
    run_sequential_pipeline(%{})
  end
end
