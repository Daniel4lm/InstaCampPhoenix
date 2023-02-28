defmodule Instacamp.Tags.Tag do
  @moduledoc """
  Tags Ecto schema
  """

  use Ecto.Schema

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field :name, :string

    timestamps()
  end
end
