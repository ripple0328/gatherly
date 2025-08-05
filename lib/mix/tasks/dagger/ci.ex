defmodule Mix.Tasks.Dagger.Ci do
  @shortdoc "Run complete CI pipeline (alias for workflows.ci)"

  @moduledoc """
  Runs the complete CI pipeline in containers.

  This is a convenience alias for `mix dagger.workflows.ci`.

  This workflow orchestrates:
  1. Environment setup (deps, compile)
  2. Code formatting check
  3. Linting (Credo + Dialyzer)
  4. Security audit
  5. Tests with coverage

  ## Examples

      mix dagger.ci
      mix dagger.ci --skip-dialyzer
      mix dagger.ci --env=test

  ## Options

    * `--env` - Environment (dev/test, default: dev)
    * `--skip-dialyzer` - Skip Dialyzer (faster CI)
    * `--skip-security` - Skip security audits
    * `--fail-fast` - Stop on first failure
  """

  use Mix.Task
  alias Mix.Tasks.Dagger.Workflows.Ci

  @impl true
  def run(args) do
    Ci.run(args)
  end

  def execute(opts) do
    Ci.execute(opts)
  end
end
