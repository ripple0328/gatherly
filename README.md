<div align="center">
  <h1>Gatherly</h1>

  [![CI/CD Pipeline](https://github.com/ripple0328/gatherly/actions/workflows/ci.yml/badge.svg)](https://github.com/ripple0328/gatherly/actions/workflows/ci.yml)
  [![Elixir](https://img.shields.io/badge/elixir-1.18.4-purple.svg)](https://elixir-lang.org)
  [![Phoenix](https://img.shields.io/badge/phoenix-1.8-orange.svg)](https://phoenixframework.org)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
  [![Live Demo](https://img.shields.io/badge/demo-gatherly.qingbo.us-green.svg)](https://gatherly.qingbo.us)

  <p><em>A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.</em></p>
</div>

## 🌟 Main Features

- **Event Creation & Management**: Create and organize collaborative events with RSVP tracking
- **Proposal & Voting System**: Propose and vote on event dates, times, and locations
- **Logistics Coordination**: Collaborative task and item management boards
- **Real-time Updates**: Live collaboration with Phoenix LiveView
- **PWA-First Design**: Mobile-optimized progressive web application
- **Authentication Integration**: Secure login with Google OAuth and magic links

## 📚 Documentation

- 📋 **[Project Roadmap](./docs/Project.md)** - Development phases and feature timeline
- 🛠️ **[Development Guide](./docs/Development.md)** - Local development setup and workflow
- ⚡ **[Development Workflow](./docs/DEVELOPMENT_WORKFLOW.md)** - Enhanced developer tools and commands
- 🔄 **[CI/CD Documentation](./docs/CICD.md)** - Continuous integration and deployment guide
- 🗺️ **[Technical Landscape](./docs/Landscape.md)** - Architecture overview and technical decisions

## 🌐 Live Demo

Visit the live application at **[gatherly.qingbo.us](https://gatherly.qingbo.us)**

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

# One-time setup
cp .env.example .env
just setup

# Start development
just dev

# Essential commands
just menu               # Show essential commands
just test              # Run tests  
just check             # Format + lint + test
just iex               # Interactive Elixir shell
```

Visit [`http://localhost:4000`](http://localhost:4000).

If you see Docker errors, ensure your Docker backend is running (Docker Desktop, OrbStack, Colima).

### Essential Development Commands

```bash
# Core workflow
just setup              # Initial project setup
just dev                # Start development server
just iex                # Interactive Elixir shell
just test               # Run tests
just test-watch         # Watch tests continuously

# Database
just db-reset           # Reset database to clean state
just db-console         # Open database console

# Code quality
just format             # Format code only (fast)
just check              # Format + lint + test (full check)
just coverage           # Generate test coverage report

# Utilities
just doctor             # Environment health check
just menu               # Show all essential commands
```

### Deployment

```bash
just deploy             # Deploy to production (runs checks first)
```

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

We welcome contributions! Please check out:
1. [Development Guide](./docs/Development.md) for local setup and workflow
2. [GitHub Issues](https://github.com/ripple0328/gatherly/issues) for feature requests and bugs
3. [Project Roadmap](./docs/Project.md) for current development priorities

### Quick Contributing Steps
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Work in the containerized development environment (`just setup`)
4. Run quality checks (`just check`) and tests (`just test`)
5. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
6. Push to the branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

For detailed project roadmap and technical documentation, see [docs/project.md](docs/project.md).
