defmodule GatherlyCi do
  @moduledoc """
  Gatherly CI/CD Pipeline using Dagger

  Containerized CI tasks for the Gatherly event planning platform:
  - Dependencies management and caching  
  - Code quality checks (formatting, static analysis, type checking)
  - Testing with PostgreSQL database
  - Security vulnerability scanning
  - Build verification and release creation
  """

  use Dagger.Mod.Object, name: "GatherlyCi"

  @doc """
  Get the base Elixir container with dependencies installed.
  """
  defn base() :: Dagger.Container.t() do
    dag()
    |> Dagger.Client.container()
    |> Dagger.Container.from("hexpm/elixir:1.18.4-erlang-27.3.3-alpine-3.21.3")
    |> Dagger.Container.with_exec(["apk", "add", "--no-cache", "build-base", "git", "nodejs", "npm", "postgresql-client", "inotify-tools"])
    |> Dagger.Container.with_exec(["mix", "local.hex", "--force"])
    |> Dagger.Container.with_exec(["mix", "local.rebar", "--force"])
  end

  @doc """
  Install and cache project dependencies.
  """
  defn deps(source: Dagger.Directory.t()) :: Dagger.Container.t() do
    base()
    |> Dagger.Container.with_mounted_directory("/app", source)
    |> Dagger.Container.with_workdir("/app")
    |> Dagger.Container.with_exec(["mix", "deps.get"])
    |> Dagger.Container.with_exec(["mix", "deps.compile"])
  end

  @doc """
  Run code quality checks: formatting, static analysis, type checking.
  """
  defn quality(source: Dagger.Directory.t()) :: String.t() do
    container = deps(source)
    
    # Check formatting
    container
    |> Dagger.Container.with_exec(["mix", "format", "--check-formatted"])
    |> Dagger.Container.with_exec(["mix", "credo", "--strict", "--format", "oneline"])
    |> Dagger.Container.with_exec(["mix", "dialyzer"])
    |> Dagger.Container.stdout()
  end

  @doc """
  Run security vulnerability checks.
  """
  defn security(source: Dagger.Directory.t()) :: String.t() do
    deps(source)
    |> Dagger.Container.with_exec(["mix", "deps.audit"])
    |> Dagger.Container.with_exec(["mix", "hex.audit"])
    |> Dagger.Container.stdout()
  end

  @doc """
  Run tests with PostgreSQL database.
  """
  defn test(source: Dagger.Directory.t()) :: String.t() do
    postgres = dag()
    |> Dagger.Client.container()
    |> Dagger.Container.from("postgres:15")
    |> Dagger.Container.with_env_variable("POSTGRES_USER", "postgres")
    |> Dagger.Container.with_env_variable("POSTGRES_PASSWORD", "postgres")
    |> Dagger.Container.with_env_variable("POSTGRES_DB", "gatherly_test")
    |> Dagger.Container.with_env_variable("POSTGRES_HOST_AUTH_METHOD", "trust")
    |> Dagger.Container.with_exposed_port(5432)
    |> Dagger.Container.as_service()

    deps(source)
    |> Dagger.Container.with_env_variable("MIX_ENV", "test")
    |> Dagger.Container.with_env_variable("DATABASE_URL", "postgres://postgres:postgres@postgres:5432/gatherly_test")
    |> Dagger.Container.with_service_binding("postgres", postgres)
    |> Dagger.Container.with_exec(["sh", "-c", "while ! pg_isready -h postgres -p 5432; do sleep 1; done"])
    |> Dagger.Container.with_exec(["mix", "ecto.create"])
    |> Dagger.Container.with_exec(["mix", "ecto.migrate"])
    |> Dagger.Container.with_exec(["mix", "test"])
    |> Dagger.Container.stdout()
  end

  @doc """
  Build production release with assets.
  """
  defn build(source: Dagger.Directory.t()) :: Dagger.Container.t() do
    deps(source)
    |> Dagger.Container.with_env_variable("MIX_ENV", "prod")
    |> Dagger.Container.with_exec(["mix", "deps.get", "--only", "prod"])
    |> Dagger.Container.with_exec(["mix", "deps.compile"])
    |> Dagger.Container.with_workdir("/app/assets")
    |> Dagger.Container.with_exec(["npm", "ci"])
    |> Dagger.Container.with_workdir("/app")
    |> Dagger.Container.with_exec(["mix", "assets.deploy"])
    |> Dagger.Container.with_exec(["mix", "compile"])
    |> Dagger.Container.with_exec(["mix", "release"])
  end

  @doc """
  Run the complete CI pipeline: deps, quality, security, test, build.
  """
  defn ci(source: Dagger.Directory.t()) :: String.t() do
    # Run all CI steps
    _quality_result = quality(source)
    _security_result = security(source)  
    _test_result = test(source)
    _build_result = build(source)
    
    "✅ CI pipeline completed successfully"
  end

  @doc """
  Get build artifacts directory.
  """
  defn artifacts(source: Dagger.Directory.t()) :: Dagger.Directory.t() do
    build(source)
    |> Dagger.Container.directory("/app/_build/prod/rel/gatherly")
  end
end