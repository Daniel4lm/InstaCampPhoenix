defmodule InstacampWeb.UserAuthLive.UserProfileTest do
  use InstacampWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Instacamp.Accounts

  describe "/user/:username" do
    setup [:setup_for_user_profile_and_post]

    test "user visits someones else's profile page", %{conn: conn, user_2: user_2, post_2: post_2} do
      {:ok, profile_live, html} =
        live(conn, Routes.user_profile_path(conn, :index, user_2.username))

      assert html =~ user_2.full_name
      assert html =~ user_2.location
      refute html =~ "Edit Profile"
      assert html =~ "Follow"
      assert has_element?(profile_live, "#follow-component")

      assert html =~ "<span>Posts <b>1</b></span>"
      assert html =~ "<span>Comments <b>0</b></span>"
      assert html =~ "<span>Followers <b>0</b></span>"
      assert html =~ "<span>Following <b>0</b></span>"

      assert has_element?(profile_live, "#post-card-" <> post_2.id)
      assert html =~ post_2.title
    end

    test "user visits his own profile page", %{
      conn: conn,
      user_1: user_1,
      user_2: user_2,
      post_1: post_1
    } do
      {:ok, profile_live, html} =
        live(conn, Routes.user_profile_path(conn, :index, user_1.username))

      assert html =~ user_1.username
      assert html =~ user_1.full_name
      assert html =~ "Edit Profile"
      refute has_element?(profile_live, "#follow-component")

      assert html =~ "<span>Posts <b>1</b></span>"
      assert html =~ "<span>Comments <b>0</b></span>"
      assert html =~ "<span>Followers <b>0</b></span>"
      assert html =~ "<span>Following <b>0</b></span>"

      assert has_element?(profile_live, "#post-card-" <> post_1.id)
      assert html =~ post_1.title

      _followed_user = Accounts.create_follow(user_1, user_2, user_1)

      {:ok, second_profile_live, second_html} =
        live(conn, Routes.user_profile_path(conn, :index, user_1.username))

      assert second_html =~ user_1.username
      refute has_element?(second_profile_live, "#follow-component")

      assert second_html =~ "<span>Posts <b>1</b></span>"
      assert second_html =~ "<span>Following <b>1</b></span>"

      {:ok, user_1_following_live, user_1_following_html} =
        live(conn, Routes.user_profile_path(conn, :following, user_1.username))

      assert has_element?(user_1_following_live, "#follow-list-title", "Following")
      assert user_1_following_html =~ user_2.username
      assert user_1_following_html =~ user_2.full_name
      assert user_1_following_html =~ "Unfollow"

      {:ok, _user_2_profile_live, user_2_html} =
        live(conn, Routes.user_profile_path(conn, :index, user_2.username))

      assert user_2_html =~ "<span>Followers <b>1</b></span>"
      assert user_2_html =~ "<span>Following <b>0</b></span>"

      {:ok, user_2_following_live, user_2_following_html} =
        live(conn, Routes.user_profile_path(conn, :followers, user_2.username))

      assert has_element?(user_2_following_live, "#follow-list-title", "Followers")
      assert user_2_following_html =~ user_1.username
      assert user_2_following_html =~ user_1.full_name
      assert user_2_following_html =~ "Unfollow"
    end
  end
end
