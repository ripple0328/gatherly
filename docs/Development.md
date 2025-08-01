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

Use the provided Dagger workflow to launch the development containers and services:

```bash
mix dagger.dev         # setup + start services
```

The first run downloads the containers and installs dependencies. Once complete,
Phoenix is available at [http://localhost:4000](http://localhost:4000).

To attach an interactive shell inside the container use:

```bash
mix dagger.dev.shell --iex
```

## Day-to-Day Workflow

1. **Start services** – `mix dagger.dev.start` if containers are already built
2. **Edit code** – changes reload automatically
3. **Database reset** (if needed) – `mix dagger.db.reset`
4. **Quality checks** – `mix dagger.quality --fix`
5. **Run tests** – `mix dagger.test`
6. **Commit & push** – `git commit -am "msg"` then `git push`

CI on GitHub Actions runs the same Dagger tasks for lint, test, and security.

## Additional Commands

```bash
mix dagger.dev.stop     # stop all services
mix dagger.ci           # run the full CI pipeline locally
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
- **Outdated dependencies** – run `mix dagger.reset` to rebuild from scratch

For more details about the project, see [Project Overview](Project.md) and [Project Landscape](Landscape.md).
