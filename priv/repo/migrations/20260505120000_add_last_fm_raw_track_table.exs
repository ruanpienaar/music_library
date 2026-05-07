defmodule MusicLibrary.Repo.Migrations.AddLastFmRawTrackTable do
  use Ecto.Migration

  def change do
    create table(:last_fm_raw_track) do
      add :data, :map, null: false
      add :listened_at, :utc_datetime, null: false
      add :processed, :boolean, null: false, default: false

      timestamps(updated_at: false)
    end
  end
end
