defmodule Gatherly.Events.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @statuses ~w(unassigned planned in_progress done)

  schema "logistics_items" do
    field :name, :string
    field :quantity, :string
    field :category, :string, default: "food"
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "unassigned"
    field :owner_name, :string
    field :notes, :string

    belongs_to :event, Event

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:event_id, :name, :quantity, :category, :tags, :status, :owner_name, :notes])
    |> normalize_blank_strings([:name, :quantity, :category, :status, :owner_name, :notes])
    |> normalize_tags()
    |> validate_required([:event_id, :name, :status])
    |> validate_length(:name, min: 1, max: 140)
    |> validate_length(:category, max: 80)
    |> validate_inclusion(:status, @statuses)
    |> assoc_constraint(:event)
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

  defp normalize_tags(changeset) do
    case get_change(changeset, :tags) do
      tags when is_list(tags) ->
        put_change(
          changeset,
          :tags,
          tags |> Enum.map(&to_string/1) |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
        )

      _ ->
        changeset
    end
  end
end
