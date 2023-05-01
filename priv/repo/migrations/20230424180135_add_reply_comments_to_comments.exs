defmodule Instacamp.Repo.Migrations.AddReplyCommentsToComments do
  use Ecto.Migration

  def change do
    alter table(:post_comments) do
      add :parent_id, references(:post_comments, on_delete: :delete_all, type: :binary_id)
      add :total_comments, :integer, default: 0
    end
  end
end
