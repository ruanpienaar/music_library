defmodule MusicLibrary.Schema.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "album" do
    field :name, :string
    field :album_cover_url, :string
    field :album_file_location, :string
    field :mbid, :string
    belongs_to :artist, MusicLibrary.Schema.Artist
  end

  def fields() do
    __MODULE__.__schema__(:fields)
  end

  def take_fields(struct) do
    Map.take(struct, fields())
  end

  def changeset(album, params \\ %{}) do
    album
    |> cast(params, [:name, :album_cover_url, :artist_id])
    |> validate_required([:name, :album_cover_url, :artist_id])
    |> unique_constraint([:name, :artist_id])
  end
end
