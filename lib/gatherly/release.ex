defmodule Gatherly.Release do
  @moduledoc """
  Helpers for running Ecto tasks in a release.

  We keep this tiny and non-interactive so it can be used by CI/CD and launchd.
  """

  @app :gatherly

  def migrate do
    load_app()

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      Ecto.Migrator.with_repo(repo, fn repo ->
        Ecto.Migrator.run(repo, :up, all: true)
      end)
    end
  end

  def rollback(repo, version) do
    load_app()

    Ecto.Migrator.with_repo(repo, fn repo ->
      Ecto.Migrator.run(repo, :down, to: version)
    end)
  end

  defp load_app do
    Application.load(@app)
  end
end
