defmodule Gatherly.Events.ThreadComment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "comments" do
    field :author_name, :string
    field :body, :string

    belongs_to :event, Event

    timestamps(type: :utc_datetime)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:event_id, :author_name, :body])
    |> validate_required([:event_id, :author_name, :body])
    |> validate_length(:author_name, min: 1, max: 120)
    |> validate_length(:body, min: 1, max: 4_000)
    |> assoc_constraint(:event)
  end
end
