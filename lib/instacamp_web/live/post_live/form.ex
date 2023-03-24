defmodule InstacampWeb.PostLive.Form do
  @moduledoc false

  use InstacampWeb, :live_view

  alias Instacamp.FileHandler
  alias Instacamp.Posts
  alias Instacamp.Posts.Post
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Endpoint
  alias InstacampWeb.PostLive.MultitagsSelectComponent
  alias InstacampWeb.TopicHelper

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:post_tags, [])
     |> allow_upload(:photo_url,
       accept: ~w(.jpg .jpeg .png),
       max_file_size: 30_000_000
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    blog_post = Posts.get_post!(id)

    socket
    |> assign(:page_title, "Edit blog post")
    |> assign(:blog_post, blog_post)
    |> assign_tags(blog_post.tags)
    |> assign(:post_changeset, Posts.change_post(blog_post))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New blog post")
    |> assign(:blog_post, %Post{})
    |> assign(:post_changeset, Posts.change_post(%Post{}))
  end

  defp assign_tags(socket, post_tags) do
    tags = Enum.map(post_tags, & &1.name)
    assign(socket, :post_tags, tags)
  end

  @impl Phoenix.LiveView
  def handle_event("cancel_image_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo_url, ref)}
  end

  def handle_event("add-item", item, socket) do
    new_tags = Enum.uniq([item | socket.assigns.post_tags])

    {:noreply,
     socket
     |> assign(:post_tags, new_tags)
     |> clear_tag_from_changeset()}
  end

  def handle_event("validate_post", %{"post" => post_params}, socket) do
    post_changeset =
      %Post{}
      |> Posts.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :post_changeset, post_changeset)}
  end

  def handle_event("save_post", %{"post" => post_params}, socket) do
    live_action = socket.assigns.live_action

    file_path =
      FileHandler.maybe_upload_image(
        socket,
        "/uploads/blog",
        "priv/static/uploads/blog",
        :photo_url
      )

    params = if file_path, do: Map.put(post_params, "photo_url", file_path), else: post_params

    changeset =
      %Post{}
      |> Posts.change_post(params)
      |> Map.put(:action, :insert)

    with true <- changeset.valid?,
         {:ok, post} <-
           Posts.create_or_update_post(
             socket.assigns.blog_post,
             socket.assigns.current_user,
             live_action,
             Map.put(params, "tags", parse_tags(socket.assigns.post_tags))
           ) do
      post_action_broadcast(live_action, post)

      {:noreply,
       push_redirect(socket,
         to: Routes.user_profile_path(socket, :index, socket.assigns.current_user.username)
       )}
    else
      false ->
        {:noreply, assign(socket, post_changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, post_changeset: changeset)}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:remove_topic, topic}, socket) do
    items = Enum.filter(socket.assigns.post_tags, &(&1 != topic))

    {:noreply, assign(socket, :post_tags, items)}
  end

  defp clear_tag_from_changeset(socket) do
    changeset_from_socket = socket.assigns.post_changeset
    changes_from_changeset = Enum.into(changeset_from_socket.changes, %{tag: ""})

    post_changeset =
      %Post{}
      |> Posts.change_post(changes_from_changeset)
      |> Map.put(:action, :validate)

    assign(socket, :post_changeset, post_changeset)
  end

  defp parse_tags(tags_list) do
    tags_list
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(String.length(&1) < 3))
    |> Posts.insert_tags()
  end

  defp post_action_broadcast(:new, post) do
    post.user_id
    |> TopicHelper.user_posts_topic()
    |> Endpoint.broadcast("new_post", %{post: post})
  end

  defp post_action_broadcast(:edit, post) do
    post.id
    |> TopicHelper.post_topic()
    |> Endpoint.broadcast("post_update", %{post: post})

    post.user_id
    |> TopicHelper.user_posts_topic()
    |> Endpoint.broadcast("post_update", %{post: post})
  end
end
