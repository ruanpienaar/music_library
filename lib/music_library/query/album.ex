defmodule MusicLibrary.Query.Album do
  require Logger
  @schema_mod MusicLibrary.Schema.Album

  def insert(params) do
    case %@schema_mod{}
         |> @schema_mod.changeset(params)
         |> MusicLibrary.Repo.insert() do
      {:ok, album} ->
        {:ok, album}

      {:error, changeset} ->
        Logger.error("#{__MODULE__} changeset.errors #{changeset.errors}")
        {:error, changeset}
    end
  end

  def upsert(params) do
    %@schema_mod{}
    |> @schema_mod.changeset(params)
    |> MusicLibrary.Repo.insert(
      on_conflict: {:replace, [:mbid, :album_cover_url]},
      conflict_target: [:name, :artist_id],
      returning: true
    )
  end
end
