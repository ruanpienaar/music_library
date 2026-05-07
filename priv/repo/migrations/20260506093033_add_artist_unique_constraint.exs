defmodule MusicLibrary.Repo.Migrations.AddArtistUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:artist, [:name])
  end
end
