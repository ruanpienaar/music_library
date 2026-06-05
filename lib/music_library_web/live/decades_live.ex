defmodule MusicLibraryWeb.DecadesLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Track, as: TrackQuery

  def mount(_params, _session, socket) do
    decades =
      TrackQuery.decade_stats()
      |> Enum.map(fn %{decade: d, count: c} ->
        %{
          decade: d,
          count: c,
          top_artists: TrackQuery.top_artists_for_decade(d, 5),
          top_albums: TrackQuery.top_albums_for_decade(d, 5),
          top_tracks: TrackQuery.top_tracks_for_decade(d, 5)
        }
      end)

    {:ok, assign(socket, :decades, decades)}
  end
end
