defmodule MusicLibrary.Query.AlbumCover do
  require Logger
  import Ecto.Query

  alias MusicLibrary.Schema.Album
  @schema_mod MusicLibrary.Schema.AlbumCover

  def get_pending(limit \\ 10) do
    now = DateTime.utc_now()

    from(ac in @schema_mod,
      join: al in Album,
      on: ac.album_id == al.id,
      where: ac.status == "pending" and not is_nil(al.mbid) and al.mbid != "",
      where: is_nil(ac.retry_after) or ac.retry_after <= ^now,
      select: %{
        album_cover_id: ac.id,
        album_id: al.id,
        mbid: al.mbid,
        retry_count: ac.retry_count
      },
      limit: ^limit
    )
    |> MusicLibrary.Repo.all()
  end

  def mark_downloaded(album_cover_id), do: set_status(album_cover_id, "downloaded")
  def mark_not_found(album_cover_id), do: set_status(album_cover_id, "not_found")
  def mark_error(album_cover_id), do: set_status(album_cover_id, "error")

  # Status stays "pending" — this is a transient failure (e.g. archive.org
  # storage node 5xx), not a permanent one, so we want get_pending/1 to
  # pick it up again once retry_after has passed.
  def mark_retry_later(album_cover_id, retry_after, retry_count) do
    from(ac in @schema_mod, where: ac.id == ^album_cover_id)
    |> MusicLibrary.Repo.update_all(set: [retry_after: retry_after, retry_count: retry_count])
  end

  defp set_status(album_cover_id, status) do
    from(ac in @schema_mod, where: ac.id == ^album_cover_id)
    |> MusicLibrary.Repo.update_all(set: [status: status])
  end

  def upsert(params) do
    # We might encounter albums we've already seen and downloaded,
    # from future tracks.
    %@schema_mod{}
    |> @schema_mod.changeset(params)
    |> MusicLibrary.Repo.insert(
      on_conflict: :nothing,
      returning: true
    )
  end
end
