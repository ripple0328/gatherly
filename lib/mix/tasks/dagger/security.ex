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
  use Gatherly.Dagger.Workflow

  @impl true
  def run(_args) do
    log_step("Running security checks", :start)
    execute()
  end

  @impl true
  def run(opts) do
    Client.with_client(fn client ->
      container = Containers.elixir_dev(client)

      log_step("Checking for retired packages")
      {:ok, _} = exec_and_get_output(container, "mix", ["hex.audit"])

      log_step("Checking for outdated packages")
      {:ok, _} = exec_and_get_output(container, "mix", ["hex.outdated"])

      log_step("Verifying dependencies")
      {:ok, _} = exec_and_get_output(container, "mix", ["deps.get", "--check-locked"])

      log_step("Security checks completed!", :finish)
      {:ok, :security_completed}
    end)
  end
end
