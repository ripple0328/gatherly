defmodule Mix.Tasks.Dagger.Dev.Shell do
  @shortdoc "Interactive shell in development container"

  @moduledoc """
  Opens an interactive shell in the development container.

  This provides access to:
  - Elixir and Mix commands
  - IEx REPL with application loaded
  - Database access via psql
  - File system within the container

  ## Examples

      mix dagger.dev.shell
      mix dagger.dev.shell --iex
      mix dagger.dev.shell --bash
      mix dagger.dev.shell --psql

  ## Options

    * `--iex` - Start IEx REPL (default)
    * `--bash` - Start bash shell
    * `--psql` - Connect to PostgreSQL
    * `--command` - Run a specific command
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl true
  def run(args) do
    {opts, remaining_args, _} =
      OptionParser.parse(args,
        switches: [iex: :boolean, bash: :boolean, psql: :boolean, command: :string],
        aliases: [c: :command]
      )

    shell_type =
      cond do
        opts[:bash] -> :bash
        opts[:psql] -> :psql
        opts[:command] -> {:command, opts[:command]}
        # default
        true -> :iex
      end

    command_args = remaining_args

    log_step("Opening development shell", :start)

    execute(shell_type: shell_type, args: command_args)
  end

  def execute(opts) do
    shell_type = Keyword.get(opts, :shell_type, :iex)
    args = Keyword.get(opts, :args, [])

    Client.with_client(fn client ->
      container =
        client
        |> Containers.elixir_dev()
        |> prepare_shell_environment()

      case shell_type do
        :iex ->
          start_iex_shell(container, args)

        :bash ->
          start_bash_shell(container, args)

        :psql ->
          start_psql_shell(container)

        {:command, command} ->
          run_command(container, command, args)
      end
    end)
  end

  defp prepare_shell_environment(container) do
    # Ensure the application is compiled
    container
    |> Dagger.Container.with_exec(["mix", "deps.get"])
    |> Dagger.Container.with_exec(["mix", "compile"])
  end

  defp start_iex_shell(container, args) do
    log_step("Starting IEx REPL", :info)
    log_step("Loading Gatherly application...", :info)

    iex_args = ["iex", "-S", "mix"] ++ args

    # This would ideally provide an interactive terminal
    # For now, we'll simulate by running IEx with a script
    {:ok, output} =
      container
      |> Dagger.Container.with_exec(iex_args)
      |> Dagger.Container.stdout()

    IO.puts(output)
    log_step("IEx session completed", :success)

    {:ok, :shell_completed}
  end

  defp start_bash_shell(container, args) do
    log_step("Starting bash shell", :info)

    bash_args = ["/bin/bash"] ++ args

    {:ok, output} =
      container
      |> Dagger.Container.with_exec(bash_args)
      |> Dagger.Container.stdout()

    IO.puts(output)
    log_step("Bash session completed", :success)

    {:ok, :shell_completed}
  end

  defp start_psql_shell(container) do
    log_step("Connecting to PostgreSQL", :info)

    # Connect to the database
    psql_command = [
      "psql",
      "postgres://postgres:postgres@db:5432/gatherly_dev"
    ]

    {:ok, output} =
      container
      |> Dagger.Container.with_exec(psql_command)
      |> Dagger.Container.stdout()

    IO.puts(output)
    log_step("Database session completed", :success)

    {:ok, :shell_completed}
  end

  defp run_command(container, command, args) do
    log_step("Running command: #{command}", :info)

    command_parts = String.split(command, " ", trim: true) ++ args

    {:ok, output} =
      container
      |> exec_and_get_output(List.first(command_parts), List.delete_at(command_parts, 0))

    IO.puts(output)
    log_step("Command completed", :success)

    {:ok, :command_completed}
  end
end
