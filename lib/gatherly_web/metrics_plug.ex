defmodule GatherlyWeb.MetricsPlug do
  @moduledoc """
  Loopback-only HTTP projection of Gatherly's Prometheus metrics registry.

  The reporter owns aggregation. This Plug only exposes a scrape representation
  so the transport can evolve independently from the metrics domain.
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  @spec init(keyword()) :: keyword()
  def init(options), do: options

  @impl Plug
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(%Plug.Conn{method: "GET", request_path: "/metrics"} = conn, options) do
    reporter_name = Keyword.fetch!(options, :name)
    metrics = TelemetryMetricsPrometheus.Core.scrape(reporter_name)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, metrics)
  end

  def call(conn, _options), do: send_resp(conn, 404, "Not Found")
end
