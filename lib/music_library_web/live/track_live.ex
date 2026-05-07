defmodule MusicLibraryWeb.TrackLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Track, as: TrackQuery

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tracks: TrackQuery.recent(100))}
  end
end
