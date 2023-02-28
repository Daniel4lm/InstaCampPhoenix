defmodule InstacampWeb.PostTopicHelper do
  @moduledoc """
  This helper module contains funcions for construction of repetitive Elixir PubSub topic names.
  """

  @post_bookmark_topic "post_bookmark:<post_id>"
  @post_comment_topic "post_comments:<post_id>"
  @user_posts_topic "user_posts:<user_id>"
  @post_or_comment_like_topic "post_or_comment_likes:<post_id>"
  @post_topic "post:<post_id>"
  @user_notification_topic "user_notification:<user_id>"

  @type post_id :: Ecto.UUID.t()
  @type user_id :: Ecto.UUID.t()
  @type topic :: String.t()

  @doc """
  Returns the topic for user notification.

  ## Examples

      iex> user_notification_topic("user-id")
      "user_notification:user-id"

  """
  @spec user_notification_topic(user_id()) :: topic()
  def user_notification_topic(user_id),
    do: String.replace(@user_notification_topic, "<user_id>", user_id)

  @doc """
  Returns the topic for post/comment likes of the specified post.

  ## Examples

      iex> post_or_comment_like_topic("post-id")
      "post_or_comment_likes:post-id"

  """
  @spec post_or_comment_like_topic(post_id()) :: topic()
  def post_or_comment_like_topic(post_id),
    do: String.replace(@post_or_comment_like_topic, "<post_id>", post_id)

  @doc """
  Returns the topic for create/update of the specified post.

  ## Examples

      iex> post_topic("post-id")
      "post:post-id"

  """
  @spec post_topic(post_id()) :: topic()
  def post_topic(post_id),
    do: String.replace(@post_topic, "<post_id>", post_id)

  @doc """
  Returns the topic for post/comment likes of the specified post.

  ## Examples

      iex> post_comment_topic("post-id")
      "post_comments:post-id"

  """
  @spec post_comment_topic(post_id()) :: topic()
  def post_comment_topic(post_id),
    do: String.replace(@post_comment_topic, "<post_id>", post_id)

  @doc """
  Returns the topic for posts update of the specified user.

  ## Examples

      iex> user_posts_topic("user-id")
      "user_posts:user-id"

  """
  @spec user_posts_topic(user_id()) :: topic()
  def user_posts_topic(user_id),
    do: String.replace(@user_posts_topic, "<user_id>", user_id)

  @doc """
  Returns the topic for post/comment likes of the specified post.

  ## Examples

      iex> post_bookmark_topic("post-id")
      "post_bookmark:post-id"

  """
  @spec post_bookmark_topic(post_id()) :: topic()
  def post_bookmark_topic(post_id),
    do: String.replace(@post_bookmark_topic, "<post_id>", post_id)
end
