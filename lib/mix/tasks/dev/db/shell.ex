defmodule Mix.Tasks.Dev.Db.Shell do
  @shortdoc "Connect to development database shell"

  @moduledoc """
  Opens a PostgreSQL shell connected to the development database.

  ## Examples

      mix dev.db.shell

  This connects directly to the PostgreSQL instance running in the container.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Connecting to database shell...")
    Compose.log_info("Use \\q to exit the database shell")
    Compose.log_info("")

    case Compose.compose(["exec", "db", "psql", "-U", "postgres", "-d", "gatherly_dev"]) do
      {_, 0} ->
        Compose.log_info("Database shell session ended")

      {_, exit_code} ->
        Compose.log_error("Database shell failed with exit code: #{exit_code}")
    end
  end
end
