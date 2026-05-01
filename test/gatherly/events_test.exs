defmodule Gatherly.EventsTest do
  use Gatherly.DataCase, async: true

  alias Gatherly.Events.{Event, Participant}
  alias Gatherly.Events
  alias Gatherly.Repo

  test "creates an event with an optional creator participant" do
    assert {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
             Events.create_event(%{
               "title" => "Neighborhood potluck",
               "event_type" => "potluck",
               "creator_name" => "Avery"
             })

    assert event.slug
    assert is_binary(owner_token)
    assert is_binary(invite_token)

    assert [
             %{
               display_name: "Avery",
               rsvp_status: "going",
               review_status: "accepted",
               submission_token_hash: nil
             }
           ] = Events.list_participants(event.id)

    assert {:error, :unauthorized} =
             Events.verify_submission_token(
               event.id,
               hd(Events.list_participants(event.id)).id,
               owner_token
             )
  end

  test "event creation returns opaque owner and invite tokens while persisting only hashes" do
    attrs = %{
      "title" => "Neighborhood potluck",
      "event_type" => "potluck",
      "creator_name" => "Avery"
    }

    assert {:ok, %{event: event_a, owner_token: owner_token_a, invite_token: invite_token_a}} =
             Events.create_event(attrs)

    assert {:ok, %{event: event_b, owner_token: owner_token_b, invite_token: invite_token_b}} =
             Events.create_event(attrs)

    for token <- [owner_token_a, invite_token_a, owner_token_b, invite_token_b] do
      assert is_binary(token)
      assert byte_size(token) >= 32
      refute String.contains?(token, event_a.id)
      refute String.contains?(token, event_a.slug)
      refute String.contains?(token, event_b.id)
      refute String.contains?(token, event_b.slug)
      refute String.contains?(String.downcase(token), "neighborhood")
      refute String.contains?(String.downcase(token), "avery")
    end

    assert owner_token_a != owner_token_b
    assert invite_token_a != invite_token_b
    assert owner_token_a != invite_token_a

    persisted_event = Repo.get!(Event, event_a.id)
    assert persisted_event.owner_token_hash
    assert persisted_event.invite_token_hash
    refute persisted_event.owner_token_hash == owner_token_a
    refute persisted_event.invite_token_hash == invite_token_a

    persisted = [
      persisted_event,
      Repo.get_by!(Participant, event_id: event_a.id, display_name: "Avery")
    ]

    persisted_text = inspect(persisted)
    refute String.contains?(persisted_text, owner_token_a)
    refute String.contains?(persisted_text, invite_token_a)
  end

  test "owner and invite token verification is event scoped and authority separated" do
    {:ok, %{event: event_a, owner_token: owner_token_a, invite_token: invite_token_a}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, %{owner_token: owner_token_b, invite_token: invite_token_b}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    assert {:ok, ^event_a} = Events.verify_owner_token(event_a.id, owner_token_a)
    assert {:ok, ^event_a} = Events.verify_invite_token(event_a.id, invite_token_a)

    invalid_tokens = [
      "",
      "   ",
      "malformed",
      owner_token_b,
      invite_token_b,
      mutate_token(owner_token_a)
    ]

    for token <- invalid_tokens do
      assert {:error, :unauthorized} = Events.verify_owner_token(event_a.id, token)
      assert {:error, :unauthorized} = Events.verify_invite_token(event_a.id, token)
    end

    assert {:error, :unauthorized} = Events.verify_invite_token(event_a.id, owner_token_a)
    assert {:error, :unauthorized} = Events.verify_owner_token(event_a.id, invite_token_a)
  end

  test "valid invite submission creates pending participant with opaque self-edit authority" do
    {:ok, %{event: event, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic"})

    assert {:ok, %{participant: participant_a, submission_token: submission_token_a}} =
             Events.submit_participant_with_invite(event.id, invite_token, %{
               "display_name" => "Sam",
               "rsvp_status" => "maybe",
               "role" => "snacks"
             })

    assert {:ok, %{submission_token: submission_token_b}} =
             Events.submit_participant_with_invite(event.id, invite_token, %{
               "display_name" => "Sam",
               "rsvp_status" => "maybe",
               "role" => "snacks"
             })

    assert participant_a.review_status == "pending"
    assert participant_a.event_id == event.id
    assert is_binary(submission_token_a)
    assert byte_size(submission_token_a) >= 32
    assert submission_token_a != submission_token_b
    refute String.contains?(submission_token_a, event.id)
    refute String.contains?(submission_token_a, participant_a.id)
    refute String.contains?(String.downcase(submission_token_a), "sam")

    persisted_participant = Repo.get!(Participant, participant_a.id)
    assert persisted_participant.submission_token_hash
    refute persisted_participant.submission_token_hash == submission_token_a

    persisted_text = inspect([Repo.get!(Event, event.id), persisted_participant])
    refute String.contains?(persisted_text, submission_token_a)
  end

  test "invalid token verification and invite submission fail closed without side effects" do
    {:ok, %{event: event_a, invite_token: invite_token_a}} =
      Events.create_event(%{"title" => "Park picnic"})

    {:ok, %{event: event_b, invite_token: invite_token_b}} =
      Events.create_event(%{"title" => "Lake picnic"})

    before_counts = row_counts()

    for token <- ["", " ", "malformed", mutate_token(invite_token_a), invite_token_b] do
      assert {:error, :unauthorized} =
               Events.submit_participant_with_invite(event_a.id, token, %{
                 "display_name" => "Mallory",
                 "rsvp_status" => "going"
               })
    end

    assert {:error, :unauthorized} =
             Events.submit_participant_with_invite(event_b.id, invite_token_a, %{
               "display_name" => "Mallory",
               "rsvp_status" => "going"
             })

    assert row_counts() == before_counts
  end

  test "submission token is scoped to its participant and cannot grant owner or invite authority" do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, %{participant: participant_a, submission_token: submission_token_a}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Sam"})

    {:ok, %{participant: participant_b, submission_token: submission_token_b}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Riley"})

    assert {:ok, ^participant_a} =
             Events.verify_submission_token(event.id, participant_a.id, submission_token_a)

    assert {:error, :unauthorized} =
             Events.verify_submission_token(event.id, participant_b.id, submission_token_a)

    assert {:ok, updated_participant} =
             Events.update_participant_with_submission(
               event.id,
               participant_a.id,
               submission_token_a,
               %{
                 "display_name" => "Sam Updated",
                 "rsvp_status" => "not_going",
                 "role" => "drinks",
                 "review_status" => "accepted",
                 "event_id" => Ecto.UUID.generate(),
                 "submission_token_hash" => "attacker"
               }
             )

    assert updated_participant.display_name == "Sam Updated"
    assert updated_participant.rsvp_status == "not_going"
    assert updated_participant.role == "drinks"
    assert updated_participant.review_status == "pending"
    assert updated_participant.event_id == event.id
    assert updated_participant.submission_token_hash == participant_a.submission_token_hash

    assert {:error, :unauthorized} =
             Events.update_participant_with_submission(
               event.id,
               participant_b.id,
               submission_token_a,
               %{"display_name" => "Forged"}
             )

    assert Repo.get!(Participant, participant_b.id).display_name == "Riley"

    assert {:error, :unauthorized} = Events.verify_owner_token(event.id, submission_token_a)
    assert {:error, :unauthorized} = Events.verify_invite_token(event.id, submission_token_a)

    assert {:error, :unauthorized} =
             Events.submit_participant_with_invite(event.id, owner_token, %{
               "display_name" => "Owner"
             })

    assert {:error, :unauthorized} =
             Events.review_participant(event.id, participant_a.id, invite_token, "accepted")

    assert {:error, :unauthorized} =
             Events.review_participant(event.id, participant_a.id, submission_token_b, "accepted")

    assert {:ok, %{review_status: "accepted"}} =
             Events.review_participant(event.id, participant_a.id, owner_token, "accepted")
  end

  test "self-edit is allowed only for pending or accepted participants and preserves forbidden fields" do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic"})

    {:ok, %{participant: pending, submission_token: pending_token}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Sam"})

    assert {:ok, updated_pending} =
             Events.update_participant_with_submission(event.id, pending.id, pending_token, %{
               "display_name" => "Sam Pending",
               "rsvp_status" => "maybe",
               "role" => "snacks",
               "review_status" => "excluded",
               "event_id" => Ecto.UUID.generate(),
               "owner_token_hash" => "attacker",
               "invite_token_hash" => "attacker",
               "submission_token_hash" => "attacker",
               "source_payload" => %{"admin" => true}
             })

    assert updated_pending.display_name == "Sam Pending"
    assert updated_pending.rsvp_status == "maybe"
    assert updated_pending.role == "snacks"
    assert updated_pending.review_status == "pending"
    assert updated_pending.event_id == event.id
    assert updated_pending.submission_token_hash == pending.submission_token_hash
    assert updated_pending.source_payload == %{}

    assert {:ok, accepted} =
             Events.review_participant(event.id, pending.id, owner_token, "accepted")

    assert {:ok, updated_accepted} =
             Events.update_participant_with_submission(event.id, accepted.id, pending_token, %{
               "display_name" => "Sam Accepted"
             })

    assert updated_accepted.display_name == "Sam Accepted"
    assert updated_accepted.review_status == "accepted"

    {:ok, %{participant: rejected, submission_token: rejected_token}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Riley"})

    {:ok, %{participant: excluded, submission_token: excluded_token}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Jordan"})

    assert {:ok, %{review_status: "rejected"}} =
             Events.review_participant(event.id, rejected.id, owner_token, "rejected")

    assert {:ok, %{review_status: "excluded"}} =
             Events.review_participant(event.id, excluded.id, owner_token, "excluded")

    assert {:error, :unauthorized} =
             Events.update_participant_with_submission(event.id, rejected.id, rejected_token, %{
               "display_name" => "Rejected Edit"
             })

    assert {:error, :unauthorized} =
             Events.update_participant_with_submission(event.id, excluded.id, excluded_token, %{
               "display_name" => "Excluded Edit"
             })

    assert Repo.get!(Participant, rejected.id).display_name == "Riley"
    assert Repo.get!(Participant, excluded.id).display_name == "Jordan"
  end

  test "mixed event participant and submission token combinations fail closed" do
    {:ok, %{event: event_a, invite_token: invite_token_a}} =
      Events.create_event(%{"title" => "Park picnic"})

    {:ok, %{event: event_b, invite_token: invite_token_b}} =
      Events.create_event(%{"title" => "Lake picnic"})

    {:ok, %{participant: participant_a, submission_token: token_a}} =
      Events.submit_participant_with_invite(event_a.id, invite_token_a, %{"display_name" => "Sam"})

    {:ok, %{participant: participant_b, submission_token: token_b}} =
      Events.submit_participant_with_invite(event_b.id, invite_token_b, %{
        "display_name" => "Riley"
      })

    before_counts = row_counts()

    assert {:error, :unauthorized} =
             Events.update_participant_with_submission(event_a.id, participant_b.id, token_b, %{
               "display_name" => "Wrong event"
             })

    assert {:error, :unauthorized} =
             Events.update_participant_with_submission(event_b.id, participant_a.id, token_a, %{
               "display_name" => "Wrong event"
             })

    assert {:error, :unauthorized} =
             Events.update_participant_with_submission(event_a.id, participant_a.id, token_b, %{
               "display_name" => "Wrong token"
             })

    assert Repo.get!(Participant, participant_a.id).display_name == "Sam"
    assert Repo.get!(Participant, participant_b.id).display_name == "Riley"
    assert row_counts() == before_counts
  end

  test "invite retry with issued submission token updates existing participant instead of duplicating" do
    {:ok, %{event: event, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic"})

    assert {:ok, %{participant: participant, submission_token: submission_token}} =
             Events.submit_participant_with_invite(event.id, invite_token, %{
               "display_name" => "Sam",
               "rsvp_status" => "going"
             })

    assert {:ok, %{participant: retried, submission_token: ^submission_token}} =
             Events.submit_participant_with_invite(event.id, invite_token, %{
               "display_name" => "Sam Retry",
               "rsvp_status" => "not_going",
               "submission_token" => submission_token
             })

    assert retried.id == participant.id
    assert retried.display_name == "Sam Retry"
    assert retried.rsvp_status == "not_going"
    assert [%{id: participant_id}] = Events.list_participants(event.id)
    assert participant_id == participant.id
  end

  test "accepted participant listing excludes pending rejected and excluded participants" do
    {:ok, %{event: event, owner_token: owner_token, invite_token: invite_token}} =
      Events.create_event(%{"title" => "Park picnic", "creator_name" => "Avery"})

    {:ok, %{participant: pending}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{"display_name" => "Pending"})

    {:ok, %{participant: rejected}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Rejected"
      })

    {:ok, %{participant: excluded}} =
      Events.submit_participant_with_invite(event.id, invite_token, %{
        "display_name" => "Excluded"
      })

    {:ok, _} = Events.review_participant(event.id, rejected.id, owner_token, "rejected")
    {:ok, _} = Events.review_participant(event.id, excluded.id, owner_token, "excluded")

    assert ["Avery"] = Enum.map(Events.list_accepted_participants(event.id), & &1.display_name)

    assert MapSet.new(Enum.map(Events.list_participants(event.id), & &1.id)) ==
             MapSet.new([
               hd(Events.list_accepted_participants(event.id)).id,
               pending.id,
               rejected.id,
               excluded.id
             ])
  end

  defp mutate_token(<<first::binary-size(1), rest::binary>>) do
    replacement = if first == "a", do: "b", else: "a"
    replacement <> rest
  end

  defp row_counts do
    %{
      events: Repo.aggregate(Event, :count),
      participants: Repo.aggregate(Participant, :count)
    }
  end

  test "adds participants, logistics items, proposals, votes, and discussion comments" do
    {:ok, %{event: event}} = Events.create_event(%{"title" => "Park picnic"})

    assert {:ok, participant} =
             Events.create_participant(%{
               "event_id" => event.id,
               "display_name" => "Sam",
               "rsvp_status" => "maybe"
             })

    assert participant.display_name == "Sam"

    assert {:ok, item} =
             Events.create_item(%{
               "event_id" => event.id,
               "name" => "Fruit",
               "quantity" => "2 trays",
               "tags" => "vegan, dessert",
               "owner_name" => "Sam"
             })

    assert item.tags == ["vegan", "dessert"]

    assert {:ok, proposal} =
             Events.create_proposal(%{
               "event_id" => event.id,
               "proposal_type" => "location",
               "title" => "Use the park pavilion",
               "proposed_by_name" => "Sam",
               "details_text" => "Covered tables if it rains."
             })

    assert proposal.details == %{"notes" => "Covered tables if it rains."}

    assert {:ok, vote} =
             Events.create_vote(%{
               "proposal_id" => proposal.id,
               "voter_name" => "Avery",
               "weight" => "1"
             })

    assert vote.weight == 1
    assert [%{votes: [^vote]}] = Events.list_proposals(event.id)

    assert {:ok, comment} =
             Events.create_comment(%{
               "event_id" => event.id,
               "author_name" => "Sam",
               "body" => "I can bring berries."
             })

    assert [^comment] = Events.list_comments(event.id)
  end
end
