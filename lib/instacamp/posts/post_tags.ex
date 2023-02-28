defmodule Instacamp.Posts.PostTags do
  @moduledoc """
  Post Tag Ecto schema
  """

  use Ecto.Schema

  alias Instacamp.Posts.Post
  alias Instacamp.Tags.Tag

  @primary_key false
  @foreign_key_type :binary_id
  schema "post_tags" do
    belongs_to :post, Post
    belongs_to :tag, Tag

    timestamps()
  end
end
