defmodule InstacampWeb.UserSettings.PassSettingsTest do
  use InstacampWeb.ConnCase, async: true

  import Instacamp.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Instacamp.Accounts
  alias Instacamp.DateTimeHelper

  setup %{conn: conn} do
    user_1 = user_fixture(%{username: "daniel", email: "daniel@gmail.com", full_name: "Daniel"})

    %{conn: log_in_user(conn, user_1), user_1: user_1}
  end

  describe "/accounts/password/change" do
    test "user visits the page and can change password settings", %{conn: conn, user_1: user_1} do
      {:ok, pass_live, html} = live(conn, ~p"/accounts/password/change")

      assert html =~ "New Password"
      assert html =~ "Confirm New Password"
      assert html =~ "Password history"

      assert html =~ "Not changed yet"

      result_attempt_1 =
        pass_live
        |> form("#update-password-form")
        |> render_change(%{
          user: %{
            "password" => "secret12",
            "password_confirmation" => "new valid password"
          }
        })

      assert result_attempt_1 =~ "should be at least 10 character(s)"
      assert result_attempt_1 =~ "does not match password"

      result_attempt_2 =
        pass_live
        |> form("#update-password-form")
        |> render_submit(%{
          user: %{
            password: "new valid password",
            password_confirmation: "new valid password",
            current_password: "4444"
          }
        })

      assert result_attempt_2 =~ "is not valid"

      {:ok, redirect_conn} =
        pass_live
        |> form("#update-password-form")
        |> render_submit(%{
          user: %{
            password: "newValidPassword4444",
            password_confirmation: "newValidPassword4444"
          },
          current_password: "H3llo_world!"
        })
        |> follow_redirect(conn, ~p"/accounts/password/change")

      assert Phoenix.Flash.get(redirect_conn.assigns.flash, :info) =~
               "Password updated successfully."

      updated_user = Accounts.get_user!(user_1.id)

      current_date = NaiveDateTime.to_date(NaiveDateTime.utc_now())
      password_updated_at = NaiveDateTime.to_date(updated_user.settings.password_updated_at)

      assert current_date == password_updated_at

      {:ok, log_in_live, _html} = live(conn, ~p"/auth/login")

      new_password = "newValidPassword4444"

      login_form =
        form(log_in_live, "#log-in-form",
          user: %{email: updated_user.email, password: new_password, remember_me: true}
        )

      conn = submit_form(login_form, conn)

      assert redirected_to(conn) == ~p"/"

      {:ok, _pass_live, pass_html} = live(conn, ~p"/accounts/password/change")

      refute pass_html =~ "Not changed yet"
      assert pass_html =~ "Last changed"

      assert pass_html =~
               DateTimeHelper.format_post_date(
                 password_updated_at,
                 "%-d %b, %Y"
               )
    end
  end
end
