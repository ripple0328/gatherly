defmodule Gatherly.Events.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gatherly.Events.Proposal

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "votes" do
    field :voter_name, :string
    field :weight, :integer, default: 1

    belongs_to :proposal, Proposal

    timestamps(type: :utc_datetime)
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:proposal_id, :voter_name, :weight])
    |> validate_required([:proposal_id, :voter_name, :weight])
    |> validate_length(:voter_name, min: 1, max: 120)
    |> validate_number(:weight, greater_than_or_equal_to: -1, less_than_or_equal_to: 1)
    |> assoc_constraint(:proposal)
  end
end
