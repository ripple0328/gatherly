# 🛠️ Development Guide

This guide explains how to run Gatherly locally using the simplified Docker Compose workflow.

## Prerequisites

- Docker (Docker Desktop, OrbStack, or Colima)
- Optional: `just` task runner (`brew install just` on macOS)

## Quick Start

```bash
# One-time setup
cp .env.example .env
just setup

# Start development
just dev   # Phoenix server at http://localhost:4000

# View all essential commands
just menu
```

## Essential Development Commands

### Core Workflow
```bash
# Setup and server
just setup                    # Initial project setup (run once)
just dev                      # Start development server
just iex                      # Interactive Elixir shell

# Testing
just test                     # Run tests
just test-watch               # Watch tests continuously
just coverage                 # Generate coverage report

# Code quality
just format                   # Format code (fast)
just check                    # Format + lint + test (full)

# Database
just db-reset                 # Reset database to clean state
just db-console               # Open database console

# Utilities
just doctor                   # Environment health check
just clean                    # Clean everything and start fresh
```

### Deployment
```bash
just deploy                   # Deploy to production (runs checks first)
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

### Quick Environment Check
```bash
just doctor  # Check Docker, environment files, and dependencies
```

### Services Won't Start
```bash
# Check what's running
docker compose ps

# Stop and restart
docker compose down
just dev  # Will start fresh
```

### Database Connection Issues
```bash
just db-reset  # Reset database to clean state
```

### Container Issues
```bash
# Clean everything and start fresh
just clean
just setup
```

### Port Already in Use
- Stop any existing Phoenix servers: `docker compose down`
- Check if port 4000 or 5432 is in use by other applications

### Permission Issues
- Ensure Docker is running
- Make sure you have permissions to use Docker commands

## Architecture Notes

- **Development**: Uses Docker Compose for consistent, containerized development
- **Task Runner**: `just` provides simplified, essential commands with smart service management
- **Efficiency**: Helper functions eliminate duplication and ensure fast, reliable execution
- **CI/CD**: Uses Dagger for reliable, containerized testing and deployment
- **Auto-Start**: `just dev-server` and `just dev-shell` automatically start required services
- **Secrets**: Use `.env` for dev (not committed). Production uses platform secret stores injected via env at runtime.

For more details about the project, see [Project Overview](Project.md) and [Project Landscape](Landscape.md).
