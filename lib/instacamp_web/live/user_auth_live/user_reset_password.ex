defmodule InstacampWeb.UserAuthLive.UserResetPassword do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.Accounts.User
  alias InstacampWeb.UserAuthLive.UserResetPassword

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    changeset = Accounts.change_user_email(%User{})

    socket
    |> assign(:changeset, changeset)
    |> assign(:page_title, "Forgot your password?")
    |> assign(:sent, false)
    |> assign(:template, :new)
  end

  defp apply_action(socket, :edit, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      changeset = Accounts.change_user_password(user)

      socket
      |> assign(:changeset, changeset)
      |> assign(:page_title, "Reset Password")
      |> assign(:template, :edit)
      |> assign(:token, token)
      |> assign(:user, user)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
    end
  end

  @impl Phoenix.LiveView
  def render(%{template: :new} = assigns) do
    ~H"""
    <.live_component
      module={UserResetPassword.New}
      id="reset-password-new"
      changeset={assigns[:changeset]}
      sent={@sent}
    />
    """
  end

  def render(%{template: :edit} = assigns) do
    ~H"""
    <.live_component
      module={UserResetPassword.Edit}
      id="reset-password-edit"
      changeset={assigns[:changeset]}
    />
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &Routes.user_reset_password_url(socket, :edit, &1)
      )
    end

    {:noreply, assign(socket, :sent, true)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: Routes.user_auth_login_path(socket, :new))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:action, :validate) |> assign(:changeset, changeset)}
    end
  end
end
