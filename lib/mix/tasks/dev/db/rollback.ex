defmodule Mix.Tasks.Dev.Db.Rollback do
  @shortdoc "Rollback database migrations"

  @moduledoc """
  Rolls back database migrations in the development container.

  ## Examples

      mix dev.db.rollback              # Rollback last migration
      mix dev.db.rollback --step 2     # Rollback 2 migrations
      mix dev.db.rollback --to 20240101120000  # Rollback to specific version

  This is equivalent to running `mix ecto.rollback` in the development container.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(args) do
    Compose.ensure_services_up()
    Compose.log_info("Rolling back database migrations...")

    args_str = Enum.join(args, " ")
    command = if args_str == "", do: "mix ecto.rollback", else: "mix ecto.rollback #{args_str}"

    case Compose.exec_app(command) do
      {_, 0} ->
        Compose.log_info("Rollback completed successfully")

      {_, exit_code} ->
        Compose.log_error("Rollback failed with exit code: #{exit_code}")
    end
  end
end
