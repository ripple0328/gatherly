defmodule GatherlyWeb.PageControllerTest do
  use GatherlyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "<!DOCTYPE html>"
    assert html_response(conn, 200) =~ "<title data-suffix=\" · Phoenix Framework\">"
    assert html_response(conn, 200) =~ "<body class=\"bg-white\">"
  end
end
