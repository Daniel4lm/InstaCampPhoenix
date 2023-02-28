defmodule InstacampWeb.LiveAuth do
  @moduledoc """
    Auth Live module

    Implements on_mount/4 callback functions, that
    checks 'user_token' presence in cookie session. If 'user_token' is present
    then it try to fetch user by this token from db.
    If user is found, the socket will be populated with :current_user
    assignment and allow the user to access this path.

    Otherwise it redirets user to the landing page.

  """
  import Phoenix.LiveView

  alias Instacamp.Accounts
  alias InstacampWeb.Router.Helpers, as: Routes

  @type socket :: Phoenix.LiveView.Socket.t()

  @spec on_mount(atom(), map(), map(), socket()) :: {:cont, socket()} | {:halt, socket()}
  def on_mount(:assign_user, _params, session, socket) do
    socket = maybe_assign_user(socket, session)

    {:cont, socket}
  end

  def on_mount(:ensure_authentication, _params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        {:halt,
         socket
         |> put_flash(:info, "You must log in to access this page.")
         |> redirect(to: Routes.user_auth_sign_up_path(socket, :new))}

      %Accounts.User{} ->
        {:cont, socket}
    end
  end

  defp maybe_assign_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
        end)

      _no_token ->
        assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
