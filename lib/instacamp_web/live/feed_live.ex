defmodule InstacampWeb.FeedLive do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Posts
  alias Instacamp.Posts.FilterPost
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.PostCardComponent
  alias InstacampWeb.Endpoint
  alias InstacampWeb.TopicHelper

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        {:ok, redirect(socket, to: Routes.user_auth_login_path(socket, :new))}

      user ->
        if connected?(socket) do
          :ok =
            user.id
            |> TopicHelper.user_notification_topic()
            |> Endpoint.subscribe()
        end

        {:ok,
         socket
         |> assign(:page, 1)
         |> assign(:per_page, 5)
         |> assign(:post_feed_section_update, "append")
         |> set_loader_status(false), temporary_assigns: [post_feed: nil]}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    params_map = Map.take(params, ["author", "tag", "title", "with_comments"])

    socket
    |> assign(:page_title, "Searching posts")
    |> assign_filter_post_changeset(params_map)
    |> assign_post_feed()
  end

  @impl Phoenix.LiveView
  def handle_event("filter_posts", %{"post_filter" => filter_options}, socket) do
    url_params =
      filter_options
      |> Enum.reject(fn {_key, value} ->
        is_nil(value) || String.length(value) == 0 || value in ["false", false]
      end)
      |> Map.new()

    {:noreply, patch_page(socket, url_params)}
  end

  def handle_event("reset_form", _params, socket) do
    {:noreply, patch_page(socket)}
  end

  def handle_event("show_more_posts", %{"page" => new_page} = _params, socket) do
    total_posts = socket.assigns.post_feed_count
    per_page = socket.assigns.per_page
    total_pages = ceil(total_posts / per_page)

    socket =
      if new_page <= total_pages do
        socket
        |> assign(:page, new_page)
        |> assign(:post_feed_section_update, "append")
        |> assign_post_feed()
      else
        set_loader_status(socket, false)
      end

    {:noreply, socket}
  end

  defp patch_page(socket, params \\ %{}) do
    socket
    |> assign(:page, 1)
    |> assign(:post_feed_section_update, "replace")
    |> push_patch(to: Routes.feed_path(socket, :index, params), replace: true)
  end

  defp assign_filter_post_changeset(socket, params_map) do
    posts_filter = format_filter_options(params_map)

    socket
    |> assign(:post_filter, posts_filter)
    |> assign(:post_filter_changeset, Posts.change_filter_post(posts_filter))
  end

  defp assign_post_feed(socket) do
    cur_page = socket.assigns.page
    per_page = socket.assigns.per_page
    post_filter = socket.assigns.post_filter
    post_feed_count = Posts.count_post_feed(post_filter)
    total_pages = ceil(post_feed_count / per_page)

    socket
    |> assign(:post_feed, Posts.get_post_feed(cur_page, per_page, post_filter))
    |> assign(:post_feed_count, post_feed_count)
    |> set_loader_status(cur_page < total_pages)
  end

  defp format_filter_options(opts) do
    options =
      Map.merge(
        %{
          "author" => nil,
          "title" => nil,
          "tag" => nil,
          "with_comments" => "false"
        },
        opts
      )

    author =
      if(options["author"] && String.length(options["author"]) > 0,
        do: options["author"],
        else: nil
      )

    title =
      if(options["title"] && String.length(options["title"]) > 0, do: options["title"], else: nil)

    tag = if(options["tag"] && String.length(options["tag"]) > 0, do: options["tag"], else: nil)
    with_comments = options["with_comments"] == "true"

    %FilterPost{
      author: author,
      title: title,
      tag: tag,
      with_comments: with_comments
    }
  end

  defp set_loader_status(socket, status), do: assign(socket, :show_posts_loader?, status)
end
