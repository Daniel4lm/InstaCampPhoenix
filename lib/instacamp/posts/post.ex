defmodule Instacamp.Posts.Post do
  @moduledoc """
  Post Ecto schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Instacamp.Accounts.User
  alias Instacamp.Notifications.Notification
  alias Instacamp.Posts.Bookmark
  alias Instacamp.Posts.Comment
  alias Instacamp.Posts.Like
  alias Instacamp.Posts.PostTags
  alias Instacamp.Tags.Tag

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :body, :string
    field :photo_url, :string
    field :title, :string
    field :total_comments, :integer
    field :total_likes, :integer
    field :slug, :string

    belongs_to :user, User

    has_many :comment, Comment
    has_many :likes, Like, foreign_key: :liked_id
    has_many :notification, Notification
    has_many :posts_bookmarks, Bookmark

    many_to_many :tags, Tag, join_through: PostTags, on_replace: :delete

    timestamps()
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(%__MODULE__{} = post, attrs) do
    post
    |> cast(attrs, [:body, :photo_url, :slug, :title, :total_comments, :total_likes])
    |> add_slug()
    |> validate_required([:body, :slug, :title])
    |> validate_length(:body, min: 50, message: "Message body should be at least 50 character(s)")
    |> validate_length(:title, min: 5, message: "Message title should be at least 5 character(s)")
  end

  defp add_slug(changeset) do
    is_post_new? =
      changeset
      |> get_field(:slug)
      |> is_nil()

    title_from_changeset = get_field(changeset, :title)

    cond do
      is_post_new? && is_nil(title_from_changeset) ->
        put_change(changeset, :slug, create_slug(""))

      is_post_new? && title_from_changeset ->
        put_change(changeset, :slug, create_slug(title_from_changeset))

      true ->
        changeset
    end
  end

  defp create_slug(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-zA-Z0-9 &]/, "")
    |> String.replace("&", "and")
    |> String.split()
    |> Enum.join("-")
  end
end
