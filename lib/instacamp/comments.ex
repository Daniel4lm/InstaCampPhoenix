defmodule Instacamp.Comments do
  @moduledoc """
  The Comments context module.
  """

  import Ecto.Query, warn: false

  alias Instacamp.Accounts.User
  alias Instacamp.Notifications
  alias Instacamp.Posts.Comment
  alias Instacamp.Posts.Like
  alias Instacamp.Posts.Post
  alias Instacamp.Repo

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id) do
    Comment
    |> Repo.get!(id)
    |> Repo.preload([:user, :likes])
  end

  @doc """
  Gets the list of replies to a given comment.

  ## Examples

      iex> get_comment_replies(123)
      [%Comment{}, ...]

      iex> get_comment_replies(456)
      []

  """
  def get_comment_replies(comment_id) do
    Comment
    |> where([comment], comment.parent_id == ^comment_id)
    |> order_by([comment], desc: comment.inserted_at)
    |> preload([:user, :post])
    |> preload(likes: :user)
    |> Repo.all()
  end

  @doc """
  Creates a new comment, updates or creates a reply to an existing one.

  ## Examples

      iex> create_or_update_comment(comment, post, user, :new, %{field: value})
      {:ok, %Comment{}}

      iex> create_or_update_comment(comment, post, user, :new, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_comment(
        %Comment{} = comment,
        %Post{} = post,
        %User{} = user,
        action,
        attrs \\ %{}
      ) do
    comment_changeset =
      comment
      |> get_comment_source(action)
      |> Comment.changeset(attrs)
      |> Ecto.Changeset.put_change(:user_id, user.id)
      |> Ecto.Changeset.put_change(:post_id, post.id)
      |> maybe_add_parent_id(comment, action)

    comments_transaction = get_comments_transaction(comment_changeset, post, comment, action)

    case comments_transaction do
      {:ok, result} ->
        comment_source = %{
          :new => result.comment,
          :comment_reply => comment
        }

        build_comment_notification(comment_source[action], post, user, action)

        {:ok,
         Repo.preload(result.comment, [
           [likes: [:user]],
           :post,
           :user
         ])}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp get_comments_transaction(comment_changeset, post, comment, action) do
    case action do
      :new ->
        build_comments_transaction(comment_changeset, :new, %{post: post})

      :edit ->
        build_comments_transaction(comment_changeset, :edit, %{})

      :comment_reply ->
        build_comments_transaction(comment_changeset, :comment_reply, %{
          comment_source: comment,
          post: post
        })
    end
  end

  defp build_comment_notification(resource, post, user, :new) do
    if post.user_id != user.id do
      comment_notification = Notifications.create_comment_notification(resource, post, user)
      Repo.insert(comment_notification)
    end
  end

  defp build_comment_notification(resource, post, user, :comment_reply) do
    if resource.user_id != user.id do
      comment_notification = Notifications.create_comment_reply_notification(resource, post, user)
      Repo.insert(comment_notification)
    end
  end

  defp build_comment_notification(_resource, _post, _user, :edit), do: nil

  defp build_comments_transaction(comment_changeset, :new, %{post: post} = _attrs) do
    update_posts_with_comments_count = from(post in Post, where: post.id == ^post.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:comment, comment_changeset)
    |> Ecto.Multi.update_all(:update_total_comments, update_posts_with_comments_count,
      inc: [total_comments: 1]
    )
    |> Repo.transaction()
  end

  defp build_comments_transaction(
         comment_changeset,
         :comment_reply,
         %{comment_source: comment_source, post: post} = _attrs
       ) do
    update_comments_with_comments_count =
      from(comment in Comment, where: comment.id == ^comment_source.id)

    update_posts_with_comments_count = from(post in Post, where: post.id == ^post.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:comment, comment_changeset)
    |> Ecto.Multi.update_all(:update_total_comments, update_comments_with_comments_count,
      inc: [total_comments: 1]
    )
    |> Ecto.Multi.update_all(:update_total_post_comments, update_posts_with_comments_count,
      inc: [total_comments: 1]
    )
    |> Repo.transaction()
  end

  defp build_comments_transaction(comment_changeset, :edit, _attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:comment, comment_changeset)
    |> Repo.transaction()
  end

  defp get_comment_source(_comment, action) when action in [:new, :comment_reply],
    do: %Comment{}

  defp get_comment_source(comment, :edit), do: comment

  defp maybe_add_parent_id(changeset, parent_comment, :comment_reply) do
    Ecto.Changeset.put_change(changeset, :parent_id, parent_comment.id)
  end

  defp maybe_add_parent_id(changeset, _parent_comment, _other), do: changeset

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment, post)
      {:ok, %Comment{}}

      iex> delete_comment(comment, post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment, %Post{} = post) do
    update_posts_with_comments_count = from(post in Post, where: post.id == ^post.id)
    delete_comment_likes = from(like in Like, where: like.liked_id == ^comment.id)

    maybe_update_comments_count =
      from(comment in Comment, where: ^with_parent_id(comment.parent_id))

    comments_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.update_all(:update_comments_count, maybe_update_comments_count,
        inc: [total_comments: -1]
      )
      |> Ecto.Multi.delete(:comment, comment)
      |> Ecto.Multi.delete_all(:delete_comment_likes, delete_comment_likes)
      |> Ecto.Multi.update_all(:update_total_comments, update_posts_with_comments_count,
        inc: [total_comments: -1]
      )
      |> Repo.transaction()

    case comments_transaction do
      {:ok, result} ->
        {:ok, result.comment}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp with_parent_id(nil), do: false
  defp with_parent_id(parent_id), do: dynamic([comment], comment.id == ^parent_id)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  @doc """
  Returns the list of all users related to comments.

  ## Examples

      iex> get_users_from_comments([comment1, comment2, ...])
      [%User{}, ...]

  """
  def get_users_from_comments(post_comments) do
    post_comments
    |> Stream.uniq_by(fn %{user: %{id: id}} = _comment -> id end)
    |> Enum.to_list()
  end
end
