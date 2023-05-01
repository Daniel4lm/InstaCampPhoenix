defmodule InstacampWeb.PostLive.Components.SidebarLeft do
  @moduledoc false

  use InstacampWeb, :html

  alias InstacampWeb.Components.Icons

  alias InstacampWeb.Components.Posts.LikeComponent
  alias InstacampWeb.Components.Posts.TagComponent

  alias Phoenix.LiveView.JS

  @spec sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def sidebar(assigns) do
    ~H"""
    <aside
      class="fixed sm:sticky w-full sm:w-max h-max z-[10] left-0 bottom-0 sm:left-auto sm:top-14 sm:p-6 sm:mr-1 border-t border-gray-300 dark:text-slate-100 rounded-lg bg-white dark:bg-slate-700 sm:border-0 sm:bg-transparent"
      aria-label="Post actions"
    >
      <div class="flex justify-around sm:flex-col">
        <div
          id="like-hover-item"
          class="relative hover-item flex sm:flex-col py-2 items-center"
          phx-hook="ToolTip"
        >
          <%= if @current_user && @current_user.id != @post.user.id do %>
            <div class="rounded-full p-2 cursor-pointer border border-transparent hover:border-red-200 hover:bg-red-100 dark:hover:bg-transparent dark:hover:border-transparent">
              <.live_component
                id="post-like-comp"
                module={LikeComponent}
                current_user={@current_user}
                resource={@post}
                resource_name={:post}
              />
            </div>
          <% else %>
            <div id="post-like-icon" class="py-2">
              <Icons.heart_icon />
            </div>
          <% end %>
          <span id="post-total-likes" class="mx-2"><%= @likes_count %></span>
          <span class="side-tooltip-text px-4 py-2 rounded-md bg-gray-800 text-white text-sm">
            Like
          </span>
        </div>

        <div
          id="scroll-to-hook"
          class="relative hover-item flex sm:flex-col py-2 items-center cursor-pointer"
          phx-hook="ToolTip"
        >
          <div
            id="post-comment-icon"
            class="rounded-full p-2 border border-transparent hover:border-orange-200 hover:bg-orange-100 hover:text-amber-500 dark:hover:bg-transparent dark:hover:border-transparent"
            phx-hook="ScrollToComments"
          >
            <Icons.comment_icon />
          </div>
          <span id="post-total-comments" class="mx-2"><%= @comments_count %></span>
          <span class="side-tooltip-text px-4 py-2 rounded-md bg-gray-800 text-white text-sm ">
            Jump to comments
          </span>
        </div>

        <div
          id="tag-hover-item"
          class="relative hover-item flex sm:flex-col py-4 items-center"
          phx-hook="ToolTip"
        >
          <%= if @current_user && @current_user.id != @post.user.id do %>
            <div class="rounded-full p-2 cursor-pointer border border-transparent hover:text-indigo-600 hover:border-indigo-300 hover:bg-indigo-50 dark:hover:bg-transparent dark:hover:border-transparent">
              <.live_component
                id="post-tag-comp"
                module={TagComponent}
                current_user={@current_user}
                post={@post}
              />
            </div>
          <% else %>
            <div id="post-tag-icon" class="py-2 text-gray-500">
              <Icons.tag_icon />
            </div>
          <% end %>
          <span id="post-bookmarks-count" class="mx-2"><%= @bookmarks_count %></span>
          <span class="side-tooltip-text px-4 py-2 rounded-md bg-gray-800 text-white text-sm">
            Save
          </span>
        </div>

        <div id="post-opts" class="relative flex sm:flex-col py-2 items-center cursor-pointer">
          <div
            id="post-options-icon"
            class="relative hover-item rounded-full p-2 cursor-pointer hover:bg-gray-200 dark:hover:bg-slate-500"
            phx-hook="ToolTip"
            phx-click={
              JS.toggle(
                to: "#opts-menu",
                in: "transition ease-out duration-200",
                out: "transition ease-out duration-200 opacity-0 transform scale-90"
              )
            }
          >
            <Icons.opts_icon />
            <span class="top-tooltip-text px-4 py-2 rounded-md bg-gray-800 text-white text-sm ">
              Other options
            </span>
          </div>
          <ul
            id="opts-menu"
            class="absolute hidden min-w-[14rem] h-max bg-white dark:bg-slate-500 dark:text-slate-100 rounded-lg border border-gray-300 dark:border-transparent bottom-full -right-1/2 sm:top-0 sm:left-full sm:ml-1 p-2"
            phx-click-away={
              JS.hide(
                to: "#opts-menu",
                transition: "transition ease-out duration-200 opacity-0 transform scale-90"
              )
            }
          >
            <li class="py-2 px-2 rounded-md">
              <div
                id="copy-url-picker"
                phx-hook="CopyUrlHook"
                data-copy-url={@copy_url}
                class="flex justify-between cursor-pointer"
              >
                <span>Copy link</span>
                <Icons.copy_link_icon />
              </div>
              <div
                id="article-copy-link-announcer"
                class="bg-sky-100 dark:bg-slate-400 rounded-md px-4 py-1 mt-2 hidden"
              >
                Copied to Clipboard
              </div>
            </li>

            <.link
              :if={@current_user && @current_user.id == @post.user.id}
              id={"delete-post-#{@post.id}"}
              phx-click="delete_post"
              phx-value-id={@post.id}
              data-confirm={"Sure you want to delete the post #{@post.title}?"}
            >
              <li class="py-2 px-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
                <div class="flex items-center justify-between">
                  <span>Delete post</span>
                  <div class="p-1"><Icons.delete_icon /></div>
                </div>
              </li>
            </.link>
            <.link
              :if={@current_user && @current_user.id == @post.user.id}
              id="edit-post-#{@post.id}"
              navigate={~p"/edit/post/#{@post.id}"}
            >
              <li class="py-2 px-2 rounded-md hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50 cursor-pointer">
                <div class="flex items-center justify-between">
                  <span>Edit post</span>
                  <div class="p-1"><Icons.edit_icon /></div>
                </div>
              </li>
            </.link>
          </ul>
        </div>
        <div id="scroll-to-container" phx-update="ignore" class="flex items-center">
          <div
            id="scroll-to-top"
            class="invisible sm:fixed duration-300 ease-in-out opacity-0 flex items-center cursor-pointer right-5 md:right-auto md:left-5 xl:left-auto xl:right-5 sm:-bottom-10"
            phx-hook="ScrollToTop"
          >
            <Icons.scroll_to_top_icon />
          </div>
        </div>
      </div>
    </aside>
    """
  end
end
