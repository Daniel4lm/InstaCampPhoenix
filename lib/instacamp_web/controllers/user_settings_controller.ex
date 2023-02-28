defmodule InstacampWeb.UserSettingsController do
  use InstacampWeb, :controller

  alias Instacamp.Accounts

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.live_path(conn, InstacampWeb.SettingsLive.Settings))
    end
  end
end
