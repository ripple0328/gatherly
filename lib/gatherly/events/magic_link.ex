defmodule Gatherly.Events.MagicLink do
  @moduledoc """
  Magic link resource for anonymous event access.
  Generates secure, time-limited tokens for event invitations.
  """

  use Ash.Resource,
    domain: Gatherly.Events,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("magic_links")
    repo(Gatherly.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :token, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :event_id, :uuid do
      allow_nil?(false)
      public?(true)
    end

    attribute :expires_at, :utc_datetime do
      allow_nil?(false)
      public?(true)
    end

    attribute :uses_count, :integer do
      allow_nil?(false)
      default(0)
      public?(true)
    end

    attribute :max_uses, :integer do
      # nil = unlimited uses
      allow_nil?(true)
      public?(true)
    end

    attribute :created_by, :uuid do
      allow_nil?(false)
      public?(true)
    end

    timestamps()
  end

  actions do
    defaults([:read])

    create :create do
      accept([:event_id, :expires_at, :max_uses, :created_by])
      primary?(true)

      change(fn changeset, _context ->
        # Generate cryptographically secure token
        token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
        Ash.Changeset.change_attribute(changeset, :token, token)
      end)
    end

    create :generate_for_event do
      description("Generate a magic link for an event")
      accept([:event_id, :created_by])

      argument :duration_hours, :integer do
        # 1 week default
        default(168)
        allow_nil?(false)
      end

      argument :max_uses, :integer do
        allow_nil?(true)
      end

      change(fn changeset, _context ->
        duration_hours = Ash.Changeset.get_argument(changeset, :duration_hours)
        max_uses = Ash.Changeset.get_argument(changeset, :max_uses)

        expires_at = DateTime.utc_now() |> DateTime.add(duration_hours, :hour)
        token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

        changeset
        |> Ash.Changeset.change_attribute(:token, token)
        |> Ash.Changeset.change_attribute(:expires_at, expires_at)
        |> Ash.Changeset.change_attribute(:max_uses, max_uses)
      end)
    end

    update :increment_uses do
      accept([])
      require_atomic?(false)

      change(fn changeset, _context ->
        current_count = Ash.Changeset.get_attribute(changeset, :uses_count) || 0
        Ash.Changeset.change_attribute(changeset, :uses_count, current_count + 1)
      end)
    end

    read :get_by_token do
      argument(:token, :string, allow_nil?: false)
      get?(true)
      filter(expr(token == ^arg(:token)))
    end

    read :valid_token do
      argument(:token, :string, allow_nil?: false)
      get?(true)

      filter(
        expr(
          token == ^arg(:token) and
            expires_at > ^DateTime.utc_now() and
            (is_nil(max_uses) or uses_count < max_uses)
        )
      )
    end
  end

  relationships do
    belongs_to :event, Gatherly.Events.Event do
      attribute_writable?(true)
    end

    belongs_to :creator, Gatherly.Accounts.User do
      source_attribute(:created_by)
      destination_attribute(:id)
    end
  end

  code_interface do
    define(:generate_for_event, args: [:event_id, :created_by])
    define(:get_by_token, args: [:token])
    define(:valid_token, args: [:token])
    define(:increment_uses)
  end

  # Helper functions
  def generate_magic_url(token) do
    "#{GatherlyWeb.Endpoint.url()}/join/#{token}"
  end

  def valid?(magic_link) do
    now = DateTime.utc_now()

    DateTime.compare(magic_link.expires_at, now) == :gt and
      (is_nil(magic_link.max_uses) or magic_link.uses_count < magic_link.max_uses)
  end
end
