defmodule Gatherly.Events.Item do
  use Ash.Resource,
    domain: Gatherly.Domain,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      constraints min_length: 1, max_length: 140
    end

    attribute :quantity, :string
    attribute :dietary_tags, {:array, :string}, default: []
    attribute :assigned_to, :string
    attribute :notes, :string

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
    table "items"
    repo Gatherly.Repo
  end
end
