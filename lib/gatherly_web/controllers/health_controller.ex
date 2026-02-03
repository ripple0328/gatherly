defmodule GatherlyWeb.HealthController do
  use GatherlyWeb, :controller

  @doc """
  Basic liveness endpoint.

  Intentionally does not check external dependencies (DB, Redis, etc.).
  """
  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
