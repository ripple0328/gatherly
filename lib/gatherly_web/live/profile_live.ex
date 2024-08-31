defmodule GatherlyWeb.ProfileLive do
  use GatherlyWeb, :live_view
  use GatherlyNative, :live_view

  def render(assigns) do
    ~H"""
    <div class="profile">
      <h1><%= @user.name %></h1>
      <p><%= @user.email %></p>
    </div>
    """
  end

  def mount(%{"user_id" => _user_id}, _session, socket) do
    %{current_user: user} = socket.assigns

    socket =
      socket
      |> assign(user: user)

    {:ok, socket}
  end
end
