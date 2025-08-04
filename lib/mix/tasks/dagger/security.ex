defmodule Mix.Tasks.Dagger.Security do
  @shortdoc "Run security checks in a container"

  @moduledoc """
  Runs security-related checks inside a containerized environment.

  This task performs the following checks:
  - `mix hex.audit`: Checks for retired packages.
  - `mix hex.outdated`: Checks for outdated packages.
  - `mix deps.get --check-locked`: Verifies dependency integrity.

  ## Examples

      mix dagger.security
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl true
  def run(_args) do
    log_step("Running security checks", :start)
    execute()
  end

  def execute(_opts \\ []) do
    Client.with_client(fn client ->
      container = Containers.elixir_dev(client)

      log_step("Checking for retired packages")
      exec(container, ["hex.audit", "--no-auth"])

      log_step("Checking for outdated packages")
      exec(container, ["hex.outdated", "--all"])

      log_step("Verifying dependencies")
      exec(container, ["deps.get", "--check-locked"])

      log_step("Security checks completed!", :finish)
      {:ok, :security_completed}
    end)
  end

  defp exec(container, args) do
    case exec_and_get_output(container, "mix", args) do
      {:ok, output} ->
        IO.puts(output)

      {:error, error} ->
        IO.puts(error.stdout)
        raise error
    end
  end
end
