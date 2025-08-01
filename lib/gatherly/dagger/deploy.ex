defmodule Gatherly.Dagger.Deploy do
  @moduledoc """
  Build and push a production image to Fly.io using Dagger.

  This module exposes a single `deploy/1` function which automatically
  reads the Fly.io `app` name from `fly.toml`. The current source is built
  into a release image and pushed to the Fly.io registry under two tags:
  `registry.fly.io/<app_name>:<git_sha>` and `registry.fly.io/<app_name>:latest`.
  Authentication must be handled beforehand
  via `fly auth docker`.

  ## Examples

      {:ok, client} = Gatherly.Dagger.Client.connect()
      Gatherly.Dagger.Deploy.deploy(client)

  The same functionality is available via `mix dagger.deploy`.
  """

  import Gatherly.Dagger.Workflow
  alias Dagger.Container
  alias Gatherly.Dagger.{Client, Containers}

  @runtime_image "elixir:1.18.4-otp-28-slim"

  @spec deploy(Dagger.Client.t()) :: {:ok, String.t()} | {:error, term()}
  def deploy(client) do
    with {:ok, app_name} <- fly_app_name() do
      do_deploy(client, app_name)
    end
  end

  defp fly_app_name do
    with {:ok, content} <- File.read("fly.toml"),
         [_, app] <- Regex.run(~r/^app\s*=\s*"([^"]+)"/m, content) do
      {:ok, app}
    else
      _ -> {:error, :app_not_found}
    end
  end

  defp git_sha do
    case System.cmd("git", ["rev-parse", "--short", "HEAD"]) do
      {sha, 0} -> String.trim(sha)
      _ -> "unknown"
    end
  end

  defp do_deploy(client, app_name) do
    sha = git_sha()
    tagged = "registry.fly.io/#{app_name}:#{sha}"
    latest = "registry.fly.io/#{app_name}:latest"

    log_step("Building release image", :start)

    builder =
      client
      |> Containers.elixir_base()
      |> Container.with_env_variable("MIX_ENV", "prod")
      |> with_source(client)
      |> Container.with_exec(["mix", "deps.get", "--only", "prod"])
      |> Container.with_exec(["mix", "deps.compile"])
      |> Container.with_exec(["mix", "assets.setup"])
      |> Container.with_exec(["mix", "assets.deploy"])
      |> Container.with_exec(["mix", "compile"])
      |> Container.with_exec(["mix", "phx.digest"])
      |> Container.with_exec(["mix", "release"])

    release_dir = Container.directory(builder, "/app/_build/prod/rel/gatherly")

    runtime =
      client
      |> Client.container([])
      |> Container.from(@runtime_image)
      |> Container.with_exec(["apt-get", "update"])
      |> Container.with_exec(["apt-get", "install", "-y", "postgresql-client", "openssl"])
      |> Container.with_exec(["groupadd", "-r", "app"])
      |> Container.with_exec(["useradd", "-r", "-g", "app", "app"])
      |> Container.with_workdir("/app")
      |> Container.with_directory("/app", release_dir)
      |> Container.with_user("app")
      |> Container.with_exposed_port(8080)
      |> Container.with_entrypoint(["./bin/gatherly", "start"])

    log_step("Tagging image as #{tagged} and #{latest}")
    {:ok, _digest} = Container.publish(runtime, tagged)
    {:ok, _} = Container.publish(runtime, latest)
    log_step("Image pushed to Fly.io registry", :finish)

    {:ok, tagged}
  end
end
