defmodule InstacampWeb.PostListLive.SavedListComponents do
  @moduledoc false

  use InstacampWeb, :component

  alias Instacamp.DateTimeHelper
  alias Instacamp.Posts

  @spec saved_list_component(map()) :: Phoenix.LiveView.Rendered.t()
  def saved_list_component(assigns) do
    ~H"""
    <h1 id="user-bookmarks-count" class="text-base md:text-xl font-semibold mx-4 my-6">
      <%= @title %>
    </h1>
    <%= unless Enum.empty?(@list) do %>
      <%= for saved <- @list do %>
        <.saved_post_card socket={@socket} post={saved} />
      <% end %>
    <% else %>
      <h1 class="w-max mx-auto my-4 text-lg">No saved posts yet</h1>
    <% end %>
    """
  end

  @spec saved_post_card(map()) :: Phoenix.LiveView.Rendered.t()
  def saved_post_card(assigns) do
    ~H"""
    <article
      class="relative flex justify-between px-2 my-2 border-b border-gray-100 dark:border-slate-300"
      id={"saved-post-" <> @post.id}
    >
      <div class="flex">
        <div class="my-3">
          <%= live_redirect to: Routes.user_profile_path(@socket, :index, @post.user.username) do %>
            <%= img_tag(@post.user.avatar_url,
              class:
                "w-8 h-8 rounded-full object-cover object-center p-[1px] border border-gray-300 dark:border-slate-400"
            ) %>
          <% end %>
        </div>
        <div class="flex flex-1 flex-col py-2 px-4 ">
          <%= live_redirect to: Routes.post_show_path(@socket, :show, @post.slug) do %>
            <h1 class="text-sm md:text-lg font-semibold hover:text-indigo-500 dark:hover:text-indigo-200">
              <%= @post.title %>
            </h1>
          <% end %>

          <div class="flex items-center flex-wrap">
            <%= live_redirect to: Routes.user_profile_path(@socket, :index, @post.user.username) do %>
              <h1 class="text-sm md:text-base font-normal hover:text-indigo-500 dark:hover:text-indigo-200">
                <%= @post.user.full_name %>
              </h1>
            <% end %>

            <time
              datetime={@post.updated_at}
              class="text-sm text-gray-500 dark:text-slate-400 ml-2"
              title={DateTimeHelper.format_post_date(@post.updated_at)}
            >
              • <%= DateTimeHelper.format_post_date(@post.updated_at) %>
            </time>

            <span class="text-gray-500 dark:text-slate-400 text-sm mx-2">
              • Reading time <%= Posts.calculate_read_time(@post) %> min
            </span>

            <%= unless Enum.empty?(@post.tags) do %>
              <div class="flex flex-wrap gap-2 mt-2 md:mt-0 text-sm">
                •
                <%= for tag <- @post.tags do %>
                  <%= live_redirect to: Routes.feed_path(@socket, :index, %{tag: tag.name}) do %>
                    <span class="border rounded-full px-3 py-[2px] border-gray-200 dark:border-slate-400 hover:bg-sky-100 hover:border-blue-300 dark:hover:bg-inherit dark:hover:border-slate-400 cursor-pointer">
                      #<%= tag.name %>
                    </span>
                  <% end %>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      <div>
        <button
          id={"delete-button-#{@post.id}"}
          class="w-max mx-2 my-4 py-2 px-4 rounded-md text-sm md:text-base border-2 border-gray-300 bg-gray-50 dark:bg-inherit font-light hover:bg-gray-100 hover:border-gray-400"
          phx-click="delete_from_list"
          phx-value-id={@post.id}
        >
          Delete
        </button>
      </div>
    </article>
    """
  end
end
