defmodule InstacampWeb.LiveHooksTest do
  use InstacampWeb.ConnCase, async: true

  import Instacamp.AccountsFixtures

  alias Instacamp.Accounts
  alias Instacamp.Repo
  alias InstacampWeb.LiveHooks
  alias Phoenix.LiveView

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, InstacampWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "on_mount: :assign_user" do
    test "assigns current_user based on a valid user_token ", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} = LiveHooks.on_mount(:assign_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user.id == user.id
    end

    test "assigns nil to current_user assign if there isn't a valid user_token ", %{conn: conn} do
      user_token = "invalid_token"
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} = LiveHooks.on_mount(:assign_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user == nil
    end

    test "assigns nil to current_user assign if there isn't a user_token", %{conn: conn} do
      session = get_session(conn)

      {:cont, updated_socket} = LiveHooks.on_mount(:assign_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user == nil
    end
  end

  describe "on_mount: :assign_theme_mode" do
    test "assigns theme_mode based on the current_user", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} =
        LiveHooks.on_mount(:assign_theme_mode, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.theme_mode == :light

      user = Repo.get(Accounts.User, user.id)

      {:ok, updated_user} =
        Accounts.update_user(user, %{
          settings: %{
            theme_mode: :dark
          }
        })

      {:cont, updated_socket_with_user} =
        LiveHooks.on_mount(:assign_theme_mode, %{}, session, %LiveView.Socket{})

      assert updated_socket_with_user.assigns.theme_mode == :dark
      assert updated_socket_with_user.assigns.theme_mode == updated_user.settings.theme_mode
    end

    test "assigns light to theme_mode assign if there is no current_user", %{conn: conn} do
      user_token = "invalid_token"
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} =
        LiveHooks.on_mount(:assign_theme_mode, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.theme_mode == :light
    end
  end

  describe "on_mount: :ensure_authentication" do
    test "authenticates current_user based on a valid user_token ", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      {:cont, updated_socket} =
        LiveHooks.on_mount(:ensure_authentication, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_user.id == user.id
    end

    test "redirects to login page if there isn't a valid user_token ", %{conn: conn} do
      user_token = "invalid_token"
      session = conn |> put_session(:user_token, user_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: RentoWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = LiveHooks.on_mount(:ensure_authentication, %{}, session, socket)

      assert updated_socket.assigns.current_user == nil
    end

    test "redirects to login page if there isn't a user_token ", %{conn: conn} do
      session = get_session(conn)

      socket = %LiveView.Socket{
        endpoint: RentoWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = LiveHooks.on_mount(:ensure_authentication, %{}, session, socket)

      assert updated_socket.assigns.current_user == nil
    end
  end

  describe "on_mount: :redirect_if_user_is_authenticated" do
    test "redirects if there is an authenticated user", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      session = conn |> put_session(:user_token, user_token) |> get_session()

      assert {:halt, _updated_socket} =
               LiveHooks.on_mount(
                 :redirect_if_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "Don't redirect is there is no authenticated user", %{conn: conn} do
      session = get_session(conn)

      assert {:cont, _updated_socket} =
               LiveHooks.on_mount(
                 :redirect_if_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end
end
