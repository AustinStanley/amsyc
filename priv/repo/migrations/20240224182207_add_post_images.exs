defmodule Amsyc.Repo.Migrations.AddPostImages do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :embedded_media, :text
      add :image, references(:images)
    end
  end
end
