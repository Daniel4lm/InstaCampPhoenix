defmodule InstacampWeb.SettingsLive.Components.SettingsSidebarComponent do
  @moduledoc false

  use InstacampWeb, :component

  alias InstacampWeb.Components.Icons

  @spec settings_sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def settings_sidebar(assigns) do
    ~H"""
    <div class={@class}>
      <ul class="flex flex-row justify-center md:flex-col ">
        <%= live_redirect to: @settings_path, replace: false do %>
          <.sidebar_link_tag
            title="Edit Profile"
            current_uri_path={@current_uri_path}
            menu_link={@settings_path}
          >
            <Icons.settings_icon />
          </.sidebar_link_tag>
        <% end %>

        <%= live_redirect to: @pass_settings_path, replace: false do %>
          <.sidebar_link_tag
            title="Change Password"
            current_uri_path={@current_uri_path}
            menu_link={@pass_settings_path}
          >
            <Icons.confirm_icon />
          </.sidebar_link_tag>
        <% end %>
      </ul>
    </div>
    """
  end
end
