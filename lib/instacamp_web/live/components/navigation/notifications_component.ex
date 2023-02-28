defmodule InstacampWeb.Components.Navigation.NotificationsComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.Notifications
  alias InstacampWeb.Components.Icons
  alias InstacampWeb.Components.Navigation.NotifyComponent
  alias Phoenix.LiveView.JS

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(notifications: [])
     |> assign(while_searching_notifications?: false)}
  end

  @impl Phoenix.LiveComponent
  def update(%{unread_notifications?: unread?} = assigns, socket) do
    {:ok,
     socket
     |> assign(unread_notifications?: unread?)
     |> assign(assigns)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(unread_notifications?: unread_notification?(assigns))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("get_notifications", _params, socket) do
    unread_notifications? = socket.assigns.unread_notifications?

    send(self(), {:get_user_notifications, unread_notifications?})

    {:noreply,
     socket
     |> assign(notifications: [])
     |> assign(while_searching_notifications?: true)}
  end

  defp any_notification_today?(notifications) do
    today = NaiveDateTime.to_date(DateTime.utc_now())

    Enum.any?(notifications, fn notify ->
      Date.compare(today, NaiveDateTime.to_date(notify.inserted_at)) == :eq
    end)
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <li id="notifications-comp" class=" ml-4 text-gray-600 dark:text-gray-200">
      <div
        id="notifications"
        class="relative flex items-center justify-center flex-col sm:flex-row cursor-pointer hover:text-indigo-400 dark:hover:text-inherit"
        phx-hook="ToolTip"
        phx-click={
          JS.push("get_notifications", target: @myself)
          |> JS.toggle(
            to: "#notifications-list",
            in: "transition ease-out duration-200",
            out: "transition ease-out duration-200 opacity-0 transform scale-90"
          )
        }
        phx-target={@myself}
      >
        <div class="relative">
          <Icons.notify_icon />
          <%= if @unread_notifications? do %>
            <span class="absolute rounded-full w-3 h-3 border-2 border-white bg-red-500 top-0 right-0" />
          <% end %>
        </div>
        <span class="sm:ml-1 font-semibold">Activity</span>
        <span class="bottom-tooltip-text px-4 py-2 rounded-md bg-indigo-500 dark:bg-slate-500 text-white text-sm ">
          User notifications
        </span>
      </div>

      <div
        id="notifications-list"
        phx-click-away={
          JS.hide(
            to: "#notifications-list",
            transition: "transition ease-out duration-200 opacity-0 transform scale-90"
          )
        }
        class="hidden z-10 absolute bg-white dark:bg-slate-500 dark:text-slate-100 right-1/2 translate-x-1/2 md:translate-x-0 md:right-2 p-2 top-12 w-11/12 md:w-[46rem] lg:w-[56rem] border-2 border-slate-300 dark:border-slate-400 rounded-lg shadow-sm"
      >
        <ul class="overflow-y-scroll p-2 h-96">
          <%= unless any_notification_today?(@notifications) do %>
            <li class="flex flex-col justify-center items-center py-4 mb-2 border-b dark:border-slate-400">
              <Icons.all_done />
              <span class="my-2">Nothing new for you today.</span>
            </li>
            <p class="px-2 mb-2 font-semibold">Previous notifications</p>
          <% end %>

          <%= for notification <- @notifications do %>
            <NotifyComponent.user_notify
              action_type={notification.action_type}
              socket={@socket}
              notification={notification}
            />
          <% end %>

          <%= if @while_searching_notifications? do %>
            <li class="flex justify-center items-center h-full">
              <Icons.while_searching />
            </li>
          <% end %>
        </ul>
      </div>
    </li>
    """
  end

  defp unread_notification?(assigns) do
    if assigns.current_user do
      Notifications.all_unread?(assigns.current_user.id)
    else
      false
    end
  end
end
