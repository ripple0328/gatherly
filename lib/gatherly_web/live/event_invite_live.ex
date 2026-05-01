defmodule GatherlyWeb.EventInviteLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @impl true
  def mount(%{"slug" => slug, "token" => token}, _session, socket) do
    event = Events.get_event_by_slug!(slug)

    case Events.verify_invite_token(event.id, token) do
      {:ok, event} ->
        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:invite_token, token)
         |> assign(:participants, Events.list_accepted_participants(event.id))
         |> assign(:participant, nil)
         |> assign(:submission_token, nil)
         |> assign(:form, to_form(default_form(), as: :participant))
         |> assign(:form_error, nil)}

      {:error, :unauthorized} ->
        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:invite_token, nil)
         |> assign(:participants, Events.list_accepted_participants(event.id))
         |> assign(:participant, nil)
         |> assign(:submission_token, nil)
         |> assign(:form, to_form(default_form(), as: :participant))
         |> assign(:form_error, "This invite link is invalid or expired.")}
    end
  rescue
    Ecto.NoResultsError ->
      {:ok,
       socket
       |> assign(:event, nil)
       |> assign(:invite_token, nil)
       |> assign(:participants, [])
       |> assign(:participant, nil)
       |> assign(:submission_token, nil)
       |> assign(:form, to_form(default_form(), as: :participant))
       |> assign(:form_error, "This invite link is invalid or expired.")}
  end

  @impl true
  def handle_event("submit", %{"participant" => params}, socket) do
    if socket.assigns.invite_token do
      params =
        if socket.assigns.submission_token do
          Map.put(params, "submission_token", socket.assigns.submission_token)
        else
          params
        end

      case Events.submit_participant_with_invite(
             socket.assigns.event.id,
             socket.assigns.invite_token,
             params
           ) do
        {:ok, %{participant: participant, submission_token: submission_token}} ->
          {:noreply,
           socket
           |> assign(:participant, participant)
           |> assign(:submission_token, submission_token)
           |> assign(:form, to_form(participant_form(participant), as: :participant))
           |> assign(:form_error, nil)}

        {:error, changeset} ->
          {:noreply,
           socket
           |> assign(:form, to_form(changeset, as: :participant))
           |> assign(:form_error, "Could not submit your RSVP.")}
      end
    else
      {:noreply, assign(socket, :form_error, "This invite link is invalid or expired.")}
    end
  end

  defp default_form do
    %{"display_name" => "", "rsvp_status" => "going", "role" => ""}
  end

  defp participant_form(participant) do
    %{
      "display_name" => participant.display_name,
      "rsvp_status" => participant.rsvp_status,
      "role" => participant.role || ""
    }
  end

  defp self_edit_path(%{participant: nil}), do: nil

  defp self_edit_path(assigns) do
    ~p"/events/#{assigns.event.slug}/participants/#{assigns.participant.id}/edit/#{assigns.submission_token}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-3xl px-6 py-10">
        <%= if @invite_token do %>
          <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Invite</p>
          <h1 class="mt-2 text-3xl font-semibold">{@event.title}</h1>
          <p class="mt-3 text-base-content/70">
            Submit your RSVP for owner review. You can use your self-edit link to update it later.
          </p>

          <div class="mt-6 rounded-box border border-base-200 bg-base-100 p-4">
            <h2 class="font-semibold">Accepted participants</h2>
            <div class="mt-3 space-y-2 text-sm">
              <%= if Enum.empty?(@participants) do %>
                <p class="text-base-content/60">No accepted participants yet.</p>
              <% else %>
                <div :for={participant <- @participants}>
                  <span class="font-medium">{participant.display_name}</span>
                  <%= if participant.role do %>
                    <span class="text-base-content/50"> ·    {participant.role}</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>

          <%= if @participant do %>
            <div class="mt-6 rounded-box border border-success/30 bg-success/10 p-4">
              <p class="font-medium">Your RSVP is pending review.</p>
              <p class="mt-1 text-sm text-base-content/70">
                Save this self-edit link to update your name, RSVP, or role/note later.
              </p>
              <.link class="link mt-2 inline-block" navigate={self_edit_path(assigns)}>
                Open your self-edit page
              </.link>
            </div>
          <% end %>

          <div class="mt-6 rounded-box border border-base-200 bg-base-100 p-6">
            <.simple_form for={@form} id="invite-participant-form" phx-submit="submit">
              <.input field={@form[:display_name]} label="Your name" required />
              <.input field={@form[:role]} label="Role or note (optional)" />
              <.input
                field={@form[:rsvp_status]}
                type="select"
                label="RSVP"
                options={[{"Going", "going"}, {"Maybe", "maybe"}, {"Not going", "not_going"}]}
              />
              <.button type="submit">
                {if @participant, do: "Update RSVP", else: "Submit RSVP"}
              </.button>
            </.simple_form>
          </div>
        <% else %>
          <div class="rounded-box border border-base-200 bg-base-100 p-6">
            <h1 class="text-2xl font-semibold">Invite unavailable</h1>
            <p class="mt-3 text-base-content/70">{@form_error}</p>
          </div>
        <% end %>

        <%= if @form_error && @invite_token do %>
          <p class="mt-4 text-sm text-error">{@form_error}</p>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
