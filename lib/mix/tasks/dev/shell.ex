defmodule Mix.Tasks.Dev.Shell do
  @shortdoc "Start interactive IEx shell (auto-starts services)"

  @moduledoc """
  Starts an interactive IEx shell in the development container with database access.

  This command automatically starts the development environment (PostgreSQL + app container)
  if not already running, then starts an IEx session with your Phoenix application loaded.

  ## Examples

      mix dev.shell

  The IEx session will have access to:
  - Your Phoenix application modules
  - Database connection via Gatherly.Repo
  - All your contexts and schemas
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Starting IEx shell...")
    Compose.log_info("Database URL: postgres://postgres:postgres@db:5432/gatherly_dev")
    Compose.log_info("")

    # Use exec instead of run to get proper TTY support
    case Compose.exec_app("iex -S mix") do
      {_, 0} ->
        Compose.log_info("IEx session ended")

      {_, exit_code} ->
        Compose.log_error("IEx session failed with exit code: #{exit_code}")

        Compose.log_info(
          "Try running: mix dev.setup to ensure dependencies and database are ready"
        )
    end
  end
end
