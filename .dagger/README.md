# Gatherly CI/CD with Dagger

This directory contains the Dagger module for Gatherly's CI/CD pipeline, built with the Elixir SDK.

## Overview

The Gatherly CI pipeline uses Dagger to provide consistent, containerized builds across local development and production environments. The pipeline includes:

- **Dependencies**: Install and cache Elixir/Phoenix dependencies
- **Quality**: Code formatting, static analysis (Credo), and type checking (Dialyzer)  
- **Security**: Vulnerability scanning with mix deps.audit and hex.audit
- **Testing**: Full test suite with containerized PostgreSQL database
- **Building**: Production release with compiled assets

## Architecture

```
.dagger/
├── lib/
│   └── gatherly_ci.ex          # Main Dagger module with pipeline functions
├── mix.exs                     # Elixir project configuration
├── dagger_sdk/                 # Generated Dagger SDK (auto-managed)
└── README.md                   # This file
```

## Usage

### GitHub Actions (Primary)

The CI pipeline automatically runs using the `dagger/dagger-for-github` action:

```yaml
- name: Run Tests with Database
  uses: dagger/dagger-for-github@v6
  with:
    version: "latest"
    verb: call
    args: test --source=.
```

This approach provides:
- No manual Dagger CLI installation required
- Automatic caching and optimization
- Seamless integration with GitHub's artifact system
- Consistent execution environment

### Local Development

Use the provided Mix tasks for local development:

```bash
# Individual steps
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

### Direct Dagger CLI (Optional)

For advanced use cases or integration with other tools:

```bash
dagger call deps --source=. sync
dagger call quality --source=.
dagger call security --source=.
dagger call test --source=.
dagger call build --source=. sync
dagger call artifacts --source=. export --path=./release
```

## Module Functions

The `GatherlyCi` module exposes these functions:

- `base()` - Base Elixir container with system dependencies
- `deps(source)` - Install and cache project dependencies  
- `quality(source)` - Run formatting, linting, and type checking
- `security(source)` - Run security vulnerability scans
- `test(source)` - Run test suite with PostgreSQL database
- `build(source)` - Build production release with assets
- `ci(source)` - Complete CI pipeline execution
- `artifacts(source)` - Export build artifacts directory

## Configuration

The module configuration is defined in `/dagger.json`:

```json
{
  "name": "gatherly-ci",
  "engineVersion": "v0.18.10", 
  "sdk": { "source": "elixir" },
  "source": ".dagger"
}
```

## Benefits

- **Consistency**: Identical environment locally and in CI
- **Isolation**: Containerized dependencies and services
- **Performance**: Intelligent caching and parallel execution
- **Portability**: Works on any system with Docker
- **Debugging**: Easy to reproduce CI issues locally

## Development

To modify the pipeline:

1. Edit `lib/gatherly_ci.ex` with your changes
2. Test locally with `mix dagger.ci`
3. The GitHub Actions will automatically use your changes

The Dagger SDK is automatically managed - no manual updates needed.