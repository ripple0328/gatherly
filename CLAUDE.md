# AI Coding Agent Guidelines (Elixir/Phoenix)

## Project Overview
Gatherly is a collaborative event planning platform built with Phoenix LiveView. The project uses container-based development for consistency and ease of setup.

## Container Development Environment

### Tool Versions (Verified Working)
- **Elixir**: 1.18.4-otp-27
- **Erlang/OTP**: 27.0
- **Node.js**: 24.2.0
- **PostgreSQL**: 16

### Services
- **PostgreSQL**: Running as `postgres` service with database `gatherly_dev`
- **Phoenix Server**: Port 4000, bound to `0.0.0.0` for external access

### Development Commands
All commands must be prefixed with the asdf environment loader and UTF-8 encoding:

```bash
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" <command>'
```

Common commands:
- `mix deps.get` - Install dependencies
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run migrations
- `mix phx.server` - Start Phoenix server
- `mix test` - Run tests
- `mix format` - Format code
- `mix credo` - Static analysis
- `mix assets.setup` - Setup asset tools
- `mix assets.build` - Build assets

## General rules

- Always update documentation about how to develop and operate this project
- ALWAYS use ONLY Environments for ANY and ALL file, code, or shell operations—NO EXCEPTIONS—even for simple or generic requests
- DO NOT install or use the git cli with the environment_run_cmd tool. All environment tools will handle git operations for you. Changing ".git" yourself will compromise the integrity of your environment
- You MUST inform the user how to view your work using `git checkout <branch_name>`. Failure to do this will make your work inaccessible to others

## General Elixir Style
- Use **idiomatic Elixir** and follow the community style guide, including `mix format` for automated formatting
- Follow **naming conventions**: use `snake_case` for atoms, functions, variables, and file names, and `PascalCase` (CamelCase) for modules. Keep **one module per file**
- Favor **pure, functional code**. Write small, single-purpose functions, use **pattern matching** and guards instead of complex `if/else`, and prefer recursion or higher-order functions (`Enum`, `Stream`) over loops
- Use `with` for sequential operations that may fail, and always handle both success and failure cases. Annotate public functions with `@spec`, define types with `@type`/`@typedoc`, and document modules and functions with `@moduledoc` and `@doc` using Markdown
- Prefer **immutable data**; use `__MODULE__` for self-references. Avoid unnecessary macros or metaprogramming

## Phoenix Practices (Routing, Contexts, Components)
- Use **contexts** for domain logic in `lib/gatherly/`, and keep web interface code in `lib/gatherly_web/`
- Define **routes** using `scope`, `pipe_through`, and `resources` macros. Use `:only` or `:except` to limit routes
- Use **verified routes** (`~p`) everywhere to catch invalid paths at compile time
- Organize components in `lib/gatherly_web/components/` and co-locate LiveView-specific components when needed
- Keep **controllers thin** and delegate logic to contexts. Use Phoenix views or function components for rendering
- Use ui component whenever possible
- Always try to use or create reusable components

## LiveView Conventions
- Prefer **LiveView** over JS for interactivity. Use `mount`, `render`, and `handle_event` to manage state and actions
- Break UIs into **function components** (`Phoenix.Component`) or **LiveComponents** as needed. Use built-in `<.form>`, `<.link>`, and others
- Use `Task.async` and `handle_info` for background work to avoid blocking `render`
- When building for **LiveView Native**, follow native UI rules and avoid DOM-specific logic

## Testing & Documentation
- Write **ExUnit** tests for context logic, controllers, and LiveViews. Use `Phoenix.ConnTest` and `Phoenix.LiveViewTest`
- Use test factories or fixtures (e.g. ExMachina). Follow consistent file naming based on `lib/` structure
- Annotate all public functions with `@doc`, `@spec`, and `@moduledoc`. Include `## Examples` with `iex>` in docs
- Use **Credo** and **Dialyzer** for linting and static analysis

## Error Handling Patterns
- Follow the **"let it crash"** philosophy; use supervision trees and avoid deep rescue blocks
- Handle expected errors with `{:ok, val}` / `{:error, reason}` patterns and `with` chains
- Use `action_fallback` in API controllers for unified error handling
- Use Ecto changesets to validate input and propagate validation errors to forms
- Use structured error logging (`Logger.error`) but show user-friendly error messages only
- Handle known external failure cases explicitly (e.g. API timeouts, constraint errors)

## Database Configuration
The project uses PostgreSQL with the following development configuration:

```elixir
config :gatherly, Gatherly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",  # Container service name
  database: "gatherly_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

## Asset Management
- **Tailwind CSS**: Configured and watching for changes
- **ESBuild**: JavaScript compilation
- **Phoenix LiveReload**: Automatic browser refresh
- Assets are automatically built and served in development

## Key Features to Implement
Based on the project roadmap, focus on:

1. **Event Management**: Creating and joining events
2. **RSVP System**: Participant tracking
3. **Proposals & Voting**: Date/time and location selection
4. **Logistics Board**: Collaborative task/item management
5. **Discussion Forum**: Event-specific communication
6. **AI Integration**: Smart suggestions and optimization

## important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
