defmodule Instacamp.Notifications.Notification do
  @moduledoc """
  Notification Ecto schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Instacamp.Accounts.User
  alias Instacamp.Posts.Comment
  alias Instacamp.Posts.Post

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :action_type, :string
    field :read, :boolean, default: false
    belongs_to :author, User
    belongs_to :user, User
    belongs_to :comment, Comment
    belongs_to :post, Post

    timestamps()
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(%__MODULE__{} = notification, attrs) do
    notification
    |> cast(attrs, [:action_type, :read])
    |> validate_required([:action_type, :read])
  end
end
