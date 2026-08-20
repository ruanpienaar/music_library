defmodule MusicLibrary.Repo.Migrations.BackfillAlbumCoversTable do
  use Ecto.Migration

  def change do
    execute """
              INSERT INTO album_cover (album_id, downloaded)
              SELECT id, false FROM album
            """,
            "DELETE FROM album_cover"
  end
end
