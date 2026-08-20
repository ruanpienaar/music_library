defmodule MusicLibrary.Schema.AlbumCover do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending downloaded not_found error)

  schema "album_cover" do
    field :status, :string
    field :retry_after, :utc_datetime
    field :retry_count, :integer, default: 0
    belongs_to :album, MusicLibrary.Schema.Album
  end

  def fields() do
    __MODULE__.__schema__(:fields)
  end

  def take_fields(struct) do
    Map.take(struct, fields())
  end

  def changeset(album_cover, params \\ %{}) do
    album_cover
    |> cast(params, [:album_id, :status])
    |> validate_required([:album_id, :status])
    |> validate_inclusion(:status, @statuses)
  end
end
