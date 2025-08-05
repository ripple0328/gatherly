defmodule Gatherly.Accounts.Token do
  @moduledoc """
  Token resource for authentication.
  """

  use Ash.Resource,
    domain: Gatherly.Api,
    extensions: [AshAuthentication.TokenResource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table("tokens")
    repo(Gatherly.Repo)
  end

  token do
  end
end
