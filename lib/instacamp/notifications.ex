defmodule Instacamp.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false

  alias Instacamp.Accounts.User
  alias Instacamp.Notifications.Notification
  alias Instacamp.Posts.Comment
  alias Instacamp.Posts.Post
  alias Instacamp.Repo

  @actions %{
    following_action: "following",
    post_like_action: "post_like",
    comment_action: "comment",
    comment_like_action: "comment_like"
  }

  @doc """
  Returns the list of all notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Notification
    |> preload([:user])
    |> Repo.all()
  end

  @doc """
  Returns the list of notifications for specific user.

  ## Examples

      iex> list_user_notifications(user_id)
      [%Notification{}, ...]

  """
  def list_user_notifications(user_id) do
    Notification
    |> where([n], n.user_id == ^user_id)
    |> where([n], n.inserted_at >= datetime_add(^NaiveDateTime.utc_now(), -1, "week"))
    |> order_by([n], desc: n.inserted_at)
    |> preload([n], [:author])
    |> Repo.all()
  end

  @doc """
  Builds a notification for post.

  ## Examples

      iex> create_post_notification(post, author)
      %Notification{}

  """
  def create_post_notification(%Post{} = post, %User{} = author) do
    %Notification{}
    |> Notification.changeset(%{action_type: @actions.post_like_action})
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Ecto.Changeset.put_assoc(:user, post.user)
  end

  @doc """
  Builds a notification for comment.

  ## Examples

      iex> create_comment_notification(comment, post, author)
      %Notification{}

  """
  def create_comment_notification(%Comment{} = comment, %Post{} = post, %User{} = author) do
    %Notification{}
    |> Notification.changeset(%{action_type: @actions.comment_action})
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Ecto.Changeset.put_assoc(:user, post.user)
    |> Ecto.Changeset.put_assoc(:comment, comment)
  end

  @doc """
  Builds a notification for comment like.

  ## Examples

      iex> create_comment_like_notification(comment, post, author)
      %Notification{}

  """
  def create_comment_like_notification(%Comment{} = comment, %Post{} = post, %User{} = author) do
    %Notification{}
    |> Notification.changeset(%{action_type: @actions.comment_like_action})
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Ecto.Changeset.put_assoc(:user, comment.user)
    |> Ecto.Changeset.put_assoc(:comment, comment)
  end

  @doc """
  Builds a following notification for user.

  ## Examples

      iex> create_following_notification(author, user)
      %Notification{}

  """
  def create_following_notification(%User{} = author, %User{} = user) do
    %Notification{}
    |> Notification.changeset(%{action_type: @actions.following_action})
    |> Ecto.Changeset.put_assoc(:author, author)
    |> Ecto.Changeset.put_assoc(:user, user)
  end

  @doc """
  Returns the following notification for user.

  ## Examples

      iex> get_following_notification(user_id, author_id)
      %Notification{}

  """
  def get_following_notification(user_id, author_id) do
    Repo.get_by!(
      Notification,
      user_id: user_id,
      author_id: author_id,
      action_type: @actions.following_action
    )
  end

  @doc """
  Returns the post notification for post.

  ## Examples

      iex> get_post_notification(author_id, post)
      %Notification{}

  """
  def get_post_notification(author_id, post) do
    notification =
      Repo.get_by(
        Notification,
        user_id: post.user_id,
        author_id: author_id,
        post_id: post.id,
        action_type: @actions.post_like_action
      )

    notification
  end

  @doc """
  Returns the comment notification.

  ## Examples

      iex> get_comment_notification(author_id, comment)
      %Notification{}

  """
  def get_comment_notification(author_id, comment) do
    notification =
      Repo.get_by(
        Notification,
        user_id: comment.user_id,
        author_id: author_id,
        comment_id: comment.id,
        action_type: @actions.comment_action
      )

    notification
  end

  @doc """
  Returns the comment like notification.

  ## Examples

      iex> get_comment_like_notification(author_id, comment)
      %Notification{}

  """
  def get_comment_like_notification(author_id, comment) do
    notification =
      Repo.get_by(
        Notification,
        user_id: comment.user_id,
        author_id: author_id,
        comment_id: comment.id,
        action_type: @actions.comment_like_action
      )

    notification
  end

  @doc """
  Checks if all user notifications are read.
  Returns a boolean value.

  ## Examples

      iex> all_unread?(user_id)
      true

  """
  def all_unread?(user_id) do
    Notification
    |> where([u], u.user_id == ^user_id and u.read == false)
    |> Repo.exists?()
  end

  @doc """
  Make sure all user notifications have been read.

  ## Examples

      iex> read_all(user_id)
      :ok

  """
  def read_all(user_id) do
    user_notifications_query = from(n in Notification, where: n.user_id == ^user_id)

    Repo.update_all(user_notifications_query, set: [read: true])
    :ok
  end
end
