defmodule MusicLibrary.Api.Artist do
  require Logger

  def get(%{name: name}) when is_binary(name) do
    MusicLibrary.Query.Artist.get_all_by_name(name)
  end

  def get(params) do
    Logger.error("API {:error, :bad_params}, #{inspect(params)}")
    {:error, :bad_params}
  end

  def post(params) do
    MusicLibrary.Query.Artist.insert(params)
  end

  # defp post(params, false) do
  #   # Return some error for json/api response
  # end

  # defp post(params, true) do
  #   MusicLibrary.Query.Artist.insert(params)
  # end

  # put
  # delete
end
