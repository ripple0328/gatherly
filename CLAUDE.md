# AI Coding Agent Guidelines (Elixir/Phoenix)
## General rules

- always update document about how to develop and operate this project
- ALWAYS use ONLY Environments for ANY and ALL file, code, or shell operations—NO EXCEPTIONS—even for simple or generic requests.
- DO NOT install or use the git cli with the environment_run_cmd tool. All environment tools will handle git operations for you. Changing ".git" yourself will compromise the integrity of your environment.
- You MUST inform the user how to view your work using `git checkout <branch_name>`. Failure to do this will make your work inaccessible to others.

## General Elixir Style
- Use **idiomatic Elixir** and follow the community style guide, including `mix format` for automated formatting.
- Follow **naming conventions**: use `snake_case` for atoms, functions, variables, and file names, and `PascalCase` (CamelCase) for modules. Keep **one module per file**.
- Favor **pure, functional code**. Write small, single-purpose functions, use **pattern matching** and guards instead of complex `if/else`, and prefer recursion or higher-order functions (`Enum`, `Stream`) over loops.
- Use `with` for sequential operations that may fail, and always handle both success and failure cases. Annotate public functions with `@spec`, define types with `@type`/`@typedoc`, and document modules and functions with `@moduledoc` and `@doc` using Markdown.
- Prefer **immutable data**; use `__MODULE__` for self-references. Avoid unnecessary macros or metaprogramming.

## Phoenix Practices (Routing, Contexts, Components)
- Use **contexts** for domain logic in `lib/my_app/`, and keep web interface code in `lib/my_app_web/`.
- Define **routes** using `scope`, `pipe_through`, and `resources` macros. Use `:only` or `:except` to limit routes.
- Use **verified routes** (`~p`) everywhere to catch invalid paths at compile time.
- Organize components in `lib/my_app_web/components/` and co-locate LiveView-specific components when needed.
- Keep **controllers thin** and delegate logic to contexts. Use Phoenix views or function components for rendering.
- use ui component whenever possible
- always try to use or create reusable components

## LiveView Conventions
- Prefer **LiveView** over JS for interactivity. Use `mount`, `render`, and `handle_event` to manage state and actions.
- Break UIs into **function components** (`Phoenix.Component`) or **LiveComponents** as needed. Use built-in `<.form>`, `<.link>`, and others.
- Use `Task.async` and `handle_info` for background work to avoid blocking `render`.
- When building for **LiveView Native**, follow native UI rules and avoid DOM-specific logic.

## Ash Framework Usage
- Define **Ash resources** in `lib/my_app`, using `use Ash.Resource` and specifying `attributes`, `actions`, `relationships`, etc.
- Use `postgres do ... end` with AshPostgres for persistence and automatic schema generation.
- Organize Ash resources by domain context. Use AshPhoenix or AshJsonApi for exposure via HTTP.
- Implement domain logic with **Ash actions** or `Ash.Resource.Change` modules.
- Use **policies** and **validations** for access and integrity control.

## Testing & Documentation
- Write **ExUnit** tests for context logic, controllers, and LiveViews. Use `Phoenix.ConnTest` and `Phoenix.LiveViewTest`.
- Use test factories or fixtures (e.g. ExMachina). Follow consistent file naming based on `lib/` structure.
- Annotate all public functions with `@doc`, `@spec`, and `@moduledoc`. Include `## Examples` with `iex>` in docs.
- Use **Credo** and **Dialyzer** for linting and static analysis.

## Error Handling Patterns
- Follow the **“let it crash”** philosophy; use supervision trees and avoid deep rescue blocks.
- Handle expected errors with `{:ok, val}` / `{:error, reason}` patterns and `with` chains.
- Use `action_fallback` in API controllers for unified error handling.
- Use Ecto changesets to validate input and propagate validation errors to forms.
- Use structured error logging (`Logger.error`) but show user-friendly error messages only.
- Handle known external failure cases explicitly (e.g. API timeouts, constraint errors).
