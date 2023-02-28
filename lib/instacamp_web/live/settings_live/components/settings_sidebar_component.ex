defmodule InstacampWeb.SettingsLive.Components.SettingsSidebarComponent do
  @moduledoc false

  use InstacampWeb, :component

  @spec settings_sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def settings_sidebar(assigns) do
    ~H"""
    <div class={@class}>
      <ul class="flex flex-row justify-center md:flex-col">
        <%= live_redirect(
          sidebar_link_tag("Edit Profile", @current_uri_path, @settings_path),
          to: @settings_path
        ) %>
        <%= live_redirect(
          sidebar_link_tag("Change Password", @current_uri_path, @pass_settings_path),
          to: @pass_settings_path
        ) %>
      </ul>
    </div>
    """
  end
end
