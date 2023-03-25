defmodule InstacampWeb.Components.Posts.PostCardComponent do
  @moduledoc false

  use InstacampWeb, :component

  alias Instacamp.DateTimeHelper
  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.TagComponent

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @spec feed_card(assigns()) :: render()
  def feed_card(assigns) do
    ~H"""
    <article
      id={"feed-item-#{@post.id}"}
      class="relative group p-2 rounded-lg bg-white dark:bg-slate-600 border dark:border-transparent border-gray-200 hover:border-transparent hover:ring-2 hover:ring-indigo-300 dark:hover:ring-slate-400 duration-200 ease-in-out"
    >
      <%= live_redirect("Link to post",
        to: Routes.post_show_path(@socket, :show, @post.slug),
        class: "absolute opacity-0 left-0 w-full h-full"
      ) %>
      <div class="flex items-center p-2">
        <%= live_redirect to: Routes.user_profile_path(@socket, :index, @post.user.username), class: "z-[1]" do %>
          <%= img_tag(@post.user.avatar_url,
            class:
              "w-8 h-8 md:w-10 md:h-10 rounded-full object-cover object-center p-[1px] bg-white dark:bg-slate-400 border border-gray-300"
          ) %>
        <% end %>
        <div class="w-max ml-4 z-[4]">
          <%= live_redirect(
            @post.user.full_name,
            to: Routes.user_profile_path(@socket, :index, @post.user.username),
            class: "font-bold text-sm lg:text-base"
          ) %>
          <p class="flex gap-1 text-xs md:text-sm lg:text-base">
            Posted on
            <time
              datetime={@post.updated_at}
              class="date-no-year"
              title={DateTimeHelper.format_post_date(@post.updated_at)}
            >
              <%= DateTimeHelper.format_post_date(@post.updated_at) %>
            </time>
          </p>
        </div>
      </div>
      <div class="w-full flex flex-col md:flex-row md:items-center p-2">
        <div class="w-full md:w-2/3 px-2">
          <h1 class="font-medium text-lg md:text-xl lg:text-2xl my-2 group-hover:text-indigo-500">
            <%= @post.title %>
          </h1>
          <span class="flex items-center gap-2 text-gray-500 dark:text-gray-100 text-xs md:text-sm lg:text-base">
            <div class="w-5 text-indigo-400"><Icons.read_time /></div>
            Reading time • <%= Posts.calculate_read_time(@post) %> min
          </span>
        </div>
        <%= if @post.photo_url do %>
          <div class="w-full md:w-1/3 my-4 md:my-0 rounded-lg overflow-hidden border">
            <%= img_tag(@post.photo_url,
              class: "object-contain rounded-lg"
            ) %>
          </div>
        <% else %>
          <div class={
            "w-full flex justify-center items-center text-center text-white md:w-1/3 h-[14em] md:h-[6em] lg:h-[10em] my-4 md:my-0 rounded-lg overflow-hidden bg-gradient-to-r #{random_image_color()}"
          }>
            <%= @post.title %>
          </div>
        <% end %>
      </div>
      <div class="flex justify-between mt-3 dark:text-slate-300">
        <div class="flex items-center gap-2">
          <div class="flex items-center gap-1 px-2 py-1 text-xs md:text-sm rounded-full hover:bg-gray-250 dark:hover:bg-slate-400 hover:cursor-pointer z-[1]">
            <div class="sm:w-6"><Icons.heart_icon_empty /></div>
            <div class="hidden sm:block"><span><%= @post.total_likes %></span> Likes</div>
            <div class="block sm:hidden"><span><%= @post.total_likes %></span></div>
          </div>
          <%= live_redirect to: "/post/#{@post.slug}#post-comments-section", class: "z-[1]" do %>
            <div class="flex items-center gap-1 px-2 py-1 text-xs md:text-sm rounded-full hover:bg-gray-250 dark:hover:bg-slate-400 hover:cursor-pointer">
              <div class="sm:w-6"><Icons.comment_icon /></div>
              <div class="hidden sm:block">
                <span><%= @post.total_comments %></span> Comments
              </div>
              <div class="block sm:hidden"><span><%= @post.total_comments %></span></div>
            </div>
          <% end %>
        </div>
        <div class="flex items-center text-[0.9em]">
          <div class="flex items-center flex-wrap p-2">
            <%= for %{user: user} <- Posts.get_users_from_comments(@post.comment) do %>
              <div
                id="user-hover-item"
                class="relative hover-item w-max flex items-center first:mx-0 -ml-2"
                phx-hook="ToolTip"
              >
                <%= live_redirect to: Routes.user_profile_path(@socket, :index, user.username) do %>
                  <%= img_tag(user.avatar_url,
                    class:
                      "w-6 h-6 md:w-8 md:h-8 bg-white dark:bg-slate-200 rounded-full object-cover object-center p-[1px] border border-gray-300 dark:border-slate-200"
                  ) %>
                <% end %>

                <span class="top-tooltip-text px-2 py-2 rounded-md bg-gray-800 opacity-80 text-white text-sm ">
                  <%= user.username %>
                </span>
              </div>
            <% end %>
          </div>
          <%= if @current_user && @current_user.id != @post.user.id do %>
            <div class="p-2 rounded-full hover:bg-gray-250 dark:hover:bg-slate-400 hover:cursor-pointer z-[1]">
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
    </article>
    """
  end

  defp random_image_color do
    Enum.random([
      "from-cyan-500 to-blue-500",
      "from-sky-500 to-indigo-500",
      "from-violet-500 to-fuchsia-500",
      "from-purple-500 to-pink-500"
    ])
  end

  @spec small_card(assigns()) :: render()
  def small_card(assigns) do
    ~H"""
    <article
      class="relative flex items-center m-2 border rounded-lg shadow-sm hover:shadow-lg overflow-hidden dark:bg-slate-500 dark:text-slate-50 border-gray-200 dark:border-slate-300 focus-within:border-transparent dark:focus-within:border-transparent focus-within:ring focus-within:ring-indigo-400 dark:focus-within:ring-blue-400 transition-all hover:border-gray-300"
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
            <%= live_redirect to: Routes.feed_path(@socket, :index, %{tag: tag.name}) do %>
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
            <div class="flex items-center gap-1 px-2 py-1 text-sm rounded-full hover:bg-gray-250 dark:hover:bg-slate-400 hover:cursor-pointer z-[1]">
              <Icons.heart_icon_empty />
              <span><%= @post.total_likes %></span> Likes
            </div>
            <%= live_redirect to: "/post/#{@post.slug}#post-comments-section", class: "z-[1]" do %>
              <div class="flex items-center gap-1 px-2 py-1 text-sm rounded-full hover:bg-gray-250 dark:hover:bg-slate-400 hover:cursor-pointer">
                <Icons.comment_icon />
                <span><%= @post.total_comments %></span> Comments
              </div>
            <% end %>
          </div>
          <div class="flex items-center gap-2 text-[0.9em]">
            <span><%= Posts.calculate_read_time(@post) %> min read</span>
            <%= if @current_user && @current_user.id != @post.user.id do %>
              <div class="p-2 rounded-full hover:bg-gray-250 dark:hover:bg-slate-400 hover:cursor-pointer z-[1]">
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
