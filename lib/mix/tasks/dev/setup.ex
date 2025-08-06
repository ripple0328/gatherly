defmodule Mix.Tasks.Dev.Setup do
  @shortdoc "Full development environment setup"

  @moduledoc """
  Runs full development environment setup including dependencies and database setup.

  ## Examples

      mix dev.setup

  This command:
  1. Installs Elixir dependencies
  2. Sets up the database (create, migrate, seed)
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(_args) do
    Compose.ensure_services_up()
    Compose.log_info("Running full development setup...")

    Compose.log_info("Installing dependencies...")

    case Compose.exec_app("mix deps.get") do
      {_, 0} ->
        Compose.log_info("Dependencies installed successfully")

      {_, exit_code} ->
        Compose.log_error("Dependency installation failed with exit code: #{exit_code}")
        :ok
    end

    Compose.log_info("Setting up database...")

    case Compose.exec_app("mix ecto.setup") do
      {_, 0} ->
        Compose.log_info("Development setup completed successfully!")
        Compose.log_info("")
        Compose.log_info("You can now:")
        Compose.log_info("  mix dev.shell      # Start IEx shell")
        Compose.log_info("  mix dev.server     # Start Phoenix server")

      {_, exit_code} ->
        Compose.log_error("Database setup failed with exit code: #{exit_code}")
    end
  end
end
