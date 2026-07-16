#!/bin/bash
# Profile Switcher for Codex CLI (Bash version)

set -e

PROFILE_NAME="$1"

if [ -z "$PROFILE_NAME" ]; then
    echo "❌ Error: Please specify a profile name."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
PROFILE_FILE="$WORKSPACE_ROOT/config/$PROFILE_NAME.toml"
CODEX_HOME="$HOME/.codex"
CONFIG_FILE="$CODEX_HOME/config.toml"
BACKUP_FILE="$CODEX_HOME/config.toml.bak"

echo "Switching Codex profile to: '$PROFILE_NAME'"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ Error: Profile '$PROFILE_NAME' does not exist at $PROFILE_FILE"
    echo "Available profiles:"
    ls -1 "$WORKSPACE_ROOT/config"/*.toml | sed 's/.*\///' | sed 's/\.toml//'
    exit 1
fi

mkdir -p "$CODEX_HOME"

if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Backup created at: $BACKUP_FILE"
fi

cp "$PROFILE_FILE" "$CONFIG_FILE"

# Replace placeholders with actual workspace path
sed "s|__WORKSPACE_ROOT__|$WORKSPACE_ROOT|g" "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo "Successfully switched to '$PROFILE_NAME'!"
echo "Active configuration updated at: $CONFIG_FILE"

# Extract model and provider info
PROVIDER=$(grep -E '^model_provider[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 || echo "unknown")
MODEL=$(grep -E '^model[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 || echo "unknown")

echo "Provider: $PROVIDER"
echo "Model   : $MODEL"
