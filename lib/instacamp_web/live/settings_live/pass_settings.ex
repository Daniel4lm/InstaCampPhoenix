defmodule InstacampWeb.SettingsLive.PassSettings do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.DateTimeHelper
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.SettingsLive.Components.SettingsSidebarComponent
  alias Phoenix.LiveView.JS

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    password_changeset = Accounts.change_user_password(current_user)

    pass_settings_path = Routes.live_path(socket, __MODULE__)
    settings_path = Routes.live_path(socket, InstacampWeb.SettingsLive.Settings)

    {:ok,
     socket
     |> assign(:password_changeset, password_changeset)
     |> assign(:page_title, "Change user password")
     |> assign(:password_updated_at, current_user.settings.password_updated_at)
     |> assign(settings_path: settings_path, pass_settings_path: pass_settings_path)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_password", params, socket) do
    %{"current_password" => _password, "user" => user_params} = params

    user = socket.assigns.current_user

    password_changeset =
      user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, password_changeset: password_changeset)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    pass_updated_at = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    updated_user_params =
      Map.put(user_params, "settings", %{"password_updated_at" => pass_updated_at})

    case Accounts.update_user_password(user, password, updated_user_params) do
      {:ok, _updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully.")
         |> redirect(to: socket.assigns.pass_settings_path)}

      {:error, changeset} ->
        {:noreply, assign(socket, :password_changeset, changeset)}
    end
  end
end
