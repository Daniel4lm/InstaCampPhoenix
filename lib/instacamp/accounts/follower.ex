defmodule Instacamp.Accounts.Follower do
  @moduledoc """
  Follower Ecto schema
  """

  use Ecto.Schema

  alias Instacamp.Accounts.User

  @type t :: %__MODULE__{}

  @primary_key false
  @foreign_key_type :binary_id
  schema "accounts_follows" do
    belongs_to :follower, User
    belongs_to :followed, User

    timestamps()
  end
end
