defmodule GatherlyWeb.PageController do
  use GatherlyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
