defmodule InstacampWeb.HomeLive do
  @moduledoc false

  use InstacampWeb, :live_view

  alias InstacampWeb.Components.CommingSoon
  alias InstacampWeb.Endpoint
  alias InstacampWeb.PostTopicHelper

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        {:ok, redirect(socket, to: Routes.user_auth_login_path(socket, :new))}

      user ->
        if connected?(socket) do
          :ok =
            user.id
            |> PostTopicHelper.user_notification_topic()
            |> Endpoint.subscribe()
        end

        {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
