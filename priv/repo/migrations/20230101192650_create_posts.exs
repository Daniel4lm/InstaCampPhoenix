defmodule Instacamp.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string
      add :title, :string
      add :body, :text
      add :photo_url, :string
      add :total_likes, :integer, default: 0
      add :total_comments, :integer, default: 0
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:posts, [:user_id])
    create unique_index(:posts, [:user_id, :slug])
  end
end
