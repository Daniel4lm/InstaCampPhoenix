defmodule InstacampWeb.LiveHelpers do
  @moduledoc false

  use Phoenix.HTML
  use Phoenix.Component

  @type tag :: Phoenix.HTML.Tag

  @doc """
  Generates sidebar tags.
  """
  @spec sidebar_link_tag(map()) ::
          Phoenix.LiveView.Rendered.t()
          | {:safe, [binary | maybe_improper_list(any, binary | [])]}
  def sidebar_link_tag(title, current_uri_path, menu_link) do
    content_tag(:li, title, class: "m-1 p-4 #{selected_link?(current_uri_path, menu_link)}")
  end

  attr :current_uri_path, :string, required: true
  attr :menu_link, :string, required: true
  attr :title, :string, required: true
  slot :inner_block

  def sidebar_link_tag(
        %{title: title, current_uri_path: current_uri_path, menu_link: menu_link} = assigns
      ) do
    assigns =
      assigns
      |> assign(:current_uri_path, current_uri_path)
      |> assign(:menu_link, menu_link)
      |> assign(:title, title)

    ~H"""
    <%= content_tag :li, class: "flex items-center justify-between m-1 p-4 #{selected_link?(@current_uri_path, @menu_link)}" do %>
      <span class="mr-2"><%= @title %></span>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end

  attr :active_path, :string, required: true
  attr :class, :string, default: nil
  attr :current_path, :string, required: true
  attr :link_path, :string, required: true
  slot :inner_block, required: true

  @doc """
  Generates navigation link.
  """
  @spec nav_link(map()) :: Phoenix.LiveView.Rendered.t()
  def nav_link(
        %{active_path: active_path, current_path: current_path, link_path: link_path} = assigns
      ) do
    assigns = assign(assigns, :link_path, link_path)

    if active_path == current_path do
      ~H"""
      <.link patch={@link_path} class={@class}>
        <%= render_slot(@inner_block) %>
      </.link>
      """
    else
      ~H"""
      <.link navigate={@link_path} class={@class}>
        <%= render_slot(@inner_block) %>
      </.link>
      """
    end
  end

  defp selected_link?(current_uri, menu_link) when current_uri == menu_link do
    "max-h-14 rounded-md bg-indigo-100 dark:bg-slate-400 text-gray-900 ease-in-out"
  end

  defp selected_link?(_current_uri, _menu_link) do
    "max-h-14 rounded-md hover:bg-gray-100 dark:hover:bg-slate-500 ease-in-out"
  end
end
