defmodule MusicLibrary.LastFm.PeriodicFetcher do
  require Logger

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

  def handle_event(:enter, old_state, _new_state = :idle, _data)
      when old_state == :idle or old_state == :running do
    {:keep_state_and_data, [{:state_timeout, :timer.minutes(1), :request_tracks_from_last_fm}]}
  end

  def handle_event(:enter, _old_state = :idle, _new_state = :running, _data) do
    {:ok, fetched} = MusicLibrary.LastFm.RecentTracks.fetch_all()

    if fetched > 0 do
      Logger.notice("Fetched #{inspect(fetched)} songs from last.fm.")
    end

    {:keep_state_and_data, [{:state_timeout, 0, :idle}]}
  end

  def handle_event(:state_timeout, :idle, :running, data) do
    {:next_state, :idle, data}
  end

  def handle_event(:state_timeout, :request_tracks_from_last_fm, :idle, data) do
    {:next_state, :running, data}
  end
end
