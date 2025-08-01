defmodule Mix.Tasks.Dagger.Deploy do
  @shortdoc "Build local image and deploy to Fly.io"

  @moduledoc """
  Builds the production release image using Dagger and exports it to the local
  Docker daemon. Then deploys to Fly.io using the local image. The image is
  tagged with the current Git commit hash.

  ## Examples

      mix dagger.deploy
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Deploy}

  @impl Mix.Task
  def run(_args) do
    Client.with_client(fn client ->
      case Deploy.deploy(client) do
        {:ok, tag} ->
          log_step("Deployed image #{tag}", :success)
          {:ok, tag}

        {:error, reason} ->
          log_step("Fly deploy failed: #{inspect(reason)}", :error)
          {:error, reason}
      end
    end)
  end
end
