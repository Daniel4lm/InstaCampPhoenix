defmodule InstacampWeb.PostLive.List do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Posts

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"name" => name}) do
    blog_posts = Posts.search_posts_by_tag(name)

    socket
    |> assign(:page_title, "Topic - ##{name}")
    |> assign(:blog_posts, blog_posts)
  end
end
