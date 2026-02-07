defmodule GatherlyWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},

      # Prometheus exporter (scraped by Prometheus)
      {TelemetryMetricsPrometheus, metrics: metrics(), name: :gatherly_metrics}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix HTTP Metrics
      distribution("phoenix.router_dispatch.stop.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        measurement: :duration,
        unit: {:native, :millisecond},
        tags: [:route],
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000, 2000, 5000]]
      ),
      
      # Database Metrics
      distribution("gatherly.repo.query.total_time",
        event_name: [:gatherly, :repo, :query],
        measurement: :total_time,
        unit: {:native, :millisecond},
        reporter_options: [buckets: [1, 5, 10, 50, 100, 500, 1000]],
        description: "Database query total time"
      ),
      distribution("gatherly.repo.query.query_time",
        event_name: [:gatherly, :repo, :query],
        measurement: :query_time,
        unit: {:native, :millisecond},
        reporter_options: [buckets: [1, 5, 10, 50, 100, 500, 1000]],
        description: "Database query execution time"
      ),
      distribution("gatherly.repo.query.queue_time",
        event_name: [:gatherly, :repo, :query],
        measurement: :queue_time,
        unit: {:native, :millisecond},
        reporter_options: [buckets: [1, 5, 10, 50, 100]],
        description: "Database connection queue time"
      ),

      # VM Metrics
      last_value("vm.memory.total", unit: :byte),
      last_value("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {GatherlyWeb, :count_users, []}
    ]
  end
end
