defmodule Gatherly.Repo do
  use AshPostgres.Repo,
    otp_app: :gatherly,
    adapter: Ecto.Adapters.Postgres,
    warn_on_missing_ash_functions?: false

  @impl AshPostgres.Repo
  def min_pg_version do
    # Keep this conservative for broad compatibility.
    %Version{major: 14, minor: 0, patch: 0}
  end
end
