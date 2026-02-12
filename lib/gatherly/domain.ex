defmodule Gatherly.Domain do
  @moduledoc """
  Gatherly Ash domain.

  This is intentionally empty in the skeleton app. Add resources as features are
  implemented.
  """

  use Ash.Domain

  resources do
    resource Gatherly.Events.Event
    resource Gatherly.Events.Rsvp
    resource Gatherly.Events.Item
  end
end
