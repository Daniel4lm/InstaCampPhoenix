defmodule InstacampWeb.UserAuthLive.SettingsTest do
  use InstacampWeb.ConnCase, async: true

  import Instacamp.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Instacamp.Accounts
  alias Instacamp.FileHandler
  alias Instacamp.Repo

  setup %{conn: conn} do
    user_1 = user_fixture(%{username: "daniel", email: "daniel@gmail.com", full_name: "Daniel"})

    %{conn: log_in_user(conn, user_1), user_1: user_1}
  end

  describe "/accounts/edit" do
    test "user visits the page and can change settings", %{conn: conn, user_1: user_1} do
      {:ok, settings_live, html} = live(conn, ~p"/accounts/edit")

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
             |> follow_redirect(conn, ~p"/accounts/edit")

      # assert submit_view =~ "User updated successfully"

      updated_user = Accounts.get_user!(user_1.id)

      {:ok, _profile_live, profile_html} =
        live(conn, Routes.user_profile_path(conn, :index, updated_user.username))

      assert profile_html =~ "daniel4mx"
      assert profile_html =~ "Daniel Molnar"
    end

    test "user can upload avatar image", %{conn: conn, user_1: user_1} do
      {:ok, settings_live, _html} = live(conn, ~p"/accounts/edit")

      upload = settings_avatar_upload(settings_live, "test_image.jpg")

      render_upload(upload, "test_image.jpg")

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
      |> follow_redirect(conn, ~p"/accounts/edit")

      assert %Accounts.User{} = user = Repo.get(Accounts.User, user_1.id)

      assert user.avatar_url =~ ~r/[a-z0-9\-]+\.jpg/i

      avatar_file =
        :instacamp
        |> Application.app_dir("priv")
        |> Path.join(user.avatar_url)

      assert File.exists?(avatar_file)

      avatar_thumb_path = FileHandler.get_avatar_thumb(user.avatar_url)

      avatar_thumb_file =
        :instacamp
        |> Application.app_dir("priv")
        |> Path.join(avatar_thumb_path)

      assert File.exists?(avatar_thumb_file)

      File.rm!(avatar_file)
      File.rm!(avatar_thumb_file)
    end

    test "user can cancel post image upload", %{conn: conn} do
      {:ok, settings_live, _html} = live(conn, ~p"/accounts/edit")

      settings_live
      |> settings_avatar_upload("test_image.jpg")
      |> render_upload("test_image.jpg")

      assert settings_live
             |> element("[name='cancel-image-upload']")
             |> render_click()

      refute has_element?(settings_live, "#blog-image")
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{conn: log_in_user(conn, user), token: token, email: email, user: user}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/auth/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/edit"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      # use confirm token again
      {:error, second_redirect} = live(conn, ~p"/auth/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = second_redirect
      assert path == ~p"/accounts/edit"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      {:error, redirect} = live(conn, ~p"/auth/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/edit"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/auth/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: _flash}} = redirect
      assert path == ~p"/auth/login"
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
