defmodule MusicLibrary.Repo.Migrations.LastFmRawTrackUniqueListenedAt do
  use Ecto.Migration

  def change do
    create unique_index(:last_fm_raw_track, [:listened_at])
  end
end
