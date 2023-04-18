defmodule InstacampWeb.PostListLive.SettingsTabsComponent do
  @moduledoc false

  use InstacampWeb, :html

  @spec settings_tabs(map()) :: Phoenix.LiveView.Rendered.t()
  def settings_tabs(assigns) do
    ~H"""
    <div class="w-full mt-2 flex items-end justify-start">
      <div class="flex items-center w-full">
        <div :for={tab <- @tabs} class="relative cursor-pointer">
          <.link patch={tab.path}><%= settings_tab(tab.title, @current_uri_path, tab.path) %></.link>
          <div class={
              "absolute bottom-0 w-0 bg-gray-600 dark:bg-slate-300 h-[2px] rounded-xl #{if(@current_uri_path == tab.path, do: "animate-[show-tab-line_0.4s_ease-in-out_forwards]", else: "")}"
            } />
        </div>
      </div>
    </div>
    """
  end

  defp settings_tab(title, current_uri_path, menu_link) do
    content_tag(:span, title,
      class: "block m-1 p-2 text-sm md:text-base #{selected_link?(current_uri_path, menu_link)}"
    )
  end

  defp selected_link?(current_uri, menu_link) when current_uri == menu_link do
    "font-semibold text-gray-800 dark:text-inherit ease-in-out"
  end

  defp selected_link?(_current_uri, _menu_link) do
    "font-semibold text-gray-500 dark:text-slate-400 ease-in-out"
  end
end
