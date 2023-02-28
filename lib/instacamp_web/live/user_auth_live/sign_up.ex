defmodule InstacampWeb.UserAuthLive.SignUp do
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
     |> assign(:page_title, "Sign up")}
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
      |> Accounts.change_user_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: user_changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("sign_up", %{"user" => user_params}, socket) do
    with true <- socket.assigns.changeset.valid?,
         {:ok, %User{} = new_user} <- Accounts.register_user(user_params) do
      {:ok, _response_body} =
        Accounts.deliver_user_confirmation_instructions(
          new_user,
          &Routes.user_confirmation_url(socket, :edit, &1)
        )

      {:noreply,
       socket
       |> put_flash(:info, "Welcome #{new_user.full_name}. Your account is created successfully!")
       |> redirect(to: Routes.user_auth_login_path(socket, :new))}
    else
      false ->
        {:noreply, put_flash(socket, :error, "Invalid user params!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
