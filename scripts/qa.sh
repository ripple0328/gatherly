#!/usr/bin/env bash
set -euo pipefail

# Run QA checks for a task worktree.
# Usage:
#   scripts/qa.sh .worktrees/GAT-55
# or
#   cd .worktrees/GAT-55 && ../../scripts/qa.sh .

DIR="${1:-.}"
cd "$DIR"

ROOT="$(git rev-parse --show-toplevel)"
echo "QA @ $ROOT"

echo "\n== Git status =="
git status --short || true

echo "\n== Diff summary =="
git --no-pager diff --stat || true

echo "\n== Format check =="
if command -v mix >/dev/null 2>&1; then
  mix format --check-formatted
else
  echo "mix not found; skipping Elixir checks" >&2
fi

echo "\n== Compile (warnings as errors) =="
MIX_ENV=test mix compile --warnings-as-errors

echo "\n== Tests =="
MIX_ENV=test mix test

echo "\n✅ QA passed"
