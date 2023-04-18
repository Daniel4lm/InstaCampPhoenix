defmodule InstacampWeb.UserAuthLive.UserSignUp do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.Accounts.User
  alias InstacampWeb.Components.Icons

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <section class="w-[95%] md:w-2/3 xl:w-[40rem] bg-white dark:bg-slate-600 dark:text-slate-100 border dark:border-transparent flex flex-col place-items-center mx-auto p-4 md:p-6 rounded-lg -mt-24">
      <h1 class="text-2xl md:text-3xl font-medium text-center">
        Sign up to see post and videos from your friends
      </h1>

      <.form
        :let={f}
        for={@changeset}
        id="user-sign-up-form"
        phx-change="validate"
        phx-submit="sign_up"
        as={:user}
        class="flex flex-col space-y-4 w-full md:px-6 text-sm md:text-base"
      >
        <div class="md:p-4">
          <div class="flex flex-col py-2">
            <%= label(f, :email, class: "mb-1") %>
            <%= email_input(f, :email,
              phx_debounce: "blur",
              autocomplete: "off",
              class:
                "rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
            ) %>
            <%= error_tag(f, :email) %>
          </div>

          <div class="flex flex-col py-2">
            <%= label(f, :full_name, class: "mb-1") %>
            <%= text_input(f, :full_name,
              phx_debounce: "blur",
              autocomplete: "off",
              class:
                "rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
            ) %>
            <%= error_tag(f, :full_name) %>
          </div>

          <div class="flex flex-col py-2">
            <%= label(f, :username, class: "mb-1") %>
            <%= text_input(f, :username,
              phx_debounce: "blur",
              autocomplete: "off",
              class:
                "rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
            ) %>
            <%= error_tag(f, :username) %>
          </div>

          <div class="flex flex-col py-2">
            <%= label(f, :location, class: "mb-1") %>
            <%= text_input(f, :location,
              phx_debounce: "blur",
              autocomplete: "off",
              class:
                "rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
            ) %>
            <%= error_tag(f, :location) %>
          </div>

          <div class="flex flex-col py-2">
            <%= label(f, :password, class: "mb-1") %>
            <div class="relative w-full">
              <%= password_input(f, :password,
                value: input_value(f, :password),
                phx_debounce: "blur",
                autocomplete: "off",
                class:
                  "w-full rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
              ) %>
              <div
                class="absolute w-6 h-6 top-1/2 right-2 -translate-y-1/2 text-gray-400 cursor-pointer"
                id="user-registration-show-password"
                phx-hook="InputShowPassword"
                data-input-id={input_id(f, :password)}
              >
                <div id="show-password-icon">
                  <Icons.hidden_icon id={input_id(f, :password)} />
                </div>
              </div>
            </div>
            <%= error_tag(f, :password) %>
          </div>

          <div class="py-6">
            <%= submit("Sign up",
              phx_disable_with: "Saving...",
              class:
                "block px-8 w-full py-2 md:w-max border-none shadow rounded-full font-semibold text-gray-50 hover:bg-indigo-500 bg-indigo-400 cursor-pointer"
            ) %>
          </div>
        </div>
      </.form>

      <p class="text-sm md:px-10 text-center mt-4 text-gray-400 font-thin">
        By signing up, you agree to our Terms , Data Policy and Cookies Policy .
      </p>
    </section>

    <section class="w-[95%] md:w-2/3 xl:w-[40rem] bg-white dark:bg-slate-600 dark:text-slate-100 border dark:border-transparent flex flex-col place-items-center mx-auto p-6 rounded-lg my-6">
      <p class="text-base">
        Have an account?
        <.link href={~p"/auth/login"} class="font-medium text-indigo-600 hover:text-indigo-400">
          Log in
        </.link>
      </p>
    </section>
    """
  end

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
    case Accounts.register_user(user_params) do
      {:ok, %User{} = new_user} ->
        {:ok, _response_body} =
          Accounts.deliver_user_confirmation_instructions(new_user, &url(~p"/auth/confirm/#{&1}"))

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Welcome #{new_user.full_name}. Your account is created successfully!"
         )
         |> redirect(to: ~p"/auth/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid user params!")
         |> assign(:changeset, changeset)}
    end
  end

  # def mount(_params, _session, socket) do
  #   changeset = Accounts.change_user_registration(%User{})

  #   socket =
  #     socket
  #     |> assign(trigger_submit: false, check_errors: false)
  #     |> assign(:page_title, "Sign up")
  #     |> assign_form(changeset)

  #   {:ok, socket, temporary_assigns: [form: nil]}
  # end

  # def handle_event("save", %{"user" => user_params}, socket) do
  #   case Accounts.register_user(user_params) do
  #     {:ok, user} ->
  #       {:ok, _} =
  #         Accounts.deliver_user_confirmation_instructions(
  #           user,
  #           &url(~p"/auth/confirm/#{&1}")
  #         )

  #       changeset = Accounts.change_user_registration(user)
  #       {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
  #   end
  # end

  # def handle_event("validate", %{"user" => user_params}, socket) do
  #   changeset = Accounts.change_user_registration(%User{}, user_params)
  #   {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  # end

  # defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #   form = to_form(changeset, as: "user")

  #   if changeset.valid? do
  #     assign(socket, form: form, check_errors: false)
  #   else
  #     assign(socket, form: form)
  #   end
  # end
end
