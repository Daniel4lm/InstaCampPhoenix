defmodule InstacampWeb.UserAuthLive.UserLoginTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup [:create_user]

  describe "/user login" do
    test "renders sign in page", %{conn: conn} do
      {:ok, _live, html} = live(conn, Routes.user_auth_login_path(conn, :new))

      assert html =~ "Instacamp · Log in</title>"
      assert html =~ "Log in form"
      assert html =~ "Forgot password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.user_auth_login_path(conn, :new))
      assert redirected_to(conn) == "/"
    end

    test "user enters the log in form", %{conn: conn} do
      {:ok, log_in_live, _html} = live(conn, Routes.user_auth_login_path(conn, :new))

      assert log_in_live
             |> form("#log-in-form", user: %{})
             |> render_change() =~ "Email can&#39;t be blank"

      refute log_in_live
             |> form("#log-in-form",
               user: %{
                 password: "**********",
                 email: "daniel_4@gmail.com"
               }
             )
             |> render_change() =~ "Email can&#39;t be blank"
    end
  end
end
