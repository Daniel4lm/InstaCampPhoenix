defmodule Instacamp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Instacamp.Accounts.Follower
  alias Instacamp.Accounts.User
  alias Instacamp.Accounts.UserNotifier
  alias Instacamp.Accounts.UserToken
  alias Instacamp.Notifications
  alias Instacamp.Repo

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("daniel4mx")
      %User{}

      iex> get_user_by_username("unknown")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    User
    |> Repo.get_by(username: username)
    |> Repo.preload([:comments, :posts_bookmarks])
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Returns the list of users searched by term.

  ## Examples

      iex> search_users_by_term("John")
      [%User{}, ...]

  """
  def search_users_by_term(term) do
    User
    |> where([user], ilike(user.full_name, ^"%#{term}%") or ilike(user.username, ^"%#{term}%"))
    |> select([user], user)
    # |> preload([:user])
    |> Repo.all()
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user params.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, register_user: false)
  end

  @doc """
  Updates the user using the given attrs.

  ## Examples

      iex> update_user(user, valid_params)
      {:ok, %User{}}

      iex> update_user(user, invalid_params)
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.registration_changeset(attrs, register_user: false)
    |> Repo.update()
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _error -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    update_user_password_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
      |> Repo.transaction()

    case update_user_password_transaction do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _reason} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    token
    |> UserToken.token_and_context_query("session")
    |> Repo.delete_all()

    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _error -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _error -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(%User{} = user, attrs) do
    reset_user_password_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
      |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
      |> Repo.transaction()

    case reset_user_password_transaction do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, :user, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  ## Accounts followers/followings

  @doc """
  Creates a follow to the given followed user, and builds
  user association to be able to preload the user when associations are loaded,
  gets users to update counts, then performs 3 Repo operations,
  creates the follow, updates user followings count, and user followers count,
  we select the user in our updated followers count query, that gets returned
  """
  def create_follow(%User{} = follower, %User{} = followed, %User{} = user) do
    follower_params = Ecto.build_assoc(follower, :following)
    follow = Ecto.build_assoc(followed, :followers, follower_params)
    update_following_count = from(u in User, where: u.id == ^user.id)
    update_followers_count = from(u in User, where: u.id == ^followed.id, select: u)

    following_notification = Notifications.create_following_notification(follower, followed)

    create_follow_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:follow, follow)
      |> Ecto.Multi.insert(:notification, following_notification)
      |> Ecto.Multi.update_all(:update_following, update_following_count,
        inc: [following_count: 1]
      )
      |> Ecto.Multi.update_all(:update_followers, update_followers_count,
        inc: [followers_count: 1]
      )
      |> Repo.transaction()

    case create_follow_transaction do
      {:ok, %{update_followers: update_followers}} ->
        {1, user} = update_followers
        hd(user)

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes following association with given user,
  then performs 3 Repo operations, to delete the association,
  update followings count, update and select followers count,
  updated followers count gets returned
  """
  def unfollow(follower_id, followed_id) do
    follow_query =
      from f in Follower,
        where: f.follower_id == ^follower_id and f.followed_id == ^followed_id

    update_following_count = from(u in User, where: u.id == ^follower_id)
    update_followers_count = from(u in User, where: u.id == ^followed_id, select: u)

    following_notification = Notifications.get_following_notification(followed_id, follower_id)

    unfollow_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.delete_all(:follow, follow_query)
      |> Ecto.Multi.delete(:notification, following_notification)
      |> Ecto.Multi.update_all(:update_following, update_following_count,
        inc: [following_count: -1]
      )
      |> Ecto.Multi.update_all(:update_followers, update_followers_count,
        inc: [followers_count: -1]
      )
      |> Repo.transaction()

    case unfollow_transaction do
      {:ok, %{update_followers: update_followers}} ->
        {1, user} = update_followers
        hd(user)

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns Follow or nil if not found
  """
  def get_following(follower_id, followed_id) do
    Follower
    |> Repo.get_by(follower_id: follower_id, followed_id: followed_id)
    |> Repo.preload([:follower, :followed])
  end

  @doc """
  Returns all user's followings
  """
  def list_following(%User{} = user) do
    user = Repo.preload(user, :following)
    Repo.preload(user.following, :followed)
  end

  @doc """
  Returns all user's followers
  """
  def list_followers(%User{} = user) do
    user = Repo.preload(user, :followers)

    Repo.preload(user.followers, :follower)
  end
end
