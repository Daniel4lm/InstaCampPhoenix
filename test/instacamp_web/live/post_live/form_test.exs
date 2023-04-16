defmodule InstacampWeb.PostLive.FormTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Posts
  alias Instacamp.Repo

  describe "/new/post - no auth" do
    test "user can't visit the post form", %{conn: conn} do
      assert {:error, {:redirect, %{flash: %{}, to: "/auth/login"}}} =
               live(conn, Routes.post_form_path(conn, :new))
    end
  end

  describe "create/edit post - with auth" do
    setup %{conn: conn} do
      user = user_fixture(%{username: "daniel", email: "daniel@gmail.com", full_name: "Daniel"})

      post_1 = blog_post_fixture(user, :new)

      %{
        conn: log_in_user(conn, user),
        user: user,
        post_1: post_1
      }
    end

    test "user visits the form but cannot create a new post", %{conn: conn} do
      {:ok, form_live, html} = live(conn, Routes.post_form_path(conn, :new))

      assert html =~ "New blog post"

      assert form_live
             |> form("#post-new-form", post: %{title: "Post title"})
             |> render_change(%{
               post: %{
                 body: nil
               }
             }) =~ "can&#39;t be blank"

      assert form_live
             |> form("#post-new-form", post: %{title: "Post title"})
             |> render_change(%{
               post: %{
                 body: "Some text here"
               }
             }) =~ "Message body should be at least 50 character(s)"
    end

    test "user successfully create a new post", %{conn: conn, user: user} do
      {:ok, form_live, _html} = live(conn, Routes.post_form_path(conn, :new))

      {:ok, _live, html} =
        form_live
        |> form("#post-new-form", post: %{title: "Elixir post"})
        |> render_submit(%{
          post: %{
            body:
              "Blog post with some text about development with Elixir and the Phoenix Framework"
          }
        })
        |> follow_redirect(conn, Routes.user_profile_path(conn, :index, user.username))

      assert html =~ "Elixir post"
    end

    test "user updates the post", %{
      conn: conn,
      user: user,
      post_1: post_1
    } do
      {:ok, form_live, html} = live(conn, Routes.post_form_path(conn, :edit, post_1))

      assert html =~ "Edit blog post"

      assert has_element?(form_live, "#post-topic-elixir", "#elixir")
      assert has_element?(form_live, "#post-topic-dev", "#dev")
      assert has_element?(form_live, "#remove-topic-dev")

      _updated_html = render_click(element(form_live, "#remove-topic-dev"))
      refute form_live |> element("#post-topic-dev", "#dev") |> has_element?()
      refute form_live |> element("#remove-topic-dev") |> has_element?()

      {:ok, _live, _form_html} =
        form_live
        |> form("#post-new-form", post: %{})
        |> render_submit(%{
          post: %{
            body:
              "This morning the view from the window was beautiful. A little heavier snow fell, but soon it started to melt and caused many troubles on the streets."
          }
        })
        |> follow_redirect(conn, Routes.user_profile_path(conn, :index, user.username))
    end

    test "user can upload post image", %{conn: conn, user: user} do
      {:ok, form_live, _html} = live(conn, Routes.post_form_path(conn, :new))

      upload = test_image_upload(form_live, "test_image.jpg")

      render_upload(upload, "test_image.jpg")

      {:ok, _live, html} =
        form_live
        |> form("#post-new-form",
          post_photo_url: upload,
          post: %{title: "Second post"}
        )
        |> render_submit(%{
          post: %{
            body:
              "Blog post with some text about development with Elixir and the Phoenix Framework"
          }
        })
        |> follow_redirect(conn, Routes.user_profile_path(conn, :index, user.username))

      # assert html =~ "Blog post created successfully"
      assert html =~ "Second post"

      assert %Posts.Post{} = post = Repo.get_by!(Posts.Post, title: "Second post")

      assert post.photo_url =~ ~r/[a-z0-9\-]+\.jpg/i

      file =
        :instacamp
        |> Application.app_dir("priv")
        |> Path.join(post.photo_url)

      assert File.exists?(file)

      File.rm!(file)
    end

    test "user can cancel post image upload", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, Routes.post_form_path(conn, :new))

      form_live
      |> test_image_upload("test_image.jpg")
      |> render_upload("test_image.jpg")

      assert form_live
             |> element("[name='cancel-image-upload']")
             |> render_click()

      refute has_element?(form_live, "#blog-image")
    end
  end

  defp test_image_upload(view, filename) do
    file_input(view, "#post-new-form", :post_photo_url, [
      %{
        name: filename,
        content: File.read!("test/support/#{filename}"),
        type: "image/png"
      }
    ])
  end
end
