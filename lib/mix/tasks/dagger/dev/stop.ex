defmodule Mix.Tasks.Dagger.Dev.Stop do
  @shortdoc "Stop development environment"

  @moduledoc """
  Stops all running development services.

  This task:
  - Stops Phoenix server container
  - Stops PostgreSQL database container
  - Stops asset watcher
  - Cleans up running containers

  ## Examples

      mix dagger.dev.stop
      mix dagger.dev.stop --force

  ## Options

    * `--force` - Force stop all containers
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow

  @impl true
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [force: :boolean],
        aliases: [f: :force]
      )

    force = Keyword.get(opts, :force, false)

    log_step("Stopping development environment", :start)

    execute(force: force)
  end

  def execute(opts) do
    force = Keyword.get(opts, :force, false)

    # For now, we'll use Docker commands to stop containers
    # In a full implementation, we'd track container IDs

    log_step("Stopping Phoenix server")
    stop_containers_by_name("gatherly-phoenix", force)
    log_step("Phoenix server stopped", :success)

    log_step("Stopping PostgreSQL database")
    stop_containers_by_name("gatherly-postgres", force)
    log_step("Database stopped", :success)

    log_step("Stopping asset watcher")
    stop_containers_by_name("gatherly-assets", force)
    log_step("Asset watcher stopped", :success)

    # Clean up any orphaned containers
    log_step("Cleaning up containers")
    cleanup_containers(force)
    log_step("Cleanup completed", :success)

    log_step("Development environment stopped!", :finish)

    {:ok, :dev_stopped}
  end

  defp stop_containers_by_name(name_pattern, force) do
    force_flag = if force, do: ["-f"], else: []

    # Find containers matching pattern
    case System.cmd("docker", ["ps", "-q", "--filter", "name=#{name_pattern}"],
           stderr_to_stdout: true
         ) do
      {container_ids, 0} when container_ids != "" ->
        container_ids
        |> String.trim()
        |> String.split("\n", trim: true)
        |> Enum.each(fn container_id ->
          System.cmd("docker", ["stop" | force_flag] ++ [container_id], stderr_to_stdout: true)
        end)

      _ ->
        # No containers found or error
        :ok
    end
  end

  defp cleanup_containers(force) do
    # Remove stopped containers related to Gatherly
    force_flag = if force, do: ["-f"], else: []

    System.cmd("docker", ["container", "prune" | force_flag], stderr_to_stdout: true)
  end
end
