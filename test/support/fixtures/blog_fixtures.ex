defmodule Instacamp.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating blog posts, comments, likes and everything related to post
  """

  alias Instacamp.Accounts
  alias Instacamp.Posts

  @type bookmark :: Posts.Bookmark.t()
  @type comment :: Posts.Comment.t()
  @type like :: Posts.Like.t()
  @type post :: Posts.Post.t()
  @type tag :: Instacamp.Tags.Tag.t()
  @type user :: Accounts.User.t()

  @doc """
  Creates a blog post.
  """
  @spec blog_post_fixture(post(), user(), atom(), map()) :: post()
  def blog_post_fixture(
        post \\ %Posts.Post{},
        %Accounts.User{} = user,
        action,
        attrs \\ %{}
      ) do
    tags = blog_tag_fixture(["elixir", "dev", "city"])

    attrs =
      Enum.into(attrs, %{
        "body" =>
          "This morning the view from the window was beautiful. A little heavier snow fell, but soon it started to melt...",
        "title" => "Some post title",
        "total_comments" => 0,
        "total_likes" => 0,
        "tags" => tags
      })

    {:ok, blog_post} = Posts.create_or_update_post(post, user, action, attrs)

    blog_post
  end

  @doc """
  Creates a blog post comment.
  """
  @spec blog_comment_fixture(post(), user(), map()) :: comment()
  def blog_comment_fixture(post \\ %Posts.Post{}, %Accounts.User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        "body" => "I love this! Never really thought about how easy it would be to..."
      })

    {:ok, comment} = Posts.create_or_update_comment(%Posts.Comment{}, post, user, :new, attrs)
    comment
  end

  @doc """
  Creates a blog post tags.
  """
  @spec blog_tag_fixture([String.t()]) :: [tag()]
  def blog_tag_fixture(tags \\ []) do
    tag_list = Posts.insert_tags(tags)
    tag_list
  end

  @doc """
  Creates a like for post or comment .
  """
  @spec like_fixture(user(), atom(), post() | comment()) :: like()
  def like_fixture(%Accounts.User{} = user, resorce_name, resorce) do
    {:ok, like} = Posts.create_like(user, resorce_name, resorce)

    like
  end

  @doc """
  Creates a like for post or comment .
  """
  @spec bookmark_fixture(post(), user()) :: bookmark()
  def bookmark_fixture(%Posts.Post{} = post, %Accounts.User{} = user) do
    {:ok, bookmark} = Posts.create_bookmark(post, user)

    bookmark
  end
end
