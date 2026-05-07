defmodule MusicLibraryWeb.Api.Artist do
  use MusicLibraryWeb, :controller
  require Logger

  def get(conn, %{"name" => name}) when is_binary(name) do
    json(conn, %{
      result:
        MusicLibrary.Api.Artist.get(%{name: name})
        |> Enum.map(fn record ->
          MusicLibrary.Schema.Artist.take_fields(record)
        end)
    })
  end

  def get(conn, params) do
    Logger.error("Controller {:error, :bad_params}, #{inspect(params)}")
    json(conn, %{result: %{error: "invalid parameters"}})
  end

  def post(conn, %{"name" => _name} = params) do
    case MusicLibrary.Api.Artist.post(params) do
      {:ok, _} ->
        json(conn, %{result: "ok"})

      {:error, _} ->
        Logger.error("{:error, :database_or_changeset_errr}, #{inspect(params)}")
        json(conn, %{result: %{error: "request failed"}})
    end
  end

  def post(conn, params) do
    Logger.error("{:error, :bad_params}, #{inspect(params)}")
    json(conn, %{result: %{error: "invalid request"}})
  end

  def put(conn, _params) do
    json(conn, %{result: "ok"})
  end
end
