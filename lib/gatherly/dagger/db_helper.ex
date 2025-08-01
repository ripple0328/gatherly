defmodule Gatherly.Dagger.DbHelper do
  @moduledoc """
  Shared helper functions for database-related Dagger tasks.

  This module provides common functionality for running Phoenix database
  tasks inside containerized environments with proper service orchestration.
  """

  import Gatherly.Dagger.Workflow
  alias Dagger.Container
  alias Gatherly.Dagger.{Client, Containers, Workflow}

  @doc """
  Runs a Phoenix database task inside containers with PostgreSQL service.

  This function:
  - Starts PostgreSQL container as a service
  - Configures DATABASE_URL to point to the container
  - Runs the specified Phoenix task inside Elixir container
  - Returns the task output
  """
  @spec run_phoenix_db_task(String.t(), String.t(), [String.t()]) ::
          {:ok, term()} | {:error, term()}
  def run_phoenix_db_task(task, env \\ "dev", args \\ []) do
    database_name = "gatherly_#{env}"

    Client.with_client(fn client ->
      # Start PostgreSQL container as a service
      log_step("Starting PostgreSQL container")

      postgres_service =
        client
        |> Containers.postgres(database: database_name)
        |> Container.as_service()

      log_step("PostgreSQL service ready", :success)

      # Log the task being run
      task_description = if args == [], do: task, else: "#{task} #{Enum.join(args, " ")}"
      log_step("Running Phoenix task: mix #{task_description}")

      # Run Phoenix task in Elixir container with proper DATABASE_URL and service binding
      database_url = "postgres://postgres:postgres@db:5432/#{database_name}"

      {:ok, output} =
        client
        |> Containers.elixir_dev(
          env: %{
            "MIX_ENV" => env,
            "DATABASE_URL" => database_url,
            "POSTGRES_HOST" => "db",
            "POSTGRES_USER" => "postgres",
            "POSTGRES_PASSWORD" => "postgres",
            "POSTGRES_DB" => database_name
          }
        )
        |> Container.with_service_binding("db", postgres_service)
        |> Workflow.exec_and_get_output("mix", [task | args])

      IO.puts(output)
      log_step("Task completed!", :finish)

      {:ok, output}
    end)
  end

  @doc """
  Runs multiple Phoenix database tasks in sequence.

  Useful for composite operations like reset (drop -> create -> migrate -> seed).
  """
  @spec run_phoenix_db_tasks([{String.t(), [String.t()]}], String.t()) ::
          {:ok, [String.t()]} | {:error, term()}
  def run_phoenix_db_tasks(tasks, env \\ "dev") do
    database_name = "gatherly_#{env}"

    Client.with_client(fn client ->
      # Start PostgreSQL container as a service (shared across all tasks)
      log_step("Starting PostgreSQL container")

      postgres_service =
        client
        |> Containers.postgres(database: database_name)
        |> Container.as_service()

      log_step("PostgreSQL service ready", :success)

      # Get a persistent Elixir container for all tasks
      database_url = "postgres://postgres:postgres@db:5432/#{database_name}"

      container =
        client
        |> Containers.elixir_dev(
          env: %{
            "MIX_ENV" => env,
            "DATABASE_URL" => database_url,
            "POSTGRES_HOST" => "db",
            "POSTGRES_USER" => "postgres",
            "POSTGRES_PASSWORD" => "postgres",
            "POSTGRES_DB" => database_name
          }
        )
        |> Container.with_service_binding("db", postgres_service)

      # Run each task in sequence
      outputs =
        Enum.map(tasks, fn {task, args} ->
          run_single_db_task(container, task, args)
        end)

      log_step("All tasks completed!", :finish)

      {:ok, outputs}
    end)
  end

  defp run_single_db_task(container, task, args) do
    task_description = if args == [], do: task, else: "#{task} #{Enum.join(args, " ")}"
    log_step("Running: mix #{task_description}")

    {:ok, output} = Workflow.exec_and_get_output(container, "mix", [task | args])

    if String.trim(output) != "" do
      IO.puts(output)
    end

    log_step("Completed: #{task}", :success)
    output
  end
end
