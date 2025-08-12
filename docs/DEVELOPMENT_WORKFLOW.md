# Development Workflow Guide

This guide covers the enhanced development workflow for Gatherly, including new tools and commands for improved developer experience.

## 🚀 Quick Start

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/ripple0328/gatherly.git
cd gatherly

# Check environment health first
just doctor

# Run the automated setup script (recommended)
./scripts/dev-setup.sh

# Or manual setup
cp .env.example .env
just dev-setup

# Install pre-commit hooks for quality gates
./scripts/install-hooks.sh
```

### Daily Development

```bash
# Start development server
just dev-server

# Quick development cycle
just quick-check        # Format + lint (fast)
just dev-check          # Format + lint + test (full)

# Interactive development menu
just dev-menu
```

## 🔧 Development Commands

### Core Development
| Command | Description |
|---------|-------------|
| `just dev-server` | Start Phoenix development server |
| `just dev-shell` | Start interactive IEx shell |
| `just dev-setup` | Initial project setup |
| `just doctor` | Check environment health |

### Code Quality
| Command | Description |
|---------|-------------|
| `just quick-check` | Fast format + lint |
| `just dev-check` | Format + lint + test |
| `just review-prep` | Prepare code for review |
| `just pr-check` | Full PR validation |
| `just coverage` | Generate test coverage report |
| `just security-audit` | Run security audit |

### Testing
| Command | Description |
|---------|-------------|
| `just test` | Run test suite |
| `just test-watch` | Watch tests continuously |
| `just test-trace` | Run tests with trace output |
| `just profile-tests` | Profile test performance |

### Database
| Command | Description |
|---------|-------------|
| `just db-console` | Open database console |
| `just db-info` | Show database connection info |
| `just db-backup` | Backup development database |
| `just reset-demo` | Reset with demo data |

### Performance & Debugging
| Command | Description |
|---------|-------------|
| `just perf-monitor` | Start performance monitoring |
| `just memory-usage` | Check container memory usage |
| `just docs` | Generate project documentation |

## 🎯 Git Workflow

### Pre-commit Hooks

Automatic quality checks run on every commit:

```bash
# Install hooks (done automatically by dev-setup.sh)
pre-commit install
pre-commit install --hook-type commit-msg

# Manual pre-commit check
just pre-commit
```

### Commit Message Format

We use conventional commits:

```
type(scope): description

feat(auth): add Google OAuth integration
fix(db): resolve connection pool timeout
docs(readme): update installation instructions
```

### Development Cycle

1. **Start working on a feature**:
   ```bash
   git checkout -b feature/amazing-feature
   just dev-check  # Ensure clean start
   ```

2. **During development**:
   ```bash
   just quick-check  # Fast feedback loop
   just test-watch   # Continuous testing
   ```

3. **Before committing**:
   ```bash
   just review-prep  # Full validation
   git add .
   git commit -m "feat(feature): add amazing feature"
   ```

4. **Before pushing**:
   ```bash
   just pr-check  # Full CI validation
   git push origin feature/amazing-feature
   ```

## 🧪 Testing Strategy

### Test Coverage

We maintain **80%+ test coverage**:

```bash
# Generate coverage report
just coverage

# View report
open cover/excoveralls.html

# CI coverage
just coverage-ci
```

### Test Types

1. **Unit Tests**: Test individual functions and modules
2. **Integration Tests**: Test component interactions
3. **LiveView Tests**: Test real-time functionality
4. **Feature Tests**: End-to-end scenarios

### Writing Tests

```elixir
# Use ExMachina for test data
defmodule MyTest do
  use Gatherly.DataCase
  import Gatherly.Factory

  test "creates user with valid attributes" do
    user = insert(:user)
    assert user.email =~ "@"
  end
end
```

## 🐛 Debugging Tools

### Development Dashboard

Visit `http://localhost:4000/dev/tools` for:
- System performance metrics
- Memory usage monitoring
- Process information
- Quick performance actions

### IEx Debugging

```elixir
# In IEx shell (just dev-shell)
alias Gatherly.Dev.DebugHelpers, as: Debug

# Time function execution
Debug.time_call(fn -> expensive_operation() end)
Debug.time_call("Database query", fn -> Repo.all(User) end)

# Profile memory usage
Debug.memory_profile(fn -> create_lots_of_data() end)

# Check process info
Debug.process_info()
Debug.process_info(pid)  # Check specific process

# System memory overview
Debug.system_memory_info()

# Top memory consuming processes
Debug.top_processes_by_memory(5)

# Database connection pool info
Debug.db_pool_info()

# Force garbage collection
Debug.force_gc_all()

# Advanced: Trace function calls (use carefully)
Debug.trace_calls(MyModule, :my_function, 2)
Debug.stop_trace()  # Always stop when done
```

### Phoenix LiveDashboard

Access comprehensive metrics at `http://localhost:4000/dev/dashboard`:
- Request metrics
- Process explorer
- ETS table browser
- Application tree

## 📊 Performance Monitoring

### Memory Monitoring

```bash
# Container memory usage
just memory-usage

# Force garbage collection
# In IEx: Debug.force_gc_all()
```

### Database Performance

```bash
# Database connection info
just db-info

# Check active connections
# In IEx: Debug.db_pool_info()
```

### Process Monitoring

```bash
# Start observer (graphical tool)
just perf-monitor
# Then in IEx: :observer.start()
```

## 🔍 Code Quality Standards

### Formatting

- Automatic formatting with `mix format`
- Enforced by pre-commit hooks
- Runs in CI/CD pipeline

### Linting

- Strict Credo configuration
- No warnings allowed in CI
- Custom rules for project conventions

### Type Checking

- Dialyzer for static analysis
- Gradual typing adoption
- Type specs on public functions

### Security

- Hex audit for dependency vulnerabilities
- Sobelow security scanner (optional)
- No secrets in code

## 🚀 Deployment Workflow

### Pre-deployment Checks

```bash
# Full validation
just pr-check

# Security audit
just security-audit

# Coverage check
just coverage
```

### Deployment

```bash
# Deploy to Fly.io
just deploy

# Check deployment status
just status

# View logs
just logs

# Rollback if needed
just rollback
```

## 🛠 Troubleshooting

### Common Issues

1. **Docker not starting**:
   ```bash
   just doctor  # Check environment
   ```

2. **Dependencies out of sync**:
   ```bash
   just deps-get
   docker compose down && docker compose up -d
   ```

3. **Database connection issues**:
   ```bash
   just db-info
   just db-reset
   ```

4. **Memory issues**:
   ```bash
   just memory-usage
   # In IEx: Debug.force_gc_all()
   ```

### Performance Issues

1. **Slow tests**:
   ```bash
   just profile-tests
   just test-trace
   ```

2. **High memory usage**:
   ```bash
   # Visit http://localhost:4000/dev/tools
   # Use Debug.top_processes_by_memory()
   ```

3. **Database slow queries**:
   ```bash
   # Enable query logging in config/dev.exs
   # Check Phoenix LiveDashboard
   # Use Debug.db_pool_info() in IEx
   ```

4. **Pre-commit hooks not working**:
   ```bash
   # Reinstall hooks
   ./scripts/install-hooks.sh
   
   # Or manual approach
   just pre-commit
   ```

5. **Dev tools not accessible**:
   ```bash
   # Ensure you're in development mode
   # Visit http://localhost:4000/dev/tools
   # Check that dev_routes: true in config/dev.exs
   ```

## 📚 Additional Resources

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/)
- [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- [Testing Best Practices](https://github.com/elixir-lang/elixir/blob/master/lib/ex_unit/lib/ex_unit/doc_test.ex)
- [Performance Optimization](https://hexdocs.pm/phoenix/performance.html)

## 🤝 Contributing

1. Follow the development workflow outlined above
2. Ensure all quality checks pass
3. Write comprehensive tests
4. Update documentation as needed
5. Use conventional commit messages

For questions or issues, check the development tools at `/dev/tools` or ask in the team chat.