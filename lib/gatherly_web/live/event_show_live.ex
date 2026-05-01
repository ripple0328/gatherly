defmodule GatherlyWeb.EventShowLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    event = Events.get_event_by_slug!(slug)

    {:ok,
     socket
     |> assign(:event, event)
     |> reload_event_workspace()
     |> assign(:participant_form, to_form(default_participant_form(), as: :participant))
     |> assign(:item_form, to_form(default_item_form(), as: :item))
     |> assign(:comment_form, to_form(default_comment_form(), as: :comment))
     |> assign(:editing_item_id, nil)
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("join", %{"participant" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    case Events.create_participant(params) do
      {:ok, _participant} ->
        {:noreply,
         socket
         |> reload_event_workspace()
         |> assign(:participant_form, to_form(default_participant_form(), as: :participant))
         |> assign(:form_error, nil)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:participant_form, to_form(changeset, as: :participant))
         |> assign(:form_error, "Could not add participant.")}
    end
  end

  @impl true
  def handle_event("add_item", %{"item" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    case Map.get(params, "id") do
      id when id in [nil, ""] -> create_item(Map.delete(params, "id"), socket)
      id -> update_item(id, Map.delete(params, "id"), socket)
    end
  end

  @impl true
  def handle_event("edit_item", %{"id" => id}, socket) do
    item = Enum.find(socket.assigns.items, &(&1.id == id))

    form =
      if item do
        %{
          "id" => item.id,
          "name" => item.name,
          "quantity" => item.quantity || "",
          "category" => item.category || "food",
          "tags" => Enum.join(item.tags || [], ", "),
          "status" => item.status || "unassigned",
          "owner_name" => item.owner_name || "",
          "notes" => item.notes || ""
        }
      else
        default_item_form()
      end

    {:noreply,
     socket
     |> assign(:item_form, to_form(form, as: :item))
     |> assign(:editing_item_id, item && item.id)}
  end

  @impl true
  def handle_event("cancel_item_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:item_form, to_form(default_item_form(), as: :item))
     |> assign(:editing_item_id, nil)}
  end

  @impl true
  def handle_event("delete_item", %{"id" => id}, socket) do
    _ = Events.delete_item(id)

    {:noreply,
     socket
     |> reload_event_workspace()
     |> assign(:item_form, to_form(default_item_form(), as: :item))
     |> assign(:editing_item_id, nil)
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("add_comment", %{"comment" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    case Events.create_comment(params) do
      {:ok, _comment} ->
        {:noreply,
         socket
         |> reload_event_workspace()
         |> assign(:comment_form, to_form(default_comment_form(), as: :comment))
         |> assign(:form_error, nil)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:comment_form, to_form(changeset, as: :comment))
         |> assign(:form_error, "Could not add comment.")}
    end
  end

  defp create_item(params, socket) do
    case Events.create_item(params) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> reload_event_workspace()
         |> assign(:item_form, to_form(default_item_form(), as: :item))
         |> assign(:editing_item_id, nil)
         |> assign(:form_error, nil)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:item_form, to_form(changeset, as: :item))
         |> assign(:form_error, "Could not save item.")}
    end
  end

  defp update_item(id, params, socket) do
    case Events.update_item(id, params) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> reload_event_workspace()
         |> assign(:item_form, to_form(default_item_form(), as: :item))
         |> assign(:editing_item_id, nil)
         |> assign(:form_error, nil)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:item_form, to_form(changeset, as: :item))
         |> assign(:form_error, "Could not save item.")}
    end
  end

  defp reload_event_workspace(socket) do
    event_id = socket.assigns.event.id

    socket
    |> assign(:participants, Events.list_participants(event_id))
    |> assign(:items, Events.list_items(event_id))
    |> assign(:proposals, Events.list_proposals(event_id))
    |> assign(:comments, Events.list_comments(event_id))
  end

  defp default_participant_form do
    %{"display_name" => "", "rsvp_status" => "going", "role" => ""}
  end

  defp default_item_form do
    %{
      "name" => "",
      "quantity" => "",
      "category" => "food",
      "tags" => "",
      "status" => "unassigned",
      "owner_name" => "",
      "notes" => ""
    }
  end

  defp default_comment_form do
    %{"author_name" => "", "body" => ""}
  end

  defp event_link(event), do: GatherlyWeb.Endpoint.url() <> "/events/" <> event.slug
  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(other), do: to_string(other)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-7xl px-6 py-10">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
              {@event.event_type}
            </p>
            <h1 class="mt-2 text-3xl font-semibold">{@event.title}</h1>
            <div class="mt-2 flex flex-wrap items-center gap-2 text-sm text-base-content/70">
              <span>{event_link(@event)}</span>
              <button
                type="button"
                class="btn btn-xs btn-ghost"
                data-clipboard={event_link(@event)}
                onclick="navigator.clipboard.writeText(this.dataset.clipboard)"
              >
                Copy link
              </button>
            </div>
          </div>
          <.link navigate={~p"/events"} class="btn btn-ghost">All events</.link>
        </div>

        <div class="mt-6 rounded-box border border-base-200 bg-base-100 p-6">
          <div class="grid gap-4 sm:grid-cols-3">
            <div>
              <div class="text-sm text-base-content/60">When</div>
              <div class="font-medium">
                {(@event.starts_at && format_dt(@event.starts_at)) || "TBD"}
              </div>
            </div>
            <div>
              <div class="text-sm text-base-content/60">Where</div>
              <div class="font-medium">{@event.location || "TBD"}</div>
            </div>
            <div>
              <div class="text-sm text-base-content/60">Planning state</div>
              <div class="font-medium">{@event.decision_status}</div>
            </div>
          </div>
          <%= if @event.description do %>
            <p class="mt-4 text-base-content/80">{@event.description}</p>
          <% end %>
        </div>

        <div class="mt-8 grid gap-8 lg:grid-cols-[0.9fr_1.1fr]">
          <section class="space-y-8">
            <div class="rounded-box border border-base-200 bg-base-100 p-6">
              <h2 class="text-lg font-semibold">Join the event</h2>
              <.simple_form
                for={@participant_form}
                id="participant-form"
                phx-submit="join"
                class="mt-6 space-y-4"
              >
                <.input field={@participant_form[:display_name]} label="Your name" required />
                <.input field={@participant_form[:role]} label="Role or note (optional)" />
                <.input
                  field={@participant_form[:rsvp_status]}
                  type="select"
                  label="RSVP"
                  options={[{"Going", "going"}, {"Maybe", "maybe"}, {"Not going", "not_going"}]}
                />
                <.button type="submit">Add myself</.button>
              </.simple_form>

              <div class="mt-6 space-y-2">
                <%= if Enum.empty?(@participants) do %>
                  <p class="text-sm text-base-content/60">No participants yet.</p>
                <% else %>
                  <div
                    :for={participant <- @participants}
                    class="flex items-center justify-between text-sm"
                  >
                    <div>
                      <span class="font-medium">{participant.display_name}</span>
                      <%= if participant.role do %>
                        <span class="text-base-content/50"> ·     {participant.role}</span>
                      <% end %>
                    </div>
                    <span class="badge badge-outline">
                      {String.replace(participant.rsvp_status, "_", " ")}
                    </span>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="rounded-box border border-base-200 bg-base-100 p-6">
              <h2 class="text-lg font-semibold">Discussion</h2>
              <.simple_form
                for={@comment_form}
                id="comment-form"
                phx-submit="add_comment"
                class="mt-6 space-y-4"
              >
                <.input field={@comment_form[:author_name]} label="Name" required />
                <.input field={@comment_form[:body]} label="Comment" type="textarea" required />
                <.button type="submit">Post</.button>
              </.simple_form>

              <div class="mt-6 space-y-3">
                <%= if Enum.empty?(@comments) do %>
                  <p class="text-sm text-base-content/60">No discussion yet.</p>
                <% else %>
                  <div :for={comment <- @comments} class="rounded-lg border border-base-200 p-3">
                    <div class="text-sm font-medium">{comment.author_name}</div>
                    <p class="mt-1 text-sm text-base-content/75">{comment.body}</p>
                  </div>
                <% end %>
              </div>
            </div>
          </section>

          <section class="rounded-box border border-base-200 bg-base-100 p-6">
            <h2 class="text-lg font-semibold">Potluck logistics</h2>
            <p class="mt-1 text-sm text-base-content/60">
              Add food, supplies, or tasks and let the group claim ownership.
            </p>
            <.simple_form for={@item_form} id="item-form" phx-submit="add_item" class="mt-6 space-y-4">
              <input type="hidden" name="item[id]" value={@editing_item_id || ""} />
              <.input field={@item_form[:name]} label="Item or task" required />
              <div class="grid gap-4 sm:grid-cols-2">
                <.input field={@item_form[:quantity]} label="Quantity" />
                <.input field={@item_form[:category]} label="Category" />
              </div>
              <div class="grid gap-4 sm:grid-cols-2">
                <.input field={@item_form[:owner_name]} label="Owner" />
                <.input
                  field={@item_form[:status]}
                  type="select"
                  label="Status"
                  options={[
                    {"Unassigned", "unassigned"},
                    {"Planned", "planned"},
                    {"In progress", "in_progress"},
                    {"Done", "done"}
                  ]}
                />
              </div>
              <.input field={@item_form[:tags]} label="Tags (comma separated)" />
              <.input field={@item_form[:notes]} label="Notes" type="textarea" />
              <div class="flex items-center gap-3">
                <.button type="submit">{(@editing_item_id && "Save changes") || "Add item"}</.button>
                <%= if @editing_item_id do %>
                  <button type="button" class="btn btn-ghost" phx-click="cancel_item_edit">
                    Cancel
                  </button>
                <% end %>
              </div>
            </.simple_form>

            <div class="mt-6 space-y-3">
              <%= if Enum.empty?(@items) do %>
                <p class="text-sm text-base-content/60">No logistics yet.</p>
              <% else %>
                <div :for={item <- @items} class="rounded-lg border border-base-200 p-4">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <div class="font-medium">{item.name}</div>
                      <div class="text-sm text-base-content/60">
                        {item.category || "general"} · {String.replace(item.status, "_", " ")}
                      </div>
                      <%= if item.owner_name do %>
                        <div class="text-sm text-base-content/60">Owned by {item.owner_name}</div>
                      <% end %>
                    </div>
                    <div class="flex items-center gap-2">
                      <button
                        type="button"
                        class="btn btn-xs btn-ghost"
                        phx-click="edit_item"
                        phx-value-id={item.id}
                      >
                        Edit
                      </button>
                      <button
                        type="button"
                        class="btn btn-xs btn-ghost text-error"
                        phx-click="delete_item"
                        phx-value-id={item.id}
                        data-confirm="Delete this item?"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                  <%= if item.quantity do %>
                    <div class="mt-1 text-sm text-base-content/60">Qty: {item.quantity}</div>
                  <% end %>
                  <%= if item.tags && item.tags != [] do %>
                    <div class="mt-2 flex flex-wrap gap-2">
                      <span :for={tag <- item.tags} class="badge badge-outline">{tag}</span>
                    </div>
                  <% end %>
                  <%= if item.notes do %>
                    <p class="mt-2 text-sm text-base-content/70">{item.notes}</p>
                  <% end %>
                </div>
              <% end %>
            </div>
          </section>
        </div>

        <div class="mt-8 rounded-box border border-dashed border-base-300 p-6 text-sm text-base-content/65">
          <strong>Next roadmap slots:</strong>
          proposal voting, commute-aware location comparison, owner review tokens, account claiming, and AI coverage checks.
        </div>

        <%= if @form_error do %>
          <p class="mt-6 text-sm text-error">{@form_error}</p>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
