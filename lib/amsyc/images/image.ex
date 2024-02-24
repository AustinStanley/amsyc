defmodule Amsyc.Images.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:path])
    |> validate_required([:path])
  end
end
