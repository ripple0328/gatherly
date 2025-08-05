defmodule Gatherly.Accounts.UserIdentity do
  @moduledoc """
  User identity resource for OAuth providers.
  """

  use Ash.Resource,
    domain: Gatherly.Api,
    extensions: [AshAuthentication.UserIdentity],
    data_layer: AshPostgres.DataLayer

  postgres do
    table("user_identities")
    repo(Gatherly.Repo)
  end

  user_identity do
    user_resource(Gatherly.Accounts.User)
  end
end
