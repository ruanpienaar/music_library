defmodule MusicLibraryWeb.TodayLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Track, as: TrackQuery

  def mount(_params, _session, socket) do
    today = Date.utc_today()
    tracks = TrackQuery.today()

    socket =
      socket
      |> assign(:date_label, Calendar.strftime(today, "%A, %B %-d %Y"))
      |> assign(:tracks, tracks)
      |> assign(:count, length(tracks))

    {:ok, socket}
  end
end
