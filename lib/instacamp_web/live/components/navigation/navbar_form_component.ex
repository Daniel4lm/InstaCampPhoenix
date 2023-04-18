defmodule InstacampWeb.Components.Navigation.NavbarFormComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.Posts

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(:searched_posts, [])
     |> assign(:while_searching_posts?, false)
     |> assign(:posts_not_found?, false)
     |> assign(:overflow_y_scroll_ul, "")}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="relative hidden md:flex w-full md:w-2/5 mx-2">
      <form id="search-posts-form" class="w-full" phx-change="search_posts" phx-target={@myself}>
        <input
          id="posts-search-input"
          phx-debounce="1000"
          name="post_term"
          type="search"
          placeholder="Search posts"
          autocomplete="off"
          class="rounded-lg w-full border dark:bg-slate-500 bg-search-icon dark:bg-search-icon-dark bg-no-repeat bg-[length:20px] bg-[right_0.6em_center] ring-0 duration-100 ring-gray-400 focus:ring-2 focus:ring-indigo-400 dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent dark:text-gray-200 pr-[2.4em] pl-[0.8em] py-[0.4em] text-base placeholder:font-thin placeholder:text-slate-400 dark:placeholder:text-slate-300"
        />
      </form>

      <ul
        :if={@while_searching_posts?}
        id="post-search-list"
        phx-click-away={
          JS.push("hide_search_list", target: @myself)
          |> close_menu("post-search-list")
        }
        phx-window-keydown={
          JS.push("hide_search_list", target: @myself)
          |> close_menu("post-search-list")
        }
        phx-key="escape"
        phx-target={@myself}
        class={
            "absolute top-10 left-0 w-96 border-2 bg-white dark:bg-slate-500 dark:text-slate-100 border-slate-300 dark:border-0 rounded-md overflow-hidden shadow-sm #{if(@posts_not_found?, do: "h-40", else: "h-96")} #{@overflow_y_scroll_ul}"
          }
      >
        <.link :for={post <- @searched_posts} navigate={~p"/post/#{post.slug}"}>
          <li class="flex items-center rounded-md m-1 px-2 py-3 hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
            <%= if post.photo_url do %>
              <%= img_tag(post.photo_url,
                class: "w-10 h-10 rounded-md object-cover object-center"
              ) %>
            <% end %>
            <div class="ml-3">
              <h2 class="font-bold text-sm ">
                <%= post.title %>
              </h2>
              <h3 class="text-sm "><%= post.user.full_name %></h3>
            </div>
          </li>
        </.link>

        <li
          :if={@posts_not_found?}
          class="text-sm text-gray-400 dark:text-gray-200 flex justify-center items-center h-full"
        >
          No results found.
        </li>
      </ul>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_posts", %{"post_term" => post_term}, socket) do
    with true <- post_term != "",
         [] <- Posts.search_posts_by_term(post_term) do
      {:noreply,
       socket
       |> assign(:searched_posts, [])
       |> assign(:while_searching_posts?, true)
       |> assign(:posts_not_found?, true)}
    else
      false ->
        {:noreply, assign(socket, :while_searching_posts?, false)}

      posts ->
        {:noreply,
         socket
         |> assign(:searched_posts, posts)
         |> assign(:while_searching_posts?, true)
         |> assign(:posts_not_found?, false)
         |> assign(:overflow_y_scroll_ul, check_search_result(posts))}
    end
  end

  def handle_event("hide_search_list", _params, socket) do
    {:noreply, assign(socket, :while_searching_posts?, false)}
  end

  defp check_search_result(found_posts) do
    if Enum.count(found_posts) > 6, do: "overflow-y-scroll", else: ""
  end
end
