defmodule Gatherly.Api do
  @moduledoc """
  Main API/Domain for Gatherly resources.
  """

  use Ash.Domain, extensions: [AshAuthentication.Domain]

  resources do
    resource(Gatherly.Accounts.User)
    resource(Gatherly.Accounts.Token)
    resource(Gatherly.Accounts.UserIdentity)
  end
end
