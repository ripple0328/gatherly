# Gatherly

A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.

## 🚀 Getting Started

### Prerequisites
- Docker (or OrbStack/Colima) running
- Git
- Optional: `just` task runner (recommended)
  - macOS: `brew install just`
  - Linux: your distro package manager

### Containerized Development (Recommended)

No local Elixir/Erlang/PostgreSQL required. Everything runs in containers.

```bash
git clone https://github.com/yourusername/gatherly.git
cd gatherly

# Copy and fill env
cp .env.example .env
# Generate secrets and paste into .env
# mix phx.gen.secret

# One-time setup (installs deps, prepares DB)
just dev-setup

# Start the Phoenix server (with live reload)
just dev-server
```

Visit [`http://localhost:4000`](http://localhost:4000).

If you see Docker errors, ensure your Docker backend is running (Docker Desktop, OrbStack, Colima).

### Common tasks

```bash
# Shell and services
just dev-shell            # IEx inside the container
just services-up          # Start all dev services
just services-status      # Show service status
just services-down        # Stop all services

# Database
just db-migrate           # Run migrations
just db-rollback          # Rollback last migration
just db-reset             # Drop/create/migrate/seed
just db-shell             # psql into dev DB

# Quality & tests
just format               # mix format (in container)
just lint                 # Credo (and Dialyzer if configured)
just test                 # Run test suite
just quality              # format + lint + dialyzer
```

Advanced, CI-ready workflows are available via Dagger. See [Dagger Integration Guide](lib/gatherly/dagger/README.md).

### Secrets management
- Copy `.env.example` to `.env` and set required secrets
- Dev containers load env from `.env` automatically (`env_file`)
- Production: use platform secret store (e.g., Fly.io `fly secrets`) and set envs like `SECRET_KEY_BASE`, `TOKEN_SIGNING_SECRET`, `DATABASE_URL`

### Tool Versions

- **Elixir**: 1.18.4-otp-28
- **Erlang/OTP**: 28.0.2
- **PostgreSQL**: 17.5
- **Phoenix**: 1.8.x

All managed in containers — no host installs required.

## 🛠 Development

### Key Features
- **🐳 Containerized**: Consistent environments, no local dependencies
- **🔄 Hot Reloading**: Code changes automatically detected and reloaded
- **🗄️ Managed Database**: PostgreSQL runs as containerized service
- **⚡ Fast CI**: Run complete CI pipeline locally before pushing
- **🔧 Asset Pipeline**: TailwindCSS + esbuild handled by Phoenix (no Node.js required)

### Branching Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

### Code Standards
- Follow [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Use `mix dagger.quality --fix` for automated formatting and linting
- Verify changes with `mix dagger.ci` before pushing

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Work in the containerized development environment
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

For detailed project roadmap and technical documentation, see [docs/project.md](docs/project.md).
