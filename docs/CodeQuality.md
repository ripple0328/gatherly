# Code Quality Tools and Configuration

This document explains the code quality tools, configurations, and practices implemented in the Gatherly project.

## Table of Contents

- [Overview](#overview)
- [Tools and Configurations](#tools-and-configurations)
- [Quick Start](#quick-start)
- [Daily Development Workflow](#daily-development-workflow)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## Overview

Gatherly uses a comprehensive set of tools to maintain high code quality, consistency, and reliability:

- **Elixir Formatter** - Automatic code formatting
- **Credo** - Static code analysis and style checking
- **Dialyzer** - Static type analysis for catching type errors
- **ExUnit** - Testing framework
- **EditorConfig** - IDE-agnostic editor configuration
- **Git Hooks** - Automated quality checks before commits

## Tools and Configurations

### 1. Elixir Formatter (`.formatter.exs`)

**Purpose**: Automatically formats Elixir code according to community standards and project-specific rules.

**What it does**:
- Enforces consistent indentation (2 spaces)
- Sets maximum line length (120 characters)
- Normalizes spacing around operators
- Orders imports and aliases consistently
- Formats Phoenix/Ecto-specific DSL functions without parentheses

**How to use**:
```bash
# Format all files
mix format

# Check if files are formatted (useful in CI)
mix format --check-formatted

# Format specific files
mix format lib/gatherly/events.ex
```

**Configuration highlights**:
- Line length: 120 characters (matches our style guide)
- Includes Phoenix LiveView HTML formatter for `.heex` files
- Comprehensive `locals_without_parens` for Ecto, Phoenix, and testing DSLs

### 2. Credo (`.credo.exs`)

**Purpose**: Static code analysis tool that checks for code readability, consistency, and potential issues.

**What it does**:
- Detects code smells and anti-patterns
- Enforces consistent naming conventions
- Checks for unused variables and functions
- Identifies overly complex functions
- Ensures proper module documentation

**How to use**:
```bash
# Run Credo with default settings
mix credo

# Run in strict mode (recommended)
mix credo --strict

# Show all issues including low priority
mix credo --strict --all

# Run on specific files
mix credo lib/gatherly/events.ex

# Generate config file
mix credo gen.config
```

**Key checks enabled**:
- **Consistency**: Function names, parameter patterns, spacing
- **Readability**: Module docs, function length, variable names
- **Refactoring**: Cyclomatic complexity (max 12), function arity (max 8)
- **Warnings**: Unused operations, unsafe functions, TODO/FIXME tags

### 3. Dialyzer (Dialyxir)

**Purpose**: Static type analysis that finds type inconsistencies and potential runtime errors.

**What it does**:
- Builds a PLT (Persistent Lookup Table) of type information
- Analyzes function specifications (`@spec`)
- Detects unreachable code and incorrect return types
- Finds inconsistent function calls

**How to use**:
```bash
# First-time setup (builds PLT - can take several minutes)
mix dialyzer --plt

# Run type analysis
mix dialyzer

# Run on specific files
mix dialyzer lib/gatherly/events.ex

# Clean PLT and rebuild
rm -rf priv/plts && mix dialyzer --plt
```

**Configuration**:
- PLT stored in `priv/plts/dialyzer.plt`
- Includes `:mix` and `:ex_unit` applications
- Ignores common false positives via `.dialyzer_ignore.exs`
- Flags: `:error_handling`, `:race_conditions`, `:underspecs`

### 4. EditorConfig (`.editorconfig`)

**Purpose**: Maintains consistent coding styles across different editors and IDEs.

**What it configures**:
- Character encoding (UTF-8)
- Line endings (LF)
- Indentation (2 spaces for Elixir/Phoenix files)
- Trailing whitespace handling
- Final newline insertion

**Supported file types**:
- Elixir (`.ex`, `.exs`)
- Phoenix templates (`.heex`, `.eex`)
- JavaScript/CSS
- JSON, YAML, Markdown
- Configuration files

### 5. Git Hooks

**Purpose**: Automatically run quality checks before commits to prevent broken code from entering the repository.

**Installation**:
```bash
# Install hooks (run once per developer)
./.githooks/install.sh
```

**What the pre-commit hook does**:
1. Checks code formatting (`mix format --check-formatted`)
2. Runs static analysis (`mix credo --strict`)
3. Executes test suite (`mix test`)
4. Optionally runs Dialyzer (`mix dialyzer`)

**Skipping hooks** (when necessary):
```bash
# Skip all hooks
git commit --no-verify

# Skip just Dialyzer (set environment variable)
export SKIP_DIALYZER=true
git commit
```

## Quick Start

### For New Developers

1. **Install dependencies**:
   ```bash
   mix deps.get
   ```

2. **Install git hooks**:
   ```bash
   ./.githooks/install.sh
   ```

3. **Build Dialyzer PLT** (optional, but recommended):
   ```bash
   mix dialyzer --plt
   ```

4. **Run quality checks**:
   ```bash
   mix quality
   ```

### For Existing Codebase

1. **Format all code**:
   ```bash
   mix format
   ```

2. **Check for issues**:
   ```bash
   mix credo --strict
   ```

3. **Run tests**:
   ```bash
   mix test
   ```

## Daily Development Workflow

### Before Writing Code

1. **Pull latest changes**:
   ```bash
   git pull origin main
   mix deps.get
   ```

2. **Run quality checks**:
   ```bash
   mix quality
   ```

### While Writing Code

1. **Format code regularly**:
   ```bash
   mix format
   ```
   
   *Most IDEs can be configured to format on save*

2. **Run Credo for immediate feedback**:
   ```bash
   mix credo --strict
   ```

3. **Run tests frequently**:
   ```bash
   mix test
   ```

### Before Committing

1. **Final quality check**:
   ```bash
   mix quality
   ```

2. **Commit** (pre-commit hooks will run automatically):
   ```bash
   git add .
   git commit -m "Add feature: event notifications"
   ```

## Mix Aliases

The project includes convenient Mix aliases for common tasks:

```bash
# Run all quality checks
mix quality

# Run CI-friendly checks (no formatting, just verification)
mix quality.ci

# Format code and run Credo
mix lint

# CI-friendly linting (no formatting, just checks)
mix lint.ci

# Generate documentation
mix docs
```

## CI/CD Integration

For continuous integration, use the CI-friendly aliases:

```yaml
# Example GitHub Actions step
- name: Run quality checks
  run: |
    mix quality.ci
```

These aliases:
- Use `--check-formatted` instead of formatting
- Exit with non-zero status on any failures
- Are suitable for automated environments

## IDE Integration

### Any IDE with EditorConfig Support

The `.editorconfig` file works with most modern IDEs:
- VS Code
- IntelliJ IDEA / PhpStorm
- Vim/Neovim
- Emacs
- Sublime Text
- Atom

### Recommended VS Code Extensions

While not required, these extensions enhance the development experience:
- `JakeBecker.elixir-ls` - Elixir language server
- `phoenixframework.phoenix` - Phoenix framework support
- `EditorConfig.EditorConfig` - EditorConfig support

## Troubleshooting

### Common Issues

#### "mix format --check-formatted" fails
```bash
# Fix: Format the code
mix format
```

#### Credo reports issues
```bash
# See detailed issues
mix credo --strict --verbose

# Check specific files
mix credo lib/gatherly/problematic_file.ex
```

#### Dialyzer takes too long
```bash
# Skip Dialyzer in commits
export SKIP_DIALYZER=true

# Or rebuild PLT if corrupted
rm -rf priv/plts && mix dialyzer --plt
```

#### Git hooks not working
```bash
# Reinstall hooks
./.githooks/install.sh

# Check if hooks are executable
ls -la .git/hooks/pre-commit
```

### Performance Tips

1. **Dialyzer PLT caching**: The PLT file is cached and only rebuilt when dependencies change
2. **Incremental Credo**: Credo only analyzes changed files by default
3. **Parallel tests**: ExUnit runs tests in parallel automatically
4. **Editor formatting**: Configure your editor to format on save

## Configuration Files Reference

| File | Purpose | Tool |
|------|---------|------|
| `.formatter.exs` | Code formatting rules | Elixir Formatter |
| `.credo.exs` | Static analysis configuration | Credo |
| `.dialyzer_ignore.exs` | Dialyzer warning suppressions | Dialyzer |
| `.editorconfig` | Editor configuration | EditorConfig |
| `.githooks/pre-commit` | Pre-commit quality checks | Git |
| `mix.exs` | Tool dependencies and settings | Mix |

## Best Practices

### Documentation
- Always add `@moduledoc` to public modules
- Add `@doc` and `@spec` to public functions
- Use examples in documentation

### Type Specifications
```elixir
@spec create_event(map(), String.t()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
def create_event(params, creator_id) do
  # implementation
end
```

### Error Handling
```elixir
# Use consistent return patterns
{:ok, result} | {:error, reason}

# Pattern match in function heads when possible
def handle_success({:ok, event}), do: broadcast_event(event)
def handle_success({:error, changeset}), do: log_error(changeset)
```

### Testing
```elixir
# Group related tests
describe "create_event/2" do
  test "creates event with valid params" do
    # test implementation
  end
  
  test "returns error with invalid params" do
    # test implementation
  end
end
```

## Conclusion

These tools work together to maintain high code quality in the Gatherly project:

1. **Elixir Formatter** ensures consistent code style
2. **Credo** catches code smells and enforces best practices  
3. **Dialyzer** prevents type-related bugs
4. **EditorConfig** maintains consistency across different editors
5. **Git hooks** prevent quality issues from entering the codebase

By following this setup and workflow, we maintain a codebase that is:
- Consistent and readable
- Free of common bugs and anti-patterns
- Well-tested and documented
- Easy for new developers to understand and contribute to

For questions or suggestions about these tools, please refer to the [Style Guide](StyleGuide.md) or reach out to the development team.