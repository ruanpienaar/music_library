defmodule MusicLibraryWeb.DashboardLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Track, as: TrackQuery

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:total_scrobbles, fmt(TrackQuery.total_count()))
      |> assign(:total_artists, fmt(TrackQuery.total_artists()))
      |> assign(:total_albums, fmt(TrackQuery.total_albums()))
      |> assign(:top_artists, TrackQuery.top_artists(10))
      |> assign(:top_albums, TrackQuery.top_albums(10))
      |> assign(:top_tracks, TrackQuery.top_tracks(10))

    {:ok, socket}
  end

  defp fmt(nil), do: "0"

  defp fmt(n) when is_integer(n) do
    n
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end
end
