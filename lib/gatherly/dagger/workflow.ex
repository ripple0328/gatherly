defmodule Gatherly.Dagger.Workflow do
  @moduledoc """
  Base behavior for Dagger workflows.

  Provides common functionality and conventions for building 
  containerized workflows.
  """

  alias Gatherly.Dagger.Client

  @doc """
  Callback for executing the workflow.
  """
  @callback run(keyword()) :: {:ok, term()} | {:error, term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Gatherly.Dagger.Workflow

      import Gatherly.Dagger.Workflow
      alias Gatherly.Dagger.{Client, Containers}

      @doc """
      Runs the workflow with a Dagger client.
      """
      def execute(opts \\ []) do
        Client.with_client(&run(&1, opts))
      end

      defp run(client, opts), do: run(opts)
    end
  end

  @doc """
  Logs a step in the workflow.
  """
  def log_step(message, type \\ :info) do
    emoji =
      case type do
        :info -> "ℹ️"
        :success -> "✅"
        :warning -> "⚠️"
        :error -> "❌"
        :start -> "🚀"
        :finish -> "✨"
      end

    IO.puts("#{emoji} #{message}")
  end

  @doc """
  Executes a command in a container and returns the output.
  """
  def exec_and_get_output(container, command, args \\ []) do
    container
    |> Dagger.Container.with_exec([command | args])
    |> Dagger.Container.stdout()
  end

  @doc """
  Mounts the host source directory into a container.
  """
  def with_source(container, client, path \\ "/app") do
    source_dir = Client.host_directory(client, ".")

    container
    |> Dagger.Container.with_directory(path, source_dir)
    |> Dagger.Container.with_workdir(path)
  end

  @doc """
  Adds environment variables to a container.
  """
  def with_env_vars(container, env_vars) when is_map(env_vars) do
    Enum.reduce(env_vars, container, fn {key, value}, acc ->
      Dagger.Container.with_env_variable(acc, to_string(key), to_string(value))
    end)
  end
end
