defmodule Gatherly.Repo.Migrations.AddSlugRsvpsItems do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :slug, :string, null: false
    end

    create unique_index(:events, [:slug])

    create table(:rsvps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :status, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:rsvps, [:event_id])

    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:events, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :quantity, :string
      add :dietary_tags, {:array, :string}, default: []
      add :assigned_to, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:items, [:event_id])
  end
end
