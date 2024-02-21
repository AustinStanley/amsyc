defmodule Amsyc.Repo.Migrations.ChangePostBodyType do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :body, :text
    end
  end
end
