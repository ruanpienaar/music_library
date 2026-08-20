defmodule MusicLibrary.Repo.Migrations.AddRetryCountToAlbumCover do
  use Ecto.Migration

  def change do
    alter table(:album_cover) do
      add :retry_count, :integer, null: false, default: 0
    end
  end
end
