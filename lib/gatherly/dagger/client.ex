defmodule Gatherly.Dagger.Client do
  @moduledoc """
  Dagger client wrapper providing a consistent interface for Dagger operations.
  
  This module handles connection management and provides convenience functions
  for common Dagger operations.
  """

  @type t :: Dagger.Client.t()

  @doc """
  Connects to the Dagger engine with error handling.
  """
  @spec connect() :: {:ok, t()} | {:error, term()}
  def connect do
    try do
      client = Dagger.connect!()
      {:ok, client}
    rescue
      error ->
        {:error, error}
    end
  end

  @doc """
  Safely closes the Dagger connection.
  """
  @spec close(t()) :: :ok
  def close(client) do
    try do
      Dagger.close(client)
      :ok
    rescue
      _ -> :ok
    end
  end

  @doc """
  Executes a function with a Dagger client, ensuring cleanup.
  """
  @spec with_client(function()) :: {:ok, term()} | {:error, term()}
  def with_client(func) when is_function(func, 1) do
    with {:ok, client} <- connect() do
      try do
        result = func.(client)
        {:ok, result}
      after
        close(client)
      end
    end
  end

  @doc """
  Creates a host directory reference for mounting source code.
  """
  @spec host_directory(t(), String.t()) :: Dagger.Directory.t()
  def host_directory(client, path \\ ".") do
    client
    |> Dagger.Client.host()
    |> Dagger.Host.directory(path)
  end
end