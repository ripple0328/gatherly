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
      {TelemetryUI, telemetry_config()},
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

  defp telemetry_config do
    import TelemetryUI.Metrics

    [
      metrics: [
        last_value("my_app.users.total_count",
          description: "Number of users",
          ui_options: [unit: " users"]
        ),
        counter("phoenix.router_dispatch.stop.duration",
          description: "Number of requests",
          unit: {:native, :millisecond},
          ui_options: [unit: " requests"]
        ),
        value_over_time("vm.memory.total", unit: {:byte, :megabyte}),
        distribution("phoenix.router_dispatch.stop.duration",
          description: "Requests duration",
          unit: {:native, :millisecond},
          reporter_options: [buckets: [0, 100, 500, 2000]]
        )
      ],
      backend: %TelemetryUI.Backend.EctoPostgres{
        repo: Gatherly.Repo,
        pruner_threshold: [months: -1],
        pruner_interval_ms: 84_000,
        max_buffer_size: 10_000,
        flush_interval_ms: 10_000
      }
    ]
  end
end
