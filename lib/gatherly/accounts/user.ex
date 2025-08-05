defmodule Gatherly.Accounts.User do
  @moduledoc """
  User resource with OAuth authentication support.
  """

  use Ash.Resource,
    domain: Gatherly.Api,
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  postgres do
    table("users")
    repo(Gatherly.Repo)

    references do
      reference(:tokens, on_delete: :delete)
    end
  end

  authentication do
    session_identifier(:jti)

    strategies do
      # Google OAuth strategy - using built-in AshAuthentication strategy
      google do
        client_id(fn _, _ ->
          Application.fetch_env(:gatherly, :google)
          |> case do
            {:ok, config} -> {:ok, config[:client_id]}
            :error -> :error
          end
        end)

        redirect_uri(fn _, _ ->
          {:ok, "#{GatherlyWeb.Endpoint.url()}/auth/user/google/callback"}
        end)

        client_secret(fn _, _ ->
          Application.fetch_env(:gatherly, :google)
          |> case do
            {:ok, config} -> {:ok, config[:client_secret]}
            :error -> :error
          end
        end)

        identity_resource(Gatherly.Accounts.UserIdentity)
        register_action_name(:register_with_google)
      end
    end

    tokens do
      enabled?(true)
      token_resource(Gatherly.Accounts.Token)
      store_all_tokens?(true)

      signing_secret(fn _, _ ->
        Application.fetch_env(:ash_authentication, :token_signing_secret)
      end)
    end

    # add_ons do
    #   confirmation :confirm do
    #     monitor_fields [:email]
    #     confirm_on_create? false
    #     confirm_on_update? false
    #   end
    # end
  end

  attributes do
    uuid_primary_key(:id)

    attribute :email, :ci_string do
      allow_nil?(false)
      public?(true)
    end

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :avatar_url, :string do
      public?(true)
    end

    attribute :confirmed_at, :utc_datetime do
      public?(true)
    end

    timestamps()
  end

  identities do
    identity(:unique_email, [:email])
  end

  actions do
    # Default actions
    defaults([:read])

    create :create do
      accept([:email, :name, :avatar_url])
      primary?(true)

      change(AshAuthentication.GenerateTokenChange)
    end

    create :register_with_google do
      description("Register or sign in with Google OAuth")
      accept([:email, :name, :avatar_url])

      argument :user_info, :map do
        description("OAuth user information from provider")
        allow_nil?(false)
      end

      argument :oauth_tokens, :map do
        description("OAuth tokens from provider")
        allow_nil?(false)
      end

      change(AshAuthentication.GenerateTokenChange)
      change(AshAuthentication.Strategy.OAuth2.IdentityChange)

      change(fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changeset
        |> Ash.Changeset.change_attribute(:email, user_info["email"])
        |> Ash.Changeset.change_attribute(:name, user_info["name"])
        |> Ash.Changeset.change_attribute(:avatar_url, user_info["picture"])
      end)

      upsert?(true)
      upsert_identity(:unique_email)
    end

    update :update do
      accept([:email, :name, :avatar_url])
      primary?(true)
    end
  end

  relationships do
    has_many :tokens, Gatherly.Accounts.Token do
      destination_attribute(:subject)
      validate_destination_attribute?(false)
    end

    has_many :identities, Gatherly.Accounts.UserIdentity do
      destination_attribute(:user_id)
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
  end

  preparations do
    prepare(build(load: [:identities]))
  end
end
