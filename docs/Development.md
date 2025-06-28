# 🛠️ Development Guide

This guide covers the containerized development setup for Gatherly, including how to use the container environment for local development instead of native installation.

## Overview

Gatherly uses a container-based development approach that provides:

- **Consistent Environment**: Same runtime across all developers
- **Zero Local Setup**: No need to install Elixir, Erlang, PostgreSQL, or Node.js locally
- **Isolated Dependencies**: Container manages all tool versions and dependencies
- **Simplified Onboarding**: New developers can start coding immediately

## Container Environment

### Tool Versions

The container environment is configured with the exact versions specified in `.tool-versions`:

```
elixir 1.18.4-otp-28
erlang 28.0.1
```

### Services

The development environment includes:

- **PostgreSQL 16**: Database service with `gatherly_dev` database
- **Phoenix Server**: Running on port 4000 with hot reloading
- **Asset Watchers**: Tailwind CSS and ESBuild for frontend assets

## Getting Started

### 1. Container Setup

Using Claude Code or compatible container tooling:

1. Open the project directory
2. The container environment will automatically:
   - Pull the Ubuntu 24.04 base image
   - Install Elixir 1.18.4 with Erlang/OTP 28.0.1
   - Set up PostgreSQL service
   - Install project dependencies
   - Build frontend assets
   - Create and migrate database
   - Start the Phoenix server

### 2. Accessing the Application

The Phoenix server runs on port 4000 and is exposed externally. You'll receive a URL like:

```
External URL: http://127.0.0.1:50091
Internal URL: http://container-name:4000
```

### 3. Working with Code

All code changes are automatically synced between your local filesystem and the container. The Phoenix server includes hot reloading, so changes to:

- Elixir code (`.ex`, `.exs` files)
- Templates (`.heex` files)
- CSS (Tailwind classes)
- JavaScript files

Will be automatically recompiled and reloaded in the browser.

## Development Commands

All development commands should be run within the container environment using the `bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" <command>'` pattern to ensure proper tool loading and UTF-8 encoding.

### Common Tasks

```bash
# Install/update Elixir dependencies
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix deps.get'

# Install/update Node.js dependencies
bash -c '. /opt/asdf.sh && cd assets && npm install'

# Run tests
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix test'

# Run specific test file
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix test test/gatherly_web/controllers/page_controller_test.exs'

# Format code
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix format'

# Run static analysis
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix credo'

# Run strict credo checks
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix credo --strict'
```

### Database Operations

```bash
# Create database (if not exists)
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.create'

# Run migrations
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.migrate'

# Rollback last migration
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.rollback'

# Reset database (drop, create, migrate, seed)
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.reset'

# Generate new migration
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.gen.migration create_users'

# Run seeds
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix run priv/repo/seeds.exs'
```

### Asset Management

```bash
# Build assets manually
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix assets.build'

# Setup assets (install tools)
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix assets.setup'

# Deploy assets (minified)
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix assets.deploy'

# Watch assets for changes (if not using Phoenix server)
bash -c '. /opt/asdf.sh && cd assets && npm run watch'
```

### Phoenix Server Management

```bash
# Start Phoenix server (if not already running)
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix phx.server'

# Start server in IEx (interactive Elixir)
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" iex -S mix phx.server'

# Generate Phoenix resources
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix phx.gen.live Events Event events title:string description:text'
```

## Database Configuration

The container environment uses the following database configuration:

```elixir
config :gatherly, Gatherly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",  # Service name in container
  database: "gatherly_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

## Project Structure

```
├── assets/                 # Frontend assets
│   ├── css/               # Tailwind CSS
│   ├── js/                # JavaScript
│   ├── package.json       # Node.js dependencies
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

## Debugging

### IEx (Interactive Elixir)

```bash
# Start IEx with the application
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" iex -S mix'

# Start IEx with Phoenix server
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" iex -S mix phx.server'
```

### Logs

Phoenix logs are displayed in the terminal where the server is running. For more detailed logging, update `config/dev.exs`:

```elixir
# Enable debug logging
config :logger, level: :debug
```

### Database Inspection

```bash
# Connect to PostgreSQL directly
psql -h postgres -U postgres -d gatherly_dev
```

## Git Workflow with Containers

The container environment automatically manages git operations:

1. **Automatic Commits**: Changes are automatically committed to a container branch
2. **Branch Naming**: Container branches follow the pattern `container-use/environment-name/random-id`
3. **Merging Changes**: To merge container changes to main:

```bash
# On your local machine
git fetch origin container-use/gatherly-debug/charmed-burro
git checkout main
git merge container-use/gatherly-debug/charmed-burro
git push origin main
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**: If port 4000 is busy, the container will assign a different external port
2. **Database Connection**: Ensure PostgreSQL service is running within the container
3. **Asset Issues**: Run `mix assets.setup` to reinstall asset tools
4. **Dependency Issues**: Clear deps with `mix deps.clean --all` then `mix deps.get`

### Reset Environment

If you need to completely reset the environment:

1. Stop the container
2. Remove the container and associated volumes
3. Restart with a fresh environment

### Checking Service Status

```bash
# Check if PostgreSQL is accessible
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.create'

# Verify tool versions
bash -c '. /opt/asdf.sh && elixir --version'
bash -c '. /opt/asdf.sh && node --version'
```

## Performance Considerations

- **File Watching**: The container watches for file changes, but large numbers of files can impact performance
- **Database**: PostgreSQL runs in a separate container service for better isolation
- **Assets**: Asset compilation happens automatically but can be disabled if needed
- **Memory**: The container environment requires sufficient memory for Erlang VM, PostgreSQL, and asset watchers

## Next Steps

Once your development environment is running:

1. Explore the existing Phoenix application structure
2. Review the test suite with `mix test`
3. Check code quality with `mix credo`
4. Start implementing features following the project roadmap
5. Use the collaborative workflow to share your progress

For more information about the project architecture and roadmap, see:
- [Project Overview](Project.md)
- [Project Landscape](Landscape.md)
