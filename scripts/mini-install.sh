#!/usr/bin/env bash
set -euo pipefail

# Installation script to run on the mini server.
# Creates a per-user LaunchAgent and starts the service.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_NAME="gatherly"
PLIST_NAME="${LAUNCHD_LABEL:-com.gatherly}"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
ENV_FILE="${ENV_FILE:-$HOME/.config/gatherly/.envrc.worker}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing ENV_FILE: $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

PORT=${PORT:-4002}
PHX_HOST=${PHX_HOST:-gatherly.qingbo.us}
SECRET_KEY_BASE=${SECRET_KEY_BASE:-}
DATABASE_URL=${DATABASE_URL:-}

if [[ -z "$SECRET_KEY_BASE" ]]; then
  echo "SECRET_KEY_BASE is missing in $ENV_FILE" >&2
  exit 1
fi

if [[ -z "$DATABASE_URL" ]]; then
  echo "DATABASE_URL is missing in $ENV_FILE" >&2
  exit 1
fi

mkdir -p "$LAUNCHAGENTS_DIR"

cat > "$LAUNCHAGENTS_DIR/$PLIST_NAME.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$PLIST_NAME</string>

  <key>ProgramArguments</key>
  <array>
    <string>$APP_PATH/_build/prod/rel/$APP_NAME/bin/$APP_NAME</string>
    <string>start</string>
  </array>

  <key>WorkingDirectory</key>
  <string>$APP_PATH/_build/prod/rel/$APP_NAME</string>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <dict>
    <key>SuccessfulExit</key>
    <false/>
  </dict>

  <key>StandardOutPath</key>
  <string>$APP_PATH/_build/prod/rel/$APP_NAME/log/stdout.log</string>

  <key>StandardErrorPath</key>
  <string>$APP_PATH/_build/prod/rel/$APP_NAME/log/stderr.log</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>MIX_ENV</key>
    <string>prod</string>
    <key>PHX_SERVER</key>
    <string>true</string>
    <key>PORT</key>
    <string>$PORT</string>
    <key>PHX_HOST</key>
    <string>$PHX_HOST</string>
    <key>SECRET_KEY_BASE</key>
    <string>$SECRET_KEY_BASE</string>
    <key>DATABASE_URL</key>
    <string>$DATABASE_URL</string>
  </dict>

  <key>ProcessType</key>
  <string>Interactive</string>
</dict>
</plist>
EOF

chmod 644 "$LAUNCHAGENTS_DIR/$PLIST_NAME.plist"
mkdir -p "$APP_PATH/_build/prod/rel/$APP_NAME/log"

launchctl unload "$LAUNCHAGENTS_DIR/$PLIST_NAME.plist" 2>/dev/null || true
launchctl load "$LAUNCHAGENTS_DIR/$PLIST_NAME.plist"

sleep 2

if launchctl list | grep -q "$PLIST_NAME"; then
  echo "✅ $PLIST_NAME loaded"
else
  echo "❌ Failed to load $PLIST_NAME" >&2
  exit 1
fi
