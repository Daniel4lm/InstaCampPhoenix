defmodule Instacamp.Repo.Migrations.CreatePostTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      timestamps()
    end

    create unique_index(:tags, [:name])

    create table(:post_tags, primary_key: false) do
      add :tag_id, references(:tags, type: :binary_id, on_delete: :delete_all), null: false
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
