defmodule MusicLibrary.Query.Album do
  require Logger
  import Ecto.Query
  alias MusicLibrary.Schema.{Artist, AlbumCover}
  @schema_mod MusicLibrary.Schema.Album

  def by_id(album_id) do
    where_by_id(album_id)
    |> MusicLibrary.Repo.one()
  end

  def all_with_covers() do
    from(al in @schema_mod,
      join: ar in Artist,
      on: al.artist_id == ar.id,
      join: ac in AlbumCover,
      on: ac.album_id == al.id,
      where:
        not is_nil(al.album_cover_url) and al.album_cover_url != "" and ac.status == "downloaded",
      select: %{name: al.name, artist: ar.name, album_file_location: al.album_file_location},
      order_by: [ar.name, al.name]
    )
    |> MusicLibrary.Repo.all()
  end

  def all_with_local_covers() do
    from(al in @schema_mod,
      join: ar in Artist,
      on: al.artist_id == ar.id,
      where: not is_nil(al.album_file_location) and al.album_file_location != "",
      select: %{name: al.name, artist: ar.name, file_path: al.album_file_location},
      order_by: [ar.name, al.name]
    )
    |> MusicLibrary.Repo.all()
  end

  def update_file_location(album_id, file_location) do
    where_by_id(album_id)
    |> MusicLibrary.Repo.update_all(set: [album_file_location: file_location])
  end

  def file_location(album_id) do
    where_by_id(album_id)
    |> select([album: a], a.album_file_location)
    |> MusicLibrary.Repo.one()
  end

  def upsert(params) do
    %@schema_mod{}
    |> @schema_mod.changeset(params)
    |> MusicLibrary.Repo.insert(
      on_conflict: {:replace, [:mbid, :album_cover_url]},
      conflict_target: [:name, :artist_id],
      returning: true
    )
  end

  # --- composing

  defp where_by_id(album_id) do
    from(
      al in @schema_mod,
      as: :album,
      where: al.id == ^album_id
    )
  end
end
