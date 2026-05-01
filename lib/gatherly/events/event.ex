defmodule Gatherly.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.{Item, Participant, Proposal, ThreadComment}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @event_types ~w(potluck camping hiking game_night general)

  schema "events" do
    field :title, :string
    field :slug, :string
    field :event_type, :string, default: "potluck"
    field :description, :string
    field :starts_at, :utc_datetime
    field :location, :string
    field :owner_token_hash, :string
    field :invite_token_hash, :string
    field :decision_status, :string, default: "planning"

    has_many :participants, Participant
    has_many :logistics_items, Item
    has_many :proposals, Proposal
    has_many :comments, ThreadComment

    timestamps(type: :utc_datetime)
  end

  def event_types, do: @event_types

  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title,
      :slug,
      :event_type,
      :description,
      :starts_at,
      :location,
      :owner_token_hash,
      :invite_token_hash,
      :decision_status
    ])
    |> normalize_blank_strings([:title, :slug, :event_type, :description, :location])
    |> validate_required([:title, :slug, :event_type])
    |> validate_length(:title, min: 1, max: 140)
    |> validate_length(:slug, min: 4, max: 32)
    |> validate_inclusion(:event_type, @event_types)
    |> validate_inclusion(:decision_status, ~w(planning locked archived))
    |> unique_constraint(:slug)
    |> unique_constraint(:owner_token_hash)
    |> unique_constraint(:invite_token_hash)
  end

  defp normalize_blank_strings(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc ->
      case get_change(acc, field) do
        value when is_binary(value) ->
          case String.trim(value) do
            "" -> put_change(acc, field, nil)
            text -> put_change(acc, field, text)
          end

        _ ->
          acc
      end
    end)
  end
end
