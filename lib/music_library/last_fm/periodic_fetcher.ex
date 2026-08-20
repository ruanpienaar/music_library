defmodule MusicLibrary.LastFm.PeriodicFetcher do
  alias MusicLibrary.LastFm.Client
  require Logger

  # TODO: we will want to make sure we can persist when we last attempted by safe try-catching code, to prevent sporadic restarts from hitting the lastfm api too much

  @behaviour :gen_statem

  defstruct quick_fetch: true

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
    {:ok, :idle, %__MODULE__{quick_fetch: true}}
  end

  def handle_event(:enter, old_state, _new_state = :idle, %__MODULE__{quick_fetch: quick_fetch?})
      when old_state == :idle or old_state == :running do
    if quick_fetch? do
      {:keep_state_and_data,
       [{:state_timeout, Client.rate_limit_ms(), :request_tracks_from_last_fm}]}
    else
      {:keep_state_and_data, [{:state_timeout, Client.slow_wait(), :request_tracks_from_last_fm}]}
    end
  end

  def handle_event(:enter, _old_state = :idle, _new_state = :running, data) do
    {:ok, fetched} = MusicLibrary.LastFm.RecentTracks.fetch_all()

    cond do
      fetched = 1 ->
        Logger.notice(
          "Fetched #{inspect(fetched)} songs from last.fm. Going to wait a little longer."
        )

        {:keep_state, %__MODULE__{data | quick_fetch: false}, [{:state_timeout, 0, :idle}]}

      fetched > 1 ->
        Logger.notice("Fetched #{inspect(fetched)} songs from last.fm.")
        :ok = MusicLibrary.PeriodicDataGenerator.process_records_now()
        {:keep_state, %__MODULE__{data | quick_fetch: true}, [{:state_timeout, 0, :idle}]}

      true ->
        Logger.notice(
          "Fetched #{inspect(fetched)} songs from last.fm. Going to wait a little longer."
        )

        {:keep_state, %__MODULE__{data | quick_fetch: false}, [{:state_timeout, 0, :idle}]}
    end

    # if fetched > 0 do
    #   Logger.notice("Fetched #{inspect(fetched)} songs from last.fm.")
    #   :ok = MusicLibrary.PeriodicDataGenerator.process_records_now()
    #   {:keep_state, %__MODULE__{data | quick_fetch: true}, [{:state_timeout, 0, :idle}]}
    # else
    #   Logger.notice(
    #     "Fetched #{inspect(fetched)} songs from last.fm. Going to wait a little longer."
    #   )

    #   {:keep_state, %__MODULE__{data | quick_fetch: false}, [{:state_timeout, 0, :idle}]}
    # end
  end

  def handle_event(:state_timeout, :idle, :running, data) do
    {:next_state, :idle, data}
  end

  def handle_event(:state_timeout, :request_tracks_from_last_fm, :idle, data) do
    {:next_state, :running, data}
  end
end
