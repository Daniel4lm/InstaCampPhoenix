# Script for populating the development database. You can run it as:
#
#     mix run priv/repo/seeds.dev.exs
#
#

alias Instacamp.{Accounts, Posts}

first_user_params = %{
  full_name: "Daniel",
  username: "daniel4molnar",
  location: "Tuzla",
  email: "daniel4molnar@gmail.com",
  password: "Tuzla4444333"
}

second_user_params = %{
  full_name: "Dijana",
  username: "dijana_tz",
  location: "Tuzla",
  email: "dijana@gmail.com",
  password: "KISELJAK4444"
}

{:ok, _first_user} = Accounts.register_user(first_user_params)
{:ok, _second_user} = Accounts.register_user(second_user_params)
