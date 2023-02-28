defmodule InstacampWeb.NavLive do
  @moduledoc false

  import Phoenix.LiveView

  @type socket :: Phoenix.LiveView.Socket.t()

  @spec on_mount(atom(), map(), map(), socket()) :: {:cont, socket()}
  def on_mount(_active_item, _params, _session, socket) do
    {:cont, attach_hook(socket, :active_path, :handle_params, &set_active_path/3)}
  end

  defp set_active_path(_params, url, socket) do
    {:cont, assign(socket, :active_path, URI.parse(url).path)}
  end
end
