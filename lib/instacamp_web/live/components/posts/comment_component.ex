defmodule InstacampWeb.Components.Posts.CommentComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.DateTimeHelper
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.LikeComponent
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
    <div class="w-full my-4" id={"comment-component-#{@comment.id}"}>
      <div class="relative flex flex-col border rounded-md dark:border-slate-400 p-4">
        <div class="flex items-center gap-2">
          <%= live_redirect to: Routes.user_profile_path(@socket, :index, @comment.user.username) do %>
            <%= img_tag(@comment.user.avatar_url,
              class:
                "w-8 h-8 rounded-full object-center p-[1px] border border-gray-300 dark:border-slate-300"
            ) %>
          <% end %>
          <%= live_redirect(@comment.user.username,
            to: Routes.user_profile_path(@socket, :index, @comment.user.username),
            class: "truncate font-bold text-gray-500 dark:text-inherit hover:underline"
          ) %>
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
        <%= if @current_user && @current_user.id == @comment.user.id do %>
          <div class="absolute top-2 right-2 cursor-pointer">
            <div
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
                <%= link to: "#", id: "delete-comment-#{@comment.id}", phx_click: "delete_comment", phx_value_id: @comment.id, data: [confirm: "Are you sure?"] do %>
                  <div class="flex items-center justify-between gap-2">
                    <span>Delete</span>
                    <Icons.delete_icon />
                  </div>
                <% end %>
              </li>
              <li class="py-2 px-2 rounded-md cursor-pointer hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
                <%= live_redirect to: Routes.post_show_path(@socket, :edit_comment, @comment.post.slug, @comment.id), id: "edit-comment-#{@comment.id}" do %>
                  <div class="flex items-center justify-between gap-2">
                    <span>Edit</span>
                    <div class="p-1"><Icons.edit_icon /></div>
                  </div>
                <% end %>
              </li>
            </ul>
          </div>
        <% end %>
        <%= unless Enum.empty?(@related_users) do %>
          <div id={"comment-#{@comment.id}-users-list"} class="hidden flex items-center">
            <hr class="dark:border-slate-500" />
            <div class="flex items-center flex-wrap gap-2 mt-4">
              <%= for user <- @related_users do %>
                <div
                  id="comment-hover-item"
                  class="relative hover-item w-max flex items-center"
                  phx-hook="ToolTip"
                >
                  <%= live_redirect to: Routes.user_profile_path(@socket, :index, user.username) do %>
                    <%= img_tag(user.avatar_url,
                      class:
                        "w-6 h-6 rounded-full object-cover object-center p-[1px] border border-gray-300"
                    ) %>
                  <% end %>

                  <span class="top-tooltip-text px-2 py-2 rounded-md bg-gray-800 opacity-80 text-white text-sm ">
                    <%= user.username %>
                  </span>
                </div>
              <% end %>
              <span class="text-sm">liked this</span>
            </div>
          </div>
        <% end %>
      </div>

      <%= if @current_user do %>
        <div class="flex my-2 text-sm sm:text-base">
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
            phx-click={JS.toggle(to: "#comment-#{@comment.id}-users-list")}
          >
            <span id={"comment-likes-count-#{@comment.id}"}><%= @comment.total_likes %> Likes</span>
          </div>
          <div class="flex items-center gap-2 p-2 ml-2 rounded-lg hover:cursor-pointer">
            <Icons.comment_icon />
            <span>Reply</span>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
