defmodule Gatherly.Events.Rsvp do
  @moduledoc """
  Legacy RSVP schema kept for old migrations.

  New product code uses `Gatherly.Events.Participant` as the richer RSVP surface.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rsvps" do
    field :name, :string
    field :status, :string

    belongs_to :event, Event

    timestamps(type: :utc_datetime)
  end

  def changeset(rsvp, attrs) do
    rsvp
    |> cast(attrs, [:event_id, :name, :status])
    |> validate_required([:event_id, :name, :status])
    |> validate_inclusion(:status, ~w(yes no maybe))
    |> assoc_constraint(:event)
  end
end
