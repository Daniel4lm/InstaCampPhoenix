defmodule Instacamp.Posts.FilterPost do
  @moduledoc """
  FilterPost Ecto schema
  """

  import Ecto.Changeset

  @types %{
    tag: :string,
    title: :string,
    author: :string,
    with_comments: :boolean
  }

  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{
          tag: String.t() | nil,
          title: String.t() | nil,
          author: String.t() | nil,
          with_comments: boolean() | nil
        }

  defstruct author: nil, tag: nil, title: nil, with_comments: false

  @doc """
  FilterPost changeset for validation.
  """
  @spec changeset(t(), map()) :: changeset()
  def changeset(%__MODULE__{} = filter_post, attrs \\ %{}) do
    cast({filter_post, @types}, attrs, Map.keys(@types))
  end
end
