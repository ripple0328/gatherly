# Gatherly Dagger Integration

A comprehensive containerized development and CI/CD workflow system using Dagger with Elixir SDK.

## Architecture

```
lib/gatherly/dagger/
├── client.ex          # Dagger client wrapper
├── workflow.ex        # Base workflow behavior
├── containers.ex      # Container definitions
└── db_helper.ex       # Database task helpers

lib/mix/tasks/dagger/
├── setup.ex           ✅ Environment setup
├── clean.ex           ✅ Cleanup artifacts
├── reset.ex           ✅ Complete reset
├── format.ex          ✅ Code formatting
├── lint.ex            ✅ Linting (Credo + Dialyzer)
├── security.ex        ✅ Security audits
├── test.ex            ✅ Test execution
├── db/
│   ├── create.ex      ✅ Database creation
│   ├── migrate.ex     ✅ Run migrations
│   ├── rollback.ex    ✅ Rollback migrations
│   ├── seed.ex        ✅ Run seeds
│   ├── reset.ex       ✅ Complete DB reset
│   └── shell.ex       ✅ Database shell
├── dev/
│   ├── start.ex       ✅ Start dev environment
│   ├── stop.ex        ✅ Stop dev environment
│   └── shell.ex       ✅ Interactive shell
└── workflows/
    ├── ci.ex          ✅ CI pipeline
    ├── quality.ex     ✅ Quality checks
    └── dev.ex         ✅ Dev environment setup
```

## Quick Start

### Development Workflow
```bash
# Complete dev setup
mix dagger.dev                    # Clean + setup + start

# Individual operations
mix dagger.setup                  # Install deps, compile
mix dagger.dev.start             # Start dev services
mix dagger.dev.shell --iex       # Interactive shell
mix dagger.db.reset              # Fresh database
```

### Quality & Testing
```bash
# Complete quality check
mix dagger.quality               # Format + lint + security

# Individual checks
mix dagger.format --check-formatted
mix dagger.lint --strict
mix dagger.security
mix dagger.test --cover
```

### CI/CD Pipeline
```bash
# Complete CI pipeline
mix dagger.ci                    # Full CI: setup → quality → test

# Environment-specific
mix dagger.ci --env=test
mix dagger.ci --skip-dialyzer    # Faster CI
```

## Key Features

### 🐳 **Containerized Everything**
- Consistent environments across team
- No local dependencies required (except Docker)
- Production parity in development

### 🔧 **Wraps Phoenix Tasks**
- Database tasks delegate to `mix ecto.*`
- All Phoenix task options pass through
- No reimplementation of existing logic

### 🏗️ **Composable Architecture**
- Atomic tasks for individual operations
- Composite workflows for common flows
- Extensible with new tasks

### 🚀 **Developer Experience**
- One command setup: `mix dagger.dev`
- Fast iteration with proper caching
- Clear error messages and progress indicators

## Container Services

### Elixir Development Container
- **Base**: `elixir:1.18.4-otp-28`
- **Tools**: Build tools, PostgreSQL client, inotify
- **Source**: Mounted from host for hot reloading

### PostgreSQL Container  
- **Version**: `postgres:17.5`
- **Databases**: `gatherly_dev`, `gatherly_test`
- **Network**: Accessible as `postgres:5432`

## Task Categories

### Environment Management
- `setup` - Install dependencies, compile
- `clean` - Remove build artifacts  
- `reset` - Clean + setup from scratch

### Database Operations
- `db.create/migrate/rollback/seed/reset` - Standard DB operations
- `db.shell` - Interactive PostgreSQL shell
- All tasks start PostgreSQL container automatically

### Development Services
- `dev.start/stop` - Manage development services
- `dev.shell` - Access container shell (IEx/bash/psql)

### Code Quality
- `format` - Code formatting (with `--check-formatted`)
- `lint` - Credo + Dialyzer static analysis
- `security` - Vulnerability scanning
- `test` - Test execution with coverage

### Workflows (Composite)
- `ci` - Complete CI pipeline
- `quality` - All quality checks
- `dev` - Complete dev environment setup

## Usage Examples

### New Developer Onboarding
```bash
git clone <repo>
cd gatherly
mix dagger.dev    # One command - everything ready!
```

### Pre-commit Workflow
```bash
mix dagger.quality --fix    # Auto-fix formatting
mix dagger.test            # Quick test run
```

### CI/CD Integration
```bash
# .github/workflows/ci.yml
- run: mix dagger.ci --env=test --skip-dialyzer
```

### Database Development
```bash
mix dagger.db.reset              # Fresh DB
mix dagger.db.shell              # Debug queries
mix dagger.db.migrate --step=1   # Careful migrations
```

## Benefits

### For Individual Developers
- **No Setup**: Just Docker + Elixir, everything else containerized
- **Consistency**: Same environment across machines/OS
- **Isolation**: No conflicts with other projects

### For Teams
- **Onboarding**: New developers productive in minutes
- **CI Parity**: Local development = CI environment
- **Debugging**: Reproduce CI issues locally

### For Operations
- **Reproducible**: Exact same containers in all environments
- **Versioned**: Infrastructure as code
- **Scalable**: Easy to add new services/databases

## Next Steps

This implementation provides a solid foundation. Consider extending with:

- Asset compilation tasks (`dagger.assets.*`)
- Deployment workflows (`dagger.deploy`)
- Performance testing (`dagger.perf`)
- Documentation generation (`dagger.docs`)
- Custom development databases (Redis, etc.)