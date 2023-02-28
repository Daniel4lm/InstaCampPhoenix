defmodule InstacampWeb.Navigation.NavbarTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Posts
  # alias Instacamp.Repo

  describe "test navigation - no auth" do
    test "user can't see navigation bar", %{conn: conn} do
      {:error, {:redirect, %{flash: %{}, to: "/auth/login"}}} =
        live(conn, Routes.live_path(conn, InstacampWeb.HomeLive))
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

    test "user see navigation bar", %{conn: conn} do
      {:ok, home_live, html} = live(conn, Routes.live_path(conn, InstacampWeb.HomeLive))

      assert html =~ "InstaCamp"
      refute html =~ "Log In"

      assert has_element?(home_live, "#search-posts-form")
      assert has_element?(home_live, "#new-post")
      refute has_element?(home_live, "#post-search-list")

      assert home_live
             |> form("#search-posts-form", %{post_term: "Someday"})
             |> render_change()

      assert has_element?(home_live, "#post-search-list")
      assert render(home_live) =~ "No results found."

      assert home_live
             |> form("#search-posts-form", %{post_term: "Some"})
             |> render_change()

      [post] = Posts.search_posts_by_term("Some")

      updated_live = render(home_live)
      assert updated_live =~ post.title
      assert updated_live =~ post.user.full_name
    end
  end
end
