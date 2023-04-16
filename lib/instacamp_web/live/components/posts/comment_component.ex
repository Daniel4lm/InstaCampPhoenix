defmodule InstacampWeb.Components.Posts.CommentComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.DateTimeHelper
  alias Instacamp.FileHandler
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.LikeComponent
  alias InstacampWeb.CoreComponents
  alias Phoenix.LiveView.JS

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:related_users, Enum.map(assigns.comment.likes, & &1.user))
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="w-full my-4" id={"comment-#{@comment.id}"}>
      <div class="relative flex flex-col border rounded-md dark:border-slate-400 p-4">
        <div class="flex items-center gap-2">
          <CoreComponents.user_avatar
            with_link={~p"/user/#{@comment.user.username}"}
            src={FileHandler.get_avatar_thumb(@comment.user.avatar_url)}
            class="w-8 h-8"
          />

          <.link
            navigate={~p"/user/#{@comment.user.username}"}
            class="truncate font-bold text-gray-500 dark:text-inherit hover:underline"
          >
            <%= @comment.user.username %>
          </.link>
          <p class="flex text-sm sm:text-base gap-1">
            •
            <time
              datetime={@comment.updated_at}
              title={DateTimeHelper.format_post_date(@comment.updated_at)}
            >
              <%= DateTimeHelper.format_post_date(@comment.updated_at) %>
            </time>
          </p>
        </div>
        <div class="py-4">
          <p class="text-sm sm:text-base text-gray-700">
            <%= raw(@comment.body) %>
          </p>
        </div>
        <div
          :if={@current_user && @current_user.id == @comment.user.id}
          class="absolute top-2 right-2 cursor-pointer"
        >
          <div
            id={"comments-option-#{@comment.id}"}
            class="relative rounded-lg p-1 hover:bg-gray-100 dark:hover:bg-slate-700"
            phx-click={JS.toggle(to: "#comments-menu-#{@comment.id}")}
          >
            <Icons.opts_icon />
          </div>
          <ul
            id={"comments-menu-#{@comment.id}"}
            phx-click-away={JS.hide(to: "#comments-menu-#{@comment.id}")}
            class="absolute hidden min-w-[10rem] w-max bg-white dark:bg-slate-500 dark:text-slate-100 dark:border-transparent top-full mt-1 right-0 rounded-lg border border-gray-300 p-2 text-sm sm:text-base"
          >
            <li class="py-2 px-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
              <.link
                class="flex items-center justify-between gap-2"
                id={"delete-comment-#{@comment.id}"}
                phx-click="delete_comment"
                phx-value_id={@comment.id}
                data-confirm="Sure you want to delete the comment?"
              >
                <span>Delete</span>
                <Icons.delete_icon />
              </.link>
            </li>
            <li class="py-2 px-2 rounded-md cursor-pointer hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
              <.link
                navigate={~p"/post/#{@comment.post.slug}/comments/#{@comment.id}/edit"}
                id="edit-comment-#{@comment.id}"
              >
                <div class="flex items-center justify-between gap-2">
                  <span>Edit</span>
                  <div class="p-1"><Icons.edit_icon /></div>
                </div>
              </.link>
            </li>
          </ul>
        </div>
        <%= unless Enum.empty?(@related_users) do %>
          <div id={"users-list-for-#{@comment.id}"} class="hidden flex items-center">
            <hr class="dark:border-slate-500" />
            <div class="flex items-center flex-wrap gap-2 mt-4">
              <div
                :for={user <- @related_users}
                id="user-hover-item"
                class="relative hover-item w-max flex items-center"
                phx-hook="ToolTip"
              >
                <CoreComponents.user_avatar
                  with_link={~p"/user/#{user.username}"}
                  src={FileHandler.get_avatar_thumb(user.avatar_url)}
                  class="w-6 h-6"
                />

                <span class="top-tooltip-text px-2 py-2 rounded-md bg-gray-800 opacity-80 text-white text-sm ">
                  <%= user.username %>
                </span>
              </div>

              <span class="text-sm">liked this</span>
            </div>
          </div>
        <% end %>
      </div>

      <div :if={@current_user} class="flex my-2 text-sm sm:text-base">
        <%= if @current_user.id != @comment.user_id do %>
          <div class="flex items-center bg-gray-50 dark:bg-slate-500 gap-2 p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer">
            <.live_component
              id={@comment.id}
              module={LikeComponent}
              current_user={@current_user}
              resource={@comment}
              resource_name={:comment}
            />
          </div>
        <% else %>
          <div class="p-2">
            <Icons.heart_icon />
          </div>
        <% end %>
        <div
          class="flex items-center bg-gray-50 dark:bg-slate-500 p-2 ml-2 rounded-lg hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer"
          phx-click={JS.toggle(to: "#users-list-for-#{@comment.id}")}
        >
          <span id={"likes-count-for-#{@comment.id}"}><%= @comment.total_likes %> Likes</span>
        </div>
        <div class="flex items-center gap-2 p-2 ml-2 rounded-lg hover:cursor-pointer">
          <Icons.comment_icon />
          <span>Reply</span>
        </div>
      </div>
    </div>
    """
  end
end
