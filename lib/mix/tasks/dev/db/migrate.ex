defmodule Mix.Tasks.Dev.Db.Migrate do
  @shortdoc "Run database migrations"

  @moduledoc """
  Runs database migrations in the development container.

  ## Examples

      mix dev.db.migrate

  This is equivalent to running `mix ecto.migrate` in the development container.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(args) do
    Compose.ensure_services_up()
    Compose.log_info("Running database migrations...")

    args_str = Enum.join(args, " ")
    command = if args_str == "", do: "mix ecto.migrate", else: "mix ecto.migrate #{args_str}"

    case Compose.exec_app(command) do
      {_, 0} ->
        Compose.log_info("Migrations completed successfully")

      {_, exit_code} ->
        Compose.log_error("Migration failed with exit code: #{exit_code}")
    end
  end
end
