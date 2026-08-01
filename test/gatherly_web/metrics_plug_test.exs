defmodule GatherlyWeb.MetricsPlugTest do
  use ExUnit.Case, async: true

  import Plug.Test

  alias GatherlyWeb.MetricsPlug

  test "serves a Prometheus scrape from the selected reporter" do
    reporter_name = :gatherly_metrics_plug_test

    start_supervised!(
      {TelemetryMetricsPrometheus.Core, name: reporter_name, metrics: [], start_async: false}
    )

    conn =
      :get
      |> conn("/metrics")
      |> MetricsPlug.call(name: reporter_name)

    assert conn.status == 200
    assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/plain; charset=utf-8"]
  end

  test "does not expose other paths" do
    conn =
      :get
      |> conn("/")
      |> MetricsPlug.call(name: :unused)

    assert conn.status == 404
  end
end
