defmodule Gatherly.EventsTest do
  use Gatherly.DataCase, async: true

  alias Gatherly.Events

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
    assert [%{display_name: "Avery", rsvp_status: "going"}] = Events.list_participants(event.id)
  end

  test "adds participants, logistics items, and discussion comments" do
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

    assert {:ok, comment} =
             Events.create_comment(%{
               "event_id" => event.id,
               "author_name" => "Sam",
               "body" => "I can bring berries."
             })

    assert [^comment] = Events.list_comments(event.id)
  end
end
