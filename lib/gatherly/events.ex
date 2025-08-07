defmodule Gatherly.Events do
  @moduledoc """
  Events domain for managing events and invitations.
  """

  use Ash.Domain

  resources do
    resource(Gatherly.Events.Event)
    resource(Gatherly.Events.MagicLink)
  end
end
