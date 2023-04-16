defmodule InstacampWeb.UserAuthLive.UserResetPassword.New do
  @moduledoc false

  use InstacampWeb, :live_component

  @type socket :: Phoenix.LiveView.Socket.t()

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <section class="w-[95%] bg-white md:w-2/3 xl:w-[40rem] dark:bg-slate-600 dark:text-slate-100 border dark:border-transparent flex flex-col place-items-center mx-auto py-4 md:p-6 rounded-lg -mt-24">
        <h1 class="text-2xl md:text-3xl font-medium">Forgot your password?</h1>
        <p class="text-gray-500 dark:text-slate-300 font-thin text-lg mt-6 text-center px-8">
          No problem! Please enter your email and we will send you a link to reset your password.
        </p>

        <.form
          :let={f}
          for={@changeset}
          id="user-form"
          phx-submit="send_email"
          phx-change="validate_email"
          as={:user}
          class="flex flex-col space-y-4 w-full px-6"
        >
          <div class="md:p-4">
            <div class="flex flex-col py-2">
              <%= label(f, :email, class: "mb-1") %>
              <%= email_input(f, :email,
                phx_debounce: "blur",
                class:
                  "rounded p-2 border-gray-300 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:ring-opacity-90 focus:border-transparent"
              ) %>
              <%= error_tag(f, :email) %>
            </div>

            <div class="py-4">
              <%= if @sent do %>
                <%= submit("Link sent!",
                  class:
                    "block w-full py-2 border-none shadow rounded-full font-semibold text-sm text-gray-50 hover:bg-indigo-500 bg-indigo-400 cursor-pointer"
                ) %>
              <% else %>
                <%= submit("Send reset link",
                  class:
                    "block w-full py-2 border-none shadow rounded-full font-semibold text-sm text-gray-50 hover:bg-indigo-500 bg-indigo-400 cursor-pointer"
                ) %>
              <% end %>
            </div>
          </div>
        </.form>
      </section>

      <section class="w-[95%] bg-white md:w-2/3 xl:w-[40rem] dark:bg-slate-600 dark:text-slate-100 border dark:border-transparent flex flex-col place-items-center mx-auto p-6 rounded-lg my-6">
        <p class="text-base">
          <.link href={~p"/auth/login"} class="font-medium text-indigo-600 hover:text-indigo-400">
            Back to sign in
          </.link>
        </p>
      </section>
    </div>
    """
  end
end
