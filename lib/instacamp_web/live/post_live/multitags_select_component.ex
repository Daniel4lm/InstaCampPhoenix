defmodule InstacampWeb.PostLive.MultitagsSelectComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias InstacampWeb.Components.Icons

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:placeholder, set_placeholder(assigns.topics))
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="flex flex-wrap border border-gray-400 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 focus-within:ring-2 focus-within:ring-indigo-400 dark:focus-within:ring-blue-400 dark:focus-within:border-transparent ring-opacity-90 focus-within:border-transparent overflow-hidden rounded-md bg-white">
      <div class="flex items-center flex-wrap flex-1">
        <%= for topic <- @topics do %>
          <div
            id={"post-topic-#{topic}"}
            class="flex flex-row justify-center items-center rounded rounded-lg text-sm md:text-base text-gray-600 text-center bg-indigo-100 dark:bg-slate-300 p-2 mx-1"
          >
            #<%= topic %>
            <div
              id={"remove-topic-#{topic}"}
              phx-click="remove_topic"
              phx-value-topic={topic}
              phx-target={@myself}
              class="w-5 h-5 cursor-pointer ml-2 rounded-full flex justify-center items-center
                     hover:transition-all hover:duration-[600] hover:ease-in-out hover:text-red-600"
            >
              <Icons.close />
            </div>
          </div>
        <% end %>
        <%= text_input(@form, @field,
          placeholder: @placeholder,
          class:
            "flex-1 px-2 py-3 border-0 dark:bg-slate-700 placeholder-gray-500 dark:placeholder-slate-400 outline-none focus:ring-0 text-sm md:text-base",
          autocomplete: "off",
          phx_target: @myself,
          phx_hook: "CreatePostTag"
        ) %>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("remove_topic", %{"topic" => item} = _params, socket) do
    send(self(), {:remove_topic, item})
    {:noreply, socket}
  end

  defp set_placeholder([]), do: "Add new tags here..."
  defp set_placeholder([_h | _rest]), do: "Add more tags..."
end
