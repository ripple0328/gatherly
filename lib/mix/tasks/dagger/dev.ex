defmodule Mix.Tasks.Dagger.Dev do
  @shortdoc "Complete development environment setup (alias for dagger.workflows.dev)"

  @moduledoc """
  Alias for `mix dagger.workflows.dev`.

  Sets up complete development environment workflow.

  This workflow runs:
  1. Clean environment (optional)
  2. Setup dependencies and database
  3. Run basic health checks
  4. Start development services

  ## Examples

      mix dagger.dev
      mix dagger.dev --clean
      mix dagger.dev --no-start

  ## Options

    * `--clean` - Clean environment before setup
    * `--no-start` - Don't start services after setup
    * `--port` - Port for development server (default: 4000)
  """

  use Mix.Task
  alias Mix.Tasks.Dagger.Workflows.Dev

  @impl Mix.Task
  def run(args) do
    Dev.run(args)
  end
end
