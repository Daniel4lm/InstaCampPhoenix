defmodule InstacampWeb.UserAuthLive.UserRegistrationTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Instacamp.Accounts
  alias Instacamp.Repo

  describe "/signup" do
    test "renders sign up page", %{conn: conn} do
      {:ok, sign_up_live, html} = live(conn, ~p"/auth/signup")

      assert html =~ "Instacamp · Sign up</title>"
      assert page_title(sign_up_live) =~ "Instacamp · Sign up"
      assert html =~ "Sign up to see post and videos from your friends"
      assert html =~ "Have an account?"
      refute has_element?(sign_up_live, "#posts-search-input")
      refute has_element?(sign_up_live, "#new-post")
    end

    test "cannot register a user", %{conn: conn} do
      {:ok, sign_up_live, _html} = live(conn, ~p"/auth/signup")

      fail_sign_up_live =
        form(sign_up_live, "#user-sign-up-form", user: %{username: "da", full_name: "da"})

      assert render_change(fail_sign_up_live) =~ "Email can&#39;t be blank"
      assert render_change(fail_sign_up_live) =~ "Username should be at least 5 character(s)"
      assert render_change(fail_sign_up_live) =~ "Full name should be at least 4 character(s)"
    end

    test "registers user and sends confirmation email", %{conn: conn} do
      {:ok, sign_up_live, _html} = live(conn, ~p"/auth/signup")

      {:ok, conn} =
        sign_up_live
        |> form("#user-sign-up-form",
          user: %{
            full_name: "John Doe",
            username: "john_doe",
            location: "",
            email: "john@doe.com",
            password: "Valid_password"
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Welcome John Doe. Your account is created successfully!"

      response = html_response(conn, 200)
      assert response =~ "Log in form"
      assert response =~ "Don't have an account?"

      assert user = Accounts.get_user_by_email_and_password("john@doe.com", "Valid_password")
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end
  end
end
