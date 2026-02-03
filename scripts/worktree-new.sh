#!/usr/bin/env bash
set -euo pipefail

# Create a dedicated git worktree for a Linear task.
# Usage:
#   scripts/worktree-new.sh GAT-55 task/GAT-55-health-home
#
# Creates:
#   .worktrees/GAT-55/ (worktree)
#   branch task/GAT-55-health-home

TASK_ID="${1:-}"
BRANCH="${2:-}"

if [[ -z "$TASK_ID" || -z "$BRANCH" ]]; then
  echo "Usage: $0 <TASK_ID> <BRANCH>" >&2
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"
WT_DIR="$ROOT/.worktrees/$TASK_ID"

mkdir -p "$ROOT/.worktrees"

if [[ -d "$WT_DIR" ]]; then
  echo "Worktree already exists: $WT_DIR" >&2
  exit 1
fi

# Safety: ensure clean main repo
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Main worktree has uncommitted changes. Commit/stash before creating task worktrees." >&2
  git status --short >&2
  exit 1
fi

# Create new worktree+branch
# Use current HEAD as base.
git worktree add "$WT_DIR" -b "$BRANCH"

echo "✅ Created worktree"
echo "  Task:   $TASK_ID"
echo "  Branch: $BRANCH"
echo "  Path:   $WT_DIR"

echo "Next: cd $WT_DIR"
