defmodule MusicLibrary.PeriodicDataGenerator do
  require Logger

  @moduledoc """
  Get the oldest 50 last_fm_raw_track records
  if results 0
      end.
  else
      For each last_fm_raw_track record
          insert artist
          upsert track & count
          Set processed field to true on the record
  """

  @behaviour :gen_statem

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
    :gen_statem.start_link(__MODULE__, args, [])
  end

  def init([]) do
    {:ok, :idle, %{}}
  end

  # 1 - Enter into idle, wait a second, check if work needs done
  def handle_event(:enter, old_state, _new_state = :idle, _data)
      when old_state == :idle or old_state == :running do
    {:keep_state_and_data, [{:state_timeout, :timer.seconds(5), :process_records}]}
  end

  # 2 - This is the periodic handle that will transition into work state
  def handle_event(:state_timeout, :process_records, :idle, data) do
    {:next_state, :running, data}
  end

  # 3 - Here we enter :running state, so do the work
  def handle_event(:enter, _old_state, _new_state = :running, data) do
    # IO.inspect("ENTER RUNNING")

    again_loop(check_if_more_entries(data))
  end

  # 5 - if entries == [], then state_timeout from running, and move into idle again - goto 1
  def handle_event(:state_timeout, :idle, :running, data) do
    {:next_state, :idle, data}
  end

  # 5 - if there's more work, keep going back to 4
  def handle_event(:timeout, :again, :running, data) do
    # IO.inspect("HANDLING TIMEOUT ")
    again_loop(check_if_more_entries(data))
  end

  # 4 - here we check if there are entries to work on - in this case, there are none, so go idle
  defp again_loop(%{entries: []} = data) do
    {:keep_state, data, [{:state_timeout, 0, :idle}]}
  end

  # 4 - Here we have entries to work on - and we create a 0 timeout to work on more entries
  defp again_loop(%{entries: entries} = data) when entries != [] do
    {:ok, _} = work(entries)
    # IO.inspect("MORE WORK")
    {:keep_state, check_if_more_entries(data), [{:timeout, 0, :again}]}
  end

  defp check_if_more_entries(data) do
    Map.put(data, :entries, MusicLibrary.Query.LastFmRawTrack.get_oldest_unprocessed_tracks())
  end

  def work(entries) do
    MusicLibrary.Repo.transaction(fn ->
      Enum.each(entries, fn entry ->
        last_fm_data = entry.data

        # Arist
        artist = last_fm_data["artist"]
        artist_name = artist["#text"]
        artist_mbid = artist["mbid"]

        {:ok, artist_struct} =
          MusicLibrary.Query.Artist.upsert(%{
            name: artist_name,
            mbid: artist_mbid
          })

        artist_id = artist_struct.id

        # Album
        album = last_fm_data["album"]
        album_cover_url = find_medium_image(last_fm_data["image"])

        album_cover_url =
          case String.length(album_cover_url) do
            l when l > 2048 -> ""
            _ -> album_cover_url
          end

        case album["#text"] do
          "" ->
            :ok

          album_name ->
            {:ok, album_struct} =
              MusicLibrary.Query.Album.upsert(%{
                name: album_name,
                album_cover_url: album_cover_url,
                mbid: album["mbid"],
                artist_id: artist_id
              })

            album_id = album_struct.id

            # Track
            track_name = last_fm_data["name"]

            track_params = %{
              name: track_name,
              listened_at: entry.listened_at,
              url: last_fm_data["url"],
              mbid: last_fm_data["mbid"],
              artist_id: artist_id,
              album_id: album_id
            }

            {:ok, _track_struct} =
              MusicLibrary.Query.Track.insert(track_params)
        end

        {:ok, _} = MusicLibrary.Query.LastFmRawTrack.set_processed(entry)
      end)
    end)
  end

  defp find_medium_image(images) do
    [img] = Enum.filter(images, fn i -> i["size"] == "medium" end)
    img["#text"]
  end
end
