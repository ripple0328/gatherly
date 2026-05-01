defmodule GatherlyWeb.OwnerReviewLiveTest do
  use GatherlyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Gatherly.Events
  alias Gatherly.Events.Participant
  alias Gatherly.Repo

  test "owner surface is token gated and groups participants by status", %{conn: conn} do
    %{event: event, owner_token: owner_token, invite_token: invite_token} =
      event_with_review_states()

    {:ok, owner_live, owner_html} = live(conn, ~p"/events/#{event.slug}/owner/#{owner_token}")

    assert owner_html =~ "Owner review"
    assert owner_html =~ "Pending"
    assert owner_html =~ "Accepted"
    assert owner_html =~ "Rejected"
    assert owner_html =~ "Excluded"
    assert owner_html =~ "Accept"
    assert owner_html =~ "Reject"
    assert owner_html =~ "Exclude"

    {:ok, _invalid_live, invalid_html} =
      live(conn, ~p"/events/#{event.slug}/owner/#{mutate_token(owner_token)}")

    assert invalid_html =~ "Owner review unavailable"
    refute invalid_html =~ "Accept"
    refute invalid_html =~ "Reject"
    refute invalid_html =~ "Exclude"

    {:ok, _invite_token_live, invite_token_html} =
      live(conn, ~p"/events/#{event.slug}/owner/#{invite_token}")

    assert invite_token_html =~ "Owner review unavailable"
    refute invite_token_html =~ "Accept"
    refute invite_token_html =~ "Reject"

    assert has_element?(owner_live, "[data-status-group='pending']")
    assert has_element?(owner_live, "[data-status-group='accepted']")
    assert has_element?(owner_live, "[data-status-group='rejected']")
    assert has_element?(owner_live, "[data-status-group='excluded']")
  end

  test "owner can accept reject and exclude through status-appropriate controls", %{conn: conn} do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, %{participant: accept_me}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Sam"})

    {:ok, %{participant: reject_me}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Riley"})

    {:ok, %{participant: exclude_me}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Jordan"})

    {:ok, owner_live, _html} = live(conn, ~p"/events/#{event.slug}/owner/#{owner_token}")

    owner_live
    |> element("#participant-#{accept_me.id} button", "Accept")
    |> render_click()

    assert Repo.get!(Participant, accept_me.id).review_status == "accepted"

    owner_live
    |> element("#participant-#{reject_me.id} button", "Reject")
    |> render_click()

    assert Repo.get!(Participant, reject_me.id).review_status == "rejected"

    owner_live
    |> element("#participant-#{exclude_me.id} button", "Exclude")
    |> render_click()

    assert Repo.get!(Participant, exclude_me.id).review_status == "excluded"

    owner_live
    |> element("#participant-#{accept_me.id} button", "Exclude")
    |> render_click()

    assert Repo.get!(Participant, accept_me.id).review_status == "excluded"

    {:ok, _public_live, public_html} = live(conn, ~p"/events/#{event.slug}")

    assert public_html =~ "Avery"
    refute public_html =~ "Sam"
    refute public_html =~ "Riley"
    refute public_html =~ "Jordan"
  end

  test "non-owner public invite and self-edit pages never expose owner controls", %{conn: conn} do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, %{participant: pending, submission_token: pending_token}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Pending"})

    {:ok, %{participant: accepted, submission_token: accepted_token}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Visible Guest"
      })

    {:ok, _accepted} = Events.review_participant(event.id, accepted.id, owner_token, "accepted")

    {:ok, _public_live, public_html} = live(conn, ~p"/events/#{event.slug}")
    assert public_html =~ "Visible Guest"
    refute public_html =~ "Pending"
    refute_owner_controls(public_html)

    {:ok, _invite_live, invite_html} =
      live(conn, ~p"/events/#{event.slug}/invite/#{invite_token}")

    assert invite_html =~ "Accepted participants"
    assert invite_html =~ "Visible Guest"
    refute invite_html =~ "Pending"
    refute_owner_controls(invite_html)

    {:ok, _self_live, self_html} =
      live(conn, ~p"/events/#{event.slug}/participants/#{pending.id}/edit/#{pending_token}")

    assert self_html =~ "Review status stays"
    assert self_html =~ "pending"
    assert self_html =~ "Accepted participants"
    assert self_html =~ "Visible Guest"
    refute self_html =~ "Reject"
    refute self_html =~ "Excluded"
    refute_owner_controls(self_html)

    {:ok, _accepted_self_live, accepted_self_html} =
      live(conn, ~p"/events/#{event.slug}/participants/#{accepted.id}/edit/#{accepted_token}")

    assert accepted_self_html =~ "Accepted participants"
    refute_owner_controls(accepted_self_html)
  end

  test "owner review reflects new invite submission after reload", %{conn: conn} do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic"})

    {:ok, _owner_live, initial_html} = live(conn, ~p"/events/#{event.slug}/owner/#{owner_token}")
    refute initial_html =~ "Late Guest"

    {:ok, %{participant: _participant}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Late Guest"
      })

    {:ok, _reloaded_owner_live, reloaded_html} =
      live(conn, ~p"/events/#{event.slug}/owner/#{owner_token}")

    assert reloaded_html =~ "Late Guest"
    assert reloaded_html =~ "Pending"
  end

  test "event creation exposes owner and invite entry points without token hashes", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/events")

    live
    |> form("#event-form",
      event: %{
        title: "Created picnic",
        event_type: "potluck",
        creator_name: "Avery",
        starts_at: "",
        location: "",
        description: ""
      }
    )
    |> render_submit()

    workspace_path =
      case assert_redirect(live) do
        {path, _flash} -> path
        path when is_binary(path) -> path
      end

    {:ok, _workspace_live, workspace_html} = live(conn, workspace_path)

    assert workspace_html =~ "Owner review link"
    assert workspace_html =~ "Invite link"
    assert workspace_html =~ "/owner/"
    assert workspace_html =~ "/invite/"
    refute workspace_html =~ "token_hash"
  end

  defp event_with_review_states do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, %{participant: rejected}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Rejected"
      })

    {:ok, %{participant: excluded}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Excluded"
      })

    {:ok, %{participant: pending}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Pending"})

    {:ok, _} = Events.review_participant(event.id, rejected.id, owner_token, "rejected")
    {:ok, _} = Events.review_participant(event.id, excluded.id, owner_token, "excluded")

    %{
      event: event,
      owner_token: owner_token,
      invite_token: invite_token,
      pending: pending,
      rejected: rejected,
      excluded: excluded
    }
  end

  defp refute_owner_controls(html) do
    refute html =~ "Owner review"
    refute html =~ "Reject"
    refute html =~ "Exclude"
    refute html =~ ~s(phx-click="review")
    refute html =~ "owner-token"
    refute html =~ "event-admin"
  end

  defp mutate_token(<<first::binary-size(1), rest::binary>>) do
    replacement = if first == "a", do: "b", else: "a"
    replacement <> rest
  end
end
