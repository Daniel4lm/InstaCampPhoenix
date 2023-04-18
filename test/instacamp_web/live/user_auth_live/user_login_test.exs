defmodule InstacampWeb.UserAuthLive.UserLoginTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup [:create_user]

  describe "/user login" do
    test "renders sign in page", %{conn: conn} do
      {:ok, login_live, html} = live(conn, ~p"/auth/login")

      assert html =~ "Instacamp · Log in</title>"
      assert html =~ "Log in form"
      assert html =~ "Forgot password?</a>"

      assert page_title(login_live) =~ "Instacamp · Log in"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(~p"/auth/login")
      assert redirected_to(conn) == "/"
    end

    test "user enters the log in form", %{conn: conn} do
      {:ok, log_in_live, _html} = live(conn, ~p"/auth/login")

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
