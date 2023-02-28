defmodule InstacampWeb.UserAuthLive.Login do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.Accounts.User

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user_changeset = Accounts.change_user_registration(%User{})

    {:ok,
     socket
     |> assign(:changeset, user_changeset)
     |> assign(:trigger_submit, false)
     |> assign(:page_title, "Log in")}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, fill_form(socket, socket.assigns.live_action, params)}
  end

  defp fill_form(socket, :new, params) do
    user_params = %{email: params["email"], password: params["password"]}
    user_changeset = Accounts.change_user_registration(%User{}, user_params)
    assign(socket, :changeset, user_changeset)
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"user" => user_params}, socket) do
    user_changeset =
      %User{}
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: user_changeset)}
  end
end
