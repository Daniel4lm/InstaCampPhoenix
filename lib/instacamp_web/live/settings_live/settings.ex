defmodule InstacampWeb.SettingsLive.Settings do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.FileHandler
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.SettingsLive.Components.SettingsSidebarComponent

  @type params :: map()
  @type socket :: Phoenix.LiveView.Socket.t()

  @impl Phoenix.LiveView
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/accounts/edit")}
  end

  def mount(_params, _session, socket) do
    user_changeset = Accounts.change_user(socket.assigns.current_user)

    settings_path = ~p"/accounts/edit"
    pass_settings_path = ~p"/accounts/password/change"

    {:ok,
     socket
     |> assign(:user_changeset, user_changeset)
     |> assign(:page_title, "Edit Profile")
     |> assign(:username, socket.assigns.current_user.username)
     |> assign(settings_path: settings_path, pass_settings_path: pass_settings_path)
     |> allow_upload(:avatar_url,
       accept: ~w(.jpg .jpeg .png),
       max_file_size: 9_000_000
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel_image_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar_url, ref)}
  end

  def handle_event("validate_settings", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    user_changeset =
      user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    show_username =
      if Map.has_key?(user_changeset.changes, :username) do
        user_changeset.changes.username
      else
        user.username
      end

    {:noreply,
     socket
     |> assign(:user_changeset, user_changeset)
     |> assign(:username, show_username)}
  end

  def handle_event("update_settings", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user
    # "priv/static/uploads/avatars"
    file_path =
      FileHandler.maybe_upload_image(
        socket,
        "priv/uploads/avatars",
        :avatar_url,
        socket.assigns.current_user.avatar_url
      )

    params_with_avatar =
      if file_path, do: Map.put(user_params, "avatar_url", file_path), else: user_params

    case Accounts.update_user(user, params_with_avatar) do
      {:ok, _updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully!")
         |> redirect(to: socket.assigns.settings_path)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :user_changeset, changeset)}
    end
  end
end
