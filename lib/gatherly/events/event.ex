defmodule Gatherly.Events.Event do
  use Ash.Resource,
    domain: Gatherly.Domain,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      constraints min_length: 1, max_length: 140
    end

    attribute :slug, :string do
      allow_nil? false
      constraints min_length: 4, max_length: 32
    end

    attribute :description, :string
    attribute :starts_at, :utc_datetime
    attribute :location, :string

    timestamps()
  end

  relationships do
    has_many :rsvps, Gatherly.Events.Rsvp
    has_many :items, Gatherly.Events.Item
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  postgres do
    table "events"
    repo Gatherly.Repo
  end
end
