defmodule MusicLibrary.Repo.Migrations.AddLastFmRawTrackVersion do
  use Ecto.Migration

  def change do
    alter table(:last_fm_raw_track) do
      add :last_fm_version, :string, default: "2.0"
    end
  end
end
