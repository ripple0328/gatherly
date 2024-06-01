defmodule GatherlyWeb.UserLoginLiveTest do
  use GatherlyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Gatherly.AccountsFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/signin")

      assert html =~ "Sign in to your account"
      assert html =~ "Login with Google"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = user_fixture()

      result =
        conn
        |> log_in_user(user)
        |> live(~p"/signin")
        |> follow_redirect(conn, "/#{user.id}")

      assert {:ok, _conn} = result
    end
  end
end
