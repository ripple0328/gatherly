defmodule Gatherly.Events.Proposal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.{Event, Vote}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @proposal_types ~w(time location)

  schema "proposals" do
    field :proposal_type, :string
    field :title, :string
    field :details, :map, default: %{}
    field :proposed_by_name, :string
    field :status, :string, default: "open"

    belongs_to :event, Event
    has_many :votes, Vote

    timestamps(type: :utc_datetime)
  end

  def changeset(proposal, attrs) do
    proposal
    |> cast(attrs, [:event_id, :proposal_type, :title, :details, :proposed_by_name, :status])
    |> validate_required([:event_id, :proposal_type, :title, :status])
    |> validate_inclusion(:proposal_type, @proposal_types)
    |> validate_inclusion(:status, ~w(open locked dismissed))
    |> validate_length(:title, min: 1, max: 180)
    |> assoc_constraint(:event)
  end
end
