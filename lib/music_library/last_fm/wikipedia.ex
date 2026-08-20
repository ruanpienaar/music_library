defmodule MusicLibrary.LastFm.Wikipedia do
  @base_url "https://en.wikipedia.org/api/rest_v1/feed/onthisday/births"

  def fetch_births(month, day) do
    url = "#{@base_url}/#{month}/#{day}"

    case Req.get(url, headers: [{"User-Agent", "MusicLibrary/1.0 (personal project)"}]) do
      {:ok, %{status: 200, body: body}} ->
        now = Date.utc_today().year

        births =
          (body["births"] || [])
          |> Enum.map(fn e ->
            page = get_in(e, ["pages", Access.at(0)])

            %{
              year: e["year"],
              text: e["text"],
              url: get_in(page, ["content_urls", "desktop", "page"])
            }
          end)
          |> Enum.filter(fn e -> e.year >= now - 100 and e.year <= now end)
          |> Enum.sort_by(& &1.year, :asc)
          |> Enum.take(30)

        {:ok, births}

      _ ->
        {:ok, []}
    end
  end
end
