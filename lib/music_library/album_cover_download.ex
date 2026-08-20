defmodule MusicLibrary.AlbumCoverDownload do
  @behaviour :gen_statem

  require Logger

  @batch_size 10
  @idle_interval_ms 30_000
  # MusicBrainz/Cover Art Archive courtesy rate limit is ~1 req/sec.
  @request_interval_ms 1_000
  @rate_limit_base_ms 60_000
  @max_backoff_ms 300_000
  # archive.org's storage nodes intermittently 5xx (unrelated to our
  # request rate) — treat as transient and retry later rather than
  # permanently blacklisting the cover. After this many attempts, give up.
  @server_error_retry_after_seconds 24 * 60 * 60
  @max_server_error_retries 5

  defstruct pending: [], backoff_ms: @rate_limit_base_ms

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def callback_mode, do: [:handle_event_function, :state_enter]

  def start_link(args) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, args, [])
  end

  def init([]) do
    {:ok, :idle, %__MODULE__{}}
  end

  # ---------------------------------------------------------------------------
  # :idle — wait, then check for pending covers
  # ---------------------------------------------------------------------------

  def handle_event(:enter, _old_state, :idle, _data) do
    {:keep_state_and_data, [{:state_timeout, @idle_interval_ms, :poll}]}
  end

  def handle_event(:state_timeout, :poll, :idle, data) do
    case MusicLibrary.Query.AlbumCover.get_pending(@batch_size) do
      [] ->
        {:keep_state_and_data, [{:state_timeout, @idle_interval_ms, :poll}]}

      pending ->
        {:next_state, :downloading, %{data | pending: pending, backoff_ms: @rate_limit_base_ms}}
    end
  end

  # ---------------------------------------------------------------------------
  # :downloading — drain the pending batch one item at a time
  # ---------------------------------------------------------------------------

  def handle_event(:enter, _old_state, :downloading, _data) do
    {:keep_state_and_data, [{:state_timeout, 0, :download_next}]}
  end

  def handle_event(:state_timeout, :download_next, :downloading, %__MODULE__{pending: []} = data) do
    {:next_state, :idle, data}
  end

  def handle_event(
        :state_timeout,
        :download_next,
        :downloading,
        %__MODULE__{pending: [item | rest]} = data
      ) do
    case download(item) do
      :ok ->
        {:keep_state, %{data | pending: rest},
         [{:state_timeout, @request_interval_ms, :download_next}]}

      {:error, :no_album_mbid} ->
        {:keep_state, %{data | pending: rest},
         [{:state_timeout, @request_interval_ms, :download_next}]}

      {:error, :rate_limited} ->
        Logger.warning("#{__MODULE__} rate limited, backing off #{data.backoff_ms}ms")
        {:next_state, :rate_limited, %{data | pending: [item | rest]}}

      {:error, reason} ->
        Logger.error(
          "#{__MODULE__} download failed for album #{item.album_id}: #{inspect(reason)}"
        )

        {:keep_state, %{data | pending: rest},
         [{:state_timeout, @request_interval_ms, :download_next}]}
    end
  end

  # ---------------------------------------------------------------------------
  # :rate_limited — exponential backoff, then resume downloading
  # ---------------------------------------------------------------------------

  def handle_event(:enter, _old_state, :rate_limited, %__MODULE__{backoff_ms: backoff_ms} = data) do
    next_backoff = min(backoff_ms * 2, @max_backoff_ms)
    {:keep_state, %{data | backoff_ms: next_backoff}, [{:state_timeout, backoff_ms, :resume}]}
  end

  def handle_event(:state_timeout, :resume, :rate_limited, data) do
    {:next_state, :downloading, data}
  end

  # ---------------------------------------------------------------------------
  # private
  # ---------------------------------------------------------------------------

  defp download(%{mbid: ""}) do
    {:error, :no_album_mbid}
  end

  defp download(%{album_cover_id: cover_id, album_id: album_id, mbid: mbid, retry_count: retry_count}) do
    if already_downloaded?(album_id) do
      Logger.debug("Album #{inspect(album_id)} already downloaded")
      :ok
    else
      case MusicLibrary.MusicBrainz.CoverArtArchive.fetch(mbid) do
        {:ok, body, ext} ->
          filename = "#{album_id}#{ext}"
          dir = cover_dir()
          :ok = File.mkdir_p!(dir)
          File.write!(Path.join(dir, filename), body)
          web_path = "/covers/#{filename}"
          {_, _} = MusicLibrary.Query.Album.update_file_location(album_id, web_path)
          {_, _} = MusicLibrary.Query.AlbumCover.mark_downloaded(cover_id)
          Logger.info("#{__MODULE__} downloaded cover for album #{album_id}")
          :ok

        {:error, :not_found} ->
          {_, _} = MusicLibrary.Query.AlbumCover.mark_not_found(cover_id)
          Logger.debug("#{__MODULE__} no cover art found for album #{album_id} (mbid #{mbid})")
          :ok

        {:error, :rate_limited} ->
          {:error, :rate_limited}

        {:error, {:server_error, status}} ->
          handle_server_error(cover_id, album_id, status, retry_count)
          :ok

        {:error, reason} ->
          {_, _} = MusicLibrary.Query.AlbumCover.mark_error(cover_id)
          {:error, reason}
      end
    end
  end

  defp handle_server_error(cover_id, album_id, status, retry_count) do
    new_retry_count = retry_count + 1

    if new_retry_count >= @max_server_error_retries do
      {_, _} = MusicLibrary.Query.AlbumCover.mark_error(cover_id)

      Logger.error(
        "#{__MODULE__} giving up on album #{album_id} after #{new_retry_count} server errors (last status #{status})"
      )
    else
      retry_after =
        DateTime.utc_now()
        |> DateTime.add(@server_error_retry_after_seconds, :second)
        |> DateTime.truncate(:second)

      {_, _} =
        MusicLibrary.Query.AlbumCover.mark_retry_later(cover_id, retry_after, new_retry_count)

      Logger.warning(
        "#{__MODULE__} server error #{status} for album #{album_id} " <>
          "(attempt #{new_retry_count}/#{@max_server_error_retries}), retrying after #{retry_after}"
      )
    end
  end

  # Belt-and-braces: the DB says it's downloaded AND the file is still on disk.
  # If the file went missing (e.g. volume wiped) but the DB thinks otherwise,
  # we still want to re-download rather than serve a 404 forever.
  defp already_downloaded?(album_id) do
    case MusicLibrary.Query.Album.file_location(album_id) do
      web_path when is_binary(web_path) and web_path != "" ->
        File.exists?(Path.join(cover_dir(), Path.basename(web_path)))

      _ ->
        false
    end
  end

  def cover_dir do
    Application.get_env(
      :music_library,
      :album_cover_dir,
      Path.join(:code.priv_dir(:music_library), "album_covers")
    )
  end
end
