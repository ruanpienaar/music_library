defmodule MusicLibraryWeb.OnThisDayLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Track, as: TrackQuery
  alias MusicLibrary.LastFm.Wikipedia

  def mount(_params, _session, socket) do
    today = Date.utc_today()
    month = today.month
    day = today.day

    scrobbles = TrackQuery.on_this_day(month, day)
    by_year = Enum.group_by(scrobbles, fn s -> s.listened_at.year end)
    {:ok, wiki_events} = Wikipedia.fetch_events(month, day)

    socket =
      socket
      |> assign(:date_label, Calendar.strftime(today, "%B %-d"))
      |> assign(:scrobbles_by_year, by_year |> Enum.sort_by(fn {y, _} -> y end, :desc))
      |> assign(:wiki_events, wiki_events)

    {:ok, socket}
  end
end
