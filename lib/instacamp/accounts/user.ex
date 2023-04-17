defmodule Instacamp.Accounts.User do
  @moduledoc """
  User Ecto schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Instacamp.Accounts.Follower
  alias Instacamp.Accounts.UserSettings
  alias Instacamp.Notifications.Notification
  alias Instacamp.Posts.Bookmark
  alias Instacamp.Posts.Comment
  alias Instacamp.Posts.Like
  alias Instacamp.Posts.Post

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type opts :: Keyword.t()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :avatar_url, :string, default: "/images/default-avatar.png"
    field :bio, :string
    field :confirmed_at, :naive_datetime
    field :email, :string
    field :followers_count, :integer, default: 0
    field :following_count, :integer, default: 0
    field :full_name, :string
    field :hashed_password, :string, redact: true
    field :location, :string
    field :password, :string, virtual: true, redact: true
    field :posts_count, :integer, default: 0
    field :username, :string
    field :website, :string

    embeds_one :settings, UserSettings, on_replace: :update

    has_many :comments, Comment
    has_many :following, Follower, foreign_key: :follower_id
    has_many :followers, Follower, foreign_key: :followed_id
    has_many :likes, Like
    has_many :notification, Notification
    has_many :posts_bookmarks, Bookmark

    has_many :posts, Post

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  @spec registration_changeset(t(), attrs(), opts()) :: changeset()
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [
      :avatar_url,
      :bio,
      :email,
      :full_name,
      :location,
      :password,
      :username,
      :website
    ])
    |> validate_user_name_and_full_name()
    |> validate_website()
    |> validate_email(opts)
    |> validate_password(opts)
  end

  defp validate_user_name_and_full_name(changeset) do
    changeset
    |> validate_required(:username, message: "Username can't be blank")
    |> validate_required(:full_name, message: "Full name can't be blank")
    |> validate_length(:username,
      min: 5,
      max: 30,
      message: "Username should be at least 5 character(s)"
    )
    |> unique_constraint(:username)
    |> validate_length(:full_name,
      min: 4,
      max: 30,
      message: "Full name should be at least 4 character(s)"
    )
  end

  defp validate_website(changeset) do
    validate_change(changeset, :website, fn :website, website ->
      uri = URI.parse(website)

      if uri.scheme do
        check_uri_scheme(uri.scheme)
      else
        [website: "Enter a valid website"]
      end
    end)
  end

  defp validate_email(changeset, opts \\ []) do
    register_user? = Keyword.get(opts, :register_user, true)

    main_email_changeset =
      changeset
      |> validate_required([:email], message: "Email can't be blank")
      |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
        message: "must have the @ sign and no spaces"
      )
      |> validate_length(:email, max: 160)

    if register_user? do
      main_email_changeset
      |> unsafe_validate_unique(:email, Instacamp.Repo)
      |> unique_constraint(:email)
    else
      main_email_changeset
    end
  end

  defp validate_password(changeset, opts) do
    register_user? = Keyword.get(opts, :register_user, true)

    if register_user? do
      changeset
      |> validate_required([:password])
      |> validate_length(:password, min: 10, max: 72)
      # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
      # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
      # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
      |> maybe_hash_password(opts)
    else
      cast_embed(changeset, :settings, required: true)
    end
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  @spec email_changeset(t(), attrs()) :: changeset()
  def email_changeset(user, attrs) do
    user_changeset =
      user
      |> cast(attrs, [:email])
      |> validate_email()

    case user_changeset do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  @spec password_changeset(t(), attrs(), opts()) :: changeset()
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> cast_embed(:settings, required: true)
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  @spec confirm_changeset(t() | changeset()) :: t() | changeset()
  def confirm_changeset(user) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  @spec valid_password?(t(), binary()) :: boolean()
  def valid_password?(%Instacamp.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_opt1, _opt2) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  @spec validate_current_password(changeset(), Ecto.UUID.t()) :: changeset()
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp check_uri_scheme(scheme) when scheme == "http", do: []
  defp check_uri_scheme(scheme) when scheme == "https", do: []
  defp check_uri_scheme(_scheme), do: [website: "Enter a valid website"]
end
