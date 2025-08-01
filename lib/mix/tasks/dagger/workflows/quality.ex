defmodule Mix.Tasks.Dagger.Workflows.Quality do
  @shortdoc "Run code quality checks"

  @moduledoc """
  Runs code quality workflow in containers.

  This workflow runs:
  1. Code formatting
  2. Linting (Credo + Dialyzer)
  3. Security audit

  ## Examples

      mix dagger.quality
      mix dagger.quality --fix
      mix dagger.quality --skip-dialyzer

  ## Options

    * `--fix` - Auto-fix formatting issues
    * `--skip-dialyzer` - Skip Dialyzer type checking
    * `--strict` - Use strict mode for all checks
  """

  use Mix.Task
  import Gatherly.Dagger.Workflow
  alias Mix.Tasks.Dagger.{Format, Lint, Security}

  @impl true
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [fix: :boolean, skip_dialyzer: :boolean, strict: :boolean],
        aliases: []
      )

    fix = Keyword.get(opts, :fix, false)
    skip_dialyzer = Keyword.get(opts, :skip_dialyzer, false)
    strict = Keyword.get(opts, :strict, false)

    log_step("Running code quality checks", :start)

    execute(fix: fix, skip_dialyzer: skip_dialyzer, strict: strict)
  end

  def execute(opts) do
    fix = Keyword.get(opts, :fix, false)
    skip_dialyzer = Keyword.get(opts, :skip_dialyzer, false)
    strict = Keyword.get(opts, :strict, false)

    handle_formatting(fix)
    handle_linting(skip_dialyzer, strict)
    handle_security_audit()

    log_step("Quality checks completed!", :finish)

    {:ok, :quality_completed}
  end

  defp handle_formatting(fix) do
    log_step("Step 1: Code formatting")
    format_args = if fix, do: [], else: ["--check-formatted"]

    case Format.execute(format_args) do
      {:ok, _} ->
        log_step("Formatting passed", :success)

      {:error, _reason} ->
        log_step("Formatting issues found", :warning)

        if fix do
          log_step("Auto-fixing formatting...", :info)
          Format.execute([])
          log_step("Formatting fixed", :success)
        else
          log_step("Run with --fix to auto-fix", :info)
        end
    end
  end

  defp handle_linting(skip_dialyzer, strict) do
    log_step("Step 2: Code linting")
    lint_args = []
    lint_args = if skip_dialyzer, do: lint_args ++ ["--skip-dialyzer"], else: lint_args
    lint_args = if strict, do: lint_args ++ ["--strict"], else: lint_args

    case Lint.execute(lint_args) do
      {:ok, _} ->
        log_step("Linting passed", :success)

      {:error, _reason} ->
        log_step("Linting issues found", :warning)
    end
  end

  defp handle_security_audit do
    log_step("Step 3: Security audit")

    case Security.execute([]) do
      {:ok, _} ->
        log_step("Security audit passed", :success)

      {:error, _reason} ->
        log_step("Security issues found", :warning)
    end
  end
end
