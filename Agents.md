# AI Coding Agent Guidelines (Elixir/Phoenix)

## Project Overview
Gatherly is a collaborative event planning platform built with Phoenix LiveView. The project uses Docker Compose for development and Dagger for CI/CD workflows.

### Quick Start
```bash
# Install dependencies and setup database
mix dev.setup

# Start Phoenix development server (auto-starts services)
mix dev.server

# Or start interactive IEx shell (auto-starts services)
mix dev.shell
```

### Framework Versions
- **Framework**: Phoenix 1.8.0 (Latest stable)
- **LiveView**: 1.1.2 (Latest stable)
- **Elixir**: 1.18.4-otp-28
- **Erlang/OTP**: 28.0.1
- **PostgreSQL**: 17.5

### Development Environment

#### Development Setup (Docker Compose)
- **PostgreSQL**: Running in `db` container with database `gatherly_dev` on port 5432
- **Elixir App**: Running in `app` container with development tools
- **Test Database**: Separate PostgreSQL instance for testing on port 5433
- **Phoenix Server**: Available at http://localhost:4000 when started

#### Asset Management
- **Asset Pipeline**: Uses esbuild and tailwind from Elixir dependencies (no Node.js required)
- **JavaScript**: Minimal JavaScript with Phoenix LiveView client
- **CSS**: Tailwind CSS with PostCSS processing

#### CI/CD (Dagger)
- **GitHub Actions**: Automated lint, test, and deploy pipeline
- **Deployment**: Fly.io with automatic database migrations
- **Health Check**: `/health` endpoint for monitoring
- **Documentation**: See `docs/CICD.md` for detailed setup instructions

## General Rules

- Always update documentation about how to develop and operate this project
- Follow Phoenix 1.8 conventions and leverage new features
- Prioritize LiveView over traditional controllers where appropriate
- Use verified routes (`~p`) everywhere for compile-time safety

## General Elixir Style
- Use **idiomatic Elixir** and follow the community style guide, including `mix format` for automated formatting
- Follow **naming conventions**: use `snake_case` for atoms, functions, variables, and file names, and `PascalCase` (CamelCase) for modules. Keep **one module per file**
- Favor **pure, functional code**. Write small, single-purpose functions, use **pattern matching** and guards instead of complex `if/else`, and prefer recursion or higher-order functions (`Enum`, `Stream`) over loops
- Use `with` for sequential operations that may fail, and always handle both success and failure cases. Annotate public functions with `@spec`, define types with `@type`/`@typedoc`, and document modules and functions with `@moduledoc` and `@doc` using Markdown
- Prefer **immutable data**; use `__MODULE__` for self-references. Avoid unnecessary macros or metaprogramming

## Phoenix 1.8 Specific Features

### New LiveView Features
- **Streams**: Use `stream/4` for efficient handling of large collections
- **Async/Await**: Leverage `assign_async/3` and `start_async/2` for background operations
- **Form Recovery**: Automatic form state recovery on disconnects
- **Component Attributes**: Use `attr/3` and `slot/3` for component definitions
- **JS Commands**: Enhanced `Phoenix.LiveView.JS` for client-side interactions

### Modern Routing
- Use `live_session/3` for optimized live navigation
- Implement `on_mount` hooks for cross-cutting concerns
- Use verified routes (`~p`) exclusively for type safety
- Prefer `push_navigate/2` over `push_redirect/2`

### Enhanced Components
- Create function components with `use Phoenix.Component`
- Use `attr/3` for compile-time attribute validation
- Define slots with `slot/3` for flexible component composition
- Leverage `render_slot/2` for slot rendering

## Phoenix Practices (Routing, Contexts, Components)
- Use **contexts** for domain logic in `lib/gatherly/`, and keep web interface code in `lib/gatherly_web/`
- Define **routes** using `scope`, `pipe_through`, and `resources` macros. Use `:only` or `:except` to limit routes
- Use **verified routes** (`~p`) everywhere to catch invalid paths at compile time
- Organize components in `lib/gatherly_web/components/` and co-locate LiveView-specific components when needed
- Keep **controllers thin** and delegate logic to contexts. Use Phoenix views or function components for rendering
- Use ui component whenever possible
- Always try to use or create reusable components

## LiveView Conventions

### Core Patterns
- Prefer **LiveView** over JS for interactivity. Use `mount`, `render`, and `handle_event` to manage state and actions
- Break UIs into **function components** (`Phoenix.Component`) or **LiveComponents** as needed. Use built-in `<.form>`, `<.link>`, and others
- Use `Task.async` and `handle_info` for background work to avoid blocking `render`
- When building for **LiveView Native**, follow native UI rules and avoid DOM-specific logic

### Async Operations (Phoenix 1.8)
```elixir
# Use assign_async for data loading
def mount(_params, _session, socket) do
  socket = 
    socket
    |> assign_async(:users, fn -> 
      {:ok, %{users: MyApp.Accounts.list_users()}}
    end)
  
  {:ok, socket}
end

# Use start_async for background tasks
def handle_event("process", _params, socket) do
  socket = start_async(socket, :processing, fn ->
    MyApp.Worker.process_data()
  end)
  
  {:noreply, socket}
end
```

### Streams for Large Collections
```elixir
# Initialize stream
def mount(_params, _session, socket) do
  socket = stream(socket, :posts, [])
  {:ok, socket}
end

# Add to stream
def handle_info({:new_post, post}, socket) do
  {:noreply, stream_insert(socket, :posts, post)}
end
```

### Modern Component Definitions
```elixir
defmodule GatherlyWeb.Components.Card do
  use Phoenix.Component
  
  attr :title, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true
  
  def card(assigns) do
    ~H"""
    <div class={"card #{@class}"}>
      <h3><%= @title %></h3>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
```

## Testing & Documentation
- Write **ExUnit** tests for context logic, controllers, and LiveViews. Use `Phoenix.ConnTest` and `Phoenix.LiveViewTest`
- Use test factories or fixtures (e.g. ExMachina). Follow consistent file naming based on `lib/` structure
- Annotate all public functions with `@doc`, `@spec`, and `@moduledoc`. Include `## Examples` with `iex>` in docs
- Use **Credo** and **Dialyzer** for linting and static analysis
- Test async operations using `Phoenix.LiveViewTest.render_async/1`
- Test streams with `Phoenix.LiveViewTest.render_hook/3`

## Error Handling Patterns
- Follow the **"let it crash"** philosophy; use supervision trees and avoid deep rescue blocks
- Handle expected errors with `{:ok, val}` / `{:error, reason}` patterns and `with` chains
- Use `action_fallback` in API controllers for unified error handling
- Use Ecto changesets to validate input and propagate validation errors to forms
- Use structured error logging (`Logger.error`) but show user-friendly error messages only
- Handle known external failure cases explicitly (e.g. API timeouts, constraint errors)

## Phoenix 1.8 Migration Notes

### From Previous Versions
- Replace `live_redirect` with `push_navigate` for better performance
- Use `attr/3` instead of manual assign validation
- Leverage streams instead of assign-based lists for large collections
- Adopt async patterns for better user experience

### Performance Optimizations
- Use streams for large collections to avoid full re-renders
- Implement async data loading to prevent blocking
- Leverage Phoenix 1.8's improved diff algorithm
- Use `phx-update="stream"` for efficient DOM updates

### New Debugging Features
- Use `Phoenix.LiveView.Utils.assign_rest/2` for debugging assigns
- Leverage enhanced error messages in development
- Use telemetry events for monitoring LiveView performance

## Development Workflow

### Development Commands
```bash
# Core development (auto-starts services)
mix dev.server             # Start Phoenix server at http://localhost:4000
mix dev.shell              # Start IEx shell with database connection
mix dev.setup              # Full setup (install deps + setup database)
```

### Database Operations
```bash
# Database management
mix dev.db.create          # Create development database
mix dev.db.migrate         # Run database migrations
mix dev.db.rollback        # Rollback migrations (supports --step, --to)
mix dev.db.reset           # Reset database (drop, create, migrate, seed)
mix dev.db.seed            # Run database seeds
mix dev.db.shell           # Connect to PostgreSQL shell
```

### Testing
```bash
# Test commands
mix dev.test               # Run all tests with test database
mix dev.test --failed      # Run only failed tests
mix dev.test test/specific_test.exs  # Run specific test file
```

### CI/CD & Quality (Dagger)
```bash
# Production workflows (containerized)
mix dagger.ci              # Full CI pipeline
mix dagger.test            # Run tests in CI environment
mix dagger.lint            # Lint with Credo & Dialyzer
mix dagger.format          # Format code
mix dagger.security        # Security audit
mix dagger.deploy          # Build & deploy to Fly.io
```

## Security Best Practices
- Always validate user input with Ecto changesets
- Use CSRF protection on all forms
- Implement proper authentication and authorization
- Sanitize user-generated content
- Use secure headers via Plug.Security
- Follow OWASP guidelines for web applications

## Performance Guidelines
- Use streams for large datasets
- Implement pagination for large result sets
- Use async operations for external API calls
- Optimize database queries with proper indexing
- Use Phoenix 1.8's improved change tracking
- Monitor with telemetry and observability tools

## AI Agent Specific Instructions

### Code Generation
- Always generate complete, working code examples
- Include proper error handling and edge cases
- Use Phoenix 1.8 patterns and conventions
- Add comprehensive tests for generated code
- Include documentation with examples

### Debugging Assistance
- Analyze errors in context of Phoenix 1.8 features
- Suggest modern alternatives to deprecated patterns
- Provide step-by-step debugging instructions
- Recommend appropriate testing strategies

### Feature Implementation
- Prefer LiveView solutions over traditional MVC
- Use modern Phoenix components and patterns
- Implement proper error boundaries
- Consider performance implications
- Follow accessibility best practices

## Key Features to Implement
Based on the project roadmap, focus on:

1. **Event Management**: Creating and joining events
2. **RSVP System**: Participant tracking
3. **Proposals & Voting**: Date/time and location selection
4. **Logistics Board**: Collaborative task/item management
5. **Discussion Forum**: Event-specific communication
6. **AI Integration**: Smart suggestions and optimization

---

*This file should be updated as Phoenix evolves and new patterns emerge.*