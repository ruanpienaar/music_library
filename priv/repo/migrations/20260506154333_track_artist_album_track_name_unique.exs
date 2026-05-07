defmodule MusicLibrary.Repo.Migrations.TrackArtistAlbumTrackNameUnique do
  use Ecto.Migration

  def change do
    create unique_index(:track, [:listened_at, :artist_id, :name])
  end
end
