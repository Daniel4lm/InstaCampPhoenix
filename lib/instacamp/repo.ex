defmodule Instacamp.Repo do
  use Ecto.Repo,
    otp_app: :instacamp,
    adapter: Ecto.Adapters.Postgres
end
