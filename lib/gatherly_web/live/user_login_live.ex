defmodule GatherlyWeb.UserLoginLive do
  use GatherlyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl py-32 sm:py-48 lg:py-56">
      <div class="text-center">
        <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
          Sign in to your account
        </h1>
        <div class="mt-10 flex items-center justify-center gap-x-6">
          <.google_auth_button>Login with Google Acount</.google_auth_button>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
