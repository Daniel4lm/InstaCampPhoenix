defmodule InstacampWeb.Components.Navigation.Navbar do
  @moduledoc false

  use InstacampWeb, :component

  alias InstacampWeb.Components.DarkMode.Switch
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Navigation.NavbarFormCompoent
  alias InstacampWeb.Components.Navigation.NotificationsComponent
  alias InstacampWeb.Components.Navigation.SettingsMenu

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @spec app_navbar(assigns()) :: render()
  def app_navbar(assigns) do
    ~H"""
    <header class="relative h-14 border-b dark:border-transparent flex fixed top-0 w-full bg-white dark:bg-slate-600 dark:text-text-slate-100 z-50">
      <div class="flex justify-between md:justify-center items-center container mx-auto max-w-full md:w-11/12 2xl:w-8/12">
        <.nav_link
          active_path={@active_path}
          current_path="/"
          link_path={Routes.live_path(@socket, InstacampWeb.HomeLive)}
        >
          <h1 class="text-xl md:text-2xl font-normal mx-4">InstaCamp</h1>
        </.nav_link>

        <.live_component id="navbar-form-comp" module={NavbarFormCompoent} />

        <nav class="lg:w-3/5">
          <ul class="flex items-center justify-end px-2 text-xs sm:text-sm md:text-base">
            <%= if @current_user do %>
              <%= live_patch to: Routes.live_path(@socket, InstacampWeb.HomeLive), id: "app-home" do %>
                <li class="flex items-center justify-center text-gray-600 flex-col sm:flex-row dark:text-gray-200 hover:text-indigo-400">
                  <Icons.home_icon />
                  <span class="sm:ml-1 font-semibold">Home</span>
                </li>
              <% end %>
              <%= live_redirect to: Routes.post_form_path(@socket, :new), id: "new-post" do %>
                <li class="flex items-center justify-center ml-4 text-gray-600 flex-col sm:flex-row dark:text-gray-200 hover:text-indigo-400">
                  <Icons.new_icon />
                  <span class="sm:ml-1 font-semibold hidden sm:block">New post</span>
                  <span class="sm:ml-1 font-semibold sm:hidden">Post</span>
                </li>
              <% end %>

              <.live_component
                id="notifications-comp"
                module={NotificationsComponent}
                current_user={@current_user}
              />

              <li
                id="theme-switch"
                class="relative ml-4 text-gray-600 dark:text-gray-200 hover:text-indigo-400"
                phx-hook="ToolTip"
              >
                <Switch.toggle />
                <span class="bottom-tooltip-text px-4 py-2 rounded-md bg-indigo-500 dark:bg-slate-500 text-white text-sm ">
                  Day/Night Theme
                </span>
              </li>

              <SettingsMenu.menu
                current_user={@current_user}
                socket={@socket}
                active_path={@active_path}
              />
            <% else %>
              <li
                id="theme-switch"
                class="relative mr-4 text-gray-600 dark:text-gray-200 hover:text-indigo-400"
                phx-hook="ToolTip"
              >
                <Switch.toggle />
                <span class="bottom-tooltip-text px-4 py-2 rounded-md bg-indigo-500 dark:bg-slate-500 text-white text-sm ">
                  Day/Night Theme
                </span>
              </li>
              <li>
                <%= live_redirect("Log In",
                  to: Routes.user_auth_login_path(@socket, :new),
                  class:
                    "#{if(@active_path == "/auth/login", do: "bg-indigo-500 text-gray-50 border-transparent hover:bg-indigo-600 hover:border-indigo-600 shadow", else: "bg-transparent text-indigo-500 dark:text-slate-100 hover:bg-indigo-500 hover:border-indigo-500 hover:text-indigo-50")} py-1 px-3 border rounded-full font-semibold duration-150 ease-in-out"
                ) %>
              </li>
              <li>
                <%= live_redirect("Sign Up",
                  to: Routes.user_auth_sign_up_path(@socket, :new),
                  class:
                    "#{if(@active_path == "/auth/signup", do: "bg-indigo-500 text-gray-50 border-transparent hover:bg-indigo-600 hover:border-indigo-600 shadow", else: "bg-transparent text-indigo-500 dark:text-slate-100 hover:bg-indigo-500 hover:border-indigo-500 hover:text-indigo-50")} ml-2 py-1 px-3 border rounded-full font-semibold duration-150 ease-in-out"
                ) %>
              </li>
            <% end %>
          </ul>
        </nav>
      </div>
    </header>
    """
  end
end
