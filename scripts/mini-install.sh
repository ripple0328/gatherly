#!/usr/bin/env bash
set -euo pipefail

# One-time setup for the "mini" macOS host.
# Installs a LaunchAgent that runs the Gatherly release.
#
# Secrets are NOT managed here. Keep them in:
#   ~/.config/gatherly/.envrc.worker

APP_DIR="${APP_DIR:-$HOME/Projects/Personal/gatherly}"
ENV_FILE="${ENV_FILE:-$HOME/.config/gatherly/.envrc.worker}"
LAUNCHD_LABEL="${LAUNCHD_LABEL:-com.gatherly}"
PLIST_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/mini/com.gatherly.plist"
PLIST_DST="$HOME/Library/LaunchAgents/$LAUNCHD_LABEL.plist"

mkdir -p "$HOME/Library/LaunchAgents" "$(dirname "$ENV_FILE")" "$APP_DIR" "$APP_DIR/log"

if [[ ! -f "$ENV_FILE" ]]; then
  cat >"$ENV_FILE" <<'EOF'
# Local secrets for the self-hosted runner (do not commit!)
#
# Required for Phoenix releases (typical):
# export SECRET_KEY_BASE=...
# export DATABASE_URL=...
# export PHX_HOST=...
# export PORT=4000
EOF
  echo "Created placeholder env file: $ENV_FILE"
  echo "Edit it and add real secrets before deploying." >&2
fi

if [[ ! -f "$PLIST_SRC" ]]; then
  echo "Missing plist template: $PLIST_SRC" >&2
  exit 1
fi

# Render plist with paths.
TMP_PLIST="$(mktemp)"
sed \
  -e "s|__APP_DIR__|$APP_DIR|g" \
  -e "s|__ENV_FILE__|$ENV_FILE|g" \
  -e "s|__LAUNCHD_LABEL__|$LAUNCHD_LABEL|g" \
  "$PLIST_SRC" > "$TMP_PLIST"

mv "$TMP_PLIST" "$PLIST_DST"

# (Re)load LaunchAgent.
launchctl bootout "gui/$(id -u)/$LAUNCHD_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"
launchctl enable "gui/$(id -u)/$LAUNCHD_LABEL"
launchctl kickstart -k "gui/$(id -u)/$LAUNCHD_LABEL"

echo "✅ Installed LaunchAgent: $PLIST_DST"
echo "   App dir: $APP_DIR"
echo "   Env:     $ENV_FILE"
