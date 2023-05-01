defmodule InstacampWeb.Components.Navigation.NavbarFormComponent do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.Accounts
  alias Instacamp.Posts
  alias InstacampWeb.Components.Icons

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(:searched_posts, [])
     |> assign(:searched_users, [])
     |> assign(:while_searching?, false)
     |> assign(:value, nil)
     |> assign(:results_not_found?, false)
     |> assign(:overflow_y_scroll_ul, "")}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="relative hidden md:flex w-full md:w-2/5 mx-2">
      <form
        id="navbar-search-form"
        class="w-full"
        phx-change="search_resources"
        phx-submit="search_resources"
        phx-target={@myself}
      >
        <div class="relative">
          <input
            id="posts-search-input"
            phx-debounce="500"
            name="search_term"
            type="search"
            placeholder="Search posts or users"
            autocomplete="off"
            value={@value}
            phx-click={maybe_open_list(@myself, @value)}
            phx-target={@myself}
            class="rounded-full w-full border dark:bg-slate-500 bg-search-icon dark:bg-search-icon-dark bg-no-repeat bg-[length:20px] bg-[right_0.8em_center] ring-0 duration-100 border-gray-400 focus:ring-2 focus:ring-indigo-400 dark:focus:ring-blue-400 focus:ring-opacity-90 focus:border-transparent dark:text-gray-200 pr-[2.4em] pl-[0.8em] py-[0.4em] text-base placeholder:font-light placeholder:text-slate-400 dark:placeholder:text-slate-300"
          />
          <div
            id="clear-form-btn"
            class={"#{if(!is_nil(@value) && String.length(@value) > 0, do: "block", else: "hidden")} absolute text-gray-500 dark:text-slate-200 top-1/2 right-10 -translate-y-1/2 transition scale-80 p-1 rounded-full hover:bg-neutral-200 hover:dark:bg-slate-400"}
            phx-click="clear_form"
            phx-target={@myself}
          >
            <Icons.close />
          </div>
        </div>
      </form>

      <ul
        :if={@while_searching?}
        id="post-search-list"
        phx-click-away={close_search_list(@myself)}
        phx-window-keydown={close_search_list(@myself)}
        phx-key="escape"
        phx-target={@myself}
        class={
            "absolute top-[110%] left-0 w-full border bg-white dark:bg-slate-500 dark:text-slate-100 border-slate-400 dark:border-0 rounded-lg overflow-hidden shadow-sm #{if(@results_not_found?, do: "h-40", else: "h-96")} #{@overflow_y_scroll_ul}"
          }
      >
        <%= unless Enum.empty?(@searched_posts) do %>
          <p class="p-2 text-sm">Posts:</p>
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
        <% end %>
        <hr />
        <%= unless Enum.empty?(@searched_users) do %>
          <p class="p-2 text-sm">Users:</p>
          <.link :for={user <- @searched_users} navigate={~p"/user/#{user.username}"}>
            <li class="flex items-center rounded-md m-1 px-2 py-3 hover:bg-indigo-50 dark:hover:bg-slate-400 dark:hover:bg-opacity-50">
              <.user_avatar src={user.avatar_url} class="w-10 h-10 " />

              <div class="ml-3">
                <h2 class="font-bold text-sm ">
                  <%= user.username %>
                </h2>
                <h3 class="text-sm "><%= user.full_name %></h3>
              </div>
            </li>
          </.link>
        <% end %>

        <li
          :if={@results_not_found?}
          class="text-sm text-gray-400 dark:text-gray-200 flex justify-center items-center h-full"
        >
          No results found.
        </li>
      </ul>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_resources", %{"search_term" => ""}, socket) do
    {:noreply,
     socket
     |> assign(:value, "")
     |> assign(:searched_posts, [])
     |> assign(:searched_users, [])
     |> assign(:results_not_found?, true)}
  end

  def handle_event("search_resources", %{"search_term" => search_term}, socket) do
    posts = Posts.search_posts_by_term(search_term)
    users = Accounts.search_users_by_term(search_term)

    with true <- String.length(search_term) > 0,
         [] <- posts,
         [] <- users do
      {:noreply,
       socket
       |> assign(:searched_posts, [])
       |> assign(:searched_users, [])
       |> assign(:value, search_term)
       |> assign(:while_searching?, true)
       |> assign(:results_not_found?, true)}
    else
      false ->
        {:noreply, assign(socket, :while_searching?, false)}

      _posts_or_users ->
        {:noreply,
         socket
         |> assign(:searched_posts, posts)
         |> assign(:searched_users, users)
         |> assign(:value, search_term)
         |> assign(:while_searching?, true)
         |> assign(:results_not_found?, false)
         |> assign(:overflow_y_scroll_ul, check_search_result(posts, users))}
    end
  end

  def handle_event("clear_form", _params, socket), do: {:noreply, assign(socket, :value, "")}

  def handle_event("hide_search_list", _params, socket),
    do: {:noreply, assign(socket, while_searching?: false)}

  def handle_event("show_search_list", _params, socket),
    do: {:noreply, assign(socket, while_searching?: true)}

  defp maybe_open_list(target, search_value) do
    if !is_nil(search_value) && String.length(search_value) > 0 do
      open_search_list(target)
    end
  end

  defp close_search_list(js \\ %JS{}, target) do
    JS.push(js, "hide_search_list", target: target)
  end

  defp open_search_list(js \\ %JS{}, target) do
    JS.push(js, "show_search_list", target: target)
  end

  defp check_search_result(found_posts, found_users) do
    if Enum.count(found_posts) + Enum.count(found_users) > 6,
      do: "overflow-y-scroll",
      else: ""
  end
end
