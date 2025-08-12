defmodule GatherlyWeb.MagicJoinLiveTest do
  use GatherlyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Gatherly.Accounts.User
  alias Gatherly.Events.{Event, MagicLink}

  setup %{conn: conn} do
    {:ok, creator} = User.create(%{name: "Host", email: "host@example.com"})
    {:ok, event} = Event.create("Potluck", creator.id)
    {:ok, magic_link} = MagicLink.generate_for_event(event.id, creator.id)

    %{conn: conn, creator: creator, event: event, magic_link: magic_link}
  end

  test "renders join form for valid token", %{conn: conn, magic_link: ml} do
    {:ok, view, _html} = live(conn, "/join/#{ml.token}")
    assert has_element?(view, "input[name=name]")
  end

  test "submits join form and follows redirects to event", %{
    conn: conn,
    magic_link: ml,
    event: event
  } do
    {:ok, view, _html} = live(conn, "/join/#{ml.token}")

    {:error, {:redirect, %{to: to_url}}} =
      view
      |> form("form", %{"name" => "Alice", "email" => "alice@example.com"})
      |> render_submit()

    assert to_url =~ "/join/#{ml.token}/complete?user_id="

    conn = get(conn, to_url)
    assert redirected_to(conn) == ~p"/events/#{event.id}"
  end
end
