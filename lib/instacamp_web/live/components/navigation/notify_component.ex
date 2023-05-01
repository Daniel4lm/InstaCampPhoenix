defmodule InstacampWeb.Components.Navigation.NotifyComponent do
  @moduledoc false

  use InstacampWeb, :html

  alias Instacamp.FileHandler
  alias Instacamp.Repo
  alias InstacampWeb.CoreComponents

  @type assigns :: map()
  @type output :: Phoenix.LiveView.Rendered.t()

  @spec user_notify(assigns()) :: output()
  def user_notify(%{action_type: action_type} = assigns)
      when action_type in ["comment", "comment_reply"] do
    notify_message = %{
      "comment" => "commented on your post",
      "comment_reply" => "replied to your comment"
    }

    assigns =
      assigns
      |> assign(:author, assigns.notification.author)
      |> assign_notification(action_type)
      |> assign(:notify_message, notify_message[action_type])
      |> assign(:time, assigns.notification.inserted_at)

    ~H"""
    <li
      id={"notification-#{@notification.action_type}-#{@notification.id}"}
      class="flex items-center p-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50"
    >
      <CoreComponents.user_avatar
        with_link={~p"/user/#{@author.username}"}
        src={FileHandler.get_avatar_thumb(@author.avatar_url)}
        class="w-8 h-8"
      />

      <.link
        navigate={~p"/post/#{@notification.post.slug}/#comment-#{@notification.comment.id}"}
        class="w-11/12 px-2"
      >
        <div>
          <.notify_body
            author={@author.username}
            message={@notify_message}
            title={@notification.post.title}
            time={@time}
          />
        </div>
      </.link>
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
    <li
      id={"notification-#{@notification.action_type}-#{@notification.id}"}
      class="flex items-center p-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50"
    >
      <CoreComponents.user_avatar
        with_link={~p"/user/#{@author.username}"}
        src={FileHandler.get_avatar_thumb(@author.avatar_url)}
        class="w-8 h-8"
      />
      <.link navigate={~p"/post/#{@notification.post.slug}"} class="w-11/12 px-2">
        <div>
          <.notify_body
            author={@author.username}
            message="liked your post"
            title={@notification.post.title}
            time={@time}
          />
        </div>
      </.link>
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
    <li
      id={"notification-#{@notification.action_type}-#{@notification.id}"}
      class="flex items-center px-2 py-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50"
    >
      <CoreComponents.user_avatar
        with_link={~p"/user/#{@author.username}"}
        src={FileHandler.get_avatar_thumb(@author.avatar_url)}
        class="w-8 h-8"
      />
      <.link
        navigate={~p"/post/#{@notification.post.slug}/#comment-#{@notification.comment.id}"}
        class="w-11/12 px-2"
      >
        <div>
          <.notify_body
            author={@author.username}
            message="liked your comment"
            title={@notification.post.title}
            time={@time}
          />
        </div>
      </.link>
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
    <.link navigate={~p"/user/#{@author.username}"} class="w-[2rem]">
      <li
        id={"notification-#{@notification.action_type}-#{@notification.id}"}
        class="flex items-center px-2 py-2 rounded-lg hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50"
      >
        <CoreComponents.user_avatar
          src={FileHandler.get_avatar_thumb(@author.avatar_url)}
          class="w-8 h-8"
        />

        <div class="px-2">
          <.notify_body
            author={@author.username}
            message="started following you"
            title={nil}
            time={@time}
          />
        </div>
      </li>
    </.link>
    """
  end

  defp notify_body(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center">
      <span class="text-sm font-light">
        <span class="font-bold text-sm text-gray-500 dark:text-gray-200">
          <%= @author %>
        </span>
        <%= @message %>
      </span>
    </div>
    <span :if={@title} class="block truncate"><%= @title %></span>
    <span class="text-gray-400 dark:text-gray-200 text-xs">
      <%= Timex.from_now(@time) %>
    </span>
    """
  end

  defp assign_notification(assigns, "following"), do: assigns

  defp assign_notification(assigns, "post_like") do
    notification = Repo.preload(assigns.notification, [:post])

    assign(assigns, :notification, notification)
  end

  defp assign_notification(assigns, action)
       when action in ["comment", "comment_like", "comment_reply"] do
    notification = Repo.preload(assigns.notification, [:comment, :post])

    assign(assigns, :notification, notification)
  end
end
