#!/usr/bin/env bash
# Start Codex CLI Ultimate Admin UI
# Usage: bash scripts/start-ui.sh [--port=3456]

set -euo pipefail

UI_DIR="$(cd "$(dirname "$0")/../ui" && pwd)"
SERVER="$UI_DIR/server.js"

if [ ! -f "$SERVER" ]; then
    echo "❌ UI server not found at $SERVER" >&2
    exit 1
fi

# Check for Node.js
if ! command -v node &>/dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js from https://nodejs.org" >&2
    exit 1
fi

# Install dependencies if needed
if [ ! -d "$UI_DIR/node_modules" ]; then
    echo "📦 Installing dependencies..."
    (cd "$UI_DIR" && npm install)
    if [ ! -d "$UI_DIR/node_modules" ]; then
        echo "❌ Failed to install dependencies." >&2
        exit 1
    fi
fi

# Default port
PORT="${CODEX_UI_PORT:-3456}"

# Parse --port argument
for arg in "$@"; do
    case "$arg" in
        --port=*) PORT="${arg#*=}" ;;
        *) ;;
    esac
done

echo "🚀 Starting Codex CLI Ultimate Admin UI..."
echo "   Server : http://localhost:$PORT"
echo "   Press Ctrl+C to stop"

cd "$UI_DIR"
exec node "$SERVER" "--port=$PORT"
