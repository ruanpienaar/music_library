defmodule MusicLibrary.Repo.Migrations.AddTrackTable do
  use Ecto.Migration

  def change do
    create table(:track) do
      add :name, :string, null: false
      add :artist, :string, null: false
      add :album, :string
      add :listened_at, :utc_datetime, null: false
      add :url, :string
      add :mbid, :string

      timestamps(updated_at: false)
    end

    # Prevent duplicate scrobbles when re-fetching from the API
    create unique_index(:track, [:listened_at, :artist, :name])
  end
end
