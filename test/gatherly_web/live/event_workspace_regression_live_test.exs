defmodule GatherlyWeb.EventWorkspaceRegressionLiveTest do
  use GatherlyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Gatherly.Events

  test "event creation reaches a stable workspace with collaboration areas", %{conn: conn} do
    {:ok, events_live, _html} = live(conn, ~p"/events")

    events_live
    |> form("#event-form",
      event: %{
        title: "Creator picnic",
        event_type: "potluck",
        creator_name: "Avery",
        starts_at: "",
        location: "Park Pavilion",
        description: "Bring something to share."
      }
    )
    |> render_submit()

    workspace_path =
      case assert_redirect(events_live) do
        {path, _flash} -> path
        path when is_binary(path) -> path
      end

    assert workspace_path =~ ~r{^/events/[^?]+}

    {:ok, _workspace_live, workspace_html} = live(conn, workspace_path)

    assert workspace_html =~ "Creator picnic"
    assert workspace_html =~ "Park Pavilion"
    assert workspace_html =~ "Bring something to share."
    assert workspace_html =~ "Participants"
    assert workspace_html =~ "Proposals and voting"
    assert workspace_html =~ "Discussion"
    assert workspace_html =~ "Potluck logistics"
    assert workspace_html =~ "Owner review link"
    assert workspace_html =~ "Invite link"
    refute workspace_html =~ "token_hash"
  end

  test "workspace collaboration remains usable after token review flows", %{conn: conn} do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{
        "title" => "Review picnic",
        "event_type" => "potluck",
        "creator_name" => "Avery"
      })

    {:ok, %{participant: accepted}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Visible Guest",
        "rsvp_status" => "going",
        "role" => "salad"
      })

    {:ok, %{participant: rejected}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Rejected Guest",
        "rsvp_status" => "maybe"
      })

    {:ok, %{participant: excluded}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Excluded Guest",
        "rsvp_status" => "going"
      })

    assert {:ok, %{review_status: "accepted"}} =
             Events.review_participant(event.id, accepted.id, owner_token, "accepted")

    assert {:ok, %{review_status: "rejected"}} =
             Events.review_participant(event.id, rejected.id, owner_token, "rejected")

    assert {:ok, %{review_status: "excluded"}} =
             Events.review_participant(event.id, excluded.id, owner_token, "excluded")

    {:ok, workspace_live, workspace_html} = live(conn, ~p"/events/#{event.slug}")

    assert workspace_html =~ "Avery"
    assert workspace_html =~ "Visible Guest"
    refute workspace_html =~ "Rejected Guest"
    refute workspace_html =~ "Excluded Guest"

    item_html =
      workspace_live
      |> form("#item-form",
        item: %{
          name: "Fruit tray",
          quantity: "2",
          category: "food",
          owner_name: "Visible Guest",
          status: "planned",
          tags: "vegan, fresh",
          notes: "Cut before arriving."
        }
      )
      |> render_submit()

    assert item_html =~ "Fruit tray"
    assert item_html =~ "Owned by Visible Guest"
    assert item_html =~ "vegan"

    [item] = Events.list_items(event.id)

    workspace_live
    |> element("button[phx-click='edit_item'][phx-value-id='#{item.id}']")
    |> render_click()

    edited_item_html =
      workspace_live
      |> form("#item-form",
        item: %{
          id: item.id,
          name: "Fruit tray updated",
          quantity: "3",
          category: "food",
          owner_name: "Avery",
          status: "done",
          tags: "vegan",
          notes: "Ready to serve."
        }
      )
      |> render_submit()

    assert edited_item_html =~ "Fruit tray updated"
    assert edited_item_html =~ "Owned by Avery"
    assert edited_item_html =~ "done"

    deleted_item_html =
      workspace_live
      |> element("button[phx-click='delete_item'][phx-value-id='#{item.id}']")
      |> render_click()

    refute deleted_item_html =~ "Fruit tray updated"
    assert deleted_item_html =~ "No logistics yet."

    proposal_html =
      workspace_live
      |> form("#proposal-form",
        proposal: %{
          proposal_type: "location",
          title: "Use the pavilion",
          proposed_by_name: "Visible Guest",
          details_text: "Covered tables if it rains."
        }
      )
      |> render_submit()

    assert proposal_html =~ "Use the pavilion"
    assert proposal_html =~ "Covered tables if it rains."

    [proposal] = Events.list_proposals(event.id)

    voted_html =
      render_submit(workspace_live, "vote", %{
        "vote" => %{
          "proposal_id" => proposal.id,
          "voter_name" => "Avery",
          "weight" => "1"
        }
      })

    assert voted_html =~ "Avery: +1"
    assert voted_html =~ "1"

    comment_html =
      workspace_live
      |> form("#comment-form",
        comment: %{
          author_name: "Avery",
          body: "Logistics and voting still work after review."
        }
      )
      |> render_submit()

    assert comment_html =~ "Logistics and voting still work after review."
    refute comment_html =~ "Rejected Guest"
    refute comment_html =~ "Excluded Guest"
  end
end
