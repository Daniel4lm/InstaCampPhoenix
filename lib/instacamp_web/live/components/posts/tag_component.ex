defmodule InstacampWeb.Components.Posts.TagComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Endpoint
  alias InstacampWeb.TopicHelper

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    user = if(assigns[:current_user], do: assigns.current_user, else: nil)

    {:ok,
     socket
     |> assign(:is_taged?, Posts.is_bookmarked(assigns.post, user))
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <button
      id={"tag-component-#{@post.id}"}
      phx-target={@myself}
      phx-click="toggle_tag"
      class={
        "#{if(@is_taged?, do: "text-indigo-500 dark:text-blue-500", else: "text-inherit")} focus:outline-none block"
      }
    >
      <%= unless @is_taged? do %>
        <Icons.new_tag_icon />
      <% else %>
        <Icons.tag_icon is_taged?={@is_taged?} />
      <% end %>
    </button>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_tag", _params, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post
    is_taged? = socket.assigns.is_taged?

    if is_taged? do
      {:ok, deleted_bookmark} = Posts.unbookmark(socket.assigns.is_taged?)
      broadcast_on_post_unbookmark(deleted_bookmark)
      {:noreply, assign(socket, :is_taged?, nil)}
    else
      {:ok, bookmark} = Posts.create_bookmark(post, user)
      broadcast_on_post_bookmark(bookmark)
      {:noreply, assign(socket, :is_taged?, bookmark)}
    end
  end

  defp broadcast_on_post_bookmark(bookmark) do
    bookmark.post_id
    |> TopicHelper.post_bookmark_topic()
    |> Endpoint.broadcast("bookmark_post", %{bookmark: bookmark})
  end

  defp broadcast_on_post_unbookmark(bookmark) do
    bookmark.post_id
    |> TopicHelper.post_bookmark_topic()
    |> Endpoint.broadcast("bookmark_post", %{bookmark: nil})
  end
end
