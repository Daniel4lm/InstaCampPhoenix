defmodule InstacampWeb.Components.Navigation.Navbar do
  @moduledoc false

  use InstacampWeb, :html

  alias InstacampWeb.Components.DarkMode.Switch
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Navigation.NavbarFormComponent
  alias InstacampWeb.Components.Navigation.NotificationsComponent
  alias InstacampWeb.Components.Navigation.SettingsMenu

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @doc """
  Renders main app navbar.

  ## Examples

      <.app_navbar current_user={@current_user} active_path={@active_path} />

  """
  attr(:active_path, :string)
  attr(:current_user, :map, required: true)
  attr(:title, :string, default: "Campy")

  @spec app_navbar(assigns()) :: render()
  def app_navbar(assigns) do
    ~H"""
    <header class="h-16 border-b dark:border-transparent flex fixed top-0 w-full bg-white dark:bg-slate-600 dark:text-slate-100 z-50">
      <div class="flex justify-between lg:justify-center items-center px-2 py-1 mx-auto w-full md:w-11/12 2xl:w-8/12">
        <div class="flex justify-center items-center gap-2 xs:gap-0">
          <div
            id="toggle-modile-menu"
            class="block xs:hidden hover:bg-gray-200 hover:dark:bg-slate-500 cursor-pointer rounded-lg p-2"
            phx-click={show_mobile_menu()}
          >
            <Icons.hamb_button />
          </div>
          <.nav_link
            active_path={@active_path}
            class="flex items-center gap-2 md:mx-4"
            current_path={~p"/"}
            link_path={~p"/"}
          >
            <Icons.app_icon />
            <h4 class="text-lg md:text-xl font-normal"><%= @title %></h4>
          </.nav_link>
        </div>

        <.live_component id="navbar-form-comp" module={NavbarFormComponent} />

        <nav class="lg:w-3/5">
          <ul class="flex items-center justify-end pl-2 text-xs sm:text-sm">
            <%= if @current_user do %>
              <.link navigate={~p"/"} id="home-icon">
                <li class="hidden xs:flex items-center justify-center text-gray-600 flex-col dark:text-gray-200 hover:text-black">
                  <Icons.home_icon />
                  <span>Home</span>
                </li>
              </.link>
              <.link navigate={~p"/new/post"} id="new-post">
                <li class="hidden xs:flex items-center justify-center ml-4 text-gray-600 flex-col dark:text-gray-200 hover:text-black">
                  <Icons.new_icon />
                  <span class="hidden lg:block">New post</span>
                  <span class="lg:hidden">Post</span>
                </li>
              </.link>
              <.live_component
                id="notifications-comp"
                module={NotificationsComponent}
                current_user={@current_user}
              />

              <SettingsMenu.menu current_user={@current_user} active_path={@active_path} />
            <% else %>
              <li
                id="theme-switch"
                class="relative xs:mr-4 text-gray-600 dark:text-gray-200 hover:text-indigo-400"
                phx-hook="ToolTip"
              >
                <Switch.toggle />
                <span class="bottom-tooltip-text px-4 py-2 rounded-md bg-indigo-500 dark:bg-slate-500 text-white text-sm ">
                  Day/Night Theme
                </span>
              </li>
              <li class="hidden xs:block">
                <.link
                  navigate={~p"/auth/login"}
                  class={"#{if(@active_path == "/auth/login", do: "bg-gray-300 border-transparent hover:bg-gray-100 hover:bg-gray-300", else: "bg-transparent dark:text-slate-100 hover:bg-gray-100")} py-1 px-3 text-indigo-500 border rounded-full font-semibold duration-150 ease-in-out"}
                >
                  Log In
                </.link>
              </li>
              <li class="hidden xs:block">
                <.link
                  navigate={~p"/auth/signup"}
                  class={"#{if(@active_path == "/auth/signup", do: "bg-gray-300 border-transparent hover:bg-gray-100 hover:bg-gray-300", else: "bg-transparent dark:text-slate-100 hover:bg-gray-100")} ml-2 py-1 text-indigo-500 px-3 border rounded-full font-semibold duration-150 ease-in-out"}
                >
                  Sign Up
                </.link>
              </li>
            <% end %>
          </ul>
        </nav>
      </div>
    </header>
    """
  end
end
