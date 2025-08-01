defmodule Gatherly.Dagger.Containers do
  @moduledoc """
  Container definitions for common Gatherly services.

  This module provides pre-configured containers for Elixir, PostgreSQL,
  and other services used in the Gatherly application.
  """

  alias Dagger.{Client, Container}
  alias Gatherly.Dagger.Workflow

  @elixir_version "1.18.4-otp-28"
  @postgres_version "17.5"
  @node_version "20"

  @doc """
  Creates a base Elixir container with system dependencies.
  """
  def elixir_base(client) do
    client
    |> Client.container([])
    |> Container.from("elixir:#{@elixir_version}")
    |> Container.with_exec(["apt-get", "update"])
    |> Container.with_exec([
      "apt-get",
      "install",
      "-y",
      "build-essential",
      "postgresql-client",
      "inotify-tools",
      "curl"
    ])
    |> Container.with_exec(["mix", "local.hex", "--force"])
    |> Container.with_exec(["mix", "local.rebar", "--force"])
  end

  @doc """
  Creates an Elixir development container with source code mounted.
  """
  def elixir_dev(client, opts \\ []) do
    env_vars = Keyword.get(opts, :env, %{})

    client
    |> elixir_base()
    |> Workflow.with_source(client)
    |> Workflow.with_env_vars(Map.merge(default_elixir_env(), env_vars))
  end

  @doc """
  Creates a PostgreSQL container for development.
  """
  def postgres(client, opts \\ []) do
    database = Keyword.get(opts, :database, "gatherly_dev")
    user = Keyword.get(opts, :user, "postgres")
    password = Keyword.get(opts, :password, "postgres")

    client
    |> Client.container([])
    |> Container.from("postgres:#{@postgres_version}")
    |> Container.with_env_variable("POSTGRES_DB", database)
    |> Container.with_env_variable("POSTGRES_USER", user)
    |> Container.with_env_variable("POSTGRES_PASSWORD", password)
    |> Container.with_exposed_port(5432)
  end

  @doc """
  Creates a Node.js container for asset compilation.
  """
  def node(client) do
    client
    |> Client.container([])
    |> Container.from("node:#{@node_version}")
    |> Workflow.with_source(client)
  end

  @doc """
  Creates a test container with test database configuration.
  """
  def elixir_test(client) do
    test_env = %{
      "MIX_ENV" => "test",
      "DATABASE_URL" => "postgres://postgres:postgres@db:5432/gatherly_test"
    }

    elixir_dev(client, env: test_env)
  end

  # Private functions

  defp default_elixir_env do
    %{
      "MIX_ENV" => "dev",
      "DATABASE_URL" => "postgres://postgres:postgres@db:5432/gatherly_dev"
    }
  end
end
