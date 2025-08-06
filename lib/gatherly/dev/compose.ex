defmodule Gatherly.Dev.Compose do
  @moduledoc """
  Helper functions for Docker Compose development workflows.

  This module provides utilities for interacting with Docker Compose
  services and running development commands.
  """

  @compose_file "docker-compose.dev.yml"

  @doc """
  Runs a Docker Compose command with the development file.
  """
  def compose(args) when is_list(args) do
    System.cmd("docker-compose", ["-f", @compose_file] ++ args, into: IO.stream(:stdio, :line))
  end

  @doc """
  Runs a command in the app container.
  """
  def exec_app(command) when is_binary(command) do
    compose(["exec", "app", "sh", "-c", command])
  end

  @doc """
  Runs a one-off command in the app container.
  """
  def run_app(command) when is_binary(command) do
    compose(["run", "--rm", "app", "sh", "-c", command])
  end

  @doc """
  Checks if services are running.
  """
  def services_running? do
    case System.cmd("docker-compose", ["-f", @compose_file, "ps", "-q"], stderr_to_stdout: true) do
      {output, 0} -> String.trim(output) != ""
      _ -> false
    end
  end

  @doc """
  Starts services if they're not already running.
  """
  def ensure_services_up do
    unless services_running?() do
      log_info("Starting development services...")
      compose(["up", "-d"])
      log_info("Waiting for services to be ready...")
      :timer.sleep(5000)
    end
  end

  @doc """
  Logs an info message with consistent formatting.
  """
  def log_info(message) do
    IO.puts(IO.ANSI.green() <> "[DEV] " <> IO.ANSI.reset() <> message)
  end

  @doc """
  Logs a warning message with consistent formatting.
  """
  def log_warn(message) do
    IO.puts(IO.ANSI.yellow() <> "[WARN] " <> IO.ANSI.reset() <> message)
  end

  @doc """
  Logs an error message with consistent formatting.
  """
  def log_error(message) do
    IO.puts(IO.ANSI.red() <> "[ERROR] " <> IO.ANSI.reset() <> message)
  end
end
