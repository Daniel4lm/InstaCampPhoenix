defmodule InstacampWeb.SettingsLive.Components.SettingsSidebarComponent do
  @moduledoc false

  use InstacampWeb, :html

  alias InstacampWeb.Components.Icons

  @spec settings_sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def settings_sidebar(assigns) do
    ~H"""
    <div class={@class}>
      <ul class="flex flex-row items-center justify-center md:flex-col">
        <.link navigate={@settings_path} class="w-1/2 md:w-full">
          <.sidebar_link_tag
            title="Edit Profile"
            current_uri_path={@current_uri_path}
            menu_link={@settings_path}
          >
            <Icons.settings_icon />
          </.sidebar_link_tag>
        </.link>

        <.link navigate={@pass_settings_path} class="w-1/2 md:w-full">
          <.sidebar_link_tag
            title="Change Password"
            current_uri_path={@current_uri_path}
            menu_link={@pass_settings_path}
          >
            <Icons.confirm_icon />
          </.sidebar_link_tag>
        </.link>
      </ul>
    </div>
    """
  end
end
