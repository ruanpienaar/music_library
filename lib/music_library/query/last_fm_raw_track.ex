defmodule MusicLibrary.Query.LastFmRawTrack do
  @schema_mod MusicLibrary.Schema.LastFmRawTrack
  import Ecto.Query
  alias MusicLibrary.LastFm.Client

  def latest_listened_at do
    from(t in @schema_mod, select: max(t.listened_at))
    |> MusicLibrary.Repo.one()
  end

  def insert_all(raw_tracks) when is_list(raw_tracks) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    rows =
      Enum.map(raw_tracks, fn track ->
        listened_at =
          track
          |> get_in(["date", "uts"])
          |> String.to_integer()
          |> DateTime.from_unix!()

        %{
          data: track,
          listened_at: listened_at,
          processed: false,
          inserted_at: now,
          last_fm_version: Client.api_version()
        }
      end)

    {count, _} =
      MusicLibrary.Repo.insert_all(@schema_mod, rows,
        on_conflict: :nothing,
        conflict_target: [:listened_at]
      )

    {:ok, count}
  end

  def get_oldest_unprocessed_tracks() do
    from(
      t in @schema_mod,
      where: t.processed == false,
      order_by: [desc: t.listened_at],
      limit: 5000
    )
    |> MusicLibrary.Repo.all()
  end

  def set_processed(entry, flag \\ true) do
    entry
    |> MusicLibrary.Schema.LastFmRawTrack.changeset(%{processed: flag})
    |> MusicLibrary.Repo.update()
  end
end
