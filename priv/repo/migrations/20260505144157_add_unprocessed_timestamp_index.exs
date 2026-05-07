defmodule MusicLibrary.Repo.Migrations.AddUnProcessedTimestampIndex do
  use Ecto.Migration

  def change do
    create index(:last_fm_raw_track, [:listened_at], where: "processed = false")
  end
end
