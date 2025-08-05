defmodule GatherlyWeb.AuthComponents do
  @moduledoc """
  Authentication UI components.
  """
  use GatherlyWeb, :html

  attr :current_user, :any, default: nil

  def auth_nav(assigns) do
    ~H"""
    <%= if @current_user do %>
      <!-- Authenticated user menu -->
      <div class="hidden md:flex items-center space-x-4">
        <div class="flex items-center space-x-3">
          <%= if @current_user.avatar_url do %>
            <img src={@current_user.avatar_url} alt={@current_user.name} class="w-8 h-8 rounded-full" />
          <% end %>
          <span class="text-gray-700 font-medium">{@current_user.name}</span>
        </div>
        <.link href={~p"/sign-out"} method="delete" class="btn btn-outline btn-sm">
          Sign Out
        </.link>
      </div>
    <% else %>
      <!-- Guest user buttons -->
      <div class="hidden md:flex items-center space-x-4">
        <.link href={~p"/auth/user/google"} class="btn btn-primary">
          <svg class="w-4 h-4 mr-2" viewBox="0 0 24 24">
            <path
              fill="currentColor"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="currentColor"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="currentColor"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
            />
            <path
              fill="currentColor"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
            />
          </svg>
          Sign in with Google
        </.link>
        <.link href={~p"/auth/user/x"} class="btn btn-primary">
          <svg class="w-4 h-4 mr-2" viewBox="0 0 24 24">
            <path
              fill="currentColor"
              d="M18.9 2h3.1l-7.2 8.2L24 22h-7l-5.2-6.9L6 22H2l7.5-8.5L0 2h7l4.7 6.4L18.9 2Z"
            />
          </svg>
          Sign in with X
        </.link>
      </div>
    <% end %>
    """
  end

  attr :current_user, :any, default: nil

  def mobile_auth_nav(assigns) do
    ~H"""
    <%= if @current_user do %>
      <!-- Mobile authenticated menu -->
      <div class="border-t border-gray-200 pt-3 mt-3">
        <div class="flex items-center px-3 pb-3">
          <%= if @current_user.avatar_url do %>
            <img
              src={@current_user.avatar_url}
              alt={@current_user.name}
              class="w-8 h-8 rounded-full mr-3"
            />
          <% end %>
          <span class="text-gray-700 font-medium">{@current_user.name}</span>
        </div>
        <.link
          href={~p"/sign-out"}
          method="delete"
          class="block px-3 py-2 text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md text-base font-medium"
        >
          Sign Out
        </.link>
      </div>
    <% else %>
      <!-- Mobile guest menu -->
      <div class="border-t border-gray-200 pt-3 mt-3">
        <.link href={~p"/auth/user/google"} class="block mx-3 btn btn-primary">
          <svg class="w-4 h-4 mr-2" viewBox="0 0 24 24">
            <path
              fill="currentColor"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="currentColor"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="currentColor"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
            />
            <path
              fill="currentColor"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
            />
          </svg>
          Sign in with Google
        </.link>
        <.link href={~p"/auth/user/x"} class="block mx-3 btn btn-primary">
          <svg class="w-4 h-4 mr-2" viewBox="0 0 24 24">
            <path
              fill="currentColor"
              d="M18.9 2h3.1l-7.2 8.2L24 22h-7l-5.2-6.9L6 22H2l7.5-8.5L0 2h7l4.7 6.4L18.9 2Z"
            />
          </svg>
          Sign in with X
        </.link>
      </div>
    <% end %>
    """
  end
end
