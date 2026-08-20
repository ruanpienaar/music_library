defmodule MusicLibrary.Repo.Migrations.CreateAlbumCoversTable do
  use Ecto.Migration

  def change do
    create table(:album_cover) do
      add :downloaded, :boolean, null: false, default: false
      add :album_id, references(:album, on_delete: :delete_all), null: false
    end

    create unique_index(:album_cover, [:album_id])
  end
end
