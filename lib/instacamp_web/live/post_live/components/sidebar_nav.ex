defmodule InstacampWeb.PostLive.Components.SidebarNav do
  @moduledoc false

  use InstacampWeb, :html

  attr(:title, :string, default: "In this article")
  attr(:side_bar_links, :list, default: [])

  @spec side_navigation(map()) :: Phoenix.LiveView.Rendered.t()
  def side_navigation(assigns) do
    ~H"""
    <aside id="side-nav" class="hidden w-1/3 md:block md:sticky w-auto h-max top-14 ml-2 px-2 py-6">
      <span id="side-nav_title" class="text-lg font-semibold"><%= @title %></span>
      <ul id="side-nav-list" class="my-2 border-l-2 border-gray-300 dark:border-slate-500 text-sm">
        <li
          :for={{side_link, index} <- Enum.with_index(@side_bar_links)}
          id={"side-nav-item-#{index}"}
          class="w-full hover:text-indigo-600 hover:dark:text-indigo-400"
        >
          <a
            id={"side-nav-link-#{index}"}
            data-href={side_link["href"]}
            href={side_link["href"]}
            class="block p-2 -ml-[2px] border-l-2 border-transparent cursor-pointer duration-100"
          >
            <%= side_link["title"] %>
          </a>
        </li>
      </ul>
    </aside>
    """
  end
end
