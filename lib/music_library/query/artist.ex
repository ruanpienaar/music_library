defmodule MusicLibrary.Query.Artist do
  @schema_mod MusicLibrary.Schema.Artist
  import Ecto.Query
  require Logger

  # TODO: This seems like a dangerous func
  def get_all() do
    from(a in @schema_mod, order_by: a.name)
    |> MusicLibrary.Repo.all()
  end

  # TODO: impl paging
  def get_all_by_name(name) do
    from(
      a in @schema_mod,
      where: a.name == ^name
    )
    |> MusicLibrary.Repo.all()
  end

  def insert(params) do
    case %@schema_mod{}
         |> @schema_mod.changeset(params)
         |> MusicLibrary.Repo.insert() do
      {:ok, artist} ->
        {:ok, artist}

      {:error, changeset} ->
        Logger.error("#{__MODULE__} changeset.errors #{changeset.errors}")
        {:error, changeset}
    end
  end

  # TODO: Create macros for these and others
  def all() do
    from(@schema_mod)
    |> MusicLibrary.Repo.all()
  end

  def by_id(id) do
    from(@schema_mod, where: [id: ^id])
    |> MusicLibrary.Repo.one()
  end

  # def upsert(%{tag_id: tag_id, setup_no: setup_no} = setup_entry) do
  #   from(
  #     cs in __MODULE__,
  #     where: cs.tag_id == ^tag_id,
  #     where: cs.setup_no == ^setup_no
  #   )
  #   |> Database.one()
  #   |> case do
  #     nil -> create(setup_entry)
  #     struct -> Ecto.Changeset.change(struct, setup_entry) |> Database.update()
  #   end
  # end

  # on_conflict - # only overwrite these columns
  # conflict_target - # the unique index columns
  # returning - # return the final row

  def upsert(params) do
    %@schema_mod{}
    |> @schema_mod.changeset(params)
    |> MusicLibrary.Repo.insert(
      on_conflict: {:replace, [:mbid]},
      conflict_target: [:name],
      returning: true
    )
  end
end
