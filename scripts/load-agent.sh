#!/bin/bash
# Codex CLI Ultimate — Agent Loader (Bash version)
# Usage:  ./scripts/load-agent.sh <agent-name>
# Example: ./scripts/load-agent.sh architect
# Outputs the agent's system instructions to use as context for Codex CLI

set -e

AGENT_NAME="$1"

if [ -z "$AGENT_NAME" ]; then
    echo "❌ Usage: $0 <agent-name>"
    echo "   Available agents:"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
    ls -1 "$WORKSPACE_ROOT/agents"/*.md 2>/dev/null | sed 's/.*\///' | sed 's/\.md$//' | sed 's/^/  - /'
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

# Validate agent name: only alphanumeric, dots, hyphens, underscores
if ! echo "$AGENT_NAME" | grep -qE '^[a-zA-Z0-9._-]+$'; then
    echo "❌ Error: Invalid agent name '$AGENT_NAME'." >&2
    echo "   Use only letters, digits, dots, hyphens, and underscores." >&2
    exit 1
fi

AGENT_FILE="$WORKSPACE_ROOT/agents/$AGENT_NAME.md"

# Path containment: ensure the resolved path stays within agents/
RESOLVED_AGENT=$(realpath "$AGENT_FILE" 2>/dev/null || echo "$AGENT_FILE")
case "$RESOLVED_AGENT" in
    "$WORKSPACE_ROOT/agents/"*) ;;
    *)
        echo "❌ Error: Invalid agent path." >&2
        exit 1
        ;;
esac

if [ ! -f "$AGENT_FILE" ]; then
    echo "❌ Agent '$AGENT_NAME' not found at: $AGENT_FILE"
    echo "   Available agents:"
    ls -1 "$WORKSPACE_ROOT/agents"/*.md 2>/dev/null | sed 's/.*\///' | sed 's/\.md$//' | sed 's/^/  - /'
    exit 1
fi

echo "========================================="
echo "🤖 Agent: $AGENT_NAME"
echo "========================================="

# Extract system instructions between ```text and ```
if grep -q '```text' "$AGENT_FILE" 2>/dev/null; then
    echo ""
    echo "📋 System Instructions:"
    echo ""
    # Extract just the code block content
    sed -n '/```text/,/```/p' "$AGENT_FILE" | sed '1d;$d'
    echo ""
    echo "--- Full context ---"
    echo ""
fi

cat "$AGENT_FILE"
echo ""
echo "========================================="
echo "💡 Send the text above to Codex CLI as context"
echo "   to activate the $AGENT_NAME agent."
echo "========================================="
