# 🛠️ Development Guide

This guide explains how to run Gatherly locally using Docker Compose for development and Dagger for CI/CD.

## Prerequisites

- [Docker](https://www.docker.com/) and Docker Compose
- [Elixir](https://elixir-lang.org/) (for running Mix tasks)

## Quick Start

```bash
# Setup project (install deps + database)
mix dev.setup

# Start development (services auto-start)
mix dev.server   # Phoenix server at http://localhost:4000
# OR
mix dev.shell    # IEx shell with database
```

## Development Workflow

### Core Development Commands
```bash
# Primary development commands (auto-start services)
mix dev.server   # Phoenix server with live reloading
mix dev.shell    # IEx shell with database connection

# Database operations
mix dev.db.migrate          # Run migrations
mix dev.db.rollback         # Rollback migrations
mix dev.db.reset           # Reset database completely
mix dev.db.seed            # Run seeds
mix dev.db.shell           # PostgreSQL shell

# Testing
mix dev.test               # Run all tests
mix dev.test --failed      # Run only failed tests
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
Services are automatically started by `mix dev.server` or `mix dev.shell`. If they fail to start:
```bash
# Stop any running containers and restart
docker-compose -f docker-compose.dev.yml down
mix dev.server  # Will start fresh
```

### Database Connection Issues
```bash
mix dev.db.reset  # Reset database
```

### Container Issues
```bash
# Nuclear option - remove everything and start fresh
docker-compose -f docker-compose.dev.yml down --volumes --remove-orphans
mix dev.server  # Will rebuild and start fresh
```

### Port Already in Use
- Stop any existing Phoenix servers
- Check if port 4000 or 5432 is in use by other applications

### Permission Issues
- Ensure Docker is running
- Make sure you have permissions to use Docker commands

## Architecture Notes

- **Development**: Uses Docker Compose for fast, local development with TTY support
- **CI/CD**: Uses Dagger for reliable, containerized testing and deployment
- **Separation**: Development commands (`mix dev.*`) vs production workflows (`mix dagger.*`)
- **Auto-Start**: `mix dev.server` and `mix dev.shell` automatically start required services

For more details about the project, see [Project Overview](Project.md) and [Project Landscape](Landscape.md).
