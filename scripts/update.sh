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

# Regenerate free model fallback chain
echo "Generating free model fallback chain..."
if bash "${SCRIPT_DIR}/generate-free-profile.sh" 2>/dev/null; then
    echo "Free model fallback chain updated."
else
    echo "Could not update free model chain (API may be unavailable). Using cached list."
fi

echo "Tip: Run 'codex profile [free|premium|local]' to re-apply updated profiles."

echo "========================================="
echo "🎉 Updates completed!"
echo "========================================="
