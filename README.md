# Gatherly

<div align="center">
  <img src="priv/static/images/logo.svg" alt="Gatherly Logo" width="200" />
  <p><em>Effortless Event Planning Made Collaborative</em></p>
</div>

Gatherly is a collaborative, AI-powered event planning platform built with Phoenix LiveView and DaisyUI. Transform your group events from chaotic planning to seamless experiences with intelligent coordination, real-time collaboration, and smart logistics.

## 🌍 Live App

- **Production**: https://gatherly.fly.dev ✅
- **Custom Domain**: https://gatherly.qingbo.us ✅

## 🚀 Development

### Local Development
```bash
# Install dependencies
mix setup

# Start Phoenix server
mix phx.server

# Visit localhost:4000
```

### Container Development (Recommended)
Using container-use for isolated, reproducible environments:
```bash
# Create development environment (via Claude Code)
mcp__container-use__environment_open --source . --name gatherly-dev

# Inside container
mix deps.get
mix phx.server
```

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
- **Deployment**: Fly.io with Docker
- **Development**: Container-use for isolation

## 🔧 Key Features

- Real-time collaborative event planning
- RSVP management and proposal voting
- Responsive UI with DaisyUI components
- Production deployment with zero-downtime updates
- MCP integration for AI-assisted development

## Learn More

- **Phoenix Framework**: https://www.phoenixframework.org/
- **DaisyUI Components**: https://daisyui.com/components/
- **Fly.io Deployment**: https://fly.io/docs/elixir/
- **Container-use**: https://github.com/dagger/container-use
