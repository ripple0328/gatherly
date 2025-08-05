defmodule Mix.Tasks.Dagger.Quality do
  @shortdoc "Run code quality checks (alias for workflows.quality)"

  @moduledoc """
  Runs code quality workflow in containers.

  This is a convenience alias for `mix dagger.workflows.quality`.

  This workflow runs:
  1. Code formatting
  2. Linting (Credo + Dialyzer)
  3. Security audit

  ## Examples

      mix dagger.quality
      mix dagger.quality --fix
      mix dagger.quality --skip-dialyzer

  ## Options

    * `--fix` - Auto-fix formatting issues
    * `--skip-dialyzer` - Skip Dialyzer type checking
    * `--strict` - Use strict mode for all checks
  """

  use Mix.Task
  alias Mix.Tasks.Dagger.Workflows.Quality

  @impl true
  def run(args) do
    Quality.run(args)
  end

  def execute(opts) do
    Quality.execute(opts)
  end
end
