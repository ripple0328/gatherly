defmodule GatherlyWeb.PageController do
  use GatherlyWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def manifest(conn, _params) do
    manifest_path = Path.join(:code.priv_dir(:gatherly), "static/manifest.json")
    
    case File.read(manifest_path) do
      {:ok, content} ->
        conn
        |> put_resp_content_type("application/json")
        |> text(content)
      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> text("Not found")
    end
  end
end
