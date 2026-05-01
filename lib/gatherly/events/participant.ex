defmodule Gatherly.Events.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @rsvp_statuses ~w(going maybe not_going)
  @review_statuses ~w(pending accepted rejected excluded)

  schema "participants" do
    field :display_name, :string
    field :rsvp_status, :string, default: "going"
    field :role, :string
    field :submission_token_hash, :string
    field :review_status, :string, default: "accepted"
    field :source_payload, :map, default: %{}

    belongs_to :event, Event

    timestamps(type: :utc_datetime)
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [
      :event_id,
      :display_name,
      :rsvp_status,
      :role,
      :submission_token_hash,
      :review_status,
      :source_payload
    ])
    |> normalize_blank_strings([:display_name, :rsvp_status, :role, :review_status])
    |> validate_required([:event_id, :display_name, :rsvp_status, :review_status])
    |> validate_length(:display_name, min: 1, max: 120)
    |> validate_length(:role, max: 100)
    |> validate_inclusion(:rsvp_status, @rsvp_statuses)
    |> validate_inclusion(:review_status, @review_statuses)
    |> assoc_constraint(:event)
    |> unique_constraint(:submission_token_hash)
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
