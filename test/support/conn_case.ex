defmodule InstacampWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use InstacampWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import InstacampWeb.ConnCase

      alias InstacampWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint InstacampWeb.Endpoint
    end
  end

  setup tags do
    Instacamp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that creates the user.

      setup :create_user

  It stores the user in the test context.
  """
  def create_user(context),
    do:
      Map.put(
        context,
        :user,
        Instacamp.AccountsFixtures.user_fixture(%{
          email: "daniel_4@gmail.com",
          username: "daniel4m",
          full_name: "Daniel"
        })
      )

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Instacamp.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Instacamp.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  @doc """
  Creates the two users and their posts, logs in the user.

  It returns an updated `conn`.
  """
  def setup_for_user_profile_and_post(%{conn: conn}) do
    user_1 =
      Instacamp.AccountsFixtures.user_fixture(%{
        username: "daniel",
        email: "daniel@gmail.com",
        full_name: "Daniel"
      })

    user_2 =
      Instacamp.AccountsFixtures.user_fixture(%{
        username: "damir",
        email: "damir@gmail.com",
        full_name: "Damir"
      })

    post_1 =
      Instacamp.BlogFixtures.blog_post_fixture(%Instacamp.Posts.Post{}, user_1, :new, %{
        "title" => "Daniels post"
      })

    post_2 =
      Instacamp.BlogFixtures.blog_post_fixture(%Instacamp.Posts.Post{}, user_2, :new, %{
        "title" => "Damirs post"
      })

    %{
      conn: log_in_user(conn, user_1),
      user_1: user_1,
      user_2: user_2,
      post_1: post_1,
      post_2: post_2
    }
  end
end
