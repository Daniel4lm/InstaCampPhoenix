defmodule InstacampWeb.SettingsLive.Components.FollowComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.Accounts
  alias InstacampWeb.Endpoint
  alias InstacampWeb.TopicHelper

  @impl Phoenix.LiveComponent
  def update(%{current_user: nil} = assigns, socket) do
    {:ok,
     socket
     |> assign(:state_text, "Follow")
     |> assign(assigns)}
  end

  def update(%{current_user: current_user, user: user} = assigns, socket) do
    user_follow = Accounts.get_following(current_user.id, user.id)

    {:ok,
     socket
     |> assign(:state_text, if(user_follow, do: "Unfollow", else: "Follow"))
     |> assign(
       :follow_btn_style,
       if(user_follow,
         do: get_follow_btn_style("unfollow"),
         else: get_follow_btn_style("follow")
       )
     )
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(%{current_user: nil} = assigns) do
    ~H"""
    <div class="my-2">
      <.link
        href={~p"/auth/login"}
        class="py-1 px-5 border-none shadow rounded-full text-gray-50 hover:bg-light-blue-600 bg-light-blue-500"
      >
        <%= @state_text %>
      </.link>
    </div>
    """
  end

  def render(%{current_user: current_user, user: user} = assigns)
      when current_user.id == user.id do
    ~H"""
    <div class="my-2">
      <.link
        patch={~p"/accounts/edit"}
        class="py-1 px-4 border-2 rounded-full font-semibold hover:bg-gray-50 dark:hover:bg-inherit"
      >
        Edit Profile
      </.link>
    </div>
    """
  end

  def render(%{current_user: _current_user} = assigns) do
    ~H"""
    <button
      id="follow-component"
      phx-target={@myself}
      phx-click="toggle_follow_status"
      class="focus:outline-none"
    >
      <span class="while-submitting">
        <span class={
          "block #{@follow_btn_style} w-28 inline-flex items-center transition ease-in-out duration-150 cursor-not-allowed"
        }>
          <svg
            class="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-300"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
            </circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            >
            </path>
          </svg>
          Saving
        </span>
      </span>

      <span id="follow-state" class={"block #{@follow_btn_style} w-28"}><%= @state_text %></span>
    </button>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_follow_status", _params, socket) do
    current_user = socket.assigns.current_user
    user = socket.assigns.user

    :timer.sleep(200)

    if Accounts.get_following(current_user.id, user.id) do
      unfollow_user(socket, current_user.id, user.id)
    else
      follow_user(socket, current_user, user)
    end
  end

  defp follow_user(socket, current_user, user) do
    updated_user = Accounts.create_follow(current_user, user, current_user)

    send(self(), {__MODULE__, :update_user_profile, updated_user})
    follow_broadcast(updated_user)

    Endpoint.broadcast_from(
      self(),
      TopicHelper.user_notification_topic(user.id),
      "notify_user",
      %{}
    )

    {:noreply,
     socket
     |> assign(:state_text, "Unfollow")
     |> assign(:follow_btn_style, "user-profile-unfollow-btn")}
  end

  defp unfollow_user(socket, current_user_id, user_id) do
    updated_user = Accounts.unfollow(current_user_id, user_id)

    send(self(), {__MODULE__, :update_user_profile, updated_user})
    follow_broadcast(updated_user)

    {:noreply,
     socket
     |> assign(:state_text, "Follow")
     |> assign(:follow_btn_style, "user-profile-follow-btn")}
  end

  defp follow_broadcast(user) do
    user.id
    |> TopicHelper.following_topic()
    |> Endpoint.broadcast("follow_user", %{user: user})
  end

  defp get_follow_btn_style("unfollow") do
    "py-1 px-5 text-red-500 border-2 rounded-full font-semibold hover:bg-gray-50 dark:hover:bg-transparent focus:outline-none"
  end

  defp get_follow_btn_style("follow") do
    "py-1 px-5 border-2 border-transparent shadow rounded-full text-gray-50 hover:bg-light-blue-600 bg-light-blue-500 focus:outline-none"
  end
end
