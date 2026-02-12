defmodule GatherlyWeb.EventShowLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    event = Events.get_event_by_slug!(slug)

    {:ok,
     socket
     |> assign(:event, event)
     |> assign(:rsvps, Events.list_rsvps(event.id))
     |> assign(:items, Events.list_items(event.id))
     |> assign(:rsvp_form, to_form(default_rsvp_form()))
     |> assign(:item_form, to_form(default_item_form()))
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("rsvp", %{"rsvp" => params}, socket) do
    params =
      params
      |> Map.put("event_id", socket.assigns.event.id)
      |> Map.update("status", "maybe", &String.downcase/1)

    case Events.create_rsvp(params) do
      {:ok, _rsvp} ->
        {:noreply,
         socket
         |> assign(:rsvps, Events.list_rsvps(socket.assigns.event.id))
         |> assign(:rsvp_form, to_form(default_rsvp_form()))
         |> assign(:form_error, nil)}

      {:error, error} ->
        {:noreply, assign(socket, :form_error, error)}
    end
  end

  @impl true
  def handle_event("add_item", %{"item" => params}, socket) do
    params =
      params
      |> Map.put("event_id", socket.assigns.event.id)
      |> Map.update("dietary_tags", [], &parse_tags/1)

    case Events.create_item(params) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> assign(:items, Events.list_items(socket.assigns.event.id))
         |> assign(:item_form, to_form(default_item_form()))
         |> assign(:form_error, nil)}

      {:error, error} ->
        {:noreply, assign(socket, :form_error, error)}
    end
  end

  defp default_rsvp_form do
    %{
      "name" => "",
      "status" => "yes"
    }
  end

  defp default_item_form do
    %{
      "name" => "",
      "quantity" => "",
      "dietary_tags" => "",
      "assigned_to" => "",
      "notes" => ""
    }
  end

  defp parse_tags(tags) when is_binary(tags) do
    tags
    |> String.split([",", ";"], trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse_tags(_), do: []

  defp event_link(event) do
    GatherlyWeb.Endpoint.url() <> "/events/" <> event.slug
  end

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(other), do: to_string(other)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-5xl px-6 py-10">
      <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 class="text-2xl font-semibold"><%= @event.title %></h1>
          <p class="text-sm text-base-content/70"><%= event_link(@event) %></p>
        </div>
        <a href="/events" class="btn btn-ghost">All events</a>
      </div>

      <div class="mt-6 rounded-box border border-base-200 bg-base-100 p-6">
        <div class="grid gap-4 sm:grid-cols-2">
          <div>
            <div class="text-sm text-base-content/60">When</div>
            <div class="font-medium"><%= @event.starts_at && format_dt(@event.starts_at) || "TBD" %></div>
          </div>
          <div>
            <div class="text-sm text-base-content/60">Where</div>
            <div class="font-medium"><%= @event.location || "TBD" %></div>
          </div>
        </div>
        <%= if @event.description do %>
          <p class="mt-4 text-base-content/80"><%= @event.description %></p>
        <% end %>
      </div>

      <div class="mt-8 grid gap-8 lg:grid-cols-2">
        <div class="rounded-box border border-base-200 bg-base-100 p-6">
          <h2 class="text-lg font-semibold">RSVP</h2>
          <.simple_form for={@rsvp_form} phx-submit="rsvp" class="mt-6 space-y-4">
            <.input field={@rsvp_form[:name]} label="Your name" required />
            <.input
              field={@rsvp_form[:status]}
              type="select"
              label="Status"
              options={[[label: "Yes", value: "yes"], [label: "Maybe", value: "maybe"], [label: "No", value: "no"]]}
            />
            <.button type="submit">Submit RSVP</.button>
          </.simple_form>

          <div class="mt-6 space-y-2">
            <%= if Enum.empty?(@rsvps) do %>
              <p class="text-sm text-base-content/60">No RSVPs yet.</p>
            <% else %>
              <%= for rsvp <- @rsvps do %>
                <div class="flex items-center justify-between text-sm">
                  <span><%= rsvp.name %></span>
                  <span class="badge badge-outline"><%= String.upcase(rsvp.status) %></span>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>

        <div class="rounded-box border border-base-200 bg-base-100 p-6">
          <h2 class="text-lg font-semibold">Potluck items</h2>
          <.simple_form for={@item_form} phx-submit="add_item" class="mt-6 space-y-4">
            <.input field={@item_form[:name]} label="Item" required />
            <.input field={@item_form[:quantity]} label="Quantity" />
            <.input field={@item_form[:dietary_tags]} label="Dietary tags (comma separated)" />
            <.input field={@item_form[:assigned_to]} label="Assigned to" />
            <.input field={@item_form[:notes]} label="Notes" type="textarea" />
            <.button type="submit">Add item</.button>
          </.simple_form>

          <div class="mt-6 space-y-3">
            <%= if Enum.empty?(@items) do %>
              <p class="text-sm text-base-content/60">No items yet.</p>
            <% else %>
              <%= for item <- @items do %>
                <div class="rounded-lg border border-base-200 p-3">
                  <div class="flex items-center justify-between">
                    <div class="font-medium"><%= item.name %></div>
                    <%= if item.assigned_to do %>
                      <div class="text-sm text-base-content/60">Assigned to <%= item.assigned_to %></div>
                    <% end %>
                  </div>
                  <%= if item.quantity do %>
                    <div class="text-sm text-base-content/60">Qty: <%= item.quantity %></div>
                  <% end %>
                  <%= if item.dietary_tags && item.dietary_tags != [] do %>
                    <div class="mt-2 flex flex-wrap gap-2">
                      <%= for tag <- item.dietary_tags do %>
                        <span class="badge badge-outline"><%= tag %></span>
                      <% end %>
                    </div>
                  <% end %>
                  <%= if item.notes do %>
                    <p class="mt-2 text-sm text-base-content/70"><%= item.notes %></p>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <%= if @form_error do %>
        <p class="mt-6 text-sm text-error">Something went wrong. Please try again.</p>
      <% end %>
    </div>
    """
  end
end
