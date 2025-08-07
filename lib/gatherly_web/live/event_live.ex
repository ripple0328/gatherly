defmodule GatherlyWeb.EventLive do
  @moduledoc """
  Simple event page for testing magic link functionality.
  """

  use GatherlyWeb, :live_view
  alias Gatherly.Accounts.User
  alias Gatherly.Events.Event
  alias Gatherly.Events.MagicLink

  def mount(%{"id" => event_id}, session, socket) do
    # Get current user from session
    current_user = get_current_user(session)

    case Event.get_by_id(event_id) do
      {:ok, event} ->
        # Load event creator
        event = Ash.load!(event, [:creator])

        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:current_user, current_user)
         |> assign(:can_generate_link, can_generate_magic_link?(current_user, event))}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Event not found")
         |> redirect(to: ~p"/")}
    end
  end

  def handle_event("generate_magic_link", _params, socket) do
    %{current_user: user, event: event} = socket.assigns

    case MagicLink.generate_for_event(event.id, user.id) do
      {:ok, magic_link} ->
        magic_url = MagicLink.generate_magic_url(magic_link.token)

        {:noreply,
         socket
         |> put_flash(:info, "Magic link generated! Check the browser console for the URL.")
         |> push_event("magic_link_generated", %{url: magic_url})}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to generate magic link")}
    end
  end

  defp get_current_user(session) do
    case Map.get(session, "current_user_id") do
      nil ->
        nil

      user_id ->
        case Ash.get(User, user_id) do
          {:ok, user} -> user
          _ -> nil
        end
    end
  end

  defp can_generate_magic_link?(user, _event) when is_nil(user), do: false

  defp can_generate_magic_link?(user, event) do
    # For now, only event creator can generate links
    user.id == event.creator_id
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-8 px-4">
      <div class="bg-white shadow-lg rounded-lg overflow-hidden">
        <div class="px-6 py-4 bg-gray-50 border-b">
          <h1 class="text-3xl font-bold text-gray-900">
            {@event.title}
          </h1>
          <%= if @event.description do %>
            <p class="mt-2 text-gray-600">{@event.description}</p>
          <% end %>
        </div>

        <div class="px-6 py-4">
          <%= if @current_user do %>
            <div class="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
              <h3 class="text-lg font-semibold text-green-800">Welcome, {@current_user.name}!</h3>
              <p class="text-green-700">
                <%= if User.anonymous?(@current_user) do %>
                  You joined as a guest via magic link
                <% else %>
                  You're signed in with {String.capitalize(to_string(@current_user.user_type))}
                <% end %>
              </p>
              <%= if @current_user.email do %>
                <p class="text-sm text-green-600">Email: {@current_user.email}</p>
              <% end %>
            </div>

            <%= if @can_generate_link do %>
              <div class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                <h3 class="text-lg font-semibold text-blue-800">Event Management</h3>
                <p class="text-blue-700 mb-3">As the event creator, you can generate invite links</p>
                <button
                  phx-click="generate_magic_link"
                  class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Generate Magic Link
                </button>
              </div>
            <% end %>

            <div class="space-y-4">
              <h3 class="text-xl font-semibold">Event Details</h3>
              <div class="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span class="font-medium">Created by:</span>
                  {@event.creator.name}
                </div>
                <div>
                  <span class="font-medium">Created:</span>
                  {Calendar.strftime(@event.inserted_at, "%B %d, %Y at %I:%M %p")}
                </div>
              </div>
            </div>
          <% else %>
            <div class="text-center py-8">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">
                You need to be signed in to view this event
              </h3>
              <.link
                href={~p"/sign-in"}
                class="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700"
              >
                Sign In
              </.link>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <script>
      window.addEventListener('phx:magic_link_generated', (e) => {
        console.log('🔗 Magic Link Generated:', e.detail.url);

        // Show a more prominent notification
        const notification = document.createElement('div');
        notification.className = 'fixed top-4 right-4 bg-green-500 text-white p-4 rounded-lg shadow-lg z-50';
        notification.innerHTML = `
          <div class="flex items-center space-x-2">
            <span>✅ Magic link copied to console!</span>
            <button onclick="this.parentElement.parentElement.remove()" class="text-white hover:text-gray-200">✕</button>
          </div>
          <div class="text-xs mt-1 opacity-90">Check browser console for the full URL</div>
        `;
        document.body.appendChild(notification);

        setTimeout(() => {
          if (notification.parentElement) {
            notification.remove();
          }
        }, 5000);
      });
    </script>
    """
  end
end
