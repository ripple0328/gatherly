defmodule GatherlyWeb.HealthController do
  @moduledoc """
  Standard health check endpoints (Platform App Contract).
  
  - /healthz: Liveness probe
  - /readyz: Readiness probe
  - /version: Build/version info
  """
  
  use GatherlyWeb, :controller
  require Logger

  @doc """
  Liveness probe - returns 200 if application is alive.
  Does NOT check external dependencies.
  """
  def liveness(conn, _params) do
    json(conn, %{
      status: "ok",
      service: "gatherly",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end

  @doc """
  Readiness probe - returns 200 if app can serve traffic.
  Checks critical dependencies (database, etc.).
  """
  def readiness(conn, _params) do
    checks = %{
      database: check_database()
    }
    
    all_healthy = Enum.all?(checks, fn {_name, status} -> status == :ok end)
    status_code = if all_healthy, do: 200, else: 503
    
    response = %{
      status: if(all_healthy, do: "ready", else: "not_ready"),
      checks: checks,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    conn
    |> put_status(status_code)
    |> json(response)
  end

  @doc """
  Version endpoint - returns build/deploy information.
  """
  def version(conn, _params) do
    json(conn, %{
      service: "gatherly",
      version: Application.spec(:gatherly, :vsn) |> to_string(),
      elixir_version: System.version(),
      otp_release: :erlang.system_info(:otp_release) |> to_string(),
      hostname: :inet.gethostname() |> elem(1) |> to_string(),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end

  # Legacy endpoint for backwards compatibility
  def index(conn, params), do: liveness(conn, params)

  # Private helpers

  defp check_database do
    try do
      case Gatherly.Repo.query("SELECT 1") do
        {:ok, _result} -> :ok
        {:error, reason} ->
          Logger.error("Database health check failed: #{inspect(reason)}")
          :error
      end
    rescue
      e ->
        Logger.error("Database health check exception: #{inspect(e)}")
        :error
    end
  end
end
