defmodule GatherlyWeb.HomeLive do
  use GatherlyWeb, :live_view
  use GatherlyNative, :live_view

  def mount(_, _session, socket) do
    socket =
      socket
      |> assign(counter: 0)

    {:ok, socket}
  end

  def handle_event("decr", _unsigned_params, socket) do
    {:noreply, assign(socket, :counter, socket.assigns.counter - 1)}
  end

  def handle_event("incr", _unsigned_params, socket) do
    {:noreply, assign(socket, :counter, socket.assigns.counter + 1)}
  end

  def handle_event("incr-by", %{"by" => value}, socket) do
    {value, _} = Integer.parse(value)
    {:noreply, assign(socket, :counter, socket.assigns.counter + value)}
  end
end
