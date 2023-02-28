defmodule Instacamp.Repo.Migrations.CreatePostBookmarks do
  use Ecto.Migration

  def change do
    create table(:post_bookmarks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:post_bookmarks, [:post_id, :user_id])
  end
end
