# 🐋 Dagger Workflow Guide

This guide explains the optimized Dagger task workflow for Gatherly development.

## Quick Start

Prefer the Docker-first workflow with `just` for local development. Use Dagger commands for CI parity or advanced workflows.

```bash
# Local development (recommended)
just dev-setup
just dev-server

# Dagger workflows (optional)
mix dagger.up
```

## Command Organization

### Tier 1: Daily Development

**`mix dagger.up`** - Smart development startup
- ✅ Detects what's already set up
- ⚡ Skips unnecessary steps for speed
- 🚀 Starts Phoenix server in foreground with live logs
- 🛑 Stop with `Ctrl+C`

```bash
mix dagger.up                    # Smart startup on port 4000
mix dagger.up --port 3000        # Custom port
mix dagger.up --force-setup      # Force full setup even if ready
```

### Tier 2: Regular Development Tasks

**Database Operations:**
```bash
mix dagger.db.create             # Create database
mix dagger.db.migrate            # Run migrations
mix dagger.db.reset              # Drop and recreate database
mix dagger.db.seed               # Seed database
mix dagger.db.shell              # Database shell
```

**Code Quality:**
```bash
mix dagger.test                  # Run tests
mix dagger.format                # Format code
mix dagger.lint                  # Run linting (Credo)
```

**Environment Management:**
```bash
mix dagger.setup                 # Install dependencies + compile
mix dagger.clean                 # Clean build artifacts
mix dagger.dev.shell             # Interactive shell in container
```

### Tier 3: Workflow Orchestration

**Quality Workflows:**
```bash
mix dagger.quality              # Format + lint + security
mix dagger.ci                   # Full CI pipeline
```

**Deployment:**
```bash
mix dagger.deploy               # Deploy to production
```

## Smart Detection Logic

`mix dagger.up` analyzes your environment:

| Component | Check | Action |
|-----------|-------|--------|
| 📦 Dependencies | `mix deps.check` | Install if missing |
| 🔨 Compilation | `mix compile` | Compile if needed |
| 🗄️ Database | Connection test | Create if missing |
| 🎨 Assets | Built assets exist | Setup if missing |

**Smart Behaviors:**
- **All ready** → Start server immediately
- **Deps missing** → Full setup then start
- **Just compile needed** → Quick compile then start
- **Unclear state** → Safe setup then start

## Development Scenarios

### First Time Setup
```bash
# Clone repo
git clone <repo>
cd gatherly

# Start development (containers only)
just dev-setup
just dev-server
```

### Daily Development
```bash
# Smart startup (fast)
mix dagger.up

# Make changes...
# Phoenix auto-reloads

# Stop when done
Ctrl+C
```

### After Pulling Changes
```bash
# Smart startup detects new deps/migrations
mix dagger.up

# Or force full setup if needed
mix dagger.up --force-setup
```

### Database Changes
```bash
# Reset database
mix dagger.db.reset

# Or just run new migrations
mix dagger.db.migrate
```

### Before Committing
```bash
# Run quality checks
mix dagger.quality

# Run tests
mix dagger.test

# Or run full CI locally
mix dagger.ci
```

## Troubleshooting

### Environment Issues
```bash
# Force full setup
mix dagger.up --force-setup

# Clean everything and restart
mix dagger.clean
mix dagger.up
```

### Port Conflicts
```bash
# Use different port
mix dagger.up --port 3000
```

### Database Issues
```bash
# Reset database
mix dagger.db.reset

# Check database connection
mix dagger.db.shell
```

### Container Issues
```bash
# Clean Docker containers
mix dagger.clean --containers

# Full cleanup
mix dagger.clean --all
```

## Performance Tips

1. **Use `mix dagger.up`** for daily development - it's optimized for speed
2. **Avoid `--force-setup`** unless needed - smart detection is faster
3. **Keep Docker running** - container startup is the slowest part
4. **Use specific commands** for targeted tasks (e.g., `mix dagger.test` vs full CI)

## Architecture

The workflow is built on these principles:

1. **Frequency-based naming** - Most used commands are shortest
2. **Smart detection** - Skip unnecessary work
3. **Foreground execution** - Developers see logs in real-time
4. **Composable tasks** - Higher-level workflows built from atomic tasks
5. **Container isolation** - Consistent environment across machines

This creates an optimal local development experience while maintaining the benefits of containerized development.