defmodule GatherlyWeb.EventsLive do
  use GatherlyWeb, :live_view

  alias Gatherly.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:events, Events.list_events())
     |> assign(:form, to_form(default_form()))
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("save", %{"event" => params}, socket) do
    params = normalize_params(params)

    case Events.create_event(params) do
      {:ok, event} ->
        {:noreply, push_navigate(socket, to: ~p"/events/#{event.slug}")}

      {:error, error} ->
        {:noreply, assign(socket, :form_error, error)}
    end
  end

  defp default_form do
    %{
      "title" => "",
      "description" => "",
      "starts_at" => "",
      "location" => ""
    }
  end

  defp normalize_params(params) do
    case Map.get(params, "starts_at") do
      nil ->
        params

      "" ->
        Map.put(params, "starts_at", nil)

      value ->
        parsed =
          case NaiveDateTime.from_iso8601(value) do
            {:ok, ndt} -> {:ok, ndt}
            _ ->
              case NaiveDateTime.from_iso8601(String.replace(value, " ", "T") <> ":00") do
                {:ok, ndt} -> {:ok, ndt}
                _ -> :error
              end
          end

        case parsed do
          {:ok, ndt} ->
            Map.put(params, "starts_at", DateTime.from_naive!(ndt, "Etc/UTC"))

          :error ->
            params
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl px-6 py-10">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-semibold">Gatherly</h1>
          <p class="text-sm text-base-content/70">Create an event and share the link.</p>
        </div>
        <a href="/" class="text-sm link">Home</a>
      </div>

      <div class="mt-8 grid gap-8 lg:grid-cols-[1.1fr_1fr]">
        <div class="rounded-box border border-base-200 bg-base-100 p-6 shadow-sm">
          <h2 class="text-lg font-semibold">New event</h2>
          <.simple_form for={@form} phx-submit="save" class="mt-6 space-y-4">
            <.input field={@form[:title]} label="Title" required />
            <.input field={@form[:description]} label="Description" type="textarea" />
            <.input field={@form[:starts_at]} label="Starts at (YYYY-MM-DD HH:MM)" />
            <.input field={@form[:location]} label="Location" />
            <.button type="submit">Create event</.button>
          </.simple_form>
          <%= if @form_error do %>
            <p class="mt-3 text-sm text-error">Could not save event. Check the fields and try again.</p>
          <% end %>
        </div>

        <div class="rounded-box border border-base-200 bg-base-100 p-6 shadow-sm">
          <h2 class="text-lg font-semibold">Upcoming events</h2>
          <div class="mt-4 space-y-4">
            <%= if Enum.empty?(@events) do %>
              <p class="text-sm text-base-content/60">No events yet.</p>
            <% else %>
              <%= for event <- @events do %>
                <div class="rounded-lg border border-base-200 p-4">
                  <div class="flex items-center justify-between">
                    <div class="font-semibold"><%= event.title %></div>
                    <a class="link text-sm" href={~p"/events/#{event.slug}"}>Open</a>
                  </div>
                  <%= if event.starts_at do %>
                    <div class="text-sm text-base-content/70"><%= format_dt(event.starts_at) %></div>
                  <% end %>
                  <%= if event.location do %>
                    <div class="text-sm text-base-content/70"><%= event.location %></div>
                  <% end %>
                  <%= if event.description do %>
                    <p class="mt-2 text-sm text-base-content/80"><%= event.description %></p>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %H:%M")
  defp format_dt(other), do: to_string(other)
end
