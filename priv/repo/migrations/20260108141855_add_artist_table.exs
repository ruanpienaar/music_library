defmodule MusicLibrary.Repo.Migrations.AddArtistTable do
  use Ecto.Migration

  def change do
    create table(:artist) do
      add :name, :string
    end
  end
end
