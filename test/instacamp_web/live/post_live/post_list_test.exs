defmodule InstacampWeb.PostLive.PostListTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Instacamp.Posts

  describe "/user/saved-list" do
    setup [:setup_for_user_profile_and_post]

    test "user visits the empty saved-list page", %{
      conn: conn
    } do
      {:ok, _saved_list_live, html} = live(conn, Routes.saved_list_path_path(conn, :list))

      assert html =~ "Saved list (0)"
      assert html =~ "No saved posts yet"
    end

    test "user visits saved-list page with content", %{
      conn: conn,
      user_1: user_1,
      post_1: post_1,
      user_2: user_2,
      post_2: post_2
    } do
      assert {:ok, _post_bookmark_1} = Posts.create_bookmark(post_2, user_1)
      assert {:ok, _post_bookmark_2} = Posts.create_bookmark(post_1, user_2)

      {:ok, _saved_list_live, saved_list_html} =
        live(conn, Routes.saved_list_path_path(conn, :list))

      assert saved_list_html =~ "Saved list (1)"
      assert saved_list_html =~ post_2.title
      assert saved_list_html =~ post_2.user.full_name
      assert saved_list_html =~ "Delete"

      {:ok, search_list_live, search_html} =
        live(conn, Routes.saved_list_path_path(conn, :search))

      assert search_html =~ "Search list (0)"

      view_1 =
        search_list_live
        |> form("#search-saved-form", list_search: %{term: "Elixir post"})
        |> render_submit()

      assert view_1 =~ "Search list (0)"

      view_2 =
        search_list_live
        |> form("#search-saved-form", list_search: %{term: "Damir"})
        |> render_submit()

      assert view_2 =~ "Search list (1)"

      {:ok, saved_list_live, _saved_list_html} =
        live(conn, Routes.saved_list_path_path(conn, :list))

      refute saved_list_live
             |> element("#delete-button-#{post_2.id}", "Delete")
             |> render_click() =~ post_2.title
    end
  end
end
