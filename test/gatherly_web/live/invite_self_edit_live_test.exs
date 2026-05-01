defmodule GatherlyWeb.InviteSelfEditLiveTest do
  use GatherlyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Gatherly.Events
  alias Gatherly.Events.Participant
  alias Gatherly.Repo

  test "invite page submits a pending participant and exposes safe self-edit page", %{conn: conn} do
    {:ok, %{event: event, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, invite_live, html} = live(conn, ~p"/events/#{event.slug}/invite/#{invite_token}")

    assert html =~ "Submit your RSVP"
    refute html =~ "review_status"
    refute html =~ "Owner"

    html =
      invite_live
      |> form("#invite-participant-form",
        participant: %{
          display_name: "Sam",
          rsvp_status: "maybe",
          role: "snacks"
        }
      )
      |> render_submit()

    assert html =~ "Your RSVP is pending review"
    assert html =~ "Open your self-edit page"

    [participant] =
      event.id
      |> Events.list_participants()
      |> Enum.reject(&(&1.display_name == "Avery"))

    assert participant.display_name == "Sam"
    assert participant.rsvp_status == "maybe"
    assert participant.role == "snacks"
    assert participant.review_status == "pending"
    assert participant.submission_token_hash

    self_edit_path = self_edit_path_from_html(html)
    {:ok, self_live, self_html} = live(conn, self_edit_path)

    assert self_html =~ "Self-edit"
    assert self_html =~ "Your name"
    assert self_html =~ "RSVP"
    assert self_html =~ "Role or note"
    refute self_html =~ "review_status"
    refute self_html =~ "Owner"

    self_live
    |> form("#self-edit-form",
      participant: %{
        display_name: "Sam Updated",
        rsvp_status: "not_going",
        role: "dessert"
      }
    )
    |> render_submit()

    updated = Repo.get!(Participant, participant.id)
    assert updated.display_name == "Sam Updated"
    assert updated.rsvp_status == "not_going"
    assert updated.role == "dessert"
    assert updated.review_status == "pending"
    assert updated.event_id == event.id
    assert updated.submission_token_hash == participant.submission_token_hash
  end

  test "invalid invite URL fails closed and public workspace does not grant participant authority",
       %{
         conn: conn
       } do
    {:ok, %{event: event, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, public_live, public_html} = live(conn, ~p"/events/#{event.slug}")

    assert public_html =~ "Accepted participants appear here"
    refute public_html =~ "Add myself"
    refute public_html =~ "Submit RSVP"

    refute has_element?(public_live, "#participant-form")

    before_count = participant_count(event.id)

    {:ok, _invalid_live, invalid_html} =
      live(conn, ~p"/events/#{event.slug}/invite/#{mutate_token(invite_token)}")

    assert invalid_html =~ "Invite unavailable"
    assert invalid_html =~ "invalid or expired"
    refute invalid_html =~ "Submit RSVP"
    assert participant_count(event.id) == before_count
  end

  test "self-edit rejects cross-participant and rejected participant links", %{conn: conn} do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic"})

    {:ok, %{participant: participant_a, submission_token: token_a}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Sam"})

    {:ok, %{participant: participant_b, submission_token: token_b}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Riley"})

    {:ok, _} = Events.review_participant(event.id, participant_b.id, owner_token, "rejected")

    {:ok, _live, cross_html} =
      live(conn, ~p"/events/#{event.slug}/participants/#{participant_b.id}/edit/#{token_a}")

    assert cross_html =~ "Self-edit unavailable"
    refute cross_html =~ "Save changes"

    {:ok, _live, rejected_html} =
      live(conn, ~p"/events/#{event.slug}/participants/#{participant_b.id}/edit/#{token_b}")

    assert rejected_html =~ "Self-edit unavailable"
    refute rejected_html =~ "Save changes"
    assert Repo.get!(Participant, participant_a.id).display_name == "Sam"
    assert Repo.get!(Participant, participant_b.id).display_name == "Riley"
  end

  defp self_edit_path_from_html(html) do
    [[path]] =
      Regex.scan(~r{href="([^"]+/participants/[^"]+/edit/[^"]+)"}, html, capture: :all_but_first)

    path
  end

  defp participant_count(event_id) do
    event_id
    |> Events.list_participants()
    |> length()
  end

  defp mutate_token(<<first::binary-size(1), rest::binary>>) do
    replacement = if first == "a", do: "b", else: "a"
    replacement <> rest
  end
end
