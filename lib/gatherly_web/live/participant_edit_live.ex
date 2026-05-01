defmodule GatherlyWeb.ParticipantEditLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @impl true
  def mount(
        %{"slug" => slug, "participant_id" => participant_id, "token" => token},
        _session,
        socket
      ) do
    event = Events.get_event_by_slug!(slug)

    case Events.verify_submission_token(event.id, participant_id, token) do
      {:ok, participant} when participant.review_status in ["pending", "accepted"] ->
        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:participant, participant)
         |> assign(:submission_token, token)
         |> assign(:participants, Events.list_accepted_participants(event.id))
         |> assign(:form, to_form(participant_form(participant), as: :participant))
         |> assign(:form_error, nil)}

      _ ->
        {:ok, unauthorized_socket(socket)}
    end
  rescue
    Ecto.NoResultsError ->
      {:ok, unauthorized_socket(socket)}
  end

  @impl true
  def handle_event("save", %{"participant" => params}, socket) do
    if socket.assigns.participant do
      case Events.update_participant_with_submission(
             socket.assigns.event.id,
             socket.assigns.participant.id,
             socket.assigns.submission_token,
             params
           ) do
        {:ok, participant} ->
          {:noreply,
           socket
           |> assign(:participant, participant)
           |> assign(:form, to_form(participant_form(participant), as: :participant))
           |> assign(:form_error, "Saved your changes.")}

        {:error, _reason} ->
          {:noreply, assign(socket, :form_error, "Could not save your changes.")}
      end
    else
      {:noreply, assign(socket, :form_error, "This self-edit link is invalid or unavailable.")}
    end
  end

  defp unauthorized_socket(socket) do
    socket
    |> assign(:event, nil)
    |> assign(:participant, nil)
    |> assign(:submission_token, nil)
    |> assign(:participants, [])
    |> assign(:form, to_form(participant_form(nil), as: :participant))
    |> assign(:form_error, "This self-edit link is invalid or unavailable.")
  end

  defp participant_form(nil), do: %{"display_name" => "", "rsvp_status" => "going", "role" => ""}

  defp participant_form(participant) do
    %{
      "display_name" => participant.display_name,
      "rsvp_status" => participant.rsvp_status,
      "role" => participant.role || ""
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-3xl px-6 py-10">
        <%= if @participant do %>
          <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Self-edit</p>
          <h1 class="mt-2 text-3xl font-semibold">{@event.title}</h1>
          <p class="mt-3 text-base-content/70">
            Update your own participant details. Review status stays <span class="font-medium">{@participant.review_status}</span>.
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

          <div class="mt-6 rounded-box border border-base-200 bg-base-100 p-6">
            <.simple_form for={@form} id="self-edit-form" phx-submit="save">
              <.input field={@form[:display_name]} label="Your name" required />
              <.input field={@form[:role]} label="Role or note (optional)" />
              <.input
                field={@form[:rsvp_status]}
                type="select"
                label="RSVP"
                options={[{"Going", "going"}, {"Maybe", "maybe"}, {"Not going", "not_going"}]}
              />
              <.button type="submit">Save changes</.button>
            </.simple_form>
          </div>
        <% else %>
          <div class="rounded-box border border-base-200 bg-base-100 p-6">
            <h1 class="text-2xl font-semibold">Self-edit unavailable</h1>
            <p class="mt-3 text-base-content/70">{@form_error}</p>
          </div>
        <% end %>

        <%= if @form_error && @participant do %>
          <p class="mt-4 text-sm text-base-content/70">{@form_error}</p>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
