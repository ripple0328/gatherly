defmodule Mix.Tasks.Dagger.Deploy do
  @shortdoc "Build and push image to Fly.io"

  @moduledoc """
  Builds the production release image using Dagger and pushes it to the Fly.io
  registry. The image is tagged with the current Git commit hash and also as
  `latest`. Ensure you have run `fly auth docker` so registry credentials are
  available.

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
