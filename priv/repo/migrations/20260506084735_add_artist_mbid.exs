defmodule MusicLibrary.Repo.Migrations.AddArtistMbid do
  use Ecto.Migration

  def change do
    alter table(:artist) do
      add :mbid, :string
    end
  end
end
