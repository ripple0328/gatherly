defmodule GatherlyWeb.PageController do
  use GatherlyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def health(conn, _params) do
    # Basic health check - you can add more sophisticated checks here
    # like database connectivity, external service status, etc.
    conn
    |> put_status(:ok)
    |> json(%{status: "ok", timestamp: DateTime.utc_now()})
  end
end
