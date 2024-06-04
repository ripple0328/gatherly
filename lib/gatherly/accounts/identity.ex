defmodule Gatherly.Accounts.Identity do
  use Ecto.Schema
  import Ecto.Changeset
  alias Gatherly.Accounts.User

  @derive {Inspect, except: [:provider_token, :provider_meta]}

  schema "identities" do
    field :provider, :string
    field :provider_email, :string
    field :provider_id, :string
    field :provider_login, :string
    field :provider_name, :string, virtual: true
    field :provider_token, :string
    field :provider_meta, :map

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [
      :provider,
      :provider_token,
      :provider_email,
      :provider_login,
      :provider_name,
      :provider_id
    ])
    |> validate_required([
      :provider,
      :provider_token,
      :provider_email,
      :provider_login,
      :provider_name,
      :provider_id
    ])
  end
end
