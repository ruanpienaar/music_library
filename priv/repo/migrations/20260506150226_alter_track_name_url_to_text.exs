defmodule MusicLibrary.Repo.Migrations.AlterTrackNameUrlToText do
  use Ecto.Migration

  def change do
    alter table(:track) do
      modify :name, :text
      modify :url, :text
    end
  end
end
