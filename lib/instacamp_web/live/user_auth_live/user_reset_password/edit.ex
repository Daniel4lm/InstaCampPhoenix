defmodule InstacampWeb.UserAuthLive.UserResetPassword.Edit do
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
      <section class="w-[90%] bg-white md:w-2/3 xl:w-[40rem] border flex flex-col place-items-center mx-auto p-6 rounded-lg mt-8">
        <h1 class="text-3xl font-semibold text-gray-700">Reset Password</h1>
        <.form
          let={f}
          for={@changeset}
          id="user-change-pass-form"
          phx-submit="save"
          as={:user}
          class="flex flex-col space-y-4 w-full px-6"
        >
          <div class="p-4">
            <div class="flex flex-col py-2">
              <%= label(f, :password, class: "text-gray-400 mb-1") %>
              <%= password_input(f, :password,
                phx_debounce: "blur",
                class:
                  "rounded p-2 border-gray-300 shadow-sm focus:ring-2 focus:ring-light-blue-500 focus:ring-opacity-90 focus:border-transparent"
              ) %>
              <%= error_tag(f, :password) %>
            </div>

            <%= if Keyword.has_key?(f.errors, :password) do %>
              <div class=" text-red h-full py-4 ml-16 pr-2 font-sohne-leicht font-sm">
                Password does not match criteria
              </div>
            <% end %>

            <div class="flex flex-col py-2">
              <%= label(f, :password_confirmation, class: "text-gray-400 mb-1") %>
              <%= password_input(f, :password_confirmation,
                phx_debounce: "blur",
                class:
                  "rounded p-2 border-gray-300 shadow-sm focus:ring-2 focus:ring-light-blue-500 focus:ring-opacity-90 focus:border-transparent"
              ) %>
              <%= error_tag(f, :password_confirmation) %>
            </div>

            <div class="py-4">
              <%= submit("Reset my password",
                phx_disable_with: "Saving...",
                class:
                  "block w-full py-2 border-none shadow rounded font-semibold text-sm text-gray-50 hover:bg-light-blue-600 bg-light-blue-500 cursor-pointer"
              ) %>
            </div>
          </div>
        </.form>

        <p class="text-sm px-10 text-center mt-4 text-gray-400 font-semibold">
          By signing up, you agree to our Terms , Data Policy and Cookies Policy .
        </p>
      </section>

      <section class="w-[90%] bg-white md:w-2/3 xl:w-[40rem] border flex flex-col place-items-center mx-auto p-6 rounded-lg my-6">
        <p class="text-lg text-gray-600">
          <%= live_redirect("Register",
            to: Routes.user_auth_sign_up_path(@socket, :new),
            class: "text-light-blue-500 font-semibold"
          ) %>
        </p>
        |
        <p class="text-lg text-gray-600">
          <%= live_redirect("Log in",
            to: Routes.user_auth_login_path(@socket, :new),
            class: "text-light-blue-500 font-semibold"
          ) %>
        </p>
      </section>
    </div>
    """
  end
end
