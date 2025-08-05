# Gatherly

A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.

## 🚀 Getting Started

### Prerequisites
- Docker (for containerized development)
- Git
- [mise](https://github.com/jdxcode/mise)
### Containerized Development (Recommended)

**One-command setup:**
```bash
git clone https://github.com/yourusername/gatherly.git
cd gatherly
mix dagger.up  # Complete environment setup + start server
```

Visit [`localhost:4000`](http://localhost:4000) to see your app running.

### Development Workflows

```bash
# Daily development
mix dagger.up               # Smart startup (setup + server)
mix dagger.dev.shell --iex  # Interactive development

# Database operations
mix dagger.db.reset         # Fresh database
mix dagger.db.shell         # Database debugging

# Code quality
mix dagger.quality --fix    # Format + lint + security
mix dagger.test             # Run tests

# CI verification (run exact same pipeline as CI)
mix dagger.ci               # Complete CI pipeline locally
mix dagger.deploy          # Build and push image to Fly.io (tagged with commit SHA)
```

**📖 For detailed development workflows, see [Dagger Integration Guide](lib/gatherly/dagger/README.md)**

### Tool Versions

- **Elixir**: 1.18.4-otp-28
- **Erlang/OTP**: 28.0.2
- **PostgreSQL**: 17.5
- **Phoenix**: 1.8.0-rc.4

All managed automatically in containers - no local installation needed.

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
