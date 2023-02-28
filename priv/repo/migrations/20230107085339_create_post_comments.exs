defmodule Instacamp.Repo.Migrations.CreatePostComments do
  use Ecto.Migration

  def change do
    create table(:post_comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :total_likes, :integer, default: 0
      add :post_id, references(:posts, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:post_comments, [:post_id])
    create index(:post_comments, [:user_id])
  end
end
