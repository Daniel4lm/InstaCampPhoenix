defmodule InstacampWeb.Components.Navigation.SettingsMenu do
  @moduledoc false

  use InstacampWeb, :component

  alias Phoenix.LiveView.JS

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @spec menu(assigns()) :: render()
  def menu(assigns) do
    ~H"""
    <li class="relative ml-6">
      <div
        id="user-avatar"
        phx-click={
          JS.toggle(
            to: "#settings-menu",
            in: "transition ease-out duration-200",
            out: "transition ease-out duration-200 opacity-0 transform scale-90"
          )
        }
        class="w-8 h-8 rounded-full border p-[1px] border-gray-300 dark:bg-slate-300 dark:border-transparent cursor-pointer overflow-hidden hover:border-indigo-300 hover:ring-2 dark:hover:ring-0 hover:ring-indigo-300 hover:ring-opacity-80"
      >
        <%= img_tag(@current_user.avatar_url,
          class: "w-full h-full rounded-full object-cover object-center"
        ) %>
      </div>
      <ul
        id="settings-menu"
        phx-click-away={
          JS.hide(
            to: "#settings-menu",
            transition: "transition ease-out duration-200 opacity-0 transform scale-90"
          )
        }
        class="absolute hidden top-10 w-56 p-2 bg-white dark:bg-slate-600 dark:text-slate-100 border border-gray-300 dark:border-slate-400 rounded-md overflow-hidden text-sm right-0 md:-right-4"
      >
        <li class="py-2 px-2 flex flex-col">
          <p class="my-2 text-[1.4em]"><%= @current_user.full_name %></p>
          <span><%= @current_user.email %></span>
        </li>
        <hr class="my-1 dark:border-slate-500" />
        <.nav_link
          active_path={@active_path}
          current_path={"/user/#{@current_user.username}"}
          link_path={Routes.user_profile_path(@socket, :index, @current_user.username)}
        >
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">My profile</li>
        </.nav_link>

        <%= live_redirect to: Routes.saved_list_path_path(@socket, :list) do %>
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Saved list</li>
        <% end %>
        <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Appearance</li>
        <%= live_redirect to: Routes.live_path(@socket, InstacampWeb.SettingsLive.Settings) do %>
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Settings</li>
        <% end %>
        <hr class="my-1 dark:border-slate-500" />
        <%= link to: Routes.user_session_path(@socket, :delete), method: :delete do %>
          <li class="p-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-500">Log Out</li>
        <% end %>
      </ul>
    </li>
    """
  end
end
