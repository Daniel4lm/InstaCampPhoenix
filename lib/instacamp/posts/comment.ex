defmodule Instacamp.Posts.Comment do
  @moduledoc """
  Post Comment Ecto schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Instacamp.Accounts.User
  alias Instacamp.Notifications.Notification
  alias Instacamp.Posts.Like
  alias Instacamp.Posts.Post

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "post_comments" do
    field :body, :string
    field :total_likes, :integer, default: 0
    belongs_to :post, Post
    belongs_to :user, User

    has_many :likes, Like, foreign_key: :liked_id
    has_many :notification, Notification

    timestamps()
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(%__MODULE__{} = comment, attrs) do
    comment
    |> cast(attrs, [:body, :total_likes])
    |> validate_required([:body, :total_likes])
  end
end
