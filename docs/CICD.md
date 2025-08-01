# CI/CD Setup

Gatherly uses GitHub Actions to lint, test and deploy the application. All jobs rely on the Dagger mix tasks so the local and CI environments behave the same.

## Pipeline Overview

1. **Lint** – `mix dagger.lint`
2. **Test** – `mix dagger.test`
3. **Security** – `mix dagger.security`
4. **Deploy** – Fly.io deployment on pushes to `main`

The workflow file is `.github/workflows/ci.yml` and runs on pushes and pull requests.

## Running CI Locally

Use the composite workflow to mirror CI on your machine:

```bash
mix dagger.ci
```

## Fly.io Secrets

Deployment requires a `FLY_API_TOKEN` secret in the GitHub repository. Generate it using the Fly CLI and add it under **Settings → Secrets and variables → Actions**.

## Manual Deployment

```bash
fly deploy
```

The command above runs the same steps used in the GitHub workflow and applies any pending migrations.

For detailed Fly.io configuration see `fly.toml`.
