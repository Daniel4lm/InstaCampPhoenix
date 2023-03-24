defmodule InstacampWeb.PostListLive.SavedList do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Endpoint
  alias InstacampWeb.PostListLive.SavedListComponents
  alias InstacampWeb.PostListLive.SettingsTabsComponent
  alias InstacampWeb.TopicHelper

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user = if(socket.assigns[:current_user], do: socket.assigns.current_user, else: nil)

    :ok =
      user.id
      |> TopicHelper.user_notification_topic()
      |> Endpoint.subscribe()

    saved_list_path = Routes.saved_list_path_path(socket, :list)
    search_list_path = Routes.saved_list_path_path(socket, :search)

    setting_tabs = [
      %{title: "Saved list", path: saved_list_path},
      %{title: "Search", path: search_list_path}
    ]

    {
      :ok,
      socket
      |> assign(posts_page: 1, per_page: 10)
      |> assign(:user, user)
      |> assign_reading_list()
      |> assign(:search_list, [])
      |> assign(:setting_tabs, setting_tabs)
      #  |> set_load_more_posts()
    }
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :list, _params) do
    user = socket.assigns.user

    socket
    |> assign(:page_title, "Reading list")
    |> assign(:user_bookmarks_count, Posts.count_user_bookmarks(user))
    |> assign_reading_list()
    |> set_load_more_posts()
  end

  defp apply_action(socket, :search, _params) do
    socket
    |> assign(:page_title, "Search saved posts")
    |> assign(:user_bookmarks_count, 0)
    |> assign(:search_list, [])
    |> set_load_more_posts()
  end

  @impl Phoenix.LiveView
  def handle_event("load_more_posts", _params, socket) do
    reading_list_total = socket.assigns.user_bookmarks_count
    page = socket.assigns.posts_page
    per_page = socket.assigns.per_page
    total_pages = ceil(reading_list_total / per_page)

    more_pages_btn = if(page + 1 == total_pages, do: "hidden", else: "flex")

    {:noreply,
     socket
     |> update(:posts_page, fn page -> page + 1 end)
     |> assign(:load_more_posts_btn, more_pages_btn)
     |> assign_reading_list()}
  end

  def handle_event("search_list", %{"list_search" => %{"term" => ""}}, socket),
    do: {:noreply, socket}

  def handle_event("search_list", %{"list_search" => %{"term" => search_term}}, socket) do
    search_value = String.downcase(search_term)

    filtered_list =
      Enum.filter(
        socket.assigns.reading_list,
        &(&1.title
          |> String.downcase()
          |> String.contains?(search_value))
      )

    {
      :noreply,
      socket
      |> assign(:user_bookmarks_count, Enum.count(filtered_list))
      |> assign(:search_list, filtered_list)
      |> set_load_more_posts()
    }
  end

  def handle_event("delete_from_list", %{"id" => save_id}, socket) do
    post = Posts.get_post!(save_id)
    post_bookmark = Posts.is_bookmarked(post, socket.assigns.user)
    {:ok, _deleted_bookmark} = Posts.unbookmark(post_bookmark)

    post_bookmark.post_id
    |> TopicHelper.post_bookmark_topic()
    |> Endpoint.broadcast("bookmark_post", %{bookmark: nil})

    filtered_reading_list =
      Enum.filter(
        socket.assigns.reading_list,
        &(&1.id != save_id)
      )

    filtered_search_list =
      Enum.filter(
        socket.assigns.search_list,
        &(&1.id != save_id)
      )

    {:noreply,
     socket
     |> assign(:reading_list, filtered_reading_list)
     |> assign(:search_list, filtered_search_list)
     |> assign(:user_bookmarks_count, Enum.count(filtered_reading_list))}
  end

  defp assign_reading_list(socket) do
    user = socket.assigns.user
    page = socket.assigns.posts_page
    per_page = socket.assigns.per_page

    user_saved_posts = Posts.list_user_saved_posts(user, page, per_page)
    assign(socket, :reading_list, user_saved_posts)
  end

  defp set_load_more_posts(socket) do
    reading_list_total = socket.assigns.user_bookmarks_count
    per_page = socket.assigns.per_page

    if reading_list_total > per_page do
      assign(socket, :load_more_posts_btn, "flex")
    else
      assign(socket, :load_more_posts_btn, "hidden")
    end
  end
end
