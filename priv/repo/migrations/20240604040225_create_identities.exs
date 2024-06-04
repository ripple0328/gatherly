defmodule Gatherly.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :provider, :string
      add :provider_token, :string
      add :provider_email, :string
      add :provider_login, :string
      add :provider_id, :string
      add :provider_meta, :map, default: "{}", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:identities, [:user_id])
    create index(:identities, [:provider])
    create unique_index(:identities, [:user_id, :provider])
  end
end
