defmodule InstacampWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use InstacampWeb, :controller
      use InstacampWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts images uploads favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: InstacampWeb

      import Plug.Conn
      import InstacampWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {InstacampWeb.Layouts, :app}

      def stream_batch_insert(socket, stream_key, items, opts \\ [{:at, -1}]) do
        Enum.reduce(items, socket, fn item, socket ->
          stream_insert(socket, stream_key, item, opts)
        end)
      end

      def stream_batch_empty(socket, stream_key, stream_ids) do
        Enum.reduce(stream_ids, socket, fn dom_id, socket ->
          stream_delete_by_dom_id(socket, stream_key, dom_id)
        end)
      end

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import InstacampWeb.Gettext
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import InstacampWeb.CoreComponents
      import InstacampWeb.LiveHelpers

      import InstacampWeb.ErrorHelpers
      import InstacampWeb.Gettext
      import Phoenix.Component

      alias Phoenix.LiveView.JS

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: InstacampWeb.Endpoint,
        router: InstacampWeb.Router,
        statics: InstacampWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
