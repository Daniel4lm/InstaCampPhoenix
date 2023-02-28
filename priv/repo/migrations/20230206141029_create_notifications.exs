defmodule Instacamp.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :action_type, :text
      add :read, :boolean, default: false, null: false

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :author_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all)
      add :comment_id, references(:post_comments, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:notifications, [:comment_id])
    create index(:notifications, [:post_id])
    create index(:notifications, [:user_id])
  end
end
