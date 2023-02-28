defmodule InstacampWeb.UserAuthLive.SettingsTest do
  use InstacampWeb.ConnCase, async: true

  import Instacamp.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Instacamp.Accounts
  alias Instacamp.Repo

  describe "/accounts/edit " do
    setup %{conn: conn} do
      user_1 = user_fixture(%{username: "daniel", email: "daniel@gmail.com", full_name: "Daniel"})

      %{conn: log_in_user(conn, user_1), user_1: user_1}
    end

    test "user visits the page and can change settings", %{conn: conn, user_1: user_1} do
      {:ok, settings_live, html} =
        live(conn, Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))

      assert html =~ user_1.username
      assert html =~ user_1.full_name
      assert html =~ user_1.email

      assert html =~ "Edit Profile"
      assert html =~ "Change Password"

      updated_view =
        settings_live
        |> form("#user-settings-form")
        |> render_change(%{
          user: %{
            username: "Dan",
            email: "daniel4molnargmail.com"
          }
        })

      assert updated_view =~ "Username should be at least 5 character(s)"
      assert updated_view =~ "must have the @ sign and no spaces"

      assert settings_live
             |> form("#user-settings-form",
               user: %{
                 full_name: user_1.full_name,
                 username: user_1.username,
                 location: user_1.location,
                 bio: user_1.bio,
                 email: user_1.email
               }
             )
             |> render_submit(%{
               user: %{
                 username: "daniel4mx",
                 full_name: "Daniel Molnar"
               }
             })
             |> follow_redirect(conn, Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))

      # assert submit_view =~ "User updated successfully"

      updated_user = Accounts.get_user!(user_1.id)

      {:ok, _profile_live, profile_html} =
        live(conn, Routes.user_profile_path(conn, :index, updated_user.username))

      assert profile_html =~ "daniel4mx"
      assert profile_html =~ "Daniel Molnar"
    end

    test "user can upload avatar image", %{conn: conn, user_1: user_1} do
      {:ok, settings_live, _html} =
        live(conn, Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))

      upload = settings_avatar_upload(settings_live, "blog_image.jpg")

      render_upload(upload, "blog_image.jpg")

      settings_live
      |> form("#user-settings-form",
        user: %{
          full_name: user_1.full_name,
          username: user_1.username,
          location: user_1.location,
          bio: user_1.bio,
          email: user_1.email
        }
      )
      |> render_submit()
      |> follow_redirect(conn, Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))

      assert %Accounts.User{} = user = Repo.get(Accounts.User, user_1.id)

      assert user.avatar_url =~ ~r/[a-z0-9\-]+\.jpg/i

      file =
        :instacamp
        |> Application.app_dir("priv/static")
        |> Path.join(user.avatar_url)

      assert File.exists?(file)

      File.rm!(file)
    end

    test "user can cancel post image upload", %{conn: conn} do
      {:ok, settings_live, _html} =
        live(conn, Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))

      settings_live
      |> settings_avatar_upload("blog_image.jpg")
      |> render_upload("blog_image.jpg")

      assert settings_live
             |> element("[name='cancel-image-upload']")
             |> render_click()

      refute has_element?(settings_live, "#blog-image")
    end
  end

  defp settings_avatar_upload(view, filename) do
    file_input(view, "#user-settings-form", :avatar_url, [
      %{
        name: filename,
        content: File.read!("test/support/#{filename}"),
        type: "image/png"
      }
    ])
  end
end
