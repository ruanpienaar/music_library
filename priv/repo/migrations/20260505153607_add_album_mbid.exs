defmodule MusicLibrary.Repo.Migrations.AddAlbumMbid do
  use Ecto.Migration

  def change do
    alter table(:album) do
      add :mbid, :string
    end
  end
end
