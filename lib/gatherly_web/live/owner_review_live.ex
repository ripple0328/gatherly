defmodule GatherlyWeb.OwnerReviewLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @statuses [
    {"pending", "Pending"},
    {"accepted", "Accepted"},
    {"rejected", "Rejected"},
    {"excluded", "Excluded"}
  ]

  @impl true
  def mount(%{"slug" => slug, "token" => token}, _session, socket) do
    event = Events.get_event_by_slug!(slug)

    case Events.list_review_participants(event.id, token) do
      {:ok, grouped_participants} ->
        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:owner_token, token)
         |> assign(:statuses, @statuses)
         |> assign(:grouped_participants, grouped_participants)
         |> assign(:form_error, nil)}

      {:error, :unauthorized} ->
        {:ok, unauthorized_socket(socket)}
    end
  rescue
    Ecto.NoResultsError ->
      {:ok, unauthorized_socket(socket)}
  end

  @impl true
  def handle_event("review", %{"participant-id" => participant_id, "status" => status}, socket) do
    if socket.assigns.owner_token do
      case Events.review_participant(
             socket.assigns.event.id,
             participant_id,
             socket.assigns.owner_token,
             status
           ) do
        {:ok, _participant} ->
          {:noreply,
           socket
           |> reload_review_participants()
           |> assign(:form_error, nil)}

        {:error, :unauthorized} ->
          {:noreply, assign(socket, :form_error, "That review action is not available.")}
      end
    else
      {:noreply, assign(socket, :form_error, "This owner review link is invalid or unavailable.")}
    end
  end

  defp reload_review_participants(socket) do
    case Events.list_review_participants(socket.assigns.event.id, socket.assigns.owner_token) do
      {:ok, grouped_participants} -> assign(socket, :grouped_participants, grouped_participants)
      {:error, :unauthorized} -> unauthorized_socket(socket)
    end
  end

  defp unauthorized_socket(socket) do
    socket
    |> assign(:event, nil)
    |> assign(:owner_token, nil)
    |> assign(:statuses, @statuses)
    |> assign(:grouped_participants, empty_groups())
    |> assign(:form_error, "This owner review link is invalid or unavailable.")
  end

  defp empty_groups do
    %{pending: [], accepted: [], rejected: [], excluded: []}
  end

  defp participants_for_status(grouped_participants, status) do
    Map.fetch!(grouped_participants, String.to_existing_atom(status))
  end

  defp actions_for_status("pending"),
    do: [{"Accept", "accepted"}, {"Reject", "rejected"}, {"Exclude", "excluded"}]

  defp actions_for_status("accepted"), do: [{"Exclude", "excluded"}]
  defp actions_for_status(_status), do: []

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-5xl px-6 py-10">
        <%= if @owner_token do %>
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
                Owner review
              </p>
              <h1 class="mt-2 text-3xl font-semibold">{@event.title}</h1>
              <p class="mt-3 text-base-content/70">
                Review participant submissions. Public, invite, and self-edit pages only show accepted participants.
              </p>
            </div>
            <.link navigate={~p"/events/#{@event.slug}"} class="btn btn-ghost">
              Public workspace
            </.link>
          </div>

          <div class="mt-8 grid gap-6 md:grid-cols-2">
            <section
              :for={{status, label} <- @statuses}
              class="rounded-box border border-base-200 bg-base-100 p-5"
              data-status-group={status}
            >
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold">{label}</h2>
                <span class="badge badge-outline">
                  {length(participants_for_status(@grouped_participants, status))}
                </span>
              </div>

              <div class="mt-4 space-y-3">
                <%= if Enum.empty?(participants_for_status(@grouped_participants, status)) do %>
                  <p class="text-sm text-base-content/60">
                    No {String.downcase(label)} participants.
                  </p>
                <% else %>
                  <div
                    :for={participant <- participants_for_status(@grouped_participants, status)}
                    id={"participant-#{participant.id}"}
                    class="rounded-lg border border-base-200 p-4"
                  >
                    <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                      <div>
                        <div class="font-medium">{participant.display_name}</div>
                        <div class="mt-1 text-sm text-base-content/60">
                          RSVP: {String.replace(participant.rsvp_status, "_", " ")}
                          <%= if participant.role do %>
                            <span> · Role/note:     {participant.role}</span>
                          <% end %>
                        </div>
                        <span class="badge badge-ghost mt-2">{label}</span>
                      </div>
                      <div class="flex flex-wrap gap-2">
                        <button
                          :for={{action_label, target_status} <- actions_for_status(status)}
                          type="button"
                          class="btn btn-xs btn-outline"
                          phx-click="review"
                          phx-value-participant-id={participant.id}
                          phx-value-status={target_status}
                        >
                          {action_label}
                        </button>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            </section>
          </div>
        <% else %>
          <div class="rounded-box border border-base-200 bg-base-100 p-6">
            <h1 class="text-2xl font-semibold">Owner review unavailable</h1>
            <p class="mt-3 text-base-content/70">{@form_error}</p>
          </div>
        <% end %>

        <%= if @form_error && @owner_token do %>
          <p class="mt-6 text-sm text-error">{@form_error}</p>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
