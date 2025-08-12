# Gatherly Development Workflow
# Simple, efficient, and reusable commands

# Show available commands
default:
    @just --list

# === Core Setup ===

# Initial project setup - run once
setup:
    @echo "🚀 Setting up Gatherly development environment..."
    @just _ensure-services
    @just _run 'mix local.hex --force && mix local.rebar --force'
    @just _run 'mix deps.get && mix ecto.setup'
    @echo "✅ Setup complete! Run 'just dev' to start developing"

# Clean everything and start fresh
clean:
    @echo "🧹 Cleaning build artifacts and dependencies..."
    @docker compose down -v
    @docker compose run --rm app mix clean
    @docker compose run --rm app mix deps.clean --all
    @echo "✅ Clean complete! Run 'just setup' to rebuild"

# === Development ===

# Start development server (most used command)
dev:
    @echo "🔥 Starting development server..."
    @just _ensure-services
    @if curl -sf http://localhost:4000/health >/dev/null 2>&1; then \
        echo "Server already running at http://localhost:4000"; \
        echo "View logs: docker compose logs -f app"; \
    else \
        just _run-detached 'mix phx.server' && \
        echo "🌐 Server starting at http://localhost:4000"; \
        echo "📊 Dashboard: http://localhost:4000/dev/dashboard"; \
        echo "📧 Mailbox: http://localhost:4000/dev/mailbox"; \
    fi

# Interactive Elixir shell with Phoenix
iex:
    @echo "💻 Starting interactive Elixir shell..."
    @just _ensure-services
    @docker compose exec app iex -S mix phx.server

# Run tests (with optional args)
test *args="":
    @echo "🧪 Running tests..."
    @just _ensure-test-db
    @just _run-test 'mix test {{args}}'

# Watch tests continuously
test-watch:
    @echo "👀 Watching tests..."
    @just _ensure-test-db
    @docker compose run --rm app mix test --listen-on-stdin

# === Database ===

# Reset database to clean state
db-reset:
    @echo "🔄 Resetting database..."
    @just _ensure-services
    @just _run 'mix ecto.reset'
    @echo "✅ Database reset complete"

# Open database console
db-console:
    @echo "🗄️  Opening database console..."
    @just _ensure-services
    @docker compose exec db psql -U postgres -d gatherly_dev

# === Code Quality ===

# Format code only (fast)
format:
    @echo "🎨 Formatting code..."
    @just _run 'mix deps.get --only dev && mix format'

# Check code formatting (CI)
format-check:
    @echo "🎨 Checking code formatting..."
    @just _run 'mix deps.get --only dev && mix format --check-formatted'

# Compile with warnings as errors (CI)
compile-strict:
    @echo "🔧 Compiling with warnings as errors..."
    @just _run 'mix compile --warnings-as-errors'

# Run Credo linting
lint:
    @echo "🔍 Running Credo linting..."
    @just _run 'mix credo --strict'

# Run Dialyzer type checking
dialyzer:
    @echo "⚡ Running Dialyzer type checking..."
    @just _run 'mix dialyzer'

# Run security audit
security:
    @echo "🛡️ Running security audit..."
    @just _run 'mix hex.audit'

# Check for unused dependencies
deps-audit:
    @echo "🕵️ Checking for unused dependencies..."
    @just _run 'mix deps.unlock --check-unused'

# Build and test assets
assets-check:
    @echo "🎨 Building and testing assets..."
    @just _run 'mix assets.setup'
    @just _run 'mix assets.build'
    @just _run 'mix assets.deploy'

# Run tests with coverage
test-coverage:
    @echo "🧪 Running tests with coverage..."
    @just _ensure-test-db
    @just _run-test 'mix coveralls.html'

# Format code and run all quality checks
check:
    @echo "✅ Running quality checks..."
    @just format
    @just lint
    @just dialyzer
    @just test
    @echo "🎉 All checks passed!"

# Fast CI checks (without slow dialyzer)
ci-check:
    @echo "⚡ Running fast CI checks..."
    @just format-check
    @just lint
    @just test
    @echo "🎉 CI checks passed!"

# Generate test coverage report
coverage:
    @echo "📊 Generating coverage report..."
    @just _ensure-test-db
    @just _run-test 'mix coveralls.html'
    @echo "📈 Coverage report: cover/excoveralls.html"

# === Deployment ===

# Deploy to production
deploy:
    @echo "🚀 Deploying to production..."
    @just check
    @fly deploy
    @echo "✅ Deployment complete!"

# === Utilities ===

# Install/update dependencies
deps-get:
    @echo "Installing dependencies..."
    @docker compose run -T --rm app mix deps.get

# Update dependencies
deps-update:
    @echo "Updating dependencies..."
    @docker compose run -T --rm app mix deps.update --all

# Health check for development environment
doctor:
    @echo "🔍 Environment health check:"
    @docker --version 2>/dev/null || echo "❌ Docker not found"
    @docker compose version 2>/dev/null || echo "❌ Docker Compose not found"
    @docker info >/dev/null 2>&1 && echo "✅ Docker running" || echo "❌ Docker not running"
    @test -f .env && echo "✅ .env found" || echo "⚠️  Copy .env.example to .env"

# Show development menu
menu:
    @echo "🎯 Essential Development Commands:"
    @echo "  just setup      - Initial project setup"
    @echo "  just dev        - Start development server"
    @echo "  just iex        - Interactive Elixir shell"
    @echo "  just test       - Run tests"
    @echo "  just check      - Format + lint + test"
    @echo "  just db-reset   - Reset database"
    @echo "  just deploy     - Deploy to production"
    @echo ""
    @echo "📚 Full list: just --list"

# === Internal Helpers (prefixed with _) ===

# Ensure services are running
_ensure-services:
    @docker compose up -d db app --wait

# Ensure test database is running
_ensure-test-db:
    @docker compose up -d test_db --wait

# Run command in app container
_run cmd:
    @docker compose run --rm app bash -c "mix local.hex --force && mix local.rebar --force && {{cmd}}"

# Run command in app container (detached)
_run-detached cmd:
    @docker compose exec -d app bash -c "mix local.hex --force && mix local.rebar --force && SECRET_KEY_BASE=BxQpZXzWv4ig1loZooOPZCnjc3TQ0R4XqzwD12jHui4G2ZyIfvJLcxc46V/rmEbb {{cmd}}"

# Run command with test environment
_run-test cmd:
    @MIX_ENV=test docker compose run --rm -e MIX_ENV=test -e DATABASE_URL=ecto://postgres:postgres@test_db/gatherly_test app bash -c "mix local.hex --force && mix local.rebar --force && {{cmd}}"