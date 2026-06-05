defmodule MusicLibrary.Query.Track do
  @schema_mod MusicLibrary.Schema.Track
  alias MusicLibrary.Schema.{Artist, Album}
  import Ecto.Query
  require Logger

  def all() do
    from(@schema_mod)
    |> MusicLibrary.Repo.all()
  end

  def total_count() do
    from(t in @schema_mod, select: count(t.id))
    |> MusicLibrary.Repo.one()
  end

  def total_artists() do
    from(t in @schema_mod, select: count(t.artist_id, :distinct))
    |> MusicLibrary.Repo.one()
  end

  def total_albums() do
    from(t in @schema_mod, select: count(t.album_id, :distinct))
    |> MusicLibrary.Repo.one()
  end

  def top_artists(limit \\ 10) do
    from(t in @schema_mod,
      join: a in Artist, on: t.artist_id == a.id,
      group_by: [a.id, a.name],
      select: %{id: a.id, name: a.name, count: count(t.id)},
      order_by: [desc: count(t.id)],
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def top_albums(limit \\ 10) do
    from(t in @schema_mod,
      join: al in Album, on: t.album_id == al.id,
      join: ar in Artist, on: t.artist_id == ar.id,
      group_by: [al.id, al.name, ar.name, al.album_cover_url],
      select: %{id: al.id, name: al.name, artist: ar.name, cover_url: al.album_cover_url, count: count(t.id)},
      order_by: [desc: count(t.id)],
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def top_tracks(limit \\ 10) do
    from(t in @schema_mod,
      join: a in Artist, on: t.artist_id == a.id,
      group_by: [t.name, t.url, a.name],
      select: %{name: t.name, artist: a.name, url: t.url, count: count(t.id)},
      order_by: [desc: count(t.id)],
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def on_this_day(month, day) do
    from(t in @schema_mod,
      join: a in Artist, on: t.artist_id == a.id,
      join: al in Album, on: t.album_id == al.id,
      where:
        fragment("EXTRACT(MONTH FROM ?)::integer = ?", t.listened_at, ^month) and
        fragment("EXTRACT(DAY FROM ?)::integer = ?", t.listened_at, ^day),
      order_by: [asc: t.listened_at],
      select: %{
        name: t.name,
        artist: a.name,
        album: al.name,
        url: t.url,
        listened_at: t.listened_at
      }
    )
    |> MusicLibrary.Repo.all()
  end

  def decade_stats() do
    from(t in @schema_mod,
      group_by: fragment("(EXTRACT(YEAR FROM ?)::integer / 10) * 10", t.listened_at),
      select: %{
        decade: fragment("(EXTRACT(YEAR FROM ?)::integer / 10) * 10", t.listened_at),
        count: count(t.id)
      },
      order_by: [asc: fragment("(EXTRACT(YEAR FROM ?)::integer / 10) * 10", t.listened_at)]
    )
    |> MusicLibrary.Repo.all()
  end

  def top_artists_for_decade(decade, limit \\ 5) do
    from(t in @schema_mod,
      join: a in Artist, on: t.artist_id == a.id,
      where: fragment("(EXTRACT(YEAR FROM ?)::integer / 10) * 10 = ?", t.listened_at, ^decade),
      group_by: [a.id, a.name],
      select: %{name: a.name, count: count(t.id)},
      order_by: [desc: count(t.id)],
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def top_albums_for_decade(decade, limit \\ 5) do
    from(t in @schema_mod,
      join: al in Album, on: t.album_id == al.id,
      join: ar in Artist, on: t.artist_id == ar.id,
      where: fragment("(EXTRACT(YEAR FROM ?)::integer / 10) * 10 = ?", t.listened_at, ^decade),
      group_by: [al.id, al.name, ar.name, al.album_cover_url],
      select: %{name: al.name, artist: ar.name, cover_url: al.album_cover_url, count: count(t.id)},
      order_by: [desc: count(t.id)],
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def top_tracks_for_decade(decade, limit \\ 5) do
    from(t in @schema_mod,
      join: a in Artist, on: t.artist_id == a.id,
      where: fragment("(EXTRACT(YEAR FROM ?)::integer / 10) * 10 = ?", t.listened_at, ^decade),
      group_by: [t.name, a.name],
      select: %{name: t.name, artist: a.name, count: count(t.id)},
      order_by: [desc: count(t.id)],
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def today() do
    today = Date.utc_today()

    from(t in @schema_mod,
      join: a in Artist, on: t.artist_id == a.id,
      join: al in Album, on: t.album_id == al.id,
      where: fragment("DATE(?) = ?", t.listened_at, ^today),
      order_by: [desc: t.listened_at],
      select: %{
        name: t.name,
        artist: a.name,
        album: al.name,
        url: t.url,
        listened_at: t.listened_at
      }
    )
    |> MusicLibrary.Repo.all()
  end

  def by_id(id) do
    from(@schema_mod, where: [id: ^id])
    |> MusicLibrary.Repo.one()
  end

  def by_artist(artist) do
    from(t in @schema_mod, where: t.artist == ^artist, order_by: [desc: t.listened_at])
    |> MusicLibrary.Repo.all()
  end

  def recent(limit \\ 50) do
    from(t in @schema_mod, order_by: [desc: t.listened_at], limit: ^limit)
    |> MusicLibrary.Repo.all()
  end

  def insert(params) do
    case %@schema_mod{}
         |> @schema_mod.changeset(params)
         |> MusicLibrary.Repo.insert() do
      {:ok, track} ->
        {:ok, track}

      {:error, changeset} ->
        Logger.error("#{__MODULE__} changeset.errors #{changeset.errors}")
        {:error, changeset}
    end
  end

  @doc """
  Bulk inserts a list of track param maps, skipping any that conflict on the
  unique index (same listened_at + artist + name). Returns the count inserted.
  """
  # def upsert_all(tracks) when is_list(tracks) do
  #   now = DateTime.utc_now() |> DateTime.truncate(:second)

  #   rows =
  #     Enum.map(tracks, fn t ->
  #       t
  #       |> Map.take([:name, :artist, :album, :listened_at, :url, :mbid])
  #       |> Map.put(:inserted_at, now)
  #     end)

  #   {count, _} =
  #     MusicLibrary.Repo.insert_all(@schema_mod, rows,
  #       on_conflict: :nothing,
  #       conflict_target: [:listened_at, :artist_id, :name]
  #     )

  #   {:ok, count}
  # end
end
