defmodule InstacampWeb.LiveHelpers do
  @moduledoc false

  use Phoenix.HTML

  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @type tag :: Phoenix.HTML.Tag

  @doc """
  Generates tag for menu link.
  """
  @spec sidebar_link_tag(String.t(), String.t(), String.t()) ::
          {:safe, [binary | maybe_improper_list(any, binary | [])]}
  def sidebar_link_tag(title, current_uri_path, menu_link) do
    content_tag(:li, title, class: "m-1 p-4 #{selected_link?(current_uri_path, menu_link)}")
  end

  @spec nav_link(map()) :: Phoenix.LiveView.Rendered.t()
  def nav_link(
        %{active_path: active_path, current_path: current_path, link_path: link_path} = assigns
      ) do
    if active_path == current_path do
      ~H"""
      <%= live_patch to: link_path do %>
        <%= render_slot(@inner_block) %>
      <% end %>
      """
    else
      ~H"""
      <%= live_redirect to: link_path do %>
        <%= render_slot(@inner_block) %>
      <% end %>
      """
    end
  end

  defp selected_link?(current_uri, menu_link) when current_uri == menu_link do
    "rounded-md bg-indigo-100 dark:bg-slate-300 text-gray-900 ease-in-out"
  end

  defp selected_link?(_current_uri, _menu_link) do
    "rounded-md ease-in-out"
  end

  @spec display_website_uri(String.t()) :: String.t()
  def display_website_uri(website) do
    website =
      website
      |> String.replace_leading("https://", "")
      |> String.replace_leading("http://", "")

    website
  end

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={...}>
        <.live_component
          module={...}
          id={@post.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={...}
          post: @post
        />
      </.modal>
  """
  @spec modal(map()) :: Phoenix.LiveView.Rendered.t()
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div
      id="modal"
      class="w-full h-full flex items-center justify-center left-0 top-0 z-50 !opacity-100 fixed bg-[#0000001a] overflow-auto fade-in"
      phx-remove={hide_modal()}
    >
      <div
        id="modal-content"
        class={
          if(assigns[:w_size], do: @w_size, else: "w-full") <>
            " h-auto rounded-xl mx-auto my-1/2 bg-gray-50 border-2 border-gray-400 fade-in-scale overflow-auto"
        }
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch("✖",
            to: @return_to,
            id: "close",
            class: "float-right my-3 mr-3 dark:text-slate-200",
            phx_click: hide_modal()
          ) %>
        <% else %>
          <a id="close" href="#" class="phx-modal-close dark:!text-slate-200" phx-click={hide_modal()}>
            ✖
          </a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end
