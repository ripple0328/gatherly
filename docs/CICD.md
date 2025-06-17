# CI/CD Pipeline Documentation

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the Gatherly project.

## Overview

The Gatherly project uses GitHub Actions for automated CI/CD with the following pipeline stages:

1. **Dependencies** - Cache and install project dependencies
2. **Code Quality** - Formatting, static analysis, and type checking
3. **Testing** - Automated test suite with database setup
4. **Security** - Vulnerability and package auditing
5. **Build** - Application compilation and release building
6. **Deploy** - Automated deployment to fly.io

## Workflows

### CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop`

**Jobs:**

#### 1. Dependencies
- Caches Elixir dependencies and compiled code
- Installs and compiles dependencies for faster subsequent jobs
- Uses cache keys based on `mix.lock` and `.tool-versions`

#### 2. Code Quality
- **Format Check**: `mix format --check-formatted`
- **Static Analysis**: `mix credo --strict --format github`
- **Type Checking**: `mix dialyzer --format github`
- Caches Dialyzer PLT files for performance

#### 3. Testing
- Sets up PostgreSQL 15 service for database tests
- Creates and migrates test database
- Runs full test suite with coverage: `mix test --cover`
- Uploads coverage reports to Codecov

#### 4. Security
- **Dependency Audit**: `mix deps.audit`
- **Package Audit**: `mix hex.audit`
- Checks for known security vulnerabilities

#### 5. Build
- Sets up Node.js 24.2.0 for asset compilation
- Installs production dependencies
- Builds and minifies assets: `mix assets.deploy`
- Compiles application in production mode
- Creates release build
- Uploads build artifacts

### Deploy Workflow (`.github/workflows/deploy.yml`)

**Triggers:**
- Push to `main` branch (production)
- Push to `develop` branch (staging)
- Manual workflow dispatch with environment selection

**Environments:**

#### Staging
- **URL**: https://gatherly-staging.fly.dev
- **App**: `gatherly-staging`
- **Config**: `fly.staging.toml`
- **Auto-deploys**: On `develop` branch pushes

#### Production
- **URL**: https://gatherly.fly.dev
- **Custom Domain**: https://gatherly.qingbo.us
- **App**: `gatherly`
- **Config**: `fly.toml`
- **Quality Gate**: Requires all CI checks to pass
- **Health Checks**: Post-deployment verification

## Environment Configuration

### Staging Environment
- **Memory**: 1GB
- **CPU**: 1 shared CPU
- **Auto-scaling**: Auto-stop when idle, auto-start on request
- **Min machines**: 0 (cost optimization)

### Production Environment
- **Memory**: As configured in `fly.toml`
- **Custom domain**: gatherly.qingbo.us
- **Health monitoring**: Automated checks post-deployment

## Required Secrets

Configure these secrets in your GitHub repository:

| Secret | Purpose | Where to Get |
|--------|---------|--------------|
| `FLY_API_TOKEN` | Deploy to fly.io | `flyctl auth token` |
| `CODECOV_TOKEN` | Upload coverage | codecov.io project settings |

### Setting up Fly.io Token

1. Install fly.io CLI: `curl -L https://fly.io/install.sh | sh`
2. Login: `flyctl auth login`
3. Generate token: `flyctl auth token`
4. Add to GitHub Secrets as `FLY_API_TOKEN`

## Caching Strategy

### Dependencies Cache
- **Key**: `deps-{os}-{mix.lock hash}-{.tool-versions hash}`
- **Paths**: `deps/`, `_build/test/`
- **Invalidation**: When dependencies change

### PLT Cache (Dialyzer)
- **Key**: `plt-{os}-{mix.lock hash}-{.tool-versions hash}`
- **Paths**: `priv/plts/`
- **Purpose**: Speed up type checking

### Build Cache
- **Key**: `build-deps-{os}-{mix.lock hash}-{.tool-versions hash}`
- **Paths**: `deps/`, `_build/prod/`
- **Purpose**: Faster production builds

## Quality Gates

### Pre-deployment Checks (Production)
All of these must pass before production deployment:

1. ✅ Code formatting (`mix format --check-formatted`)
2. ✅ Static analysis (`mix credo --strict`)
3. ✅ Type checking (`mix dialyzer`)
4. ✅ Test suite (`mix test`)
5. ✅ Security audit (`mix deps.audit`, `mix hex.audit`)
6. ✅ Successful build (`mix release`)

### Development Workflow
- **Pull Requests**: All CI checks must pass
- **Main Branch**: Quality gate + successful deployment
- **Develop Branch**: CI checks + staging deployment

## Manual Deployment

You can trigger deployments manually:

### Via GitHub UI
1. Go to Actions → Deploy to Fly.io
2. Click "Run workflow"
3. Select target environment
4. Click "Run workflow"

### Via CLI
```bash
# Production
flyctl deploy --app gatherly

# Staging  
flyctl deploy --config fly.staging.toml --app gatherly-staging
```

## Monitoring and Alerts

### Build Status
- Check GitHub Actions tab for build status
- Failed builds prevent deployment
- Notifications via GitHub (configurable)

### Deployment Health
- Automated health checks post-deployment
- Verifies both primary and custom domain
- Fails deployment if health checks fail

### Coverage Tracking
- Codecov integration tracks test coverage
- Coverage reports on pull requests
- Historical coverage trends

## Troubleshooting

### Common Issues

#### Cache Issues
```bash
# Clear caches by updating cache keys or:
# - Increment version in .tool-versions
# - Update dependency in mix.exs
```

#### Failed Deployments
```bash
# Check fly.io logs
flyctl logs --app gatherly

# Check deployment status
flyctl status --app gatherly

# Manual deployment
flyctl deploy --app gatherly
```

#### Test Failures
```bash
# Run tests locally with same setup
export MIX_ENV=test
mix deps.get
mix ecto.create
mix ecto.migrate
mix test
```

#### PLT Build Failures
```bash
# Rebuild PLT locally
rm -rf priv/plts
mix dialyzer --plt
```

### Debug Commands

```bash
# Local quality check (matches CI)
mix quality.ci

# Check formatting
mix format --check-formatted

# Run Credo with GitHub format
mix credo --strict --format github

# Test with coverage
mix test --cover

# Build production release
MIX_ENV=prod mix release
```

## Performance Optimizations

### Parallel Jobs
- Dependencies, quality, and security checks run in parallel
- Testing runs independently after dependencies
- Build only starts after quality and tests pass

### Caching
- Dependencies cached across jobs
- PLT files cached to speed up Dialyzer
- Node.js dependencies cached for asset building

### Conditional Deployments
- Staging: Only on `develop` branch
- Production: Only on `main` branch with quality gate
- Manual deployments available for both environments

## Security Considerations

### Secrets Management
- API tokens stored as GitHub Secrets
- No secrets in repository code
- Environment-specific configurations

### Dependency Security
- Automated security audits on every build
- Retired package detection
- Dependency vulnerability scanning

### Deploy Security
- Quality gates prevent deploying broken code
- Health checks verify successful deployments
- Rollback capability via fly.io

## Future Enhancements

### Planned Improvements
- [ ] Database migration checks
- [ ] Performance regression testing
- [ ] Automated security scanning
- [ ] Slack/Discord notifications
- [ ] Blue-green deployments
- [ ] Automated rollback on health check failures

### Monitoring Integration
- [ ] Application performance monitoring
- [ ] Error tracking integration
- [ ] Log aggregation setup
- [ ] Uptime monitoring

## Getting Help

### Resources
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fly.io Documentation](https://fly.io/docs/)
- [Elixir CI Best Practices](https://github.com/dwyl/learn-elixir/blob/master/ci.md)

### Support
- Check GitHub Actions logs for build failures
- Review fly.io dashboard for deployment issues
- Consult team for CI/CD questions
- Update this documentation as the pipeline evolves