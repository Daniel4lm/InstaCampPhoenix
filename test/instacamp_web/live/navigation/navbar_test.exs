defmodule InstacampWeb.Navigation.NavbarTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Posts

  describe "test navigation - no auth" do
    test "user can't see navigation bar", %{conn: conn} do
      {:ok, home_live, html} = live(conn, Routes.feed_path(conn, :index))

      assert html =~ "Campy"
      assert html =~ "Log In"
      assert html =~ "Sign Up"
      refute has_element?(home_live, "#new-post")
    end
  end

  describe "test navigation - with auth" do
    setup %{conn: conn} do
      user = user_fixture(%{username: "daniel", email: "daniel@gmail.com", full_name: "Daniel"})

      post_1 = blog_post_fixture(user, :new)

      %{
        conn: log_in_user(conn, user),
        user: user,
        post_1: post_1
      }
    end

    test "user can see and use navigation bar", %{conn: conn, user: user} do
      {:ok, home_live, html} = live(conn, Routes.feed_path(conn, :index))

      assert html =~ "Campy"
      refute html =~ "Log In"

      assert has_element?(home_live, "#navbar-search-form")
      assert has_element?(home_live, "#new-post")
      refute has_element?(home_live, "#post-search-list")

      assert home_live
             |> form("#navbar-search-form", %{search_term: "Someday"})
             |> render_change()

      assert has_element?(home_live, "#post-search-list")
      assert render(home_live) =~ "No results found."

      assert home_live
             |> form("#navbar-search-form", %{search_term: "Some"})
             |> render_change()

      [post] = Posts.search_posts_by_term("Some")

      u_l_1 = render(home_live)
      assert u_l_1 =~ post.title
      assert u_l_1 =~ post.user.full_name

      assert home_live
             |> form("#navbar-search-form", %{search_term: "dan"})
             |> render_change()

      u_l_2 = render(home_live)
      assert u_l_2 =~ user.username
      assert u_l_2 =~ user.full_name
    end
  end
end
