defmodule MusicLibrary.Schema.LastFmRawTrack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "last_fm_raw_track" do
    field :data, :map
    field :listened_at, :utc_datetime
    field :processed, :boolean, default: false
    field :last_fm_version, :string

    timestamps(updated_at: false)
  end

  def changeset(raw_track, params \\ %{}) do
    raw_track
    |> cast(params, [:data, :listened_at, :processed, :last_fm_version])
    |> validate_required([:data, :listened_at])
  end
end
