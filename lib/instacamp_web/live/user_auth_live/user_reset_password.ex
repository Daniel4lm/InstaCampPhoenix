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
      |> redirect(to: ~p"/")
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
        &url(~p"/auth/reset-password/#{&1}")
      )
    end

    {:noreply, assign(socket, :sent, true)}
  end

  def handle_event("validate_email", %{"user" => %{"email" => email}}, socket) do
    email_changeset =
      %User{}
      |> Accounts.change_user_email(%{"email" => email})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: email_changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    pass_updated_at = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    updated_user_params =
      Map.put(user_params, "settings", %{"password_updated_at" => pass_updated_at})

    case Accounts.reset_user_password(socket.assigns.user, updated_user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/auth/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:action, :validate) |> assign(:changeset, changeset)}
    end
  end

  # def handle_event("validate", %{"user" => user_params}, socket) do
  #   changeset = Accounts.change_user_password(socket.assigns.user, user_params)
  #   {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :validate))}
  # end

  # def render(assigns) do
  #   ~H"""
  #   <div class="mx-auto max-w-sm">
  #     <.header class="text-center">Reset Password</.header>

  #     <.simple_form
  #       for={@form}
  #       id="reset_password_form"
  #       phx-submit="reset_password"
  #       phx-change="validate"
  #     >
  #       <.error :if={@form.errors != []}>
  #         Oops, something went wrong! Please check the errors below.
  #       </.error>

  #       <.input field={@form[:password]} type="password" label="New password" required />
  #       <.input
  #         field={@form[:password_confirmation]}
  #         type="password"
  #         label="Confirm new password"
  #         required
  #       />
  #       <:actions>
  #         <.button phx-disable-with="Resetting..." class="w-full">Reset Password</.button>
  #       </:actions>
  #     </.simple_form>

  #     <p class="text-center text-sm mt-4">
  #       <.link href={~p"/auth/signup"}>Register</.link>
  #       | <.link href={~p"/auth/login"}>Log in</.link>
  #     </p>
  #   </div>
  #   """
  # end

  # def mount(params, _session, socket) do
  #   socket = assign_user_and_token(socket, params)

  #   form_source =
  #     case socket.assigns do
  #       %{user: user} ->
  #         Accounts.change_user_password(user)

  #       _ ->
  #         %{}
  #     end

  #   {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  # end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  # def handle_event("reset_password", %{"user" => user_params}, socket) do
  #   case Accounts.reset_user_password(socket.assigns.user, user_params) do
  #     {:ok, _} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Password reset successfully.")
  #        |> redirect(to: ~p"/auth/login")}

  #     {:error, changeset} ->
  #       {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
  #   end
  # end

  # def handle_event("validate", %{"user" => user_params}, socket) do
  #   changeset = Accounts.change_user_password(socket.assigns.user, user_params)
  #   {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  # end

  # defp assign_user_and_token(socket, %{"token" => token}) do
  #   if user = Accounts.get_user_by_reset_password_token(token) do
  #     assign(socket, user: user, token: token)
  #   else
  #     socket
  #     |> put_flash(:error, "Reset password link is invalid or it has expired.")
  #     |> redirect(to: ~p"/")
  #   end
  # end

  # defp assign_form(socket, %{} = source) do
  #   assign(socket, :form, to_form(source, as: "user"))
  # end
end
