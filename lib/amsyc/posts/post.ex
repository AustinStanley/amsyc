defmodule Amsyc.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string
    field :user, :id
    field :embedded_media, :string
    field :image, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :user, :embedded_media, :image])
    |> validate_required([:title, :body, :user])
  end
end
