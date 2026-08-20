defmodule MusicLibraryWeb.CoverController do
  use MusicLibraryWeb, :controller

  # Cover files are always named "#{album_id}#{ext}" — this also rules out path traversal.
  @filename_regex ~r/^\d+\.(jpg|jpeg|png|gif|webp)$/

  def show(conn, %{"filename" => filename}) do
    if Regex.match?(@filename_regex, filename) do
      path = Path.join(MusicLibrary.AlbumCoverDownload.cover_dir(), filename)

      if File.regular?(path) do
        conn
        |> put_resp_header("cache-control", "public, max-age=31536000, immutable")
        |> send_file(200, path)
      else
        send_resp(conn, 404, "")
      end
    else
      send_resp(conn, 404, "")
    end
  end
end
