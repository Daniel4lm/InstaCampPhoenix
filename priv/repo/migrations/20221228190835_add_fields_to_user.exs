defmodule Instacamp.Repo.Migrations.AddFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar_url, :string
      add :bio, :string
      add :full_name, :string
      add :location, :string
      add :username, :string
    end
  end
end
