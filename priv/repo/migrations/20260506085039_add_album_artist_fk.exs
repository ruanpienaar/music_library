defmodule MusicLibrary.Repo.Migrations.AddAlbumArtistFk do
  use Ecto.Migration

  def change do
    alter table(:album) do
      add :artist_id, references(:artist, on_delete: :delete_all), null: false
    end

    create index(:album, [:artist_id])
  end
end
