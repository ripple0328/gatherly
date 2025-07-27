# AI Coding Agent Guidelines (Elixir/Phoenix)

## Project Overview
Gatherly is a collaborative event planning platform built with Phoenix LiveView. The project uses container-based development for consistency and ease of setup.
<!-- ## General rules

- Always update documentation about how to develop and operate this project
- ALWAYS use ONLY Environments for ANY and ALL file, code, or shell operations—NO EXCEPTIONS—even for simple or generic requests
- DO NOT install or use the git cli with the environment_run_cmd tool. All environment tools will handle git operations for you. Changing ".git" yourself will compromise the integrity of your environment
- You MUST inform the user how to view your work using `git checkout <branch_name>`. Failure to do this will make your work inaccessible to others -->

## Container Development Environment

### Tool Versions (Verified Working)
- **Elixir**: 1.18.4-otp-28
- **Erlang/OTP**: 28.0.1
- **PostgreSQL**: 17.5
- **Phoenix**: 1.8.0-rc.3

### Services
- **PostgreSQL**: Running as `postgres` service with database `gatherly_dev`
- **Phoenix Server**: Port 4000, bound to `0.0.0.0` for external access

### Asset Management
- **Asset Pipeline**: Uses esbuild and tailwind from Elixir dependencies (no Node.js required)
- **JavaScript**: Minimal JavaScript with Phoenix LiveView client
- **CSS**: Tailwind CSS with PostCSS processing

### CI/CD
- **GitHub Actions**: Automated lint, test, and deploy pipeline
- **Deployment**: Fly.io with automatic database migrations
- **Health Check**: `/health` endpoint for monitoring
- **Documentation**: See `docs/CICD.md` for detailed setup instructions


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

## Key Features to Implement
Based on the project roadmap, focus on:

1. **Event Management**: Creating and joining events
2. **RSVP System**: Participant tracking
3. **Proposals & Voting**: Date/time and location selection
4. **Logistics Board**: Collaborative task/item management
5. **Discussion Forum**: Event-specific communication
6. **AI Integration**: Smart suggestions and optimization
