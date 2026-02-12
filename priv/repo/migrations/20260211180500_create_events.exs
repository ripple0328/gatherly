defmodule Gatherly.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :starts_at, :utc_datetime
      add :location, :string

      timestamps(type: :utc_datetime)
    end
  end
end
