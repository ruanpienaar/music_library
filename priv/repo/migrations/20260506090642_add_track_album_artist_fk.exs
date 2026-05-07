defmodule MusicLibrary.Repo.Migrations.AddTrackAlbumArtistFk do
  use Ecto.Migration

  def change do
    alter table(:track) do
      remove :artist
      remove :album
      add :artist_id, references(:artist, on_delete: :delete_all), null: false
      add :album_id, references(:album, on_delete: :delete_all), null: false
    end

    create index(:track, [:artist_id])
    create index(:track, [:album_id])
  end
end
