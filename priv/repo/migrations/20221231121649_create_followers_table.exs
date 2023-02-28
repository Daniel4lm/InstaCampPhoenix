defmodule Instacamp.Repo.Migrations.CreateFollowersTable do
  use Ecto.Migration

  def change do
    create table(:accounts_follows, primary_key: false) do
      add :follower_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :followed_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:accounts_follows, [:follower_id])
    create index(:accounts_follows, [:followed_id])
  end
end
