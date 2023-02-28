defmodule InstacampWeb.Components.Navigation.NotifyComponent do
  @moduledoc false

  use InstacampWeb, :component

  alias Instacamp.Repo

  @type assigns :: map()
  @type output :: Phoenix.LiveView.Rendered.t()

  @spec user_notify(assigns()) :: output()
  def user_notify(%{action_type: "comment"} = assigns) do
    assigns =
      assigns
      |> assign(:author, assigns.notification.author)
      |> assign_notification("comment")
      |> assign(:time, assigns.notification.inserted_at)

    ~H"""
    <li class="flex items-center p-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @author.username), class: "w-[2rem]" do %>
        <%= img_tag(@author.avatar_url,
          class: "w-8 h-8 rounded-full object-center p-[1px] border border-gray-300"
        ) %>
      <% end %>
      <%= live_redirect to: "/post/#{@notification.post.slug}#comment-#{@notification.comment.id}", class: "w-11/12 px-2" do %>
        <div class="">
          <div class="flex flex-wrap items-center">
            <span class="text-sm font-light">
              <span class="font-bold text-sm text-gray-500 dark:text-gray-200">
                <%= @author.username %>
              </span>
              commented on your post
            </span>
          </div>
          <span class="block truncate"><%= @notification.post.title %></span>
          <span class="text-gray-400 dark:text-gray-200 text-xs">
            <%= Timex.from_now(@time) %>
          </span>
        </div>
      <% end %>
    </li>
    """
  end

  def user_notify(%{action_type: "post_like"} = assigns) do
    assigns =
      assigns
      |> assign(:author, assigns.notification.author)
      |> assign_notification("post_like")
      |> assign(:time, assigns.notification.inserted_at)

    ~H"""
    <li class="flex items-center p-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @author.username), class: "w-[2rem]" do %>
        <%= img_tag(@author.avatar_url,
          class: "w-8 h-8 rounded-full object-center p-[1px] border border-gray-300"
        ) %>
      <% end %>
      <%= live_redirect to: Routes.post_show_path(@socket, :show, @notification.post.slug), class: "w-11/12 px-2" do %>
        <div class="">
          <div class="flex flex-wrap items-center">
            <span class="text-sm font-light">
              <span class="font-bold text-sm text-gray-500 dark:text-gray-200">
                <%= @author.username %>
              </span>
              liked your post
            </span>
          </div>
          <span class="block truncate"><%= @notification.post.title %></span>
          <span class="text-gray-400 dark:text-gray-200 text-xs">
            <%= Timex.from_now(@time) %>
          </span>
        </div>
      <% end %>
    </li>
    """
  end

  def user_notify(%{action_type: "comment_like"} = assigns) do
    assigns =
      assigns
      |> assign(:author, assigns.notification.author)
      |> assign_notification("comment_like")
      |> assign(:time, assigns.notification.inserted_at)

    ~H"""
    <li class="flex items-center px-2 py-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @author.username), class: "w-[2rem]" do %>
        <%= img_tag(@author.avatar_url,
          class: "w-8 h-8 rounded-full object-center p-[1px] border border-gray-300"
        ) %>
      <% end %>
      <%= live_redirect to: Routes.post_show_path(@socket, :show, @notification.post.slug), class: "w-11/12 px-2" do %>
        <div>
          <div class="flex flex-wrap items-center">
            <span class="text-sm font-light">
              <span class="font-bold text-sm text-gray-500 dark:text-gray-200">
                <%= @author.username %>
              </span>
              liked your comment
            </span>
          </div>
          <span class="block truncate"><%= @notification.post.title %></span>
          <span class="text-gray-400 dark:text-gray-200 text-xs">
            <%= Timex.from_now(@time) %>
          </span>
        </div>
      <% end %>
    </li>
    """
  end

  def user_notify(%{action_type: "following"} = assigns) do
    assigns =
      assigns
      |> assign(:author, assigns.notification.author)
      |> assign_notification("following")
      |> assign(:time, assigns.notification.inserted_at)

    ~H"""
    <%= live_redirect to: Routes.user_profile_path(@socket, :index, @author.username), class: "w-[2rem]" do %>
      <li class="flex items-center px-2 py-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
        <%= img_tag(@author.avatar_url,
          class: "w-8 h-8 rounded-full object-center p-[1px] border border-gray-300"
        ) %>
        <div class="px-2">
          <div class="flex flex-wrap items-center">
            <span class="text-sm font-light">
              <span class="font-bold text-sm text-gray-500 dark:text-gray-200">
                <%= @author.username %>
              </span>
              started following you
            </span>
          </div>
          <span class="text-gray-400 dark:text-gray-200 text-xs">
            <%= Timex.from_now(@time) %>
          </span>
        </div>
      </li>
    <% end %>
    """
  end

  defp assign_notification(assigns, "following"), do: assigns

  defp assign_notification(assigns, "post_like") do
    notification = Repo.preload(assigns.notification, [:post])

    assign(assigns, :notification, notification)
  end

  defp assign_notification(assigns, action) when action in ["comment", "comment_like"] do
    notification = Repo.preload(assigns.notification, [:comment, :post])

    assign(assigns, :notification, notification)
  end
end
