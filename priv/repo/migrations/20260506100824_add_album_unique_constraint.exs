defmodule MusicLibrary.Repo.Migrations.AddAlbumUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:album, [:name, :artist_id])
  end
end
