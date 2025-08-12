defmodule Gatherly.Events.Event do
  @moduledoc """
  Event resource - minimal implementation for magic link testing.
  """

  use Ash.Resource,
    domain: Gatherly.Events,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("events")
    repo(Gatherly.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :title, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :description, :string do
      public?(true)
    end

    attribute :creator_id, :uuid do
      allow_nil?(false)
      public?(true)
    end

    timestamps()
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([:title, :description, :creator_id])
      primary?(true)
    end

    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end
  end

  relationships do
    belongs_to :creator, Gatherly.Accounts.User do
      attribute_writable?(true)
    end

    has_many :magic_links, Gatherly.Events.MagicLink do
      destination_attribute(:event_id)
    end

    has_many :participants, Gatherly.Events.EventParticipant do
      destination_attribute(:event_id)
    end
  end

  code_interface do
    define(:create, args: [:title, :creator_id])
    define(:get_by_id, args: [:id])
    define(:read)
  end
end
