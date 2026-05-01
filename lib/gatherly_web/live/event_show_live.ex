defmodule GatherlyWeb.EventShowLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @impl true
  def mount(%{"slug" => slug} = params, _session, socket) do
    event = Events.get_event_by_slug!(slug)

    {:ok,
     socket
     |> assign(:event, event)
     |> assign_authority_entry_points(params)
     |> reload_event_workspace()
     |> assign(:item_form, to_form(default_item_form(), as: :item))
     |> assign(:proposal_form, to_form(default_proposal_form(), as: :proposal))
     |> assign(:comment_form, to_form(default_comment_form(), as: :comment))
     |> assign(:editing_item_id, nil)
     |> assign(:form_error, nil)}
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
  def handle_event("add_proposal", %{"proposal" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    case Events.create_proposal(params) do
      {:ok, _proposal} ->
        {:noreply,
         socket
         |> reload_event_workspace()
         |> assign(:proposal_form, to_form(default_proposal_form(), as: :proposal))
         |> assign(:form_error, nil)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:proposal_form, to_form(changeset, as: :proposal))
         |> assign(:form_error, "Could not add proposal.")}
    end
  end

  @impl true
  def handle_event("vote", %{"vote" => params}, socket) do
    case Events.create_vote(params) do
      {:ok, _vote} ->
        {:noreply,
         socket
         |> reload_event_workspace()
         |> assign(:form_error, nil)}

      {:error, _changeset} ->
        {:noreply, assign(socket, :form_error, "Could not record vote.")}
    end
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
    |> assign(:participants, Events.list_accepted_participants(event_id))
    |> assign(:items, Events.list_items(event_id))
    |> assign(:proposals, Events.list_proposals(event_id))
    |> assign(:comments, Events.list_comments(event_id))
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

  defp default_proposal_form do
    %{
      "proposal_type" => "time",
      "title" => "",
      "proposed_by_name" => "",
      "details_text" => ""
    }
  end

  defp default_comment_form do
    %{"author_name" => "", "body" => ""}
  end

  defp proposal_score(proposal) do
    proposal.votes
    |> Enum.map(& &1.weight)
    |> Enum.sum()
  end

  defp proposal_notes(%{details: %{"notes" => notes}}) when is_binary(notes), do: notes
  defp proposal_notes(_proposal), do: nil

  defp event_link(event), do: GatherlyWeb.Endpoint.url() <> "/events/" <> event.slug

  defp owner_review_url(event, token),
    do: GatherlyWeb.Endpoint.url() <> ~p"/events/#{event.slug}/owner/#{token}"

  defp invite_url(event, token),
    do: GatherlyWeb.Endpoint.url() <> ~p"/events/#{event.slug}/invite/#{token}"

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(other), do: to_string(other)

  defp assign_authority_entry_points(socket, params) do
    event_id = socket.assigns.event.id
    owner_token = Map.get(params, "owner_token")
    invite_token = Map.get(params, "invite_token")

    owner_token =
      case Events.verify_owner_token(event_id, owner_token) do
        {:ok, _event} -> owner_token
        {:error, :unauthorized} -> nil
      end

    invite_token =
      case Events.verify_invite_token(event_id, invite_token) do
        {:ok, _event} -> invite_token
        {:error, :unauthorized} -> nil
      end

    socket
    |> assign(:owner_token, owner_token)
    |> assign(:invite_token, invite_token)
  end

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

        <%= if @owner_token || @invite_token do %>
          <div class="mt-6 rounded-box border border-primary/30 bg-primary/5 p-6">
            <h2 class="text-lg font-semibold">Event authority links</h2>
            <p class="mt-1 text-sm text-base-content/70">
              Save these links now. They are the only browser-visible entry points for owner review and invited participant submission.
            </p>
            <div class="mt-4 grid gap-3">
              <%= if @owner_token do %>
                <div>
                  <div class="text-sm font-medium">Owner review link</div>
                  <.link
                    class="link break-all text-sm"
                    navigate={~p"/events/#{@event.slug}/owner/#{@owner_token}"}
                  >
                    {owner_review_url(@event, @owner_token)}
                  </.link>
                </div>
              <% end %>
              <%= if @invite_token do %>
                <div>
                  <div class="text-sm font-medium">Invite link</div>
                  <.link
                    class="link break-all text-sm"
                    navigate={~p"/events/#{@event.slug}/invite/#{@invite_token}"}
                  >
                    {invite_url(@event, @invite_token)}
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <div class="mt-8 grid gap-8 lg:grid-cols-[0.9fr_1.1fr]">
          <section class="space-y-8">
            <div class="rounded-box border border-base-200 bg-base-100 p-6">
              <h2 class="text-lg font-semibold">Participants</h2>
              <p class="mt-1 text-sm text-base-content/60">
                Accepted participants appear here. Use an invite link to submit your RSVP.
              </p>

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
                        <span class="text-base-content/50"> ·          {participant.role}</span>
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
              <h2 class="text-lg font-semibold">Proposals and voting</h2>
              <p class="mt-1 text-sm text-base-content/60">
                Anyone can suggest a time or location, then the group can vote it up or down.
              </p>
              <.simple_form
                for={@proposal_form}
                id="proposal-form"
                phx-submit="add_proposal"
                class="mt-6 space-y-4"
              >
                <.input
                  field={@proposal_form[:proposal_type]}
                  type="select"
                  label="Proposal type"
                  options={[{"Time", "time"}, {"Location", "location"}]}
                />
                <.input field={@proposal_form[:title]} label="Proposal" required />
                <.input field={@proposal_form[:proposed_by_name]} label="Proposed by" />
                <.input field={@proposal_form[:details_text]} label="Details" type="textarea" />
                <.button type="submit">Add proposal</.button>
              </.simple_form>

              <div class="mt-6 space-y-3">
                <%= if Enum.empty?(@proposals) do %>
                  <p class="text-sm text-base-content/60">No proposals yet.</p>
                <% else %>
                  <div :for={proposal <- @proposals} class="rounded-lg border border-base-200 p-4">
                    <div class="flex items-start justify-between gap-4">
                      <div>
                        <div class="text-xs uppercase tracking-wide text-base-content/50">
                          {proposal.proposal_type}
                        </div>
                        <div class="font-medium">{proposal.title}</div>
                        <%= if proposal.proposed_by_name do %>
                          <div class="text-sm text-base-content/60">
                            Proposed by {proposal.proposed_by_name}
                          </div>
                        <% end %>
                      </div>
                      <div class="text-right">
                        <div class="text-2xl font-semibold">{proposal_score(proposal)}</div>
                        <div class="text-xs text-base-content/50">score</div>
                      </div>
                    </div>
                    <%= if proposal_notes(proposal) do %>
                      <p class="mt-2 text-sm text-base-content/70">{proposal_notes(proposal)}</p>
                    <% end %>
                    <form phx-submit="vote" class="mt-4 grid gap-2 sm:grid-cols-[1fr_auto_auto]">
                      <input type="hidden" name="vote[proposal_id]" value={proposal.id} />
                      <input
                        id={"vote-name-#{proposal.id}"}
                        name="vote[voter_name]"
                        class="input input-bordered input-sm w-full"
                        placeholder="Your name"
                        required
                      />
                      <button class="btn btn-sm btn-outline" name="vote[weight]" value="1">
                        Upvote
                      </button>
                      <button class="btn btn-sm btn-ghost" name="vote[weight]" value="-1">
                        Downvote
                      </button>
                    </form>
                    <%= if proposal.votes != [] do %>
                      <div class="mt-3 flex flex-wrap gap-2 text-xs text-base-content/60">
                        <span :for={vote <- proposal.votes} class="badge badge-ghost">
                          {vote.voter_name}: {if vote.weight > 0, do: "+1", else: "-1"}
                        </span>
                      </div>
                    <% end %>
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
          commute-aware location comparison, owner review tokens, account claiming, and AI coverage checks.
        </div>

        <%= if @form_error do %>
          <p class="mt-6 text-sm text-error">{@form_error}</p>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
