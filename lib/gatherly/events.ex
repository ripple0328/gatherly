defmodule Gatherly.Events do
  @moduledoc """
  Event helpers for Gatherly.
  """

  alias Gatherly.Domain
  alias Gatherly.Events.Event

  def list_events do
    Ash.read!(Event, domain: Domain)
  end

  def create_event(params) do
    Ash.create(Event, params, domain: Domain)
  end
end
