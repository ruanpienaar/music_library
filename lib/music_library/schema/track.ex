defmodule MusicLibrary.Schema.Track do
  use Ecto.Schema
  import Ecto.Changeset

  schema "track" do
    field :name, :string
    field :listened_at, :utc_datetime
    field :url, :string
    field :mbid, :string
    belongs_to :artist, MusicLibrary.Schema.Artist
    belongs_to :album, MusicLibrary.Schema.Album

    timestamps(updated_at: false)
  end

  def fields() do
    __MODULE__.__schema__(:fields)
  end

  def take_fields(struct) do
    Map.take(struct, fields())
  end

  def changeset(track, params \\ %{}) do
    track
    |> cast(params, [:name, :listened_at, :url, :mbid, :artist_id, :album_id])
    |> validate_required([:name, :listened_at, :url, :artist_id, :album_id])
    |> unique_constraint([:listened_at, :artist_id, :album_id, :name])
  end
end
