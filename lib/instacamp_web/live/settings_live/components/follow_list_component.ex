defmodule InstacampWeb.SettingsLive.Components.FollowListComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.FileHandler
  alias InstacampWeb.CoreComponents
  alias InstacampWeb.SettingsLive.Components.FollowComponent

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="dark:bg-slate-500 dark:text-slate-100">
      <header class="bg-gray-50 dark:bg-slate-500 p-2 border-b dark:border-slate-400 rounded-t-xl">
        <h1 id="follow-list-title" class="flex justify-center text-xl font-semibold">
          <%= get_title(@action) %>
        </h1>
      </header>

      <%= unless Enum.empty?(@follow_list) do %>
        <%= for follow <- @follow_list do %>
          <div class="p-4">
            <div class="flex items-center">
              <CoreComponents.user_avatar
                with_link={~p"/user/#{get_follow_user(follow, @action).username}"}
                src={FileHandler.get_avatar_thumb(get_follow_user(follow, @action).avatar_url)}
                class="w-8 h-8 md:w-10 md:h-10"
              />

              <div class="ml-3">
                <.link
                  navigate={~p"/user/#{get_follow_user(follow, @action).username}"}
                  class="font-semibold text-sm truncate hover:underline"
                >
                  <%= get_follow_user(follow, @action).username %>
                </.link>
                <h6
                  id={"follow-name-#{get_follow_user(follow, @action).id}"}
                  class="font-semibold text-sm truncate text-gray-400 dark:text-slate-100"
                >
                  <%= get_follow_user(follow, @action).full_name %>
                </h6>
              </div>
              <%= if @current_user && @current_user != get_follow_user(follow, @action) do %>
                <span class="ml-auto">
                  <.live_component
                    module={FollowComponent}
                    id={"#{get_follow_user(follow, @action).id}-list"}
                    user={get_follow_user(follow, @action)}
                    current_user={@current_user}
                  />
                </span>
              <% end %>
            </div>
          </div>
        <% end %>
      <% else %>
        <div class="p-4">Empty list</div>
      <% end %>
    </div>
    """
  end

  defp get_follow_user(follow, :followers), do: follow.follower
  defp get_follow_user(follow, :following), do: follow.followed

  defp get_title(:followers), do: "Followers"
  defp get_title(:following), do: "Following"
end
