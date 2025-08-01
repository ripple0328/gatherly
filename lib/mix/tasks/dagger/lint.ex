defmodule Mix.Tasks.Dagger.Lint do
  @shortdoc "Run linting (Credo + Dialyzer) in containers"
  
  @moduledoc """
  Runs linting tasks inside a containerized environment.
  
  This task runs:
  - Credo static analysis
  - Dialyzer type checking (if enabled)
  
  ## Examples
  
      mix dagger.lint
      mix dagger.lint --skip-dialyzer
      mix dagger.lint --strict
  
  ## Options
  
    * `--skip-dialyzer` - Skip Dialyzer type checking
    * `--strict` - Use strict mode for Credo
    * `--dialyzer-only` - Run only Dialyzer
  """
  
  use Mix.Task
  use Gatherly.Dagger.Workflow

  @impl true
  def run(args) do
    {opts, remaining_args, _} = 
      OptionParser.parse(args, 
        switches: [skip_dialyzer: :boolean, strict: :boolean, dialyzer_only: :boolean],
        aliases: [s: :strict]
      )
    
    skip_dialyzer = Keyword.get(opts, :skip_dialyzer, false)
    strict = Keyword.get(opts, :strict, false)
    dialyzer_only = Keyword.get(opts, :dialyzer_only, false)
    extra_args = remaining_args
    
    log_step("Running linting tools", :start)
    
    execute(
      skip_dialyzer: skip_dialyzer, 
      strict: strict, 
      dialyzer_only: dialyzer_only,
      extra_args: extra_args
    )
  end

  @impl true
  def run(opts) do
    skip_dialyzer = Keyword.get(opts, :skip_dialyzer, false)
    strict = Keyword.get(opts, :strict, false)
    dialyzer_only = Keyword.get(opts, :dialyzer_only, false)
    extra_args = Keyword.get(opts, :extra_args, [])
    
    Client.with_client(fn client ->
      container = Containers.elixir_dev(client)
      
      # Run Credo (unless dialyzer-only)
      unless dialyzer_only do
        run_credo(container, strict, extra_args)
      end
      
      # Run Dialyzer (unless skipped)
      unless skip_dialyzer do
        run_dialyzer(container, extra_args)
      end
      
      log_step("Linting completed!", :finish)
      
      {:ok, :lint_completed}
    end)
  end

  defp run_credo(container, strict, extra_args) do
    log_step("Running Credo static analysis")
    
    credo_args = ["credo"] ++ extra_args
    credo_args = if strict, do: credo_args ++ ["--strict"], else: credo_args
    
    {:ok, output} = exec_and_get_output(container, "mix", credo_args)
    
    IO.puts(output)
    log_step("Credo analysis completed", :success)
  end

  defp run_dialyzer(container, extra_args) do
    log_step("Running Dialyzer type checking")
    log_step("Note: First run may take several minutes to build PLT", :warning)
    
    dialyzer_args = ["dialyzer"] ++ extra_args
    
    {:ok, output} = exec_and_get_output(container, "mix", dialyzer_args)
    
    IO.puts(output)
    log_step("Dialyzer analysis completed", :success)
  end
end