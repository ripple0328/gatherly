#!/usr/bin/env bash
set -euo pipefail

APP_HOST="${APP_HOST:-gatherly.localhost}"
APP_DISPLAY_NAME="${APP_DISPLAY_NAME:-Gatherly}"
PORT="${PORT:-4000}"
PORTLESS_PORT="${PORTLESS_PORT:-1355}"

if ! nc -z 127.0.0.1 9832 >/dev/null 2>&1; then
  open -a Tidewave >/dev/null 2>&1 || true
fi

cat <<BANNER
${APP_DISPLAY_NAME} dev URLs
  App:                  http://${APP_HOST}:${PORT}
  Portless:             http://${APP_HOST}:${PORTLESS_PORT}
  Tidewave Web:         http://${APP_HOST}:9832/?origin=http%3A%2F%2F${APP_HOST}%3A${PORT}
  Tidewave MCP (POST):  http://127.0.0.1:${PORT}/tidewave/mcp
BANNER

exec mix phx.server
