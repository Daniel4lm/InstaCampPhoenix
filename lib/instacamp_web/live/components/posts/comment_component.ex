defmodule InstacampWeb.Components.Posts.CommentComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.DateTimeHelper
  alias Instacamp.FileHandler
  alias Instacamp.Repo
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.LikeComponent
  alias Phoenix.LiveView.JS

  @impl Phoenix.LiveComponent
  def update(%{is_reply?: true, comment: comment} = assigns, socket) do
    preloaded_comment =
      comment
      |> Repo.preload([:user, :post])
      |> Repo.preload([:replies, likes: :user])

    {:ok,
     socket
     |> assign(:related_users, Enum.map(preloaded_comment.likes, & &1.user))
     |> assign(assigns)
     |> assign(:comment, preloaded_comment)
     |> assign(:show_embedded_section, false)
     |> assign(:menu_id, "reply-comments-menu-#{comment.id}")}
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(:related_users, Enum.map(assigns.comment.likes, & &1.user))
      |> assign(:menu_id, "comments-menu-#{assigns.comment.id}")
      |> assign(:show_embedded_section, false)
      |> assign(assigns)
    }
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_embedded_section", _params, socket) do
    section_toggle = !socket.assigns.show_embedded_section
    {:noreply, assign(socket, :show_embedded_section, section_toggle)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="flex items-start">
      <div
        :if={@is_reply?}
        class="w-max p-1 mr-2 my-4 border rounded-lg border-gray-200 text-gray-300"
      >
        <Icons.reply class="w-5 h-5" />
      </div>
      <div class="w-full my-4" id={"user-comment-#{@comment.id}"}>
        <div class="relative flex flex-col border rounded-md dark:border-slate-400">
          <div class="flex items-center p-2 gap-2 rounded-md bg-neutral-100 dark:bg-slate-500">
            <.user_avatar
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
          <div class="p-4">
            <p class="text-sm sm:text-base text-gray-700">
              <%= raw(@comment.body) %>
            </p>
          </div>
          <div
            :if={@current_user && @current_user.id == @comment.user.id}
            class="absolute top-2 right-2 cursor-pointer"
          >
            <div
              id={"comments-option-#{@menu_id}"}
              class="relative rounded-lg p-1 hover:bg-neutral-200 dark:hover:bg-slate-600"
              phx-click={JS.toggle(to: "##{@menu_id}")}
            >
              <Icons.opts_icon />
            </div>
            <ul
              id={@menu_id}
              phx-click-away={JS.hide(to: "##{@menu_id}")}
              class="absolute hidden min-w-[10rem] w-max bg-white dark:bg-slate-500 dark:text-slate-100 dark:border-transparent top-full mt-1 right-0 rounded-lg border border-gray-300 p-1 text-sm sm:text-base"
            >
              <li class="py-2 px-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
                <.link
                  class="flex items-center justify-between gap-2"
                  id={
                    if(@is_reply?,
                      do: "delete-comment-reply-#{@comment.id}",
                      else: "delete-comment-#{@comment.id}"
                    )
                  }
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
                  id={
                    if(@is_reply?,
                      do: "edit-comment-reply-#{@comment.id}",
                      else: "edit-comment-#{@comment.id}"
                    )
                  }
                >
                  <div class="flex items-center justify-between gap-2">
                    <span>Edit</span>
                    <div class="p-1"><Icons.edit_icon /></div>
                  </div>
                </.link>
              </li>
            </ul>
          </div>

          <.reply_button
            :if={@comment.total_comments > 0}
            comment={@comment}
            show_embedded_section={@show_embedded_section}
          />

          <div id={"embedded-comment-bottom-#{@comment.id}"} class="hidden flex flex-col p-2">
            <%= unless Enum.empty?(@related_users) do %>
              <div id={"users-list-for-#{@comment.id}"} class="hidden flex items-center">
                <hr class="dark:border-slate-500" />
                <div class="flex items-center flex-wrap gap-2 p-2">
                  <div
                    :for={user <- @related_users}
                    id={"user-hover-item-#{@comment.id}-#{user.id}"}
                    class="relative hover-item w-max flex items-center"
                    phx-hook="ToolTip"
                  >
                    <.user_avatar
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

            <div
              :if={@show_embedded_section}
              id={"reply-list-for-#{@comment.id}"}
              class="flex flex-col"
            >
              <hr />
              <div :if={Enum.count(@comment.replies) > 0}>
                <div :for={current_comment <- @comment.replies} :if={not is_nil(current_comment)}>
                  <.live_component
                    id={"reply-comment-list-comp-#{unique_comment_id(current_comment.id)}"}
                    is_reply?={true}
                    module={__MODULE__}
                    current_user={@current_user}
                    comment={current_comment}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <div :if={@current_user} class="flex justify-between my-2 text-sm sm:text-base">
          <div class="flex items-center">
            <%= if @current_user.id != @comment.user_id do %>
              <div class="flex items-center bg-gray-50 dark:bg-slate-500 gap-2 p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer">
                <.live_component
                  id={
                    if(@is_reply?,
                      do: "reply-like-#{unique_comment_id(@comment.id)}",
                      else: "like-#{@comment.id}"
                    )
                  }
                  module={LikeComponent}
                  current_user={@current_user}
                  resource={@comment}
                  resource_name={:comment}
                />
              </div>
            <% else %>
              <div class="p-2 text-gray-500">
                <Icons.heart_icon />
              </div>
            <% end %>
            <div
              class="flex items-center bg-gray-50 border border-gray-250 dark:bg-slate-500 ml-1 px-2 py-1 rounded-full hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer"
              {if(@comment.total_likes > 0, do: [phx_click: toggle_likes_section(@comment.id)], else: [])}
            >
              <span id={"likes-count-for-#{@comment.id}"}><%= @comment.total_likes %> Likes</span>
            </div>
          </div>
          <.link
            navigate={~p"/post/#{@comment.post.slug}/comments/#{@comment.id}/reply"}
            id={"reply-to-comment-#{@comment.id}"}
          >
            <div class="flex items-center gap-2 ml-1 px-2 py-1 border border-gray-250 rounded-full hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer">
              <Icons.comment_icon />
              <span>Reply</span>
            </div>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp reply_button(assigns) do
    ~H"""
    <div
      id={"reply-button-for-#{@comment.id}"}
      class="flex items-center gap-1 w-max m-2 border border-gray-250 dark:bg-slate-500 px-2 py-1 rounded-full hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer"
      phx-click={
        JS.push("toggle_embedded_section", target: "#user-comment-#{@comment.id}")
        |> JS.toggle(to: "#embedded-comment-bottom-#{@comment.id}")
      }
    >
      <span>
        <%= if @comment.total_comments == 1 do %>
          1 Reply
        <% else %>
          <%= @comment.total_comments %> Replies
        <% end %>
      </span>
      <Icons.arrow_down :if={!@show_embedded_section} />
      <Icons.arrow_up :if={@show_embedded_section} />
    </div>
    """
  end

  defp toggle_likes_section(js \\ %JS{}, comment_id) do
    js
    |> JS.toggle(to: "#embedded-comment-bottom-#{comment_id}")
    |> JS.toggle(to: "#users-list-for-#{comment_id}")
  end

  defp unique_comment_id(id) do
    unique_id =
      id
      |> String.split("", trim: true)
      |> Enum.shuffle()
      |> Enum.join()

    unique_id <> id
  end
end
