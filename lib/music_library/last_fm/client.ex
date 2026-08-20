defmodule MusicLibrary.LastFm.Client do
  require Logger

  # TODO: make buse_url config
  @base_url "https://ws.audioscrobbler.com/2.0/"
  @api_version @base_url
               |> URI.parse()
               |> Map.get(:path)
               |> String.split("/")
               |> Enum.reject(&(&1 == ""))
               |> List.first()

  # ( Bumped it to 1s to be safe ) Last.fm allows ~5 req/sec; 250ms gives us 4/sec with a safe margin
  @rate_limit_ms 5000
  # 4 mins - the average length of a single song, we're not going to be listening to music at
  # speeds above 1x, so might as well wait the average length of a single song,
  # before asking for new listened tracks
  @slow_wait_ms 240_000

  def get(method, params \\ %{}) do
    query =
      Map.merge(
        %{method: method, api_key: api_key(), format: "json"},
        params
      )

    case Req.get(@base_url,
           params: query,
           headers: [{"user-agent", "music_library/0.1 (ruan800@gmail.com)"}],
           cache: true
         ) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Last.fm API error #{status}: #{inspect(body)}")
        {:error, {status, body}}

      {:error, reason} ->
        Logger.error("Last.fm HTTP error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def username, do: Application.fetch_env!(:music_library, :last_fm)[:username]
  def rate_limit_ms, do: @rate_limit_ms
  def slow_wait, do: @slow_wait_ms
  def api_version, do: @api_version

  defp api_key, do: Application.fetch_env!(:music_library, :last_fm)[:api_key]
end
