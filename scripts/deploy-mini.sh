#!/usr/bin/env bash
set -euo pipefail

# GitHub Actions deploy script for the self-hosted runner "mini".
#
# Strategy (mirrors SocialCircle):
#   1) rsync workspace -> DEPLOY_DIR
#   2) load secrets from ENV_FILE (kept locally on runner)
#   3) build a production release
#   4) run migrations
#   5) restart service
#   6) verify /health and /

DEPLOY_DIR="${DEPLOY_DIR:-$HOME/Projects/Personal/gatherly}"
ENV_FILE="${ENV_FILE:-$HOME/.config/gatherly/.envrc.worker}"
LAUNCHD_LABEL="${LAUNCHD_LABEL:-com.gatherly}"
HEALTHCHECK_BASE_URL="${HEALTHCHECK_BASE_URL:-http://127.0.0.1:${PORT:-4000}}"

ROOT_SRC="${GITHUB_WORKSPACE:-$(pwd)}"

if [[ ! -d "$ROOT_SRC" ]]; then
  echo "GITHUB_WORKSPACE not found: $ROOT_SRC" >&2
  exit 1
fi

mkdir -p "$DEPLOY_DIR"

echo "==> Syncing code to $DEPLOY_DIR"
rsync -a --delete \
  --exclude '.git/' \
  --exclude '.github/' \
  --exclude '.worktrees/' \
  --exclude 'deps/' \
  --exclude '_build/' \
  --exclude 'node_modules/' \
  --exclude '.envrc*' \
  --exclude '.tool-versions' \
  "$ROOT_SRC/" "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing ENV_FILE: $ENV_FILE" >&2
  echo "Create it on the runner (do not commit secrets), e.g.:" >&2
  echo "  mkdir -p $(dirname "$ENV_FILE")" >&2
  echo "  vi $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

# Optional: allow ENV_FILE to set PORT, DATABASE_URL, SECRET_KEY_BASE, etc.

if [[ ! -f mix.exs ]]; then
  echo "mix.exs not found in $DEPLOY_DIR; nothing to build." >&2
  echo "This repo currently contains docs/scripts only." >&2
  exit 1
fi

echo "==> Building release"
export MIX_ENV=prod

# Install deps & compile.
mix local.hex --force
mix local.rebar --force
mix deps.get --only prod
mix compile

# Phoenix 1.7+ assets task (no-op if not present).
if mix help assets.deploy >/dev/null 2>&1; then
  mix assets.deploy
fi

mix release --overwrite

echo "==> Running migrations"
REL_BIN="_build/prod/rel/gatherly/bin/gatherly"
if [[ -x "$REL_BIN" ]]; then
  # Preferred: run migrations via release task.
  "$REL_BIN" eval "Gatherly.Release.migrate"
else
  # Fallback for early stages.
  mix ecto.migrate
fi

echo "==> Restarting service ($LAUNCHD_LABEL)"
# macOS launchd (LaunchAgent). The service should already be installed via scripts/mini-install.sh.
launchctl kickstart -k "gui/$(id -u)/$LAUNCHD_LABEL"

echo "==> Health checks"
for path in "/health" "/"; do
  url="$HEALTHCHECK_BASE_URL$path"
  echo "curl $url"
  curl -fsS "$url" >/dev/null
done

echo "✅ Deploy complete"
