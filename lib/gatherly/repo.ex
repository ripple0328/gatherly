defmodule Gatherly.Repo do
  use AshPostgres.Repo, otp_app: :gatherly

  def installed_extensions do
    # Return list of PostgreSQL extensions we want available
    ["uuid-ossp", "citext"]
  end
end
