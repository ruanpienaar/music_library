defmodule MusicLibraryWeb.ArtistLive do
  use MusicLibraryWeb, :live_view

  alias MusicLibrary.Query.Artist, as: ArtistQuery
  alias MusicLibrary.Schema.Artist

  def mount(_params, _session, socket) do
    artists = ArtistQuery.get_all()
    form = to_form(Artist.changeset(%Artist{}))
    {:ok, assign(socket, artists: artists, form: form)}
  end

  def handle_event("create", %{"artist" => params}, socket) do
    case ArtistQuery.insert(params) do
      {:ok, _artist} ->
        artists = ArtistQuery.get_all()
        form = to_form(Artist.changeset(%Artist{}))
        {:noreply, assign(socket, artists: artists, form: form)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
