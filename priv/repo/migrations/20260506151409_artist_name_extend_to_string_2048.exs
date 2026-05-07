defmodule MusicLibrary.Repo.Migrations.ArtistNameExtendToString2048 do
  use Ecto.Migration

  def change do
    alter table(:artist) do
      modify :name, :text
    end
  end
end
