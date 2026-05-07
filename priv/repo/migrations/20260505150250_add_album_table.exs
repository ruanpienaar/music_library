defmodule MusicLibrary.Repo.Migrations.AddAlbumTable do
  use Ecto.Migration

  def change do
    create table(:album) do
      add :name, :string
    end
  end
end
