defmodule Instacamp.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false

  alias Instacamp.Accounts.User
  alias Instacamp.Notifications
  alias Instacamp.Posts.Bookmark
  alias Instacamp.Posts.Comment
  alias Instacamp.Posts.Like
  alias Instacamp.Posts.Post
  alias Instacamp.Posts.PostTags
  alias Instacamp.Repo
  alias Instacamp.Tags.Tag

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Post
    |> select([post], post)
    |> order_by([post], desc: post.inserted_at)
    |> preload([post], [:user])
    |> Repo.all()
  end

  @doc """
  Returns the list of posts searched by term.

  ## Examples

      iex> search_posts_by_term("Elixir")
      [%Post{}, ...]

  """
  def search_posts_by_term(term) do
    Post
    |> where([post], ilike(post.title, ^"%#{term}%"))
    |> select([post], post)
    |> preload([:user])
    |> Repo.all()
  end

  @doc """
  Returns the list of posts searched by specific tag/topic.

  ## Examples

      iex> search_posts_by_tag("elixir")
      [%Post{}, ...]

  """
  def search_posts_by_tag(tag_name) do
    Repo.all(
      from(p in Post,
        join: pt in PostTags,
        on: p.id == pt.post_id,
        join: t in Tag,
        on: t.id == pt.tag_id,
        where: t.name == ^tag_name,
        distinct: p.id,
        select: p,
        order_by: [desc: p.inserted_at],
        preload: [:user, :tags]
      )
    )
  end

  def list_user_saved_posts(user, page, per_page) do
    Repo.all(
      from(p in Post,
        join: bm in Bookmark,
        on: p.id == bm.post_id,
        join: u in User,
        on: u.id == bm.user_id and u.id == ^user.id,
        distinct: p.id,
        select: p,
        limit: ^per_page,
        offset: ^((page - 1) * per_page),
        order_by: [desc: p.inserted_at],
        preload: [:user, :tags]
      )
    )
  end

  @doc """
  Returns the paginated list of posts by user.

  ## Examples

      iex> list_user_profile_posts(user, 2, 5)
      [%Post{}, ...]

  """
  def list_user_profile_posts(user, page, per_page) do
    Post
    |> select([post], post)
    |> where([post], post.user_id == ^user.id)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> order_by([post], desc: post.inserted_at)
    |> preload([:user, :tags])
    |> Repo.all()
  end

  def get_post_feed do
    comments_portions =
      from(c in Comment,
        select: %{id: c.id, body: c.body, row_number: over(row_number(), :posts_partition)},
        windows: [posts_partition: [partition_by: :post_id, order_by: [desc: :id]]]
      )

    main_comments_query =
      from(c in Comment,
        join: r in subquery(comments_portions),
        on: c.id == r.id
      )

    Repo.all(main_comments_query)
  end

  @doc """
  Calculates estimated reading time(in minutes) for post body.

  ## Examples

      iex> calculate_read_time(post)
      7

  """
  def calculate_read_time(post) do
    average_words_per_minute = 225

    words_count =
      post.body
      |> String.trim()
      |> String.split(~r/\s+/)
      |> Enum.count()

    (words_count / average_words_per_minute)
    |> Float.ceil()
    |> trunc()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload([:user, :likes, :tags])
  end

  @doc """
  Gets a single post by post slug.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post_by_slug!("welcome-to-elixir")
      %Post{}

      iex> get_post_by_slug!("456")
      ** (Ecto.NoResultsError)

  """
  def get_post_by_slug!(slug) do
    Post
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:user, :likes, :tags])
  end

  @doc """
  Creates a new post or updates an existing one.

  ## Examples

      iex> create_or_update_post(%Post{}, %User{}, :new, %{title: "post"})
      {:ok, %Post{}}

      iex> create_or_update_post(%Post{}, %User{}, :new, %{title: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_post(
        %Post{} = post,
        %User{} = user,
        action,
        %{"tags" => tags} = attrs \\ %{}
      ) do
    new_tags = prepare_tags(post, tags, action)

    post_changeset =
      post
      |> Post.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:tags, new_tags)
      |> Ecto.Changeset.put_change(:user_id, user.id)

    post_transaction =
      case action do
        :new ->
          create_or_update_post_transaction(post_changeset, :new, %{user: user})

        :edit ->
          create_or_update_post_transaction(post_changeset, :edit, %{})
      end

    case post_transaction do
      {:ok, result} ->
        {:ok, Repo.preload(result.post, [:user])}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp create_or_update_post_transaction(post_changeset, :new, %{user: user} = _attrs) do
    update_users_with_posts_count = from(user in User, where: user.id == ^user.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:post, post_changeset)
    |> Ecto.Multi.update_all(:update_posts_count, update_users_with_posts_count,
      inc: [posts_count: 1]
    )
    |> Repo.transaction()
  end

  defp create_or_update_post_transaction(post_changeset, :edit, _attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:post, post_changeset)
    |> Repo.transaction()
  end

  defp prepare_tags(post, tags, action) do
    post_with_tags = Repo.preload(post, :tags)
    get_post_tags(post_with_tags.tags, tags, action)
  end

  defp get_post_tags(post_tags, new_tags, :new) do
    post_tags
    |> Enum.concat(new_tags)
    |> Enum.uniq()
  end

  defp get_post_tags(post_tags, new_tags, :edit) do
    Enum.reduce(new_tags, [], fn
      tag, acc when tag in [post_tags] -> [tag | acc]
      tag, acc when tag not in [post_tags] -> [tag | acc]
    end)
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post, user)
      {:ok, %Post{}}

      iex> delete_post(post, user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post, %User{} = user) do
    update_users_with_posts_count = from(user in User, where: user.id == ^user.id)

    post_delete_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:post, post)
      |> Ecto.Multi.update_all(:update_posts_count, update_users_with_posts_count,
        inc: [posts_count: -1]
      )
      |> Repo.transaction()

    case post_delete_transaction do
      {:ok, result} ->
        {:ok, result.post}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Returns the list of post_comments.

  ## Examples

      iex> list_post_comments(post, 1, 10)
      [%Comment{}, ...]

  """
  def list_post_comments(%Post{} = post, page, per_page) do
    Comment
    |> select([comment], comment)
    |> where([comment], comment.post_id == ^post.id)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> order_by([comment], desc: comment.inserted_at)
    |> preload([:user, :post])
    |> preload(likes: :user)
    |> Repo.all()
  end

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

  def insert_tags(tags) do
    timestamp = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    placeholders = %{timestamp: timestamp}

    entries =
      Enum.map(
        tags,
        &%{
          name: &1,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      )

    Repo.insert_all(
      Tag,
      entries,
      placeholders: placeholders,
      on_conflict: :nothing
    )

    Repo.all(from(t in Tag, where: t.name in ^tags))
  end

  @doc """
  Creates a new comment or updates an existing one.

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
      |> Comment.changeset(attrs)
      |> Ecto.Changeset.put_change(:user_id, user.id)
      |> Ecto.Changeset.put_change(:post_id, post.id)

    comments_transaction =
      case action do
        :new ->
          build_comments_transaction(comment_changeset, :new, %{post: post})

        :edit ->
          build_comments_transaction(comment_changeset, :edit, %{})
      end

    case comments_transaction do
      {:ok, result} ->
        if action == :new do
          comment_notification = build_comment_notification(result.comment, post, user)
          Repo.insert(comment_notification)
        end

        {:ok, Repo.preload(result.comment, [[likes: [:user]], :post, :user])}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp build_comments_transaction(comment_changeset, :new, %{post: post} = _attrs) do
    update_posts_with_comments_count = from(post in Post, where: post.id == ^post.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:comment, comment_changeset)
    |> Ecto.Multi.update_all(:update_total_comments, update_posts_with_comments_count,
      inc: [total_comments: 1]
    )
    |> Repo.transaction()
  end

  defp build_comments_transaction(comment_changeset, :edit, _attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:comment, comment_changeset)
    |> Repo.transaction()
  end

  defp build_comment_notification(resource, post, user) do
    Notifications.create_comment_notification(resource, post, user)
  end

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

    comments_transaction =
      Ecto.Multi.new()
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
  Creates a like for Post or post comment.

  ## Examples

      iex> create_like(user, resource_name, resource)
      {:ok, %Like{}}

      iex> create_like(user, bad_value, resource)
      {:error, %Ecto.Changeset{}}

  """
  def create_like(%User{} = user, resource_name, resource) do
    like_changeset =
      %Like{}
      |> Like.changeset(%{liked_id: resource.id})
      |> Ecto.Changeset.put_change(:user_id, user.id)

    update_resource_with_total_likes = get_resource_query(resource_name, resource.id)

    like_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:like, like_changeset)
      |> create_or_update_like_notification(user, resource, resource_name)
      |> Ecto.Multi.update_all(:update_total_likes, update_resource_with_total_likes,
        inc: [total_likes: 1]
      )
      |> Repo.transaction()

    case like_transaction do
      {:ok, result} ->
        {:ok, Repo.preload(result.like, [:user])}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp create_or_update_like_notification(transaction, user, resource, resource_name) do
    case Notifications.get_post_notification(user.id, resource) do
      nil ->
        like_notification = build_like_notification(user, resource, resource_name)

        Ecto.Multi.insert(transaction, :notification, like_notification)

      last_like_notif ->
        Ecto.Multi.update(transaction, :update_notification, last_like_notif, set: [read: false])
    end
  end

  defp build_like_notification(user, resource, :post) do
    Notifications.create_post_notification(resource, user)
  end

  defp build_like_notification(user, resource, :comment) do
    comment_with_post = Repo.preload(resource, post: :user)
    Notifications.create_comment_like_notification(resource, comment_with_post.post, user)
  end

  defp get_like_notification(user_id, resource, :post) do
    Notifications.get_post_notification(user_id, resource)
  end

  defp get_like_notification(user_id, resource, :comment) do
    Notifications.get_comment_like_notification(user_id, resource)
  end

  @doc """
  Deletes a like for Post or comment.

  ## Examples

      iex> unlike(user, resource_name, resource)
      {:ok, %Like{}}

      iex> unlike(user, bad_value, resource)
      {:error, %Ecto.Changeset{}}

  """
  def unlike(%User{} = user, resource_name, resource) do
    like = get_like(user, resource)

    update_resource_with_total_likes = get_resource_query(resource_name, resource.id)

    like_notification = get_like_notification(user.id, resource, resource_name)

    like_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:like, like)
      |> Ecto.Multi.delete(:notification, like_notification)
      |> Ecto.Multi.update_all(:update_total_likes, update_resource_with_total_likes,
        inc: [total_likes: -1]
      )
      |> Repo.transaction()

    case like_transaction do
      {:ok, result} ->
        {:ok, result.like}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp get_resource_query(:post, liked_id), do: from(post in Post, where: post.id == ^liked_id)

  defp get_resource_query(:comment, liked_id),
    do: from(comment in Comment, where: comment.id == ^liked_id)

  defp get_like(user, resource) do
    Enum.find(resource.likes, fn resource ->
      resource.user_id == user.id
    end)
  end

  @doc """
  Creates a post bookmark.

  ## Examples

      iex> create_bookmark(post, user)
      {:ok, %Bookmark{}}

  """
  def create_bookmark(%Post{} = post, %User{} = user) do
    bookmark_with_user = Ecto.build_assoc(user, :posts_bookmarks)
    bookmark_with_post = Ecto.build_assoc(post, :posts_bookmarks, bookmark_with_user)
    Repo.insert(bookmark_with_post)
  end

  @doc """
  Deletes a post bookmark.

  ## Examples

      iex> unbookmark(bookmark)
      {:ok, %Bookmark{}}

  """
  def unbookmark(bookmark) do
    Repo.delete(bookmark)
  end

  @doc """
  Gets the number of post bookmarks.
  Returns nil if there is none.

  ## Examples

      iex> count_post_bookmarks(post)
      4

      iex> count_post_bookmarks(other_post)
      nil

  """
  def count_post_bookmarks(post) do
    Bookmark
    |> where(post_id: ^post.id)
    |> select([b], count(b.id))
    |> Repo.one()
  end

  @doc """
  Gets the number of bookmarks made by given user.
  Returns nil if there is none.

  ## Examples

      iex> count_post_bookmarks(user)
      4

      iex> count_post_bookmarks(other_user)
      nil

  """
  def count_user_bookmarks(user) do
    Bookmark
    |> where(user_id: ^user.id)
    |> select([b], count(b.id))
    |> Repo.one()
  end

  @doc """
  Checks if the post is bookmarked or not.
  Returns the bookmark in positive case or nil otherwise.

  ## Examples

      iex> is_bookmarked(post, user)
      %Bookmark{}

      iex> is_bookmarked(post, nil)
      nil

  """
  def is_bookmarked(%Post{} = _post, nil), do: nil

  def is_bookmarked(%Post{} = post, %User{} = user) do
    Repo.get_by(Bookmark, post_id: post.id, user_id: user.id)
  end
end
