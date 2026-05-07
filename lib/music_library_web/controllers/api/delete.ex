defmodule MusicLibraryWeb.Api.Delete do
  use MusicLibraryWeb, :controller

  def delete(conn, %{}) do
    json(conn, %{result: "ok"})
  end
end
