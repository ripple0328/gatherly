defmodule Gatherly.Repo do
  use Ecto.Repo,
    otp_app: :gatherly,
    adapter: Ecto.Adapters.Postgres
end
