defmodule InstacampWeb.Components.Posts.PostCardComponent do
  @moduledoc false

  use InstacampWeb, :component

  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.TagComponent

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @spec card(assigns()) :: render()
  def card(assigns) do
    ~H"""
    <article
      class="relative flex items-center m-2 border rounded-lg shadow-sm hover:shadow-lg overflow-hidden dark:bg-slate-500 dark:text-slate-50 border-gray-200 dark:border-slate-300 focus-within:border-transparent dark:focus-within:border-transparent focus-within:ring focus-within:ring-indigo-500 dark:focus-within:ring-blue-500 transition-all hover:border-gray-300nt"
      id={"post-card-" <> @post.id}
    >
      <%= live_redirect("Link to post",
        to: Routes.post_show_path(@socket, :show, @post.slug),
        class: "absolute opacity-0 left-0 w-full h-full"
      ) %>
      <div class="hidden sm:block w-1/4">
        <%= if @post.photo_url do %>
          <%= live_redirect(
            img_tag(@post.photo_url, class: "object-cover object-center h-36 md:h-40 w-full"),
            id: @post.slug,
            to: Routes.post_show_path(@socket, :show, @post.slug)
          ) %>
        <% else %>
          <div class="h-36 md:h-40 bg-gray-100 w-full"></div>
        <% end %>
      </div>
      <div class="w-full sm:w-3/4 flex flex-col py-4 px-4 sm:py-0">
        <%= live_redirect to: Routes.post_show_path(@socket, :show, @post.slug), class: "z-[1]" do %>
          <h1 class="text-[1em] md:text-[1.2em] font-semibold hover:text-indigo-500 dark:hover:text-indigo-100 mb-3">
            <%= @post.title %>
          </h1>
        <% end %>
        <div class="flex flex-wrap gap-2 text-sm z-[1]">
          <%= for tag <- @post.tags do %>
            <%= live_redirect to: Routes.post_list_path(@socket, :index, tag.name) do %>
              <span
                id={"post-topic-#{tag.id}"}
                class="border rounded-full px-3 py-[2px] border-gray-200 dark:border-slate-400 hover:bg-sky-100 hover:border-blue-300 dark:hover:bg-inherit dark:hover:border-slate-400 cursor-pointer"
              >
                #<%= tag.name %>
              </span>
            <% end %>
          <% end %>
        </div>

        <div class="flex justify-between mt-3 dark:text-slate-300">
          <div class="flex items-center gap-2">
            <div class="flex gap-2 p-2 text-sm rounded-lg hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer z-[1]">
              <Icons.heart_icon_empty />
              <span><%= @post.total_likes %></span> Likes
            </div>
            <%= live_redirect to: "/post/#{@post.slug}#post-comments-section", class: "z-[1]" do %>
              <div class="flex gap-2 p-2 text-sm rounded-lg hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer">
                <Icons.comment_icon />
                <span><%= @post.total_comments %></span> Comments
              </div>
            <% end %>
          </div>
          <div class="flex items-center gap-2 text-[0.9em]">
            <span><%= Posts.calculate_read_time(@post) %> min read</span>
            <%= if @current_user && @current_user.id != @post.user.id do %>
              <div class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-slate-400 hover:cursor-pointer z-[1]">
                <.live_component
                  id={"tag-comp-#{@post.id}"}
                  module={TagComponent}
                  current_user={@current_user}
                  post={@post}
                />
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </article>
    """
  end
end
