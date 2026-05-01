defmodule Gatherly.Repo.Migrations.RebootEventCollaborationModel do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :event_type, :string, null: false, default: "potluck"
      add :owner_token_hash, :string
      add :invite_token_hash, :string
      add :decision_status, :string, null: false, default: "planning"
    end

    create unique_index(:events, [:owner_token_hash], where: "owner_token_hash IS NOT NULL")
    create unique_index(:events, [:invite_token_hash], where: "invite_token_hash IS NOT NULL")
    create index(:events, [:event_type])

    create table(:participants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false
      add :display_name, :string, null: false
      add :rsvp_status, :string, null: false, default: "going"
      add :role, :string
      add :submission_token_hash, :string
      add :review_status, :string, null: false, default: "accepted"
      add :source_payload, :map, null: false, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:participants, [:event_id])

    create unique_index(:participants, [:submission_token_hash],
             where: "submission_token_hash IS NOT NULL"
           )

    create table(:logistics_items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :quantity, :string
      add :category, :string, null: false, default: "food"
      add :tags, {:array, :string}, null: false, default: []
      add :status, :string, null: false, default: "unassigned"
      add :owner_name, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:logistics_items, [:event_id])
    create index(:logistics_items, [:event_id, :status])

    create table(:proposals, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false
      add :proposal_type, :string, null: false
      add :title, :string, null: false
      add :details, :map, null: false, default: %{}
      add :proposed_by_name, :string
      add :status, :string, null: false, default: "open"

      timestamps(type: :utc_datetime)
    end

    create index(:proposals, [:event_id, :proposal_type])

    create table(:votes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :proposal_id, references(:proposals, type: :uuid, on_delete: :delete_all), null: false
      add :voter_name, :string, null: false
      add :weight, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:proposal_id])

    create table(:comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false
      add :author_name, :string, null: false
      add :body, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:event_id])
  end
end
