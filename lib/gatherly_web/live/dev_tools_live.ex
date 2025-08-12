defmodule GatherlyWeb.DevToolsLive do
  @moduledoc """
  Development tools LiveView for debugging and monitoring.
  Only available in development environment.
  """
  use GatherlyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if Application.get_env(:gatherly, :environment) == :dev do
      {:ok, assign(socket, page_title: "Dev Tools", system_info: get_system_info())}
    else
      {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900">Development Tools</h1>
          <p class="mt-2 text-gray-600">Debug and monitor your Gatherly application</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- System Information -->
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">System Information</h3>
              <dl class="grid grid-cols-1 gap-x-4 gap-y-2 text-sm">
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Elixir Version</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.elixir_version}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">OTP Version</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.otp_version}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Environment</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.env}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Uptime</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.uptime}</dd>
                </div>
              </dl>
            </div>
          </div>
          
    <!-- Memory Usage -->
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Memory Usage</h3>
              <dl class="grid grid-cols-1 gap-x-4 gap-y-2 text-sm">
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Total Memory</dt>
                  <dd class="mt-1 text-gray-900">{format_bytes(@system_info.memory.total)}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Process Memory</dt>
                  <dd class="mt-1 text-gray-900">{format_bytes(@system_info.memory.processes)}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Atom Memory</dt>
                  <dd class="mt-1 text-gray-900">{format_bytes(@system_info.memory.atom)}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Binary Memory</dt>
                  <dd class="mt-1 text-gray-900">{format_bytes(@system_info.memory.binary)}</dd>
                </div>
              </dl>
            </div>
          </div>
          
    <!-- Process Information -->
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Processes</h3>
              <dl class="grid grid-cols-1 gap-x-4 gap-y-2 text-sm">
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Process Count</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.process_count}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Process Limit</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.process_limit}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">Ports</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.port_count}</dd>
                </div>
                <div class="sm:col-span-1">
                  <dt class="font-medium text-gray-500">ETS Tables</dt>
                  <dd class="mt-1 text-gray-900">{@system_info.ets_count}</dd>
                </div>
              </dl>
            </div>
          </div>
          
    <!-- Quick Actions -->
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Quick Actions</h3>
              <div class="space-y-3">
                <button
                  phx-click="garbage_collect"
                  class="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
                >
                  Force Garbage Collection
                </button>
                <button
                  phx-click="refresh_info"
                  class="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors"
                >
                  Refresh System Info
                </button>
                <a
                  href={~p"/dev/dashboard"}
                  class="block w-full bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700 transition-colors text-center"
                >
                  Phoenix LiveDashboard
                </a>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Performance Tips -->
        <div class="mt-8 bg-white overflow-hidden shadow rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Performance Tips</h3>
            <div class="prose prose-sm text-gray-600">
              <ul>
                <li>Use <code>:observer.start()</code> in IEx for detailed system monitoring</li>
                <li>Monitor memory growth - force GC if memory usage is high</li>
                <li>Check process count - investigate if approaching the limit</li>
                <li>Use Phoenix LiveDashboard for real-time metrics</li>
                <li>Enable telemetry in production for performance monitoring</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("garbage_collect", _params, socket) do
    :erlang.garbage_collect()
    {:noreply, put_flash(socket, :info, "Garbage collection completed")}
  end

  @impl true
  def handle_event("refresh_info", _params, socket) do
    {:noreply, assign(socket, system_info: get_system_info())}
  end

  defp get_system_info do
    memory = :erlang.memory()

    %{
      elixir_version: System.version(),
      otp_version: System.otp_release(),
      env: Application.get_env(:gatherly, :environment, :dev),
      uptime: format_uptime(:erlang.statistics(:wall_clock)),
      memory: %{
        total: memory[:total],
        processes: memory[:processes],
        atom: memory[:atom],
        binary: memory[:binary]
      },
      process_count: :erlang.system_info(:process_count),
      process_limit: :erlang.system_info(:process_limit),
      port_count: :erlang.system_info(:port_count),
      ets_count: length(:ets.all())
    }
  end

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  defp format_uptime({uptime_ms, _}) do
    uptime_seconds = div(uptime_ms, 1000)
    hours = div(uptime_seconds, 3600)
    minutes = div(rem(uptime_seconds, 3600), 60)
    seconds = rem(uptime_seconds, 60)

    "#{hours}h #{minutes}m #{seconds}s"
  end
end
