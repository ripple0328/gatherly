# 🛠️ Development Guide

This guide explains how to run Gatherly locally using the container workflow powered by Dagger.
It assumes a Unix-like environment.

## Prerequisites

- [Docker](https://www.docker.com/)
- [mise](https://github.com/jdx/mise) for managing tool versions

After cloning the repository run:

```bash
mise install
```

This installs the Elixir and Erlang versions defined in `mise.toml`.

## Tool Versions

```
elixir 1.18.4-otp-28
erlang 28.0.2
```

## Starting the Environment

Use the optimized Dagger workflow to launch the development environment:

```bash
mix dagger.up          # smart setup + start server
```

The first run downloads containers and installs dependencies. The command uses smart detection to skip unnecessary steps on subsequent runs. Phoenix runs in the foreground at [http://localhost:4000](http://localhost:4000).

**Stop the server:** Press `Ctrl+C`

## Day-to-Day Workflow

1. **Start development** – `mix dagger.up` (smart setup + server)
2. **Edit code** – changes reload automatically in the foreground server
3. **Stop server** – `Ctrl+C`
4. **Quality checks** – `mix dagger.quality --fix`
5. **Run tests** – `mix dagger.test`
6. **Commit & push** – `git commit -am "msg"` then `git push`

## Additional Commands

```bash
# Development
mix dagger.up --port 3000   # custom port
mix dagger.up --force-setup # force full setup
mix dagger.dev.shell --iex  # interactive shell in container

# Database
mix dagger.db.reset         # reset database
mix dagger.db.create        # create database
mix dagger.db.migrate       # run migrations

# Quality & Testing
mix dagger.quality          # format + lint + security
mix dagger.test             # run tests
mix dagger.ci               # full CI pipeline locally

# Utilities
mix dagger.clean            # clean build artifacts
mix dagger.setup            # setup dependencies only
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

- **Port in use** – stop any previous Phoenix instance or change the port with `PHX_SERVER_PORT`
- **Database connection** – ensure Docker is running and containers are started
- **Outdated dependencies** – run `mix dagger.clean` then `mix dagger.up --force-setup` to rebuild from scratch

For more details about the project, see [Project Overview](Project.md) and [Project Landscape](Landscape.md).
