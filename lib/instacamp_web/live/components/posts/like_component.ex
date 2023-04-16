defmodule InstacampWeb.Components.Posts.LikeComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Endpoint
  alias InstacampWeb.TopicHelper

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:is_liked?, is_liked?(assigns.current_user, assigns.resource))
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <button
      id={"like-component-#{@resource.id}"}
      phx-target={@myself}
      phx-click="toggle_like"
      class="text-transparent focus:outline-none block"
    >
      <Icons.like_icon liked={@is_liked?} />
    </button>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_like", _params, socket) do
    user = socket.assigns.current_user
    resource = socket.assigns.resource
    resource_name = socket.assigns.resource_name

    if is_liked?(user, resource) do
      {:ok, _like} = Posts.unlike(user, resource_name, resource)
      like_broadcast(resource_name, resource)
      {:noreply, assign(socket, :is_liked?, false)}
    else
      {:ok, _like} = Posts.create_like(user, resource_name, resource)
      like_broadcast(resource_name, resource)
      notify_broadcast(resource.user_id)
      {:noreply, assign(socket, :is_liked?, true)}
    end
  end

  defp notify_broadcast(user_id) do
    Endpoint.broadcast_from(
      self(),
      TopicHelper.user_notification_topic(user_id),
      "notify_user",
      %{}
    )
  end

  defp like_broadcast(:post, resource) do
    updated_post = Posts.get_post!(resource.id)

    resource.id
    |> TopicHelper.post_or_comment_like_topic()
    |> Endpoint.broadcast("like_post", %{post: updated_post})

    resource.user_id
    |> TopicHelper.user_posts_topic()
    |> Endpoint.broadcast("like_post", %{post: updated_post})
  end

  defp like_broadcast(:comment, resource) do
    resource.post_id
    |> TopicHelper.post_or_comment_like_topic()
    |> Endpoint.broadcast("like_post_comment", %{comment_id: resource.id})
  end

  defp is_liked?(user, resource) do
    Enum.any?(resource.likes, fn like ->
      like.user_id == user.id
    end)
  end
end
