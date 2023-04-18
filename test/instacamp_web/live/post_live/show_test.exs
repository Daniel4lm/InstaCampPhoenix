defmodule InstacampWeb.PostLive.ShowTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Instacamp.DateTimeHelper
  alias Instacamp.Repo

  describe "/post/:slug" do
    setup [:setup_for_user_profile_and_post]

    test "user can visit someone else's post page, like and bookmark the post", %{
      conn: conn,
      user_2: user_2,
      post_2: post_2
    } do
      {:ok, post_live, html} = live(conn, Routes.post_show_path(conn, :show, post_2.slug))

      assert page_title(post_live) =~ post_2.title
      assert html =~ user_2.full_name
      assert html =~ DateTimeHelper.format_post_date(post_2.updated_at)
      assert html =~ "Damirs post"
      assert html =~ post_2.body

      assert has_element?(post_live, "#like-component-" <> post_2.id)
      assert has_element?(post_live, "#post-total-likes", "0")

      assert has_element?(post_live, "#tag-component-" <> post_2.id)
      assert has_element?(post_live, "#post-bookmarks-count", "0")

      _like_updated_html = render_click(element(post_live, "#like-component-" <> post_2.id))
      assert has_element?(post_live, "#post-total-likes", "1")

      _tag_updated_html = render_click(element(post_live, "#tag-component-" <> post_2.id))
      assert has_element?(post_live, "#post-bookmarks-count", "1")

      _unlike_updated_html = render_click(element(post_live, "#like-component-" <> post_2.id))
      assert has_element?(post_live, "#post-total-likes", "0")
    end

    test "user can visit someone else's post page and attempt to make a comment", %{
      conn: conn,
      user_2: user_2,
      post_2: post_2
    } do
      {:ok, post_live, html} = live(conn, Routes.post_show_path(conn, :show, post_2.slug))

      assert html =~ user_2.full_name
      assert html =~ "Damirs post"

      _updated_html =
        post_live
        |> form("#new-comment-form", comment: %{body: ""})
        |> render_submit()

      assert has_element?(post_live, "#post-total-comments", "0")

      _updated_html =
        post_live
        |> form("#new-comment-form")
        |> render_submit(
          comment: %{
            body: "Hii. This is my first comment"
          }
        )

      assert has_element?(post_live, "#post-total-comments", "1")
      assert render(post_live) =~ "Hii. This is my first comment"

      preloaded_post_2 = Repo.preload(post_2, [:comment])
      [comment] = preloaded_post_2.comment

      refute has_element?(post_live, "#like-component-" <> comment.id)
      assert has_element?(post_live, "#likes-count-for-" <> comment.id, "0")
    end

    test "user can visit his own page", %{
      conn: conn,
      user_1: user_1,
      post_1: post_1
    } do
      {:ok, post_live, html} = live(conn, Routes.post_show_path(conn, :show, post_1.slug))

      assert html =~ user_1.full_name
      assert html =~ DateTimeHelper.format_post_date(post_1.updated_at)
      assert html =~ "Daniels post"
      assert html =~ post_1.body

      refute has_element?(post_live, "#like-component-" <> post_1.id)
      assert has_element?(post_live, "#post-total-likes", "0")

      refute has_element?(post_live, "#tag-component-" <> post_1.id)
      assert has_element?(post_live, "#post-bookmarks-count", "0")
    end
  end
end
