defmodule MusicLibrary.Query.Track do
  @schema_mod MusicLibrary.Schema.Track
  import Ecto.Query
  require Logger

  def all() do
    from(@schema_mod)
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
