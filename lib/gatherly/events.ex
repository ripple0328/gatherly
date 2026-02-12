defmodule Gatherly.Events do
  @moduledoc """
  Event helpers for Gatherly.
  """

  alias Gatherly.Domain
  alias Gatherly.Events.{Event, Item, Rsvp}

  def list_events do
    Ash.read!(Event, domain: Domain)
  end

  def get_event_by_slug!(slug) do
    Ash.read_one!(Event, domain: Domain, filter: [slug: slug])
  end

  def list_rsvps(event_id) do
    Ash.read!(Rsvp, domain: Domain, filter: [event_id: event_id])
  end

  def list_items(event_id) do
    Ash.read!(Item, domain: Domain, filter: [event_id: event_id])
  end

  def create_event(params) do
    params = Map.put_new(params, "slug", generate_slug())
    Ash.create(Event, params, domain: Domain)
  end

  def create_rsvp(params) do
    Ash.create(Rsvp, params, domain: Domain)
  end

  def create_item(params) do
    Ash.create(Item, params, domain: Domain)
  end

  defp generate_slug do
    :crypto.strong_rand_bytes(6)
    |> Base.url_encode64(padding: false)
    |> String.replace(~r/[^a-zA-Z0-9]/, "")
    |> String.downcase()
    |> String.slice(0, 10)
  end
end
