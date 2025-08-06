defmodule Mix.Tasks.Dev.Db.Reset do
  @shortdoc "Reset development database (drop, create, migrate, seed)"

  @moduledoc """
  Resets the development database by dropping it, creating it, running migrations, and seeding data.

  ## Examples

      mix dev.db.reset

  This is equivalent to running `mix ecto.reset` in the development container.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Resetting development database...")

    case Compose.exec_app("mix ecto.reset") do
      {_, 0} ->
        Compose.log_info("Database reset completed successfully")

      {_, exit_code} ->
        Compose.log_error("Database reset failed with exit code: #{exit_code}")
    end
  end
end
