defmodule Gatherly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GatherlyWeb.Telemetry,
      Gatherly.Repo,
      {DNSCluster, query: Application.get_env(:gatherly, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gatherly.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gatherly.Finch},
      # Start a worker by calling: Gatherly.Worker.start_link(arg)
      # {Gatherly.Worker, arg},
      # Start to serve requests, typically the last entry
      GatherlyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gatherly.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GatherlyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
