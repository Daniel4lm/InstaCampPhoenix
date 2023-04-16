defmodule InstacampWeb.SettingsLive.UserProfile do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.Accounts
  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.PostCardComponent
  alias InstacampWeb.Endpoint
  alias InstacampWeb.SettingsLive.Components.FollowComponent
  alias InstacampWeb.SettingsLive.Components.FollowListComponent
  alias InstacampWeb.TopicHelper
  alias Phoenix.Socket.Broadcast

  @impl Phoenix.LiveView
  def mount(%{"username" => username} = _params, _session, socket) do
    user = Accounts.get_user_by_username(username)

    if connected?(socket) do
      :ok =
        user.id
        |> TopicHelper.user_posts_topic()
        |> Endpoint.subscribe()

      :ok =
        user.id
        |> TopicHelper.user_notification_topic()
        |> Endpoint.subscribe()

      :ok =
        user.id
        |> TopicHelper.following_topic()
        |> Endpoint.subscribe()
    end

    {
      :ok,
      socket
      |> assign(:page, 1)
      |> assign(:per_page, 5)
      |> assign(:active_section, "posts")
      |> assign(:comments_count, Enum.count(user.comments))
      |> assign(:bookmarks_count, Posts.count_user_bookmarks(user))
      |> stream(:user_posts, [])
      |> assign(:user, user)
      |> set_loader_status(false)
    }
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    {:noreply,
     socket
     |> assign(current_uri_path: URI.parse(uri).path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    user = socket.assigns.user

    if is_nil(user) do
      redirect(socket, to: ~p"/auth/login")
    else
      socket
      |> assign(:page_title, "#{user.full_name} (@#{user.username})")
      |> assign(:active_section, "posts")
      |> assign_posts()
    end
  end

  defp apply_action(socket, :following, _params) do
    following = Accounts.list_following(socket.assigns.user)
    assign(socket, :following, following)
  end

  defp apply_action(socket, :followers, _params) do
    followers = Accounts.list_followers(socket.assigns.user)
    assign(socket, :followers, followers)
  end

  @impl Phoenix.LiveView
  def handle_event("show_more_posts", %{"page" => new_page} = _params, socket) do
    total_posts = socket.assigns.user.posts_count
    per_page = socket.assigns.per_page
    total_pages = ceil(total_posts / per_page)

    socket =
      if new_page <= total_pages do
        socket
        |> assign(:page, new_page)
        |> assign_posts()
      else
        set_loader_status(socket, false)
      end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({FollowComponent, :update_user_profile, updated_user}, socket) do
    profile_user = socket.assigns.user

    case profile_user.id == updated_user.id do
      true ->
        {:noreply, push_navigate(socket, to: ~p"/user/#{updated_user.username}")}

      false ->
        {:noreply, push_navigate(socket, to: ~p"/user/#{profile_user.username}")}
    end
  end

  def handle_info(
        %Broadcast{
          event: event_name,
          payload: %{post: post},
          topic: "user_posts:" <> _user_id
        },
        socket
      )
      when event_name in ["new_post", "post_update"] do
    {:noreply, update_post_list(socket, post)}
  end

  def handle_info(
        %Broadcast{
          event: event_name,
          payload: %{post: post},
          topic: "user_posts:" <> _user_id
        } = _message,
        socket
      )
      when event_name in ["like_post", "update_post_comment"] do
    {:noreply, update_post_list(socket, post)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "follow_user",
          payload: %{user: updated_user},
          topic: "following:" <> _user_id
        } = _message,
        socket
      ) do
    {:noreply, update(socket, :user, fn _user -> updated_user end)}
  end

  @spec display_website_uri(String.t()) :: String.t()
  def display_website_uri(website) do
    website =
      website
      |> String.replace_leading("https://", "")
      |> String.replace_leading("http://", "")

    website
  end

  defp update_post_list(socket, post) do
    stream_insert(socket, :user_posts, post, at: -1)
  end

  defp assign_posts(socket) do
    user = socket.assigns.user
    cur_page = socket.assigns.page
    total_posts = user.posts_count
    per_page = socket.assigns.per_page
    total_pages = ceil(total_posts / per_page)

    user_posts = Posts.list_user_profile_posts(user, cur_page, per_page)

    socket
    |> stream_batch_insert(:user_posts, user_posts)
    |> set_loader_status(cur_page < total_pages)
  end

  defp set_loader_status(socket, status), do: assign(socket, :show_posts_loader?, status)
end
