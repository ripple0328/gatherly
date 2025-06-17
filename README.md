# Gatherly

<div align="center">
  <img src="priv/static/images/logo.svg" alt="Gatherly Logo" width="200" />
  <p><em>Effortless Event Planning Made Collaborative</em></p>
  
  [![CI Status](https://github.com/ripple0328/gatherly/workflows/CI/badge.svg)](https://github.com/ripple0328/gatherly/actions/workflows/ci.yml)
  [![Code Quality](https://img.shields.io/badge/code%20quality-credo-brightgreen)](https://github.com/rrrene/credo)
  [![Deploy Status](https://github.com/ripple0328/gatherly/workflows/Deploy%20to%20Fly.io/badge.svg)](https://github.com/ripple0328/gatherly/actions/workflows/deploy.yml)
</div>

Gatherly is a collaborative, AI-powered event planning platform built with Phoenix LiveView and DaisyUI. Transform your group events from chaotic planning to seamless experiences with intelligent coordination, real-time collaboration, and smart logistics.

## 🌍 Live App
- **Production**: https://gatherly.qingbo.us ✅

## 🚀 Development

### Prerequisites
- Elixir 1.18+ and Erlang 27+
- PostgreSQL (for local development)
- Docker (for containerized workflows)
- [Dagger CLI](https://dagger.io) (for CI/CD workflows)

### Quick Start
```bash
# Install dependencies
mix setup

# Start Phoenix server
mix phx.server

# Visit localhost:4000
```

### Containerized Development (Recommended)

#### Option 1: Mix Tasks (Most Developer Friendly)
```bash
# Install Dagger CLI
curl -L https://github.com/dagger/dagger/releases/latest/download/dagger_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/').tar.gz | tar -xz && sudo mv dagger /usr/local/bin/

# Run containerized development tasks
mix dagger.deps              # Install dependencies in container
mix dagger.test              # Run tests with PostgreSQL in container
mix dagger.quality           # Code quality checks (formatting, Credo, Dialyzer)
mix dagger.security          # Security vulnerability scanning
mix dagger.build             # Build production release

# Complete CI pipeline locally (matches GitHub Actions exactly)
mix dagger.ci                # Full pipeline
mix dagger.ci --fast         # Skip slower checks for quick feedback
mix dagger.ci --export ./release  # Export built release
```

#### Option 2: Direct Dagger CLI
```bash
# Alternative for CI environments or cross-language teams
dagger call deps --source=. sync
dagger call test --source=.
dagger call quality --source=.
dagger call build --source=. sync
```

#### Option 3: Container-use (Via Claude Code)
```bash
# Create development environment
mcp__container-use__environment_open --source . --name gatherly-dev

# Inside container
mix deps.get
mix phx.server
```

### Local vs Containerized Development
- **Local** (`mix test`): Fast iteration, debugging
- **Containerized** (`mix dagger.test`): CI-identical environment, database included
- **Hybrid approach**: Use local for development, containerized before pushing

## 🎨 UI Framework

Built with **DaisyUI** + TailwindCSS for consistent, beautiful components:
- Custom "gatherly" theme with brand colors
- Responsive navbar, hero sections, cards
- Production-ready styling

## 🛠 Deployment

### Fly.io Production
```bash
# Deploy to production
flyctl deploy

# Check app status
flyctl status

# View logs
flyctl logs
```

### MCP Integration
For Claude Code users, MCP servers are configured for seamless management:
```bash
# Setup MCP servers (one-time)
claude mcp add flyio flyctl
claude mcp add gatherly-fs npx "@modelcontextprotocol/server-filesystem" "/path/to/gatherly"
claude mcp add github npx "@modelcontextprotocol/server-github"

# List configured servers
claude mcp list
```

## 📋 Architecture

- **Framework**: Phoenix LiveView 1.7+
- **Database**: PostgreSQL (Fly.io managed)
- **Styling**: DaisyUI + TailwindCSS
- **CI/CD**: Dagger with Elixir SDK for containerized pipelines
- **Deployment**: Fly.io with Docker
- **Development**: Multiple options (local, containerized, container-use)

## 🔧 Key Features

### Event Planning
- Real-time collaborative event planning
- RSVP management and proposal voting
- Responsive UI with DaisyUI components

### Development & Deployment
- **Containerized CI/CD**: Dagger pipeline with Elixir SDK
- **Developer Experience**: Mix tasks for local containerized workflows
- **Production Deployment**: Fly.io with zero-downtime updates
- **Quality Assurance**: Automated formatting, static analysis, type checking
- **Security Scanning**: Dependency vulnerability and retirement checks
- **Database Testing**: Automated PostgreSQL integration testing
- **MCP Integration**: AI-assisted development with Claude Code

## Learn More

- **Phoenix Framework**: https://www.phoenixframework.org/
- **DaisyUI Components**: https://daisyui.com/components/
- **Dagger CI/CD**: https://dagger.io/ & [Elixir SDK](https://dagger.io/blog/dagger-elixir-sdk)
- **Fly.io Deployment**: https://fly.io/docs/elixir/
- **Container-use**: https://github.com/dagger/container-use
