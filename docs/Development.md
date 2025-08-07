# 🛠️ Development Guide

This guide explains how to run Gatherly locally using Docker Compose for development and Dagger for CI/CD.

## Prerequisites

- Docker (Docker Desktop, OrbStack, or Colima)
- Optional: `just` task runner (`brew install just` on macOS)

## Quick Start

```bash
# One-time setup (installs deps + database in containers)
cp .env.example .env   # fill in secrets
just dev-setup

# Start development (services auto-start)
just dev-server   # Phoenix server at http://localhost:4000

# OR interactive IEx shell
just dev-shell
```

## Development Workflow

### Core Development Commands (via `just`)
```bash
# App
just dev-server               # Phoenix server with live reloading
just dev-shell                # IEx shell with database connection

# Database operations
just db-migrate               # Run migrations
just db-rollback -- --step=1  # Rollback migrations (pass args after --)
just db-reset                 # Reset database completely
just db-seed                  # Run seeds
just db-shell                 # PostgreSQL shell

# Testing
just test                     # Run all tests against isolated test DB
```

### CI/CD Commands (Dagger)
```bash
# Production workflows (containerized)
mix dagger.ci              # Full CI pipeline
mix dagger.test            # Run tests in CI environment
mix dagger.lint            # Code linting with Credo & Dialyzer
mix dagger.format          # Format code
mix dagger.security        # Security audit
mix dagger.deploy          # Deploy to production
```

## Project Structure

```
├── assets/                 # Frontend assets
│   ├── css/               # Tailwind CSS
│   ├── js/                # JavaScript
│   └── tailwind.config.js # Tailwind configuration
├── config/                # Application configuration
│   ├── config.exs         # Base config
│   ├── dev.exs           # Development config
│   ├── prod.exs          # Production config
│   └── test.exs          # Test config
├── lib/
│   ├── gatherly/          # Core domain logic
│   └── gatherly_web/      # Web interface
├── priv/
│   ├── repo/migrations/   # Database migrations
│   └── static/           # Static assets
└── test/                  # Test files
```

## Troubleshooting

### Services Won't Start
Services are automatically started by `just dev-server` or `just dev-shell`. If they fail to start:
```bash
# Stop any running containers and restart
docker compose -f docker-compose.dev.yml down
just dev-server  # Will start fresh
```

### Database Connection Issues
```bash
just db-reset  # Reset database
```

### Container Issues
```bash
# Nuclear option - remove everything and start fresh
docker compose -f docker-compose.dev.yml down --volumes --remove-orphans
just dev-server  # Will rebuild and start fresh
```

### Live Reload Warning (file_system / inotify)
- When running non-server Mix tasks in one-off containers, you may see a warning about `inotify-tools`.
- This is harmless. When you start the server via `just dev-server`, the app container installs `inotify-tools` and live-reload works.

### Quick Environment Check
```bash
just doctor  # Validates Docker daemon and compose availability
```

### Port Already in Use
- Stop any existing Phoenix servers
- Check if port 4000 or 5432 is in use by other applications

### Permission Issues
- Ensure Docker is running
- Make sure you have permissions to use Docker commands

## Architecture Notes

- **Development**: Uses Docker Compose for fast, local development with TTY support
- **Task Runner**: `just` provides a Docker-first command layer
- **CI/CD**: Uses Dagger for reliable, containerized testing and deployment
- **Auto-Start**: `just dev-server` and `just dev-shell` automatically start required services
- **Secrets**: Use `.env` for dev (not committed). Production uses platform secret stores injected via env at runtime.

For more details about the project, see [Project Overview](Project.md) and [Project Landscape](Landscape.md).
