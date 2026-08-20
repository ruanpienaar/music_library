defmodule MusicLibraryWeb.CollageLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Album, as: AlbumQuery

  def mount(_params, _session, socket) do
    albums = AlbumQuery.all_with_local_covers()
    {:ok, assign(socket, albums: albums), layout: {MusicLibraryWeb.Layouts, :app_collage}}
  end
end
