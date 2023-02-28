defmodule Instacamp.Posts.Like do
  @moduledoc """
  Post Cooment Ecto schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Instacamp.Accounts.User

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "likes" do
    field :liked_id, :binary_id
    belongs_to :user, User

    timestamps()
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(%__MODULE__{} = like, attrs) do
    like
    |> cast(attrs, [:liked_id])
    |> validate_required([:liked_id])
  end
end
