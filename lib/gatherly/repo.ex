defmodule Gatherly.Repo do
  use AshPostgres.Repo, otp_app: :gatherly

  def min_pg_version do
    %Version{major: 17, minor: 0, patch: 0}
  end

  def installed_extensions do
    # Return list of PostgreSQL extensions we want available
    ["uuid-ossp", "citext", "ash-functions"]
  end
end
