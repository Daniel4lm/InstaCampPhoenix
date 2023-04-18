defmodule Instacamp.Repo.Migrations.AddWebsiteToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :website, :string
    end
  end
end
