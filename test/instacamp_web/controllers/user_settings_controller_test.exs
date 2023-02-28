defmodule InstacampWeb.UserSettingsControllerTest do
  use InstacampWeb.ConnCase, async: true

  import Instacamp.AccountsFixtures

  alias Instacamp.Accounts

  setup :register_and_log_in_user

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.live_path(conn, InstacampWeb.SettingsLive.Settings)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      updated_conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))

      assert redirected_to(updated_conn) ==
               Routes.live_path(updated_conn, InstacampWeb.SettingsLive.Settings)

      assert get_flash(updated_conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.live_path(conn, InstacampWeb.SettingsLive.Settings)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      updated_conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(updated_conn) == Routes.user_auth_login_path(updated_conn, :new)
    end
  end
end
