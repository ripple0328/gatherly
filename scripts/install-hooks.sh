#!/bin/bash
# Install Git hooks for Gatherly development

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info "Installing Git hooks for Gatherly..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    warning "Not in a git repository, skipping hook installation"
    exit 0
fi

# Try to install pre-commit hooks
if command -v pre-commit >/dev/null 2>&1; then
    info "Installing pre-commit hooks..."
    pre-commit install
    pre-commit install --hook-type commit-msg
    success "Pre-commit hooks installed"
    
    # Test the hooks
    info "Testing hooks..."
    pre-commit run --all-files || true
    success "Hook installation complete"
else
    warning "pre-commit not found"
    info "Install with: pip install pre-commit"
    info "Or use 'just pre-commit' to run checks manually"
fi

info "Available manual commands:"
echo "  just pre-commit    - Run pre-commit checks"
echo "  just review-prep   - Prepare code for review"
echo "  just quick-check   - Fast format + lint"