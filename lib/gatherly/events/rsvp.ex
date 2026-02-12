defmodule Gatherly.Events.Rsvp do
  use Ash.Resource,
    domain: Gatherly.Domain,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      constraints min_length: 1, max_length: 120
    end

    attribute :status, :string do
      allow_nil? false
      constraints match: ~r/^(yes|no|maybe)$/
    end

    timestamps()
  end

  relationships do
    belongs_to :event, Gatherly.Events.Event do
      allow_nil? false
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  postgres do
    table "rsvps"
    repo Gatherly.Repo
  end
end
