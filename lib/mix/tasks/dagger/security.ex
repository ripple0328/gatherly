defmodule Mix.Tasks.Dagger.Security do
  @shortdoc "Run security audits in containers"
  
  @moduledoc """
  Runs security audit tasks inside a containerized environment.
  
  This task runs:
  - hex.audit to check for known vulnerabilities
  - deps.audit to analyze dependency security
  
  ## Examples
  
      mix dagger.security
      mix dagger.security --retired-only
  
  ## Options
  
    * `--retired-only` - Only check for retired packages
  """
  
  use Mix.Task
  use Gatherly.Dagger.Workflow

  @impl true
  def run(args) do
    {opts, remaining_args, _} = 
      OptionParser.parse(args, 
        switches: [retired_only: :boolean],
        aliases: []
      )
    
    retired_only = Keyword.get(opts, :retired_only, false)
    extra_args = remaining_args
    
    log_step("Running security audits", :start)
    
    execute(retired_only: retired_only, extra_args: extra_args)
  end

  @impl true
  def run(opts) do
    retired_only = Keyword.get(opts, :retired_only, false)
    extra_args = Keyword.get(opts, :extra_args, [])
    
    Client.with_client(fn client ->
      container = Containers.elixir_dev(client)
      
      # Always run hex.audit for known vulnerabilities
      run_hex_audit(container, extra_args)
      
      # Run additional checks unless retired-only
      unless retired_only do
        run_deps_audit(container, extra_args)
      end
      
      log_step("Security audit completed!", :finish)
      
      {:ok, :security_completed}
    end)
  end

  defp run_hex_audit(container, extra_args) do
    log_step("Checking for known vulnerabilities (hex.audit)")
    
    {:ok, output} = exec_and_get_output(container, "mix", ["hex.audit" | extra_args])
    
    IO.puts(output)
    
    if String.contains?(output, "No retired packages found") do
      log_step("No known vulnerabilities found", :success)
    else
      log_step("Potential security issues detected", :warning)
    end
  end

  defp run_deps_audit(container, extra_args) do
    log_step("Analyzing dependency security")
    
    # Check for outdated packages that might have security updates
    {:ok, outdated_output} = exec_and_get_output(container, "mix", ["hex.outdated" | extra_args])
    
    if String.trim(outdated_output) != "" do
      IO.puts("\nOutdated packages (may include security updates):")
      IO.puts(outdated_output)
    end
    
    log_step("Dependency analysis completed", :success)
  end
end