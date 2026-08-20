defmodule MusicLibrary.Repo.Migrations.AddRetryAfterToAlbumCover do
  use Ecto.Migration

  def change do
    alter table(:album_cover) do
      add :retry_after, :utc_datetime
    end
  end
end
