defmodule InstacampWeb.LiveHooks do
  @moduledoc """
    Live Hooks module

  """
  import Phoenix.LiveView

  alias Instacamp.Accounts
  alias Instacamp.Notifications
  alias InstacampWeb.Components.Navigation.NotificationsComponent
  alias InstacampWeb.Router.Helpers, as: Routes
  alias Phoenix.Ecto.SQL.Sandbox

  @type socket :: Phoenix.LiveView.Socket.t()

  @spec on_mount(atom(), map(), map(), socket()) :: {:cont, socket()} | {:halt, socket()}
  def on_mount(:default, _params, _session, socket) do
    allow_ecto_sandbox(socket)

    {:cont,
     socket
     |> attach_hook(:active_path, :handle_params, &set_active_path/3)
     |> attach_hook(:user_notifications, :handle_info, &handle_user_notifications/2)}
  end

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

  defp allow_ecto_sandbox(socket) do
    %{assigns: %{phoenix_ecto_sandbox: metadata}} =
      assign_new(socket, :phoenix_ecto_sandbox, fn ->
        if connected?(socket), do: get_connect_info(socket, :user_agent)
      end)

    Sandbox.allow(metadata, Application.get_env(:instacamp, :sandbox))
  end

  defp handle_user_notifications({:get_user_notifications, unread_notifications?}, socket) do
    case Notifications.list_user_notifications(socket.assigns.current_user.id) do
      [] ->
        send_update(NotificationsComponent,
          id: "notifications-comp",
          notifications: [],
          while_searching_notifications?: false,
          current_user: socket.assigns.current_user
        )

        {:halt, socket}

      notifications ->
        if unread_notifications? do
          Notifications.read_all(socket.assigns.current_user.id)
        end

        sorted_notifications = Enum.sort_by(notifications, & &1.inserted_at, {:desc, Date})

        send_update(NotificationsComponent,
          id: "notifications-comp",
          notifications: sorted_notifications,
          while_searching_notifications?: false,
          current_user: socket.assigns.current_user
        )

        {:halt, socket}
    end
  end

  defp handle_user_notifications(
         %Phoenix.Socket.Broadcast{
           event: "notify_user",
           payload: %{},
           topic: "user_notification:" <> _user_id
         } = _message,
         socket
       ) do
    send_update(NotificationsComponent,
      id: "notifications-comp",
      current_user: socket.assigns.current_user,
      unread_notifications?: true
    )

    {:halt, socket}
  end

  defp handle_user_notifications(_message, socket) do
    {:cont, socket}
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

  defp set_active_path(_params, url, socket) do
    {:cont, assign(socket, :active_path, URI.parse(url).path)}
  end
end
