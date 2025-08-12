# Development workflow commands for Gatherly
# Run with: just <command>

# Default recipe - show available commands
default:
    @just --list

# === Development Server ===

# Start Phoenix development server (auto-starts services)
dev-server:
    @echo "Starting development services and Phoenix server..."
    @docker compose up -d db
    @echo "Waiting for services to be ready..."
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @echo "Starting Phoenix server at http://localhost:4000"
    @docker compose run --rm --service-ports app mix phx.server

# Start interactive IEx shell (auto-starts services)
dev-shell:
    @echo "Starting development services and IEx shell..."
    @docker compose up -d db
    @echo "Waiting for services to be ready..."
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @echo "Starting interactive IEx shell..."
    @docker compose run --rm -it app iex -S mix

# === Setup Commands ===

# Full development setup (install deps + setup database)
dev-setup:
    @echo "Setting up development environment..."
    @docker compose up -d db
    @echo "Waiting for services to be ready..."
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @echo "Installing dependencies..."
    @docker compose run -T --rm app mix deps.get
    @echo "Setting up database..."
    @docker compose run -T --rm app mix ecto.setup
    @echo "Development environment ready!"

# === Database Operations ===

# Create development database
db-create:
    @echo "Creating development database..."
    @docker compose up -d db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose run -T --rm app mix ecto.create

# Run database migrations
db-migrate:
    @echo "Running database migrations..."
    @docker compose up -d db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose run -T --rm app mix ecto.migrate

# Rollback database migrations
db-rollback *args="":
    @echo "Rolling back database migrations..."
    @docker compose up -d db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose run -T --rm app mix ecto.rollback {{args}}

# Reset database (drop, create, migrate, seed)
db-reset:
    @echo "Resetting development database..."
    @docker compose up -d db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose run -T --rm app mix ecto.reset

# Run database seeds
db-seed:
    @echo "Running database seeds..."
    @docker compose up -d db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose run -T --rm app mix run priv/repo/seeds.exs

# Connect to PostgreSQL shell
db-shell:
    @echo "Connecting to PostgreSQL shell..."
    @docker compose up -d db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose exec db psql -U postgres -d gatherly_dev

# === Testing ===

# Run all tests with test database
test *args="":
    @echo "Running tests..."
    @docker compose up -d test_db
    @docker compose exec -T test_db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @MIX_ENV=test docker compose run -T --rm -e MIX_ENV=test app bash -c 'mix local.hex --force && mix local.rebar --force && mix deps.get && mix test {{args}}'

# === Service Management ===

# Start all development services
services-up:
    @echo "Starting development services..."
    @docker compose up -d

# Stop all development services
services-down:
    @echo "Stopping development services..."
    @docker compose down

# Show service status
services-status:
    @docker compose ps

# Show service logs
services-logs service="":
    #!/usr/bin/env bash
    if [ "{{service}}" = "" ]; then
        docker compose logs --tail=50 -f
    else
        docker compose logs --tail=50 -f {{service}}
    fi

# Restart all services
services-restart:
    @echo "Restarting development services..."
    @docker compose restart

# === Code Quality ===

# Format code
format:
    @echo "Formatting code..."
    @docker compose run -T --rm app bash -c 'mix local.hex --force && mix local.rebar --force && mix deps.get && mix format'

# Run linting
lint:
    @echo "Running linter..."
    @docker compose run -T --rm app bash -c 'mix local.hex --force && mix local.rebar --force && mix deps.get && mix credo --strict'

# Run Dialyzer type checking
dialyzer:
    @echo "Running Dialyzer..."
    @docker compose run -T --rm app bash -c 'mix local.hex --force && mix local.rebar --force && mix deps.get && mix dialyzer'

# Run all quality checks
quality: format lint dialyzer
    @echo "All quality checks completed!"

# === Utilities ===

# Install/update dependencies
deps-get:
    @echo "Installing dependencies..."
    @docker compose run -T --rm app mix deps.get

# Update dependencies
deps-update:
    @echo "Updating dependencies..."
    @docker compose run -T --rm app mix deps.update --all

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    @docker compose run -T --rm app mix clean
    @docker compose run -T --rm app mix deps.clean --all

# Run arbitrary mix command
mix command:
    @echo "Running mix {{command}}..."
    @docker compose up -d db test_db
    @docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    @docker compose run -T --rm app mix {{command}}

# === CI/CD ===

# Check formatting without writing changes
format-check:
    @echo "Checking formatting..."
    @docker compose run -T --rm app bash -c 'mix local.hex --force && mix local.rebar --force && mix deps.get && mix format --check-formatted'

# Removed redundant CI tasks - reuse standard format-check, lint, dialyzer tasks

# CI pipeline: uses compose inheritance with persistent service for CI optimizations
ci:
    @echo "Running CI pipeline with optimized settings..."
    @docker compose -f docker-compose.yml -f docker-compose.ci.yml up -d app --wait
    @echo "Checking formatting..."
    @docker compose -f docker-compose.yml -f docker-compose.ci.yml exec -T app env MIX_ENV=dev mix format --check-formatted
    @echo "Running linter..."
    @docker compose -f docker-compose.yml -f docker-compose.ci.yml exec -T app env MIX_ENV=dev mix credo --strict  
    @echo "Running type checker..."
    @docker compose -f docker-compose.yml -f docker-compose.ci.yml exec -T app env MIX_ENV=dev mix dialyzer
    @echo "Running tests..."
    @docker compose -f docker-compose.yml -f docker-compose.ci.yml exec -T app mix test
    @docker compose -f docker-compose.yml -f docker-compose.ci.yml down
    @echo "✅ CI pipeline completed successfully!"

# Build and deploy to Fly.io in one step
deploy:
    @echo "Building and deploying to Fly.io..."
    @fly deploy

# Build with Fly.io build system only (no deploy)
build:
    @echo "Building with Fly.io (no deploy)..."
    @fly deploy --build-only --local-only --vm-memory=512 --vm-cpus=1 || fly deploy --build-only

# Rollback to previous deployment
rollback:
    @echo "Rolling back to previous deployment..."
    @fly releases list --limit 2 --json | jq -r '.[1].id' | xargs fly releases rollback

# Show deployment status and recent releases
status:
    @echo "Current deployment status:"
    @fly status
    @echo -e "\nRecent releases:"
    @fly releases list --limit 5

# Open application logs
logs:
    @echo "Opening application logs..."
    @fly logs

# Security audit (basic)
security:
    @echo "Running security audit..."
    @docker compose run -T --rm app mix hex.audit || true

# === Environment & Assets ===

# Quick health check for local environment
doctor:
    @echo "Diagnosing environment..."
    @docker --version || true
    @docker compose version || true
    @echo "Checking Docker daemon connectivity..."
    @docker info >/dev/null 2>&1 && echo "Docker daemon: OK" || (echo "Docker daemon: NOT RUNNING or inaccessible" && exit 1)
    @echo "Checking compose file..."
    @test -f docker-compose.yml && echo "Compose file: found" || (echo "Compose file: missing" && exit 1)


# Build assets via mix aliases inside the container
assets-build:
    @echo "Building assets..."
    @docker compose run -T --rm app mix assets.build

# Build and digest assets for production
assets-deploy:
    @echo "Building and digesting assets for production..."
    @docker compose run -T --rm app mix assets.deploy

# Run tests with coverage (ExCoveralls)
coveralls:
    @echo "Running tests with coverage..."
    @MIX_ENV=test docker compose -f docker-compose.dev.yml run -T --rm -e MIX_ENV=test app mix coveralls

# === Git Hooks Aggregators ===

# Run before commit: format code and lint strictly
pre-commit: format lint
    @echo "Pre-commit checks passed!"
