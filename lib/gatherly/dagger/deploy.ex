defmodule Gatherly.Dagger.Deploy do
  @moduledoc """
  Build a local production image and deploy to Fly.io using Dagger.

  This module exposes a single `deploy/1` function which automatically
  reads the Fly.io `app` name from `fly.toml`. The current source is built
  into a release image and exported to the local Docker daemon, then
  deployed using `fly deploy --local-only` to avoid pushing to remote registries.

  ## Deployment Process

  1. Build the Phoenix release using Dagger containers
  2. Create a minimal runtime image with the release
  3. Export the image to the local Docker daemon
  4. Deploy to Fly.io using `--local-only` flag (no remote push)

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

  @spec build_only(Dagger.Client.t()) :: {:ok, String.t()} | {:error, term()}
  def build_only(client) do
    with {:ok, app_name} <- fly_app_name() do
      do_build_only(client, app_name)
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
    local_tag = "#{app_name}:#{sha}"

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

    log_step("Exporting image to local Docker daemon as #{local_tag}")

    # Use Container.export_image to export to local Docker daemon
    case Container.export_image(runtime, local_tag) do
      :ok ->
        log_step("Image exported to local Docker", :success)

        # Verify image exists locally
        case System.cmd("docker", ["images", local_tag, "--format", "table {{.Repository}}:{{.Tag}}\t{{.Size}}"],
                        stderr_to_stdout: true) do
          {output, 0} ->
            log_step("Local image verified: #{String.trim(output)}")

          {error, _} ->
            log_step("Warning: Could not verify local image: #{error}", :warning)
        end

        # Now deploy using fly deploy with the local image
        log_step("Deploying to Fly.io using local image")
        case System.cmd("fly", ["deploy", "--local-only", "--image", local_tag, "--now", "--release-command-timeout", "10m"],
                        stderr_to_stdout: true) do
          {output, 0} ->
            IO.puts(output)
            log_step("Deployment successful", :finish)
            {:ok, local_tag}

          {output, exit_code} ->
            IO.puts(output)
            log_step("Deployment failed with exit code #{exit_code}", :error)
            {:error, {:deploy_failed, exit_code, output}}
        end

      {:error, reason} ->
        log_step("Failed to export image: #{inspect(reason)}", :error)
        {:error, {:export_failed, reason}}
    end
  end

  defp do_build_only(client, app_name) do
    sha = git_sha()
    local_tag = "#{app_name}:#{sha}"

    log_step("Building release image (build-only mode)", :start)

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

    log_step("Exporting image to local Docker daemon as #{local_tag}")

    # Use Container.export_image to export to local Docker daemon
    case Container.export_image(runtime, local_tag) do
      :ok ->
        log_step("Image exported to local Docker", :success)

        # Verify image exists locally
        case System.cmd("docker", ["images", local_tag, "--format", "table {{.Repository}}:{{.Tag}}\t{{.Size}}"],
                        stderr_to_stdout: true) do
          {output, 0} ->
            log_step("Local image verified: #{String.trim(output)}")
            log_step("Build completed successfully - ready for deployment", :success)
            {:ok, local_tag}

          {error, _} ->
            log_step("Error: Could not verify local image: #{error}", :error)
            {:error, {:image_verification_failed, error}}
        end

      {:error, reason} ->
        log_step("Failed to export image: #{inspect(reason)}", :error)
        {:error, {:export_failed, reason}}
    end
  end
end
