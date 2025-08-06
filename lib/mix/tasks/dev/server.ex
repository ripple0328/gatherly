defmodule Mix.Tasks.Dev.Server do
  @shortdoc "Start Phoenix development server (auto-starts services)"

  @moduledoc """
  Starts the Phoenix development server in the development container.

  This command automatically starts the development environment (PostgreSQL + app container)
  if not already running, then starts the Phoenix server with live reloading enabled.

  ## Examples

      mix dev.server

  The server will be available at http://localhost:4000
  Press Ctrl+C to stop the server and services.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Starting Phoenix server...")
    Compose.log_info("Server will be available at http://localhost:4000")
    Compose.log_info("Press Ctrl+C to stop")
    Compose.log_info("")

    case Compose.exec_app("mix phx.server") do
      {_, 0} ->
        Compose.log_info("Phoenix server stopped")

      {_, exit_code} ->
        Compose.log_error("Phoenix server failed with exit code: #{exit_code}")

        Compose.log_info(
          "Try running: mix dev.setup to ensure dependencies and database are ready"
        )
    end
  end
end
