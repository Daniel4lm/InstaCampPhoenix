defmodule InstacampWeb.UserAuthLive.UserLogin do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.Accounts.User
  alias InstacampWeb.Components.Icons

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <section class="w-[95%] md:w-2/3 xl:w-[40rem] bg-white dark:bg-slate-600 dark:text-slate-100 border dark:border-0 flex flex-col place-items-center mx-auto py-4 md:p-6 rounded-lg -mt-24">
      <h1 class="text-2xl md:text-3xl font-medium">Log in form</h1>

      <.form
        :let={f}
        for={@changeset}
        id="log-in-form"
        action={~p"/auth/login"}
        phx-trigger-action={@trigger_submit}
        phx-change="validate"
        as={:user}
        class="flex flex-col space-y-4 w-full md:px-6 text-sm md:text-base"
      >
        <div class="p-4">
          <div class="flex flex-col py-2">
            <%= label(f, :email, class: " mb-1") %>
            <%= email_input(f, :email,
              phx_debounce: "blur",
              autocomplete: "off",
              class:
                "rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
            ) %>
            <%= error_tag(f, :email) %>
          </div>

          <div class="flex flex-col py-2">
            <%= label(f, :password, class: " mb-1") %>
            <div class="relative w-full">
              <%= password_input(f, :password,
                value: input_value(f, :password),
                phx_debounce: "blur",
                autocomplete: "off",
                class:
                  "w-full rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm focus:ring-2 focus:ring-indigo-500 dark:focus:border-transparent dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent"
              ) %>
              <div
                class="absolute w-5 h-max top-1/2 right-2 -translate-y-1/2 text-gray-400 cursor-pointer"
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

          <div class="flex items-center gap-2 py-2">
            <%= label(f, :remember_me, "Keep me logged in for 60 days", class: "") %>
            <%= checkbox(f, :remember_me,
              class:
                "rounded p-2 border-gray-300 shadow-sm text-sm md:text-base focus:ring-2 focus:ring-indigo-500 focus:ring-opacity-90 focus:border-transparent"
            ) %>
          </div>

          <div class="py-6">
            <%= submit("Log In",
              phx_disable_with: "Logging In...",
              class:
                "block px-8 w-full py-2 md:w-max border-none shadow rounded-full font-semibold text-sm text-gray-50 hover:bg-indigo-500 bg-indigo-400 cursor-pointer"
            ) %>
          </div>
        </div>
      </.form>

      <p class="text-md px-10 text-center mt-4 text-indigo-600 hover:text-indigo-400">
        <.link href={~p"/auth/reset-password"}>Forgot password?</.link>
      </p>
    </section>

    <section class="w-[95%] md:w-2/3 xl:w-[40rem] bg-white dark:bg-slate-600 dark:text-slate-100 border dark:border-transparent flex flex-col place-items-center mx-auto p-6 rounded-lg my-6">
      <p class="text-base">
        Don't have an account?
        <.link href={~p"/auth/signup"} class="font-medium text-indigo-600 hover:text-indigo-400">
          Sign up
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
