#!/usr/bin/env bash
set -euo pipefail

# Remove a task worktree. Optionally delete its branch.
# Usage:
#   scripts/worktree-rm.sh GAT-55 [--delete-branch task/GAT-55-health-home]

TASK_ID="${1:-}"
shift || true

if [[ -z "$TASK_ID" ]]; then
  echo "Usage: $0 <TASK_ID> [--delete-branch <branch>]" >&2
  exit 1
fi

DEL_BRANCH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete-branch)
      DEL_BRANCH="${2:-}"; shift 2 ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

ROOT="$(git rev-parse --show-toplevel)"
WT_DIR="$ROOT/.worktrees/$TASK_ID"

if [[ ! -d "$WT_DIR" ]]; then
  echo "No such worktree dir: $WT_DIR" >&2
  exit 1
fi

# Remove worktree
git worktree remove "$WT_DIR"

echo "✅ Removed worktree: $WT_DIR"

if [[ -n "$DEL_BRANCH" ]]; then
  git branch -D "$DEL_BRANCH" || true
  echo "🗑️  Deleted branch: $DEL_BRANCH"
fi
