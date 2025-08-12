#!/bin/bash
# Gatherly Development Environment Setup Script
# This script sets up the complete development environment for Gatherly

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
echo -e "${BLUE}"
cat << 'EOF'
   ____       _   _               _       
  / ___| __ _| |_| |__   ___ _ __| |_   _ 
 | |  _ / _` | __| '_ \ / _ \ '__| | | | |
 | |_| | (_| | |_| | | |  __/ |  | | |_| |
  \____|\__,_|\__|_| |_|\___|_|  |_|\__, |
                                   |___/ 
  Development Environment Setup
EOF
echo -e "${NC}"

info "Starting Gatherly development environment setup..."

# Check if we're in the right directory
if [ ! -f "mix.exs" ]; then
    error "This doesn't appear to be a Gatherly project directory"
    error "Please run this script from the project root"
    exit 1
fi

# Check prerequisites
info "Checking prerequisites..."

check_command() {
    if command -v $1 >/dev/null 2>&1; then
        success "$1 is installed"
        return 0
    else
        error "$1 is not installed"
        return 1
    fi
}

MISSING_DEPS=0

# Check Docker
if ! check_command docker; then
    MISSING_DEPS=1
    echo "  → Install from: https://docs.docker.com/get-docker/"
fi

# Check Docker Compose
if ! check_command "docker compose"; then
    MISSING_DEPS=1
    echo "  → Docker Compose should be included with Docker Desktop"
fi

# Check Just (optional but recommended)
if ! check_command just; then
    warning "just is not installed (recommended but optional)"
    echo "  → macOS: brew install just"
    echo "  → Linux: Check https://github.com/casey/just#installation"
    echo "  → Or use make commands instead"
fi

# Check Git
if ! check_command git; then
    MISSING_DEPS=1
    echo "  → Install Git from your package manager"
fi

if [ $MISSING_DEPS -eq 1 ]; then
    error "Please install missing dependencies before continuing"
    exit 1
fi

# Check Docker daemon
info "Checking Docker daemon..."
if ! docker info >/dev/null 2>&1; then
    error "Docker daemon is not running"
    error "Please start Docker Desktop or your Docker service"
    exit 1
fi
success "Docker daemon is running"

# Setup environment file
info "Setting up environment configuration..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        success "Created .env from .env.example"
        warning "Please edit .env with your local configuration"
    else
        warning ".env.example not found, you'll need to create .env manually"
    fi
else
    info ".env already exists"
fi

# Generate secrets if needed
if [ -f ".env" ] && grep -q "SECRET_KEY_BASE=.*changeme" .env 2>/dev/null; then
    warning "Generating new secret keys..."
    # This would need to be done in the container, just remind user
    info "Run 'just dev-shell' then 'mix phx.gen.secret' to generate secrets"
fi

# Setup development environment
info "Setting up development containers and database..."

if command -v just >/dev/null 2>&1; then
    # Use just if available
    info "Using just for setup..."
    just dev-setup
else
    # Fallback to direct docker commands
    info "Using docker compose directly..."
    docker compose up -d db
    docker compose exec -T db sh -c 'until pg_isready -U postgres; do sleep 1; done'
    docker compose run -T --rm app mix deps.get
    docker compose run -T --rm app mix ecto.setup
fi

# Setup Git hooks (if pre-commit is available)
info "Setting up development tools..."

if command -v pre-commit >/dev/null 2>&1; then
    info "Installing pre-commit hooks..."
    pre-commit install
    pre-commit install --hook-type commit-msg
    success "Pre-commit hooks installed"
else
    warning "pre-commit not found - install with: pip install pre-commit"
    info "You can also use 'just pre-commit' to run checks manually"
fi

# Create necessary directories
info "Creating development directories..."
mkdir -p logs backups cover doc
success "Development directories created"

# Show available commands
echo
success "🎉 Development environment setup complete!"
echo
info "Available commands:"
if command -v just >/dev/null 2>&1; then
    echo "  just dev-menu      - Show development menu"
    echo "  just dev-server    - Start development server"
    echo "  just dev-shell     - Start interactive shell"
    echo "  just test          - Run tests"
    echo "  just quick-check   - Fast format + lint"
    echo "  just coverage      - Generate test coverage"
else
    echo "  docker compose run --service-ports app mix phx.server"
    echo "  docker compose run app iex -S mix"
fi
echo
info "Next steps:"
echo "  1. Review and update .env configuration"
echo "  2. Start development server"
echo "  3. Visit http://localhost:4000"
echo
success "Happy coding! 🚀"