defmodule MusicLibrary.MusicBrainz.CoverArtArchive do
  require Logger

  @base_url "https://coverartarchive.org"
  @user_agent "music_library/0.1 (ruan800@gmail.com)"

  def fetch(mbid) do
    case get_front(:release, mbid) do
      {:error, :not_found} -> get_front(:release_group, mbid)
      result -> result
    end
  end

  # Cover Art Archive serves the original scan at /front, which can be
  # tens or hundreds of MB. We only ever display covers as small thumbnails,
  # so use the pre-generated 250px thumbnail variant instead.
  defp get_front(kind, mbid) do
    url = "#{@base_url}/#{path_segment(kind)}/#{mbid}/front-250"

    case Req.get(url, headers: [{"user-agent", @user_agent}]) do
      {:ok, %{status: 200, body: body, headers: headers}} ->
        {:ok, body, ext_from_content_type(headers)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: 429}} ->
        {:error, :rate_limited}

      {:ok, %{status: status}} when status >= 500 and status < 600 ->
        {:error, {:server_error, status}}

      {:ok, %{status: status}} ->
        {:error, {:http_status, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp path_segment(:release), do: "release"
  defp path_segment(:release_group), do: "release-group"

  defp ext_from_content_type(headers) do
    case Map.get(headers, "content-type", []) do
      ["image/png" <> _ | _] -> ".png"
      ["image/gif" <> _ | _] -> ".gif"
      ["image/webp" <> _ | _] -> ".webp"
      _ -> ".jpg"
    end
  end
end
