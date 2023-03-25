defmodule Instacamp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Instacamp.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_username, do: "username#{System.unique_integer()}"
  def valid_user_password, do: "H3llo_world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      username: unique_username(),
      full_name: "Marco Antonio",
      location: "San Marino",
      password: valid_user_password(),
      settings: %{}
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Instacamp.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
