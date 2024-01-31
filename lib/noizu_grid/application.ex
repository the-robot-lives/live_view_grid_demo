defmodule NoizuGrid.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NoizuGridWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:noizu_grid, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NoizuGrid.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: NoizuGrid.Finch},
      # Start a worker by calling: NoizuGrid.Worker.start_link(arg)
      # {NoizuGrid.Worker, arg},
      # Start to serve requests, typically the last entry
      NoizuGridWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NoizuGrid.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NoizuGridWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
