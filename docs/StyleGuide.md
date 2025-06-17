# Gatherly Elixir/Phoenix Style Guide

This document outlines the coding standards, conventions, and best practices for the Gatherly project.

## Table of Contents

- [General Principles](#general-principles)
- [Code Formatting](#code-formatting)
- [Naming Conventions](#naming-conventions)
- [Documentation](#documentation)
- [Function and Module Design](#function-and-module-design)
- [Phoenix-Specific Guidelines](#phoenix-specific-guidelines)
- [Testing](#testing)
- [Error Handling](#error-handling)
- [Performance](#performance)
- [Tools and Automation](#tools-and-automation)

## General Principles

### 1. Clarity Over Cleverness
Write code that is easy to read and understand. Prefer explicit over implicit.

```elixir
# Good
def calculate_total_price(items, tax_rate) do
  subtotal = Enum.sum(items)
  tax = subtotal * tax_rate
  subtotal + tax
end

# Avoid
def calc_total(items, rate), do: Enum.sum(items) |> (&(&1 + &1 * rate)).()
```

### 2. Consistency
Follow established patterns within the codebase. When in doubt, check existing code.

### 3. Functional Programming
Embrace immutability, pattern matching, and functional composition.

## Code Formatting

### Line Length
- Maximum line length: **120 characters**
- Break long lines at logical points

### Indentation
- Use **2 spaces** for indentation
- No tabs

### Whitespace
```elixir
# Good - spaces around operators and after commas
def add(a, b), do: a + b
list = [1, 2, 3, 4]

# Bad
def add(a,b),do:a+b
list=[1,2,3,4]
```

### Pipe Operator
```elixir
# Good - each step on new line for readability
data
|> Enum.map(&transform/1)
|> Enum.filter(&valid?/1)
|> Enum.sort()

# Avoid long single-line pipes
data |> Enum.map(&transform/1) |> Enum.filter(&valid?/1) |> Enum.sort()
```

## Naming Conventions

### Modules
- Use `PascalCase`
- Be descriptive and hierarchical

```elixir
# Good
defmodule Gatherly.Events.EventManager do
defmodule GatherlyWeb.EventLive.Index do

# Avoid
defmodule EM do
defmodule EventStuff do
```

### Functions and Variables
- Use `snake_case`
- Use descriptive names
- Boolean functions should be predicates

```elixir
# Good
def create_event(params)
def event_published?(event)
user_name = "John"

# Avoid
def ce(p)
def check_event(event)  # prefer event_published?/1
userName = "John"
```

### Constants and Attributes
- Use `SCREAMING_SNAKE_CASE` for module constants
- Use `snake_case` for module attributes

```elixir
defmodule Gatherly.Events do
  @max_attendees 100
  @doc "Maximum number of attendees per event"
  
  @type event_status :: :draft | :published | :cancelled
  
  MAX_TITLE_LENGTH = 255
end
```

### Atoms
- Use `snake_case`
- Prefer atoms over strings for internal APIs

```elixir
# Good
%{status: :active, type: :potluck}

# Avoid
%{status: "active", type: "Potluck"}
```

## Documentation

### Module Documentation
Every public module must have `@moduledoc`.

```elixir
defmodule Gatherly.Events.EventManager do
  @moduledoc """
  Manages event lifecycle including creation, updates, and state transitions.
  
  This module provides high-level functions for event management and coordinates
  with other bounded contexts like Users and Notifications.
  
  ## Examples
  
      iex> EventManager.create_event(%{title: "Potluck Party"})
      {:ok, %Event{}}
  """
end
```

### Function Documentation
Document all public functions with `@doc` and `@spec`.

```elixir
@doc """
Creates a new event with the given parameters.

## Parameters

- `params` - A map containing event attributes
- `creator_id` - The ID of the user creating the event

## Returns

- `{:ok, event}` - Successfully created event
- `{:error, changeset}` - Validation errors

## Examples

    iex> create_event(%{title: "Game Night"}, user.id)
    {:ok, %Event{title: "Game Night"}}
    
    iex> create_event(%{}, user.id)
    {:error, %Ecto.Changeset{}}
"""
@spec create_event(map(), String.t()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
def create_event(params, creator_id) do
  # implementation
end
```

### Type Specifications
Always provide `@spec` for public functions.

```elixir
@spec get_event(String.t()) :: {:ok, Event.t()} | {:error, :not_found}
@spec list_events(keyword()) :: [Event.t()]
@spec update_event(Event.t(), map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
```

## Function and Module Design

### Function Length
- Keep functions short and focused (max 20 lines)
- Extract complex logic into private functions

### Single Responsibility
Each function should do one thing well.

```elixir
# Good - focused responsibility
def send_event_notification(event) do
  event
  |> build_notification_message()
  |> deliver_notification()
end

defp build_notification_message(event) do
  # message building logic
end

defp deliver_notification(message) do
  # delivery logic
end
```

### Pattern Matching
Use pattern matching for control flow and data extraction.

```elixir
# Good
def handle_event_creation({:ok, event}) do
  broadcast_event_created(event)
  {:ok, event}
end

def handle_event_creation({:error, changeset}) do
  log_creation_error(changeset)
  {:error, changeset}
end

# Avoid nested conditionals
def handle_event_creation(result) do
  if elem(result, 0) == :ok do
    event = elem(result, 1)
    broadcast_event_created(event)
    {:ok, event}
  else
    changeset = elem(result, 1)
    log_creation_error(changeset)
    {:error, changeset}
  end
end
```

### With Statements
Use `with` for chained operations that may fail.

```elixir
def create_event_with_invitations(params, creator_id, invitees) do
  with {:ok, event} <- create_event(params, creator_id),
       {:ok, _invitations} <- send_invitations(event, invitees),
       {:ok, _notification} <- notify_creator(event) do
    {:ok, event}
  else
    {:error, reason} -> {:error, reason}
  end
end
```

## Phoenix-Specific Guidelines

### Controllers
- Keep controllers thin
- Delegate business logic to contexts
- Use verified routes (`~p`)

```elixir
defmodule GatherlyWeb.EventController do
  use GatherlyWeb, :controller
  
  alias Gatherly.Events
  
  def create(conn, %{"event" => event_params}) do
    case Events.create_event(event_params, get_current_user_id(conn)) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully")
        |> redirect(to: ~p"/events/#{event}")
        
      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
```

### LiveViews
- Organize by feature
- Use descriptive function component names
- Handle loading states

```elixir
defmodule GatherlyWeb.EventLive.Index do
  use GatherlyWeb, :live_view
  
  alias Gatherly.Events
  
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:loading, true)
      |> assign(:events, [])
    
    {:ok, socket}
  end
  
  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    events = Events.list_events()
    
    socket =
      socket
      |> assign(:loading, false)
      |> assign(:events, events)
    
    {:noreply, socket}
  end
end
```

### Context Modules
- Group related functionality
- Use clear public APIs
- Hide implementation details

```elixir
defmodule Gatherly.Events do
  @moduledoc """
  The Events context handles event management.
  """
  
  alias Gatherly.Events.{Event, EventManager, Invitation}
  alias Gatherly.Repo
  
  # Public API - what other contexts can use
  
  def create_event(params, creator_id) do
    EventManager.create(params, creator_id)
  end
  
  def get_event!(id) do
    Repo.get!(Event, id)
  end
  
  def list_user_events(user_id) do
    EventManager.list_for_user(user_id)
  end
  
  # More public functions...
end
```

### Schemas
- Use meaningful field names
- Add appropriate validations
- Document fields and relationships

```elixir
defmodule Gatherly.Events.Event do
  @moduledoc """
  Schema for events in the Gatherly platform.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  
  @type t :: %__MODULE__{
    id: String.t(),
    title: String.t(),
    description: String.t() | nil,
    status: :draft | :published | :cancelled,
    # ... other fields
  }
  
  schema "events" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:draft, :published, :cancelled], default: :draft
    field :max_attendees, :integer
    field :starts_at, :utc_datetime
    
    belongs_to :creator, Gatherly.Accounts.User
    has_many :attendees, Gatherly.Events.Attendance
    
    timestamps(type: :utc_datetime)
  end
  
  @doc """
  Changeset for creating and updating events.
  """
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :max_attendees, :starts_at])
    |> validate_required([:title, :starts_at])
    |> validate_length(:title, min: 3, max: 255)
    |> validate_number(:max_attendees, greater_than: 0)
    |> validate_future_date(:starts_at)
  end
  
  defp validate_future_date(changeset, field) do
    validate_change(changeset, field, fn _, date ->
      if DateTime.compare(date, DateTime.utc_now()) == :gt do
        []
      else
        [{field, "must be in the future"}]
      end
    end)
  end
end
```

## Testing

### Test Organization
- One test file per module
- Group related tests with `describe`
- Use descriptive test names

```elixir
defmodule Gatherly.EventsTest do
  use Gatherly.DataCase
  
  alias Gatherly.Events
  
  describe "create_event/2" do
    test "creates event with valid parameters" do
      user = user_fixture()
      params = %{title: "Test Event", starts_at: future_datetime()}
      
      assert {:ok, event} = Events.create_event(params, user.id)
      assert event.title == "Test Event"
      assert event.creator_id == user.id
    end
    
    test "returns error with invalid parameters" do
      user = user_fixture()
      params = %{title: ""}
      
      assert {:error, changeset} = Events.create_event(params, user.id)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end
  end
  
  describe "get_event!/1" do
    test "returns event when exists" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end
    
    test "raises when event doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Events.get_event!("nonexistent")
      end
    end
  end
end
```

### Test Data
- Use factories or fixtures for test data
- Keep test data minimal and focused

```elixir
defmodule Gatherly.Support.Fixtures do
  def user_fixture(attrs \\ %{}) do
    {:ok, user} = 
      attrs
      |> Enum.into(%{
        email: "user#{System.unique_integer()}@example.com",
        password: "validpassword123"
      })
      |> Gatherly.Accounts.create_user()
    
    user
  end
  
  def event_fixture(attrs \\ %{}) do
    user = user_fixture()
    
    {:ok, event} = 
      attrs
      |> Enum.into(%{
        title: "Test Event",
        starts_at: DateTime.add(DateTime.utc_now(), 3600, :second)
      })
      |> Gatherly.Events.create_event(user.id)
    
    event
  end
end
```

## Error Handling

### Return Tuples
Use consistent return patterns.

```elixir
# Good - consistent {:ok, result} | {:error, reason} pattern
def create_event(params) do
  case validate_params(params) do
    :ok -> 
      {:ok, insert_event(params)}
    {:error, reason} -> 
      {:error, reason}
  end
end

# Avoid mixed return types
def create_event(params) do
  if valid_params?(params) do
    insert_event(params)  # returns struct directly
  else
    {:error, "invalid params"}  # returns tuple
  end
end
```

### Error Messages
- Be specific and actionable
- Use consistent error formats

```elixir
# Good
{:error, :event_not_found}
{:error, {:validation_failed, %{title: ["can't be blank"]}}}

# Avoid generic errors
{:error, "something went wrong"}
```

## Performance

### Database Queries
- Use `Repo.preload/2` for associations
- Avoid N+1 queries
- Use `select/3` for specific fields when appropriate

```elixir
# Good - preload associations
def list_events_with_creators do
  Event
  |> Repo.all()
  |> Repo.preload(:creator)
end

# Good - select only needed fields
def list_event_titles do
  Event
  |> select([e], {e.id, e.title})
  |> Repo.all()
end
```

### Memory Usage
- Use streams for large datasets
- Avoid loading unnecessary data into memory

```elixir
# Good for large datasets
def process_all_events do
  Event
  |> Repo.stream()
  |> Stream.map(&process_event/1)
  |> Stream.run()
end
```

## Tools and Automation

### Required Tools
1. **Elixir Formatter** - Automatic code formatting
2. **Credo** - Static code analysis
3. **Dialyzer** - Static type analysis
4. **ExUnit** - Testing framework
5. **ExDoc** - Documentation generation

### IDE Configuration
See `.editorconfig`, `.formatter.exs`, and `.credo.exs` for tool configurations.

### Git Hooks
Pre-commit hooks run:
1. `mix format --check-formatted`
2. `mix credo --strict`
3. `mix test`
4. `mix dialyzer` (if configured)

## Conclusion

This style guide should be treated as a living document. As the project evolves, so should these guidelines. When in doubt:

1. Check existing code patterns
2. Consult the Elixir community style guide
3. Prioritize readability and maintainability
4. Ask for code review feedback

Remember: The goal is consistent, readable, and maintainable code that serves the Gatherly platform's users effectively.