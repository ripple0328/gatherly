defmodule Mix.Tasks.Dagger.Format do
  @shortdoc "Run code formatting using containerized Phoenix task"
  
  @moduledoc """
  Runs `mix format` inside a containerized environment.
  
  This task:
  - Runs Phoenix's `mix format` task inside Elixir container
  - Passes through all Phoenix format options
  - No database required
  
  ## Examples
  
      mix dagger.format
      mix dagger.format --check-formatted
      mix dagger.format lib/specific_file.ex
  
  ## Options
  
    * All options are passed through to `mix format`
  """
  
  use Mix.Task
  
  import Gatherly.Dagger.Workflow
  alias Gatherly.Dagger.{Client, Containers}

  @impl Mix.Task
  def run(args) do
    log_step("Running code formatting", :start)
    
    execute_format(phoenix_args: args)
  end

  def execute(opts \\ []), do: execute_format(opts)

  defp execute_format(opts) do
    phoenix_args = Keyword.get(opts, :phoenix_args, [])
    
    Client.with_client(fn client ->
      log_step("Running Phoenix task: mix format #{Enum.join(phoenix_args, " ")}")
      
      {:ok, output} = 
        client
        |> Containers.elixir_dev()
        |> exec_and_get_output("mix", ["format" | phoenix_args])
      
      if String.trim(output) != "" do
        IO.puts(output)
      end
      
      log_step("Formatting completed!", :finish)
      
      {:ok, :format_completed}
    end)
  end
end