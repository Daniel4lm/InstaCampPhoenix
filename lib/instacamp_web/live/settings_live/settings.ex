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
  def mount(_params, _session, socket) do
    user_changeset = Accounts.change_user(socket.assigns.current_user)

    settings_path = Routes.live_path(socket, __MODULE__)
    pass_settings_path = Routes.live_path(socket, InstacampWeb.SettingsLive.PassSettings)

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

    file_path =
      FileHandler.maybe_upload_image(
        socket,
        "/uploads/avatars",
        "priv/static/uploads/avatars",
        :avatar_url
      )

    params_with_avatar =
      if file_path, do: Map.put(user_params, "avatar_url", file_path), else: user_params

    case Accounts.update_user(user, params_with_avatar) do
      {:ok, _updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully!")
         |> redirect(to: Routes.live_path(socket, InstacampWeb.SettingsLive.Settings))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :user_changeset, changeset)}
    end
  end
end
