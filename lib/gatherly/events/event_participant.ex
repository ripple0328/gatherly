defmodule Gatherly.Events.EventParticipant do
  @moduledoc """
  Event participant resource.

  Records membership for a `user_id` in an `event_id`, with optional RSVP status.
  """

  use Ash.Resource,
    domain: Gatherly.Events,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("event_participants")
    repo(Gatherly.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :event_id, :uuid do
      allow_nil?(false)
      public?(true)
    end

    attribute :user_id, :uuid do
      allow_nil?(false)
      public?(true)
    end

    attribute :rsvp_status, :atom do
      allow_nil?(true)
      constraints(one_of: [:going, :maybe, :not_going])
      public?(true)
    end

    timestamps()
  end

  identities do
    # Ensure one row per user/event pair
    identity(:unique_event_user, [:event_id, :user_id])
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([:event_id, :user_id, :rsvp_status])
      primary?(true)
    end

    read :get_by_event_and_user do
      argument(:event_id, :uuid, allow_nil?: false)
      argument(:user_id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(event_id == ^arg(:event_id) and user_id == ^arg(:user_id)))
    end
  end

  relationships do
    belongs_to :event, Gatherly.Events.Event do
      attribute_writable?(true)
    end

    belongs_to :user, Gatherly.Accounts.User do
      source_attribute(:user_id)
      destination_attribute(:id)
    end
  end

  code_interface do
    define(:create, args: [:event_id, :user_id, :rsvp_status])
    define(:get_by_event_and_user, args: [:event_id, :user_id])
    define(:read)
  end
end
