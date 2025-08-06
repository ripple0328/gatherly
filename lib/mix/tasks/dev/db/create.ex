defmodule Mix.Tasks.Dev.Db.Create do
  @shortdoc "Create development database"

  @moduledoc """
  Creates the development database in the containerized PostgreSQL instance.

  ## Examples

      mix dev.db.create

  This is equivalent to running `mix ecto.create` in the development container.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Creating development database...")

    case Compose.exec_app("mix ecto.create") do
      {_, 0} ->
        Compose.log_info("Database created successfully")

      {_, exit_code} ->
        Compose.log_error("Database creation failed with exit code: #{exit_code}")
    end
  end
end
