defmodule Instacamp.Posts.Bookmark do
  @moduledoc """
  Post Bookmark Ecto schema
  """

  use Ecto.Schema

  alias Instacamp.Accounts.User
  alias Instacamp.Posts.Post

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "post_bookmarks" do
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end
end
