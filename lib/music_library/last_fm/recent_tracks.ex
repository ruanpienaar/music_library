defmodule MusicLibrary.LastFm.RecentTracks do
  require Logger

  alias MusicLibrary.LastFm.Client
  alias MusicLibrary.Query.LastFmRawTrack

  @page_size 200

  @doc """
  Fetches all recent tracks for the configured user and inserts them as raw
  JSON into `last_fm_raw_track`. On subsequent calls, passes the latest stored
  `listened_at` as `from` so only new scrobbles are fetched. Returns
  `{:ok, total_inserted}` or `{:error, reason}`.
  """
  def fetch_all do
    from_ts = LastFmRawTrack.latest_listened_at()

    Logger.info("Fetching Last.fm recent tracks — page 1")

    {:ok, %{tracks: page1_tracks, total_pages: total_pages}} =
      fetch_page_with_retry(1, @page_size, from_ts)

    # Fetch oldest pages first so MAX(listened_at) stays a valid resume cursor
    {:ok, count} = fetch_pages(total_pages, 2, 0, from_ts)

    {:ok, page1_count} = LastFmRawTrack.insert_all(page1_tracks)
    {:ok, count + page1_count}
  end

  @doc """
  Fetches a single page of recent tracks. Returns raw track maps from the API.
  """
  def fetch_page(page \\ 1, limit \\ @page_size, from_ts \\ nil) do
    params = %{user: Client.username(), page: page, limit: limit}
    params = if from_ts, do: Map.put(params, :from, DateTime.to_unix(from_ts)), else: params

    Client.get("user.getrecenttracks", params)
    |> parse_response()
  end

  # --- private ---

  @retry_delay_ms 5_000

  # Iterates from `page` down to `stop_at`, oldest-first.
  defp fetch_pages(page, stop_at, total_inserted, _from_ts) when page < stop_at do
    {:ok, total_inserted}
  end

  defp fetch_pages(page, stop_at, total_inserted, from_ts) do
    Logger.info("Fetching Last.fm recent tracks — page #{page}")

    {:ok, %{tracks: tracks}} = fetch_page_with_retry(page, @page_size, from_ts)
    {:ok, count} = LastFmRawTrack.insert_all(tracks)

    Process.sleep(Client.rate_limit_ms())
    fetch_pages(page - 1, stop_at, total_inserted + count, from_ts)
  end

  defp fetch_page_with_retry(page, limit, from_ts) do
    case fetch_page(page, limit, from_ts) do
      {:ok, _} = ok ->
        ok

      {:error, reason} ->
        Logger.warning(
          "Page #{page} failed (#{inspect(reason)}), retrying in #{@retry_delay_ms}ms..."
        )

        Process.sleep(@retry_delay_ms)
        fetch_page_with_retry(page, limit, from_ts)
    end
  end

  defp parse_response({:ok, %{"recenttracks" => %{"track" => tracks, "@attr" => attrs}}}) do
    raw_tracks = Enum.reject(tracks, &nowplaying?/1)

    {:ok,
     %{
       tracks: raw_tracks,
       page: attrs["page"] |> String.to_integer(),
       total_pages: attrs["totalPages"] |> String.to_integer(),
       total: attrs["total"] |> String.to_integer()
     }}
  end

  defp parse_response({:ok, body}) do
    {:error, {:unexpected_response, body}}
  end

  defp parse_response({:error, _} = err), do: err

  defp nowplaying?(%{"@attr" => %{"nowplaying" => "true"}}), do: true
  defp nowplaying?(_), do: false
end
