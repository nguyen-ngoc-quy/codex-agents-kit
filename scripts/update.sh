#!/bin/bash
# Codex CLI Ultimate Update Script (Bash version)

echo "========================================="
echo "🔄 Updating Codex CLI Ultimate..."
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -d "$WORKSPACE_ROOT/.git" ]; then
    echo "Pulling latest starter kit changes from Git..."
    if git -C "$WORKSPACE_ROOT" pull; then
        echo "✅ Git repository updated successfully."
    else
        echo "⚠️ Warning: Git pull failed. Please pull updates manually."
    fi
else
    echo "Not a git repository, skipping git pull."
fi

echo "Synchronizing templates..."
echo "Tip: Run 'codex profile [free|premium|local]' to re-apply updated profiles."

echo "========================================="
echo "🎉 Updates completed!"
echo "========================================="
