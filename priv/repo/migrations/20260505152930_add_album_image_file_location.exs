defmodule MusicLibrary.Repo.Migrations.AddAlbumImageFileLocation do
  use Ecto.Migration

  def change do
    alter table(:album) do
      add :album_file_location, :string, size: 1024
    end
  end
end
