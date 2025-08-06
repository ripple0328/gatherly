defmodule Mix.Tasks.Dev.Test do
  @shortdoc "Run tests in development environment"

  @moduledoc """
  Runs tests using the test database in Docker Compose.

  ## Examples

      mix dev.test                    # Run all tests
      mix dev.test --failed           # Run only failed tests
      mix dev.test test/specific_test.exs  # Run specific test file

  This command starts the test database and runs tests with proper isolation.
  """

  use Mix.Task
  alias Gatherly.Dev.Compose

  @impl true
  def run(args) do
    Compose.log_info("Starting test database...")
    Compose.compose(["up", "-d", "test_db"])
    :timer.sleep(3000)

    Compose.log_info("Running tests...")
    args_str = Enum.join(args, " ")
    command = if args_str == "", do: "mix test", else: "mix test #{args_str}"

    # Use run instead of exec for test isolation
    case Compose.compose([
           "run",
           "--rm",
           "-e",
           "MIX_ENV=test",
           "-e",
           "DATABASE_URL=postgres://postgres:postgres@test_db:5432/gatherly_test",
           "app",
           "sh",
           "-c",
           command
         ]) do
      {_, 0} ->
        Compose.log_info("Tests completed successfully")

      {_, exit_code} ->
        Compose.log_error("Tests failed with exit code: #{exit_code}")
    end
  end
end
