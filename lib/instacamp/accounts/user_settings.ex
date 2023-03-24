defmodule Instacamp.Accounts.UserSettings do
  @moduledoc """
  Ecto schema for user settings
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :online, :boolean
    field :password_updated_at, :naive_datetime
    field :theme_mode, Ecto.Enum, values: [:light, :dark], default: :light
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(%__MODULE__{} = settings, attrs \\ %{}) do
    settings
    |> cast(attrs, [:online, :password_updated_at, :theme_mode])
    |> validate_inclusion(:theme_mode, [:light, :dark])
  end
end
