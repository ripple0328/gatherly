defmodule GatherlyWeb.MagicJoinLive do
  @moduledoc """
  LiveView for joining an event via magic link as an anonymous user.
  """

  use GatherlyWeb, :live_view

  alias Ash
  alias Gatherly.Accounts.User
  alias Gatherly.Events.{EventParticipant, MagicLink}

  def mount(%{"token" => token}, _session, socket) do
    case MagicLink.valid_token(token) do
      {:ok, magic_link} ->
        magic_link = Ash.load!(magic_link, [:event])

        {:ok,
         socket
         |> assign(:token, token)
         |> assign(:magic_link, magic_link)
         |> assign(:event, magic_link.event)
         |> assign(:form, to_form(%{"name" => "", "email" => ""}))
         |> assign(:error, nil)}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Invalid or expired invitation link.")
         |> redirect(to: ~p"/")}
    end
  end

  def handle_event("register", params, socket) do
    params = Map.get(params, "user", params)
    %{token: token} = socket.assigns

    # Basic presence validation
    if (params["name"] || "") == "" do
      {:noreply, assign(socket, :error, "Please enter your name.")}
    else
      with {:ok, magic_link} <- MagicLink.valid_token(token),
           {:ok, user} <- User.create_anonymous(Map.put(params, "magic_token", token)),
           _ <- EventParticipant.create(magic_link.event_id, user.id, nil),
           _ <- MagicLink.increment_uses(magic_link) do
        # Redirect to a controller endpoint to set the session cookie, then to event
        {:noreply,
         redirect(socket,
           to: ~p"/join/#{token}/complete?user_id=#{user.id}"
         )}
      else
        {:error, changeset} ->
          {:noreply, assign(socket, :error, humanize_changeset_error(changeset))}

        _ ->
          {:noreply, assign(socket, :error, "Failed to join. Please try again.")}
      end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Join "{@event.title}"
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">You've been invited to join this event</p>
      </div>

      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <.form :let={f} for={@form} phx-submit="register" class="space-y-6">
            <div>
              <.label for="user_name" class="block text-sm font-medium text-gray-700">
                Your Name
              </.label>
              <div class="mt-1">
                <.input
                  field={f[:name]}
                  type="text"
                  autocomplete="name"
                  required
                  placeholder="Enter your name"
                  class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                />
              </div>
            </div>

            <div>
              <.label for="user_email" class="block text-sm font-medium text-gray-700">
                Email (optional)
              </.label>
              <div class="mt-1">
                <.input
                  field={f[:email]}
                  type="email"
                  autocomplete="email"
                  placeholder="Enter your email (optional)"
                  class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                />
              </div>
              <p class="mt-1 text-xs text-gray-500">
                Optional: We'll use this to send you event updates
              </p>
            </div>

            <%= if @error do %>
              <p class="text-sm text-red-600">{@error}</p>
            <% end %>

            <div>
              <.button type="submit" class="w-full">Join Event</.button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp humanize_changeset_error(changeset) do
    case changeset do
      %Ash.Changeset{errors: [first | _]} ->
        first.message || "Invalid input"

      _ ->
        "Invalid input"
    end
  end
end
