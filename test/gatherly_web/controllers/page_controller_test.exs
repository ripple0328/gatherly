defmodule GatherlyWeb.PageControllerTest do
  use GatherlyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Crowdsourced event planning"
  end
end
