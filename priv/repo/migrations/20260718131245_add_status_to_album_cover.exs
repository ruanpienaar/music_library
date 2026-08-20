defmodule MusicLibrary.Repo.Migrations.AddStatusToAlbumCover do
  use Ecto.Migration

  def change do
    alter table(:album_cover) do
      add :status, :string, null: false, default: "pending"
    end

    execute """
            UPDATE album_cover SET status = 'downloaded' WHERE downloaded = true
            """,
            """
            UPDATE album_cover SET downloaded = true WHERE status = 'downloaded'
            """

    alter table(:album_cover) do
      remove :downloaded, :boolean, default: false, null: false
    end
  end
end
