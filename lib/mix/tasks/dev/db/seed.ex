defmodule Mix.Tasks.Dev.Db.Seed do
  @shortdoc "Run database seeds"

  @moduledoc """
  Runs database seeds in the development container.

  ## Examples

      mix dev.db.seed

  This runs the seeds file located at priv/repo/seeds.exs
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Running database seeds...")

    case Compose.exec_app("mix run priv/repo/seeds.exs") do
      {_, 0} ->
        Compose.log_info("Database seeding completed successfully")

      {_, exit_code} ->
        Compose.log_error("Database seeding failed with exit code: #{exit_code}")
    end
  end
end
