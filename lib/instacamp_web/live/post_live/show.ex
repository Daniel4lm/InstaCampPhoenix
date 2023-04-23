defmodule InstacampWeb.PostLive.Show do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.DateTimeHelper
  alias Instacamp.FileHandler
  alias Instacamp.Posts
  alias Instacamp.Posts.Comment
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Posts.CommentComponent
  alias InstacampWeb.Components.Posts.LikeComponent
  alias InstacampWeb.Components.Posts.TagComponent
  alias InstacampWeb.Endpoint
  alias InstacampWeb.PostLive.EditComment
  alias InstacampWeb.PostLive.SideNav
  alias InstacampWeb.TopicHelper
  alias Phoenix.LiveView.JS
  alias Phoenix.Socket.Broadcast

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug}, _session, socket) do
    user = if(socket.assigns[:current_user], do: socket.assigns.current_user, else: nil)
    user_post = Posts.get_post_by_slug!(slug)
    comment_changeset = Posts.change_comment(%Comment{})

    if connected?(socket) && user do
      topic_subscriptions(user.id, user_post.id)
    end

    {
      :ok,
      socket
      |> assign(comments_page: 1, per_page: 5)
      |> assign(:comments_section_update, "prepend")
      |> assign(:comment_changeset, comment_changeset)
      |> assign(:post, user_post)
      |> assign(:is_taged?, Posts.is_bookmarked(user_post, user))
      |> assign(:bookmarks_count, Posts.count_post_bookmarks(user_post))
      |> assign_comments()
      |> assign(:side_nav_items, [])
      |> assign(:page_title, user_post.title)
      |> set_load_more_comments(),
      temporary_assigns: [post_comments: []]
    }
  end

  defp topic_subscriptions(user_id, post_id) do
    :ok =
      post_id
      |> TopicHelper.post_comment_topic()
      |> Endpoint.subscribe()

    :ok =
      post_id
      |> TopicHelper.post_or_comment_like_topic()
      |> Endpoint.subscribe()

    :ok =
      post_id
      |> TopicHelper.post_topic()
      |> Endpoint.subscribe()

    :ok =
      post_id
      |> TopicHelper.post_bookmark_topic()
      |> Endpoint.subscribe()

    :ok =
      user_id
      |> TopicHelper.user_notification_topic()
      |> Endpoint.subscribe()
  end

  @impl Phoenix.LiveView
  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign(:copy_url, url)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_comment, %{"id" => id}) do
    comment = Posts.get_comment!(id)

    socket
    |> assign(:page_title, "Edit comment")
    |> assign(:comment_changeset, Posts.change_comment(comment))
    |> assign(:comment, comment)
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl Phoenix.LiveView
  def handle_event("save_comment", %{"comment" => %{"body" => ""}} = _params, socket),
    do: {:noreply, socket}

  def handle_event("save_comment", %{"comment" => comment_attrs} = _params, socket) do
    live_action = socket.assigns.live_action

    action_type = %{
      :show => :new,
      :edit_comment => :edit
    }

    comment = if live_action == :show, do: %Comment{}, else: socket.assigns.comment

    case Posts.create_or_update_comment(
           comment,
           socket.assigns.post,
           socket.assigns.current_user,
           action_type[live_action],
           comment_attrs
         ) do
      {:ok, comment} ->
        socket.assigns.post.id
        |> TopicHelper.post_comment_topic()
        |> Endpoint.broadcast("create_post_comment", %{comment: comment})

        broadcast_on_update_post_comment(socket.assigns.post)

        if action_type[live_action] == :new do
          Endpoint.broadcast_from(
            self(),
            TopicHelper.user_notification_topic(socket.assigns.post.user_id),
            "notify_user",
            %{}
          )
        end

        {:noreply,
         socket
         |> assign(:comment_changeset, Posts.change_comment(%Comment{}))
         |> maybe_return_to_show_page(action_type[live_action])}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete_comment", %{"id" => id}, socket) do
    comment = Posts.get_comment!(id)
    {:ok, _comment} = Posts.delete_comment(comment, socket.assigns.post)

    socket.assigns.post.id
    |> TopicHelper.post_comment_topic()
    |> Endpoint.broadcast("delete_post_comment", %{comment: comment})

    broadcast_on_update_post_comment(socket.assigns.post)

    {:noreply, assign_comments(socket)}
  end

  def handle_event("delete_post", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post, socket.assigns.current_user)

    {:noreply, redirect(socket, to: ~p"/user/#{post.user.username}")}
  end

  def handle_event("load_more_comments", _params, socket) do
    total_comments = socket.assigns.post.total_comments
    page = socket.assigns.comments_page
    per_page = socket.assigns.per_page
    total_pages = ceil(total_comments / per_page)

    more_comments_btn = if(page + 1 == total_pages, do: "hidden", else: "flex")

    {:noreply,
     socket
     |> assign(:comments_section_update, "append")
     |> update(:comments_page, fn page -> page + 1 end)
     |> assign(:load_more_comments_btn, more_comments_btn)
     |> assign_comments()}
  end

  def handle_event("side_nav_items", %{"side_items" => post_sections}, socket) do
    {:noreply, assign(socket, :side_nav_items, post_sections)}
  end

  @impl Phoenix.LiveView
  def handle_info(
        %Broadcast{
          event: "create_post_comment",
          payload: %{comment: comment},
          topic: "post_comments:" <> post_id
        } = _message,
        socket
      ) do
    {:noreply,
     socket
     |> assign(comments_section_update: "prepend")
     |> update(:post_comments, fn comments -> [comment | comments] end)
     |> update(:post, fn _post -> Posts.get_post!(post_id) end)}
  end

  def handle_info(
        %Broadcast{
          event: "delete_post_comment",
          payload: %{comment: _comment},
          topic: "post_comments:" <> post_id
        } = _message,
        socket
      ) do
    {:noreply,
     socket
     |> assign(comments_section_update: "replace")
     |> assign_comments()
     |> update(:post, fn _post -> Posts.get_post!(post_id) end)}
  end

  def handle_info(
        %Broadcast{
          event: event_name,
          payload: %{post: post}
          # topic: "post:" <> _post_id
        },
        socket
      )
      when event_name in ["post_update", "like_post"] do
    {:noreply, update(socket, :post, fn _post -> post end)}
  end

  def handle_info(
        %Broadcast{
          event: "like_post_comment",
          topic: "post_or_comment_likes:" <> _post_id
        } = _message,
        socket
      ) do
    {:noreply, assign_comments(socket)}
  end

  def handle_info(
        %Broadcast{
          event: "bookmark_post",
          payload: %{bookmark: bookmark},
          topic: "post_bookmark:" <> _post_id
        } = _message,
        socket
      ) do
    {:noreply,
     socket
     |> assign(:is_taged?, bookmark)
     |> assign(:bookmarks_count, Posts.count_post_bookmarks(socket.assigns.post))}
  end

  defp assign_comments(socket) do
    page = socket.assigns.comments_page
    post = socket.assigns.post
    per_page = socket.assigns.per_page

    comments = Posts.list_post_comments(post, page, per_page)
    assign(socket, :post_comments, comments)
  end

  defp broadcast_on_update_post_comment(post) do
    post.user_id
    |> TopicHelper.user_posts_topic()
    |> Endpoint.broadcast("update_post_comment", %{post: post})
  end

  defp maybe_return_to_show_page(socket, :new), do: socket

  defp maybe_return_to_show_page(socket, :edit),
    do: push_navigate(socket, to: ~p"/post/#{socket.assigns.post.slug}")

  defp set_load_more_comments(socket) do
    post_total_comments = socket.assigns.post.total_comments
    per_page = socket.assigns.per_page

    if post_total_comments > per_page do
      assign(socket, :load_more_comments_btn, "flex")
    else
      assign(socket, :load_more_comments_btn, "hidden")
    end
  end
end
