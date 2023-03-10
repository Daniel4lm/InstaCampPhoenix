defmodule Instacamp.Repo.Migrations.AddPostsCountToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :posts_count, :integer, default: 0
    end
  end
end
