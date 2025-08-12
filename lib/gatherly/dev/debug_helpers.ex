defmodule Gatherly.Dev.DebugHelpers do
  @moduledoc """
  Debugging and performance helpers for development.
  Only available in development environment.
  """

  require Logger

  @doc """
  Times the execution of a function and logs the result.

  ## Examples

      iex> Gatherly.Dev.DebugHelpers.time_call(fn -> Enum.sum(1..1000) end)
      [debug] Function executed in 0.123ms
      500500
  """
  def time_call(fun) when is_function(fun) do
    {time_microseconds, result} = :timer.tc(fun)
    time_ms = time_microseconds / 1000
    Logger.debug("Function executed in #{time_ms}ms")
    result
  end

  @doc """
  Times the execution of a function with a custom label.
  """
  def time_call(label, fun) when is_binary(label) and is_function(fun) do
    {time_microseconds, result} = :timer.tc(fun)
    time_ms = time_microseconds / 1000
    Logger.debug("#{label} executed in #{time_ms}ms")
    result
  end

  @doc """
  Logs memory usage before and after executing a function.
  """
  def memory_profile(fun) when is_function(fun) do
    memory_before = :erlang.memory(:total)
    result = fun.()
    memory_after = :erlang.memory(:total)
    memory_diff = memory_after - memory_before

    Logger.debug("Memory before: #{format_bytes(memory_before)}")
    Logger.debug("Memory after: #{format_bytes(memory_after)}")
    Logger.debug("Memory diff: #{format_bytes(memory_diff)}")

    result
  end

  @doc """
  Logs detailed process information.
  """
  def process_info(pid \\ self()) do
    info = Process.info(pid, [:memory, :message_queue_len, :heap_size, :stack_size, :reductions])

    Logger.debug("Process #{inspect(pid)} info:")
    Logger.debug("  Memory: #{format_bytes(info[:memory])}")
    Logger.debug("  Message queue: #{info[:message_queue_len]}")
    Logger.debug("  Heap size: #{info[:heap_size]} words")
    Logger.debug("  Stack size: #{info[:stack_size]} words")
    Logger.debug("  Reductions: #{info[:reductions]}")

    info
  end

  @doc """
  Logs system-wide memory usage.
  """
  def system_memory_info do
    memory = :erlang.memory()

    Logger.debug("System memory usage:")
    Logger.debug("  Total: #{format_bytes(memory[:total])}")
    Logger.debug("  Processes: #{format_bytes(memory[:processes])}")
    Logger.debug("  Atom: #{format_bytes(memory[:atom])}")
    Logger.debug("  Binary: #{format_bytes(memory[:binary])}")
    Logger.debug("  Code: #{format_bytes(memory[:code])}")
    Logger.debug("  ETS: #{format_bytes(memory[:ets])}")

    memory
  end

  @doc """
  Finds the top N processes by memory usage.
  """
  def top_processes_by_memory(n \\ 10) do
    processes =
      Process.list()
      |> Enum.map(fn pid ->
        case Process.info(pid, [:memory, :registered_name, :initial_call]) do
          nil -> nil
          info -> {pid, info}
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(fn {_pid, info} -> info[:memory] end, :desc)
      |> Enum.take(n)

    Logger.debug("Top #{n} processes by memory:")

    Enum.each(processes, fn {pid, info} ->
      name = info[:registered_name] || inspect(info[:initial_call])
      memory = format_bytes(info[:memory])
      Logger.debug("  #{inspect(pid)} (#{name}): #{memory}")
    end)

    processes
  end

  @doc """
  Logs database connection pool information.
  """
  def db_pool_info do
    alias Ecto.Adapters.SQL

    pool_info =
      SQL.query!(
        Gatherly.Repo,
        "SELECT COUNT(*) as active_connections FROM pg_stat_activity WHERE state = 'active'"
      )

    Logger.debug("Database pool info:")
    Logger.debug("  Active connections: #{hd(pool_info.rows) |> hd()}")
  rescue
    error ->
      Logger.debug("Could not fetch DB pool info: #{inspect(error)}")
  end

  @doc """
  Forces garbage collection on all processes.
  """
  def force_gc_all do
    count =
      Process.list()
      |> Enum.map(&:erlang.garbage_collect/1)
      |> length()

    Logger.debug("Forced garbage collection on #{count} processes")
    count
  end

  @doc """
  Traces function calls for debugging.
  """
  defmacro trace_calls(module, function, arity) do
    quote do
      :dbg.tracer()
      :dbg.p(:all, :c)
      :dbg.tpl(unquote(module), unquote(function), unquote(arity), [])
    end
  end

  @doc """
  Stops all tracing.
  """
  def stop_trace do
    :dbg.stop_clear()
  end

  # Private helpers

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  # Only compile in development
  if Mix.env() != :dev do
    def time_call(_), do: raise("DebugHelpers only available in development")
    def time_call(_, _), do: raise("DebugHelpers only available in development")
    def memory_profile(_), do: raise("DebugHelpers only available in development")
    def process_info(_), do: raise("DebugHelpers only available in development")
    def system_memory_info, do: raise("DebugHelpers only available in development")
    def top_processes_by_memory(_), do: raise("DebugHelpers only available in development")
    def db_pool_info, do: raise("DebugHelpers only available in development")
    def force_gc_all, do: raise("DebugHelpers only available in development")
    def stop_trace, do: raise("DebugHelpers only available in development")
  end
end
