defmodule InstacampWeb.Components.Navigation.SettingsMenu do
  @moduledoc false

  use InstacampWeb, :html

  alias Instacamp.FileHandler
  alias Phoenix.LiveView.JS

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @doc """
  Renders app settings menu.

  ## Examples

      <.menu current_user={@current_user} active_path={@active_path} />

  """
  attr :active_path, :string, required: true
  attr :current_user, :map, required: true

  @spec menu(assigns()) :: render()
  def menu(assigns) do
    ~H"""
    <li class="xs:relative ml-4">
      <div
        id="user-avatar"
        phx-click={
          JS.toggle(
            to: "#settings-menu",
            in: "transition ease-out duration-200",
            out: "transition ease-out duration-200 opacity-0 transform scale-90"
          )
        }
        class="w-8 cursor-pointer flex items-center justify-center text-gray-600 flex-col dark:text-gray-200 hover:text-black"
      >
        <.user_avatar
          src={FileHandler.get_avatar_thumb(@current_user.avatar_url)}
          class="w-7 h-7 md:w-8 md:h-8 hover:border-indigo-300 hover:ring-2 dark:hover:ring-0 hover:ring-indigo-300 hover:ring-opacity-80"
        />
        <span>Me</span>
      </div>

      <ul
        id="settings-menu"
        phx-click-away={close_menu("settings-menu")}
        phx-window-keydown={close_menu("settings-menu")}
        phx-key="escape"
        class="absolute hidden top-16 xs:top-14 w-[98%] xs:w-56 p-2 left-1 right-1 xs:left-auto md:-right-4 bg-white dark:bg-slate-600 dark:text-slate-100 border border-gray-300 dark:border-slate-400 rounded-md overflow-hidden text-sm"
      >
        <li class="py-2 px-2 flex flex-col">
          <p class="my-2 text-[1.4em]"><%= @current_user.full_name %></p>
          <span><%= @current_user.email %></span>
        </li>
        <hr class="my-1 dark:border-slate-500" />
        <.nav_link
          active_path={@active_path}
          current_path={"/user/#{@current_user.username}"}
          link_path={~p"/user/#{@current_user.username}"}
        >
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">My profile</li>
        </.nav_link>

        <.link navigate={~p"/saved-list"} phx-click={close_menu("settings-menu")}>
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Saved list</li>
        </.link>

        <.link navigate={~p"/accounts/edit"} phx-click={close_menu("settings-menu")}>
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Settings</li>
        </.link>
        <hr class="my-1 dark:border-slate-500" />

        <.link href={~p"/auth/logout"} method="delete" phx-click={close_menu("settings-menu")}>
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Log Out</li>
        </.link>
      </ul>
    </li>
    """
  end
end
