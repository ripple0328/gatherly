# CI/CD Pipeline with Fly.io Deployment

This document describes the complete CI/CD pipeline for Gatherly, including automated testing, building, and deployment to Fly.io.

## Overview

The Gatherly project uses a modern CI/CD pipeline with:
- **Dagger** for containerized, reproducible builds
- **GitHub Actions** for automation
- **Fly.io** for hosting both staging and production environments
- **Elixir/Phoenix** with comprehensive testing

## Pipeline Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Development   │    │   CI Pipeline    │    │   Deployment    │
│                 │    │                  │    │                 │
│ • Local Testing │───▶│ • Quality Checks │───▶│ • Production    │
│ • Mix Tasks     │    │ • Security Scan  │    │ • Health Checks │
│ • Dagger Local  │    │ • Full Tests     │    │ • Rollback      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Workflows

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` branch only
- Called by other workflows

**Steps:**
1. **Dependencies**: Install and cache Elixir/Phoenix dependencies
2. **Quality Checks**: Run code formatting, Credo linting, Dialyzer type checking
3. **Security Scanning**: Check for vulnerabilities with `mix deps.audit` and `hex.audit`
4. **Testing**: Full test suite with containerized PostgreSQL database
5. **Building**: Production release with compiled assets
6. **Artifact Export**: Package release for deployment

**Outputs:**
- Build artifacts ready for deployment
- Test results and coverage reports
- Security scan results

### 2. Deployment Workflow (`.github/workflows/deploy.yml`)

**Triggers:**
- Push to `main` → Production deployment
- Manual workflow dispatch for production deployment

**Jobs:**

#### CI for Deployment
- Runs complete CI pipeline
- Creates timestamped build artifacts
- Only runs if not manually skipped

#### Deploy to Production
- **Environment**: `gatherly.fly.dev` + `gatherly.qingbo.us`
- **Config**: `fly.toml`
- **Health Checks**: Multi-domain availability testing
- **Triggered by**: Push to `main` branch
- **Requires**: Quality gate approval

#### Quality Gate
- Additional quality checks for production deployments
- Must pass before production deployment proceeds

#### Rollback Capability
- Manual rollback to previous version
- Available for production environment  
- Uses Fly.io release history

## Environment Configuration

### Production Environment
```toml
# fly.toml
app = "gatherly"
primary_region = "sjc"

[env]
  PHX_HOST = "gatherly.qingbo.us"
  PORT = "8080"

[deploy]
  release_command = "/app/bin/migrate"

[[vm]]
  memory = "1gb"
  cpu_kind = "shared"
  cpus = 1
```

## Local Development Workflow

### Primary: Mix Tasks
```bash
# Individual components
mix dagger.deps      # Install dependencies
mix dagger.quality   # Code quality checks
mix dagger.security  # Security scanning
mix dagger.test      # Run tests with database
mix dagger.build     # Build production release

# Complete pipeline
mix dagger.ci                    # Full CI pipeline
mix dagger.ci --fast            # Skip slower checks
mix dagger.ci --export ./dist   # Export built artifacts
```

### Alternative: Direct Dagger CLI
```bash
dagger call deps --source=. sync
dagger call quality --source=.
dagger call security --source=.
dagger call test --source=.
dagger call build --source=. sync
```

## Required Secrets

Configure these secrets in your GitHub repository:

### Fly.io Deployment
- `FLY_API_TOKEN`: Fly.io API token for deployments

### Optional (for enhanced features)
- `DAGGER_CLOUD_TOKEN`: Dagger Cloud integration
- `SENTRY_DSN`: Error tracking (if using Sentry)

## Deployment Process

### Automatic Deployments

1. **Production Deployment**:
   ```bash
   git push origin main
   ```
   - Triggers quality gate
   - Runs full CI pipeline
   - Deploys to production
   - Runs comprehensive health checks

### Manual Deployments

1. **Via GitHub Actions UI**:
   - Go to Actions → Deploy to Fly.io
   - Click "Run workflow"
   - Select environment and options

2. **Emergency Rollback**:
   - Use workflow dispatch
   - Automatic rollback to previous version

## Health Checks

### Production
- Multi-domain health checks
- Extended timeout (45 seconds)
- Both `gatherly.fly.dev` and `gatherly.qingbo.us`
- DNS propagation tolerance

## Monitoring and Observability

### Deployment Status
- GitHub Actions provides real-time deployment status
- Fly.io dashboard shows application metrics
- Health check results in workflow logs

### Post-Deployment Verification
```bash
# Check application status
curl -f https://gatherly.fly.dev/
curl -f https://gatherly.qingbo.us/

# Fly.io application status
flyctl status --app gatherly
flyctl logs --app gatherly
```

## Troubleshooting

### Common Issues

1. **Deployment Failures**:
   - Check Fly.io application logs: `flyctl logs --app gatherly`
   - Verify secrets are configured correctly
   - Ensure database migrations completed

2. **Health Check Failures**:
   - Application may still be starting (increase timeout)
   - DNS propagation issues for custom domains
   - Check Phoenix application configuration

3. **Build Failures**:
   - Review Dagger CI logs
   - Check for dependency issues
   - Verify test database connectivity

### Manual Deployment (Emergency)
```bash
# Direct deployment (requires flyctl setup)
flyctl deploy --app gatherly

# Check deployment status
flyctl status --app gatherly

# View recent logs
flyctl logs --app gatherly --region sjc
```

## Performance Optimization

### Dagger Caching
- Dependencies are cached between builds
- Docker layer caching for faster rebuilds
- Parallel execution where possible

### Fly.io Optimization
- Single region deployment (SJC)
- Auto-stop/start machines for cost efficiency
- Shared CPU for development workloads

### CI/CD Optimization
- Skip builds on documentation-only changes
- Parallel test execution
- Artifact reuse between deployment stages

## Security Considerations

### Secrets Management
- All sensitive data stored in GitHub Secrets
- No hardcoded credentials in repository
- Fly.io API tokens with minimal required permissions

### Deployment Security
- Production deployments require environment approval
- Quality gates prevent broken deployments
- Automatic rollback capability

### Application Security
- Regular security scanning in CI
- Dependency vulnerability checks
- HTTPS enforcement

### Best Practices

### Development Workflow
1. Work directly on `main` branch
2. Run `mix dagger.ci --fast` locally for validation
3. Commit and push to `main` (triggers CI and production deployment)

### Deployment Strategy
- Thorough local testing before production deployment
- Production deployments only from `main`
- Monitor deployment health checks
- Keep rollback capability ready

### Monitoring
- Watch GitHub Actions for deployment status
- Monitor Fly.io application metrics
- Set up alerts for critical failures

## Future Enhancements

### Planned Improvements
- Blue-green deployments
- Canary releases
- Enhanced monitoring with Prometheus
- Database migration rollback strategies
- Multi-region deployment

### Integration Opportunities
- Slack notifications for deployments
- Performance monitoring integration
- Automated security scanning reports
- Cost optimization alerts

---

This CI/CD pipeline provides a robust, automated deployment process while maintaining the flexibility for manual interventions when needed. The combination of Dagger's containerized builds and Fly.io's deployment platform ensures consistent, reliable deployments across all environments.