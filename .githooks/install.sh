#!/bin/bash
#
# Install git hooks for the Gatherly project
#

echo "🔧 Installing git hooks for Gatherly..."

# Get the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.githooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Create symlinks for hooks
for hook in "$HOOKS_DIR"/*; do
    if [ -f "$hook" ] && [ "$(basename "$hook")" != "install.sh" ]; then
        hook_name=$(basename "$hook")
        echo "  📎 Installing $hook_name hook..."
        
        # Remove existing hook if it exists
        if [ -f "$GIT_HOOKS_DIR/$hook_name" ]; then
            rm "$GIT_HOOKS_DIR/$hook_name"
        fi
        
        # Create symlink
        ln -s "../../.githooks/$hook_name" "$GIT_HOOKS_DIR/$hook_name"
        
        # Make sure it's executable
        chmod +x "$hook"
    fi
done

echo "✅ Git hooks installed successfully!"
echo ""
echo "📝 Installed hooks:"
echo "  - pre-commit: Runs formatting, linting, and tests before commits"
echo ""
echo "💡 To bypass hooks temporarily, use: git commit --no-verify"
echo ""