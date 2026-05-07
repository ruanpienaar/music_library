defmodule MusicLibrary.Repo.Migrations.AddAlbumImageUrl do
  use Ecto.Migration

  def change do
    alter table(:album) do
      add :album_cover_url, :string, size: 2048
    end
  end
end
