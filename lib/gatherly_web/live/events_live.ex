defmodule GatherlyWeb.EventsLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events
  alias Gatherly.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:events, Events.list_events())
     |> assign(:form, to_form(default_form(), as: :event))
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("save", %{"event" => params}, socket) do
    case Events.create_event(params) do
      {:ok, %{event: event}} ->
        {:noreply, push_navigate(socket, to: ~p"/events/#{event.slug}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: :event))
         |> assign(:form_error, "Could not create event. Check the fields and try again.")}
    end
  end

  defp default_form do
    %{
      "title" => "",
      "event_type" => "potluck",
      "creator_name" => "",
      "starts_at" => "",
      "location" => "",
      "description" => ""
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-6xl px-6 py-10">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
              Gatherly reboot
            </p>
            <h1 class="mt-2 text-3xl font-semibold">Crowdsource the event, not just the invite.</h1>
            <p class="mt-3 max-w-2xl text-base-content/70">
              Start with a potluck, share the link, and let participants add themselves and own logistics.
            </p>
          </div>
          <.link navigate={~p"/"} class="btn btn-ghost">Home</.link>
        </div>

        <div class="mt-8 grid gap-8 lg:grid-cols-[1.05fr_1fr]">
          <div class="rounded-box border border-base-200 bg-base-100 p-6 shadow-sm">
            <h2 class="text-lg font-semibold">Start an event</h2>
            <.simple_form for={@form} id="event-form" phx-submit="save" class="mt-6 space-y-4">
              <.input field={@form[:title]} label="Event title" required />
              <.input
                field={@form[:event_type]}
                type="select"
                label="Event type"
                options={
                  Enum.map(
                    Event.event_types(),
                    &{String.replace(&1, "_", " ") |> String.capitalize(), &1}
                  )
                }
              />
              <.input field={@form[:creator_name]} label="Your name (optional)" />
              <.input field={@form[:starts_at]} type="datetime-local" label="Start time (optional)" />
              <.input field={@form[:location]} label="Location (optional)" />
              <.input field={@form[:description]} type="textarea" label="Description (optional)" />
              <.button type="submit">Create shareable event</.button>
            </.simple_form>
            <%= if @form_error do %>
              <p class="mt-3 text-sm text-error">{@form_error}</p>
            <% end %>
          </div>

          <div class="rounded-box border border-base-200 bg-base-100 p-6 shadow-sm">
            <h2 class="text-lg font-semibold">Recent events</h2>
            <div class="mt-4 space-y-4">
              <%= if Enum.empty?(@events) do %>
                <p class="text-sm text-base-content/60">No events yet.</p>
              <% else %>
                <div :for={event <- @events} class="rounded-lg border border-base-200 p-4">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <div class="font-semibold">{event.title}</div>
                      <div class="text-xs uppercase tracking-wide text-base-content/50">
                        {event.event_type}
                      </div>
                    </div>
                    <.link class="link text-sm" navigate={~p"/events/#{event.slug}"}>Open</.link>
                  </div>
                  <%= if event.starts_at do %>
                    <div class="mt-2 text-sm text-base-content/70">{format_dt(event.starts_at)}</div>
                  <% end %>
                  <%= if event.location do %>
                    <div class="text-sm text-base-content/70">{event.location}</div>
                  <% end %>
                  <%= if event.description do %>
                    <p class="mt-2 text-sm text-base-content/80">{event.description}</p>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(other), do: to_string(other)
end
