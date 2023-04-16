defmodule Instacamp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      InstacampWeb.Telemetry,
      # Start the Ecto repository
      Instacamp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Instacamp.PubSub},
      # Start Finch
      {Finch, name: Instacamp.Finch},
      {Finch, name: Swoosh.Finch},
      # Start the Endpoint (http/https)
      InstacampWeb.Endpoint
      # Start a worker by calling: Instacamp.Worker.start_link(arg)
      # {Instacamp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Instacamp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    InstacampWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
