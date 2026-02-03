# CI/CD Setup

Gatherly uses GitHub Actions to lint, test and deploy the application using containerized `just` tasks and the Fly.io CLI.

## Pipeline Overview

1. **Lint** – `just lint`
2. **Test** – `just test`
3. **Types** – `just dialyzer`
4. **Deploy** – Fly.io deployment on pushes to `main` via `just deploy`

The workflow is defined in `.github/workflows/ci.yml` and runs on:
- Every push to the `main` branch
- Every pull request to the `main` branch

## Running CI Locally

Use the composite workflow to mirror CI on your machine:

```bash
just ci
```

## Jobs

### Lint Job

Runs code quality checks:
- `mix format --check-formatted` - Ensures code is properly formatted
- `mix credo --strict` - Static code analysis
- `mix dialyzer` - Type checking and analysis

### Test Job

Runs the test suite:
- Sets up PostgreSQL 17.5 service
- Installs dependencies
- Compiles code with warnings as errors
- Sets up and builds assets
- Runs the test suite

### Deploy Job

Deploys to Fly.io:
- Only runs on pushes to the `main` branch after lint and test jobs pass
- Validates required secrets before deployment
- Deploys using the Fly CLI
- Runs database migrations automatically 
- Performs health check verification after deployment
- Fails deployment if health check doesn't pass

## Required Secrets

The following secrets need to be configured in your GitHub repository:

### FLY_API_TOKEN

1. Install the Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Sign up and login: `fly auth signup` or `fly auth login`
3. Create a new app: `fly apps create gatherly`
4. Generate an API token: `fly auth token`
5. Add the token to GitHub Secrets:
   - Go to your GitHub repository
   - Navigate to Settings > Secrets and variables > Actions
   - Click "New repository secret"
   - Name: `FLY_API_TOKEN`
   - Value: The token from step 4

## Fly.io Configuration

The `fly.toml` file configures the Fly.io deployment:

- **App name**: `gatherly`
- **Region**: `sjc` (San Jose)
- **Port**: 8080 (internal)
- **Resources**: 1 CPU, 1GB RAM
- **Auto-scaling**: Enabled with minimum 0 machines
- **Health check**: `/health` endpoint
- **Database migrations**: Run automatically on deploy

## Environment Variables

The application requires the following environment variables in production:

### Database

Fly.io automatically provides database connection via the `DATABASE_URL` environment variable when you attach a PostgreSQL database.

### Application

- `PHX_HOST` - Set to your Fly.io app URL (e.g., `gatherly.fly.dev`)
- `SECRET_KEY_BASE` - Generated automatically by Fly.io
- `PORT` - Set to 8080

## Database Setup

To set up a PostgreSQL database on Fly.io:

```bash
# Create PostgreSQL database
fly postgres create gatherly-db

# Attach it to your app
fly postgres attach gatherly-db --app gatherly
```

## Deployment

### Manual Deployment

To deploy manually using Fly CLI:

```bash
# Deploy to production
just deploy

# Check deployment status  
just status

# View application logs
just logs

# Rollback to previous version
just rollback

# Build without deploying
just build
```

### Automatic Deployment

The GitHub Actions workflow automatically deploys when:
1. Code is pushed to the `main` branch
2. All lint and test jobs pass
3. The `FLY_API_TOKEN` secret is properly configured

## Health Check

The application includes a health check endpoint at `/health` that returns:

```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

This endpoint is used by Fly.io to monitor application health.

## Monitoring

You can monitor your deployment using:

```bash
# View logs
fly logs

# Check app status
fly status

# View metrics
fly dashboard
```

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure PostgreSQL database is attached
   - Check `DATABASE_URL` environment variable

2. **Build Failures**
   - Check that all dependencies are properly locked in `mix.lock`
   - Ensure Dockerfile is up to date

3. **Health Check Failures**
   - Verify the `/health` endpoint is accessible
   - Check application logs for startup errors

### Debugging

To debug deployment issues:

```bash
# SSH into the running container
fly ssh console

# Check environment variables
fly secrets list

# View detailed logs
fly logs --follow
```
