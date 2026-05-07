defmodule MusicLibrary.Schema.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artist" do
    field :name
    field :mbid
  end

  def fields() do
    __MODULE__.__schema__(:fields)
  end

  def take_fields(struct) do
    Map.take(struct, fields())
  end

  def changeset(artist, params \\ %{}) do
    artist
    |> cast(params, [:name, :mbid])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
