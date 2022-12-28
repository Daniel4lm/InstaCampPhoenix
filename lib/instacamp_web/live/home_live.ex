defmodule InstacampWeb.HomeLive do
  @moduledoc false

  use InstacampWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
