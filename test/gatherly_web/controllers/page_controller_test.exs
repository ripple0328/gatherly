defmodule GatherlyWeb.PageControllerTest do
  use GatherlyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "<!DOCTYPE html>"
    assert html_response(conn, 200) =~ "<title>Gatherly</title>"
    assert html_response(conn, 200) =~ "The single platform"
  end
end
