defmodule Mix.Tasks.Dagger.Workflows.Ci do
  @shortdoc "Run complete CI pipeline"

  @moduledoc """
  Runs the complete CI pipeline in containers.

  This workflow orchestrates:
  1. Environment setup (deps, compile)
  2. Code formatting check
  3. Linting (Credo + Dialyzer)
  4. Security audit
  5. Tests with coverage

  ## Examples

      mix dagger.ci
      mix dagger.ci --skip-dialyzer
      mix dagger.ci --env=test

  ## Options

    * `--env` - Environment (dev/test, default: dev)
    * `--skip-dialyzer` - Skip Dialyzer (faster CI)
    * `--skip-security` - Skip security audits
    * `--fail-fast` - Stop on first failure
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow
  alias Mix.Tasks.Dagger.{Format, Lint, Security, Setup, Test}

  @impl true
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          env: :string,
          skip_dialyzer: :boolean,
          skip_security: :boolean,
          fail_fast: :boolean
        ],
        aliases: [e: :env]
      )

    env = Keyword.get(opts, :env, "dev")
    skip_dialyzer = Keyword.get(opts, :skip_dialyzer, false)
    skip_security = Keyword.get(opts, :skip_security, false)
    fail_fast = Keyword.get(opts, :fail_fast, true)

    log_step("Starting CI pipeline for #{env} environment", :start)

    execute(
      env: env,
      skip_dialyzer: skip_dialyzer,
      skip_security: skip_security,
      fail_fast: fail_fast
    )
  end

  def execute(opts) do
    env = Keyword.get(opts, :env, "dev")
    skip_dialyzer = Keyword.get(opts, :skip_dialyzer, false)
    skip_security = Keyword.get(opts, :skip_security, false)
    fail_fast = Keyword.get(opts, :fail_fast, true)

    # Define CI pipeline steps
    steps = [
      {"Setup", fn -> Setup.execute(env: env) end},
      {"Format Check", fn -> Format.execute(["--check-formatted"]) end},
      {"Linting",
       fn ->
         lint_opts = if skip_dialyzer, do: ["--skip-dialyzer"], else: []
         Lint.execute(lint_opts)
       end},
      {"Security Audit",
       fn ->
         if skip_security do
           log_step("Skipping security audit", :info)
           {:ok, :skipped}
         else
           Security.execute([])
         end
       end},
      {"Tests", fn -> Test.execute(["--cover"]) end}
    ]

    # Execute pipeline
    execute_pipeline(steps, fail_fast)
  end

  defp execute_pipeline(steps, fail_fast) do
    results =
      Enum.reduce_while(steps, [], fn {step_name, step_func}, acc ->
        log_step("CI Step: #{step_name}", :info)
        handle_step_result(step_name, step_func, fail_fast, acc)
      end)

    # Check final results
    failed_steps = Enum.filter(results, fn {_, status, _} -> status == :failed end)

    if failed_steps == [] do
      log_step("🎉 CI pipeline completed successfully!", :finish)
      {:ok, :ci_passed}
    else
      log_step("💥 CI pipeline failed", :error)

      Enum.each(failed_steps, fn {step, _, reason} ->
        log_step("  - #{step}: #{inspect(reason)}", :error)
      end)

      {:error, {:ci_failed, failed_steps}}
    end
  end

  defp handle_step_result(step_name, step_func, fail_fast, acc) do
    case step_func.() do
      {:ok, result} ->
        log_step("✅ #{step_name} passed", :success)
        {:cont, [{step_name, :passed, result} | acc]}

      {:error, reason} ->
        log_step("❌ #{step_name} failed: #{inspect(reason)}", :error)

        if fail_fast do
          {:halt, [{step_name, :failed, reason} | acc]}
        else
          {:cont, [{step_name, :failed, reason} | acc]}
        end
    end
  end
end
