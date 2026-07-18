#!/bin/bash
# Diagnostics Script for Codex CLI (Bash version)
# Checks environment, API keys, endpoints, CLI pathing, and MCP dependencies

set -uo pipefail

echo "========================================="
echo "ðŸ‘¨â€âš•ï¸ Codex CLI Ultimate Health Diagnostics"
echo "========================================="

ALL_PASSED=true

ok()   { echo "  âœ… $1"; }
warn() { echo "  âš ï¸  $1"; }
fail() { echo "  âŒ $1"; ALL_PASSED=false; }

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 1. System Information
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "--- System Info ---"
echo "  OS       : $(uname -a 2>/dev/null || echo 'unknown')"
echo "  User     : $(whoami 2>/dev/null || echo 'unknown')"
echo "  Shell    : $SHELL"

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 2. Active Config File
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "--- Active Configuration ---"
CONFIG_FILE="$HOME/.codex/config.toml"
echo -n "  Config file... "
if [ -f "$CONFIG_FILE" ]; then
    ok "Found"
    echo "    Path: $CONFIG_FILE"
    PROVIDER=$(grep -E '^model_provider[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 2>/dev/null || echo "unknown")
    MODEL=$(grep -E '^model[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 2>/dev/null || echo "unknown")
    echo "    Provider: $PROVIDER"
    echo "    Model   : $MODEL"
else
    fail "Config file not found at $CONFIG_FILE"
    echo "    -> Run install.sh first"
fi

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 3. Codex CLI Availability
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "--- Codex CLI ---"
echo -n "  Binary detection... "

# Try CODEX_CLI_PATH, then PATH
CODEX_PATH=""
if [ -n "$CODEX_CLI_PATH" ] && [ -x "$CODEX_CLI_PATH" ]; then
    CODEX_PATH="$CODEX_CLI_PATH"
elif command -v codex >/dev/null 2>&1; then
    CODEX_PATH=$(command -v codex)
fi

if [ -n "$CODEX_PATH" ]; then
    ok "Found"
    echo "    Path: $CODEX_PATH"
    echo -n "  Version... "
    VER_OUTPUT=$("$CODEX_PATH" --version 2>&1 || true)
    if [ -n "$VER_OUTPUT" ]; then
        ok "$VER_OUTPUT"
    else
        warn "Could not determine version"
    fi
else
    fail "Codex CLI binary not found"
    echo "    -> Ensure Codex CLI is installed and in PATH"
fi

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 4. Runtime Dependencies
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "--- Runtime Dependencies ---"

echo -n "  Node.js... "
if command -v node >/dev/null 2>&1; then
    ok "$(node --version 2>&1)"
else
    fail "Node.js not found (required for MCP servers via npx)"
fi

echo -n "  npx... "
if command -v npx >/dev/null 2>&1; then
    ok "$(npx --version 2>&1)"
else
    fail "npx not found (required to run MCP servers)"
fi

echo -n "  Git... "
if command -v git >/dev/null 2>&1; then
    ok "$(git --version 2>&1)"
else
    warn "Git not found (some MCP features unavailable)"
fi

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 5. Provider Connectivity
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
if [ "$PROVIDER" = "openrouter" ]; then
    echo ""
    echo "--- OpenRouter ---"

    ENV_KEY_NAME=$(grep -E '^env_key[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" 2>/dev/null | head -n1 | cut -d'"' -f2 || echo "OPENROUTER_API_KEY")
    API_KEY="${!ENV_KEY_NAME}"

    echo -n "  API Key... "
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "OPENROUTER_API_KEY" ]; then
        fail "Environment variable '$ENV_KEY_NAME' is empty or not set"
        echo "    -> export $ENV_KEY_NAME='sk-or-v1-...'"
    else
        MASKED_KEY="${API_KEY:0:12}..."
        ok "Configured ($MASKED_KEY)"
    fi

    echo -n "  API connectivity... "
    if curl -s -m 5 "https://openrouter.ai/api/v1/models" >/dev/null 2>&1; then
        ok "Connected"
    else
        fail "Cannot reach OpenRouter API"
        echo "    -> Check internet connection or proxy"
    fi

elif [ "$PROVIDER" = "ollama" ]; then
    echo ""
    echo "--- Ollama (Local LLM) ---"

    echo -n "  Service... "
    if curl -s -m 3 "http://localhost:11434/api/tags" >/dev/null 2>&1; then
        ok "Connected"
        LOCAL_MODELS=$(curl -s "http://localhost:11434/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        if echo "$LOCAL_MODELS" | grep -qx "$MODEL" 2>/dev/null; then
            echo "    âœ… Model '$MODEL' is ready"
        else
            warn "Active model '$MODEL' is not pulled"
            echo "    -> Run 'ollama pull $MODEL'"
        fi
    else
        fail "Ollama is not running"
        echo "    -> Start Ollama or run 'ollama serve'"
    fi
fi

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 6. MCP Server Dependencies (quick check)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "--- MCP Servers (cached) ---"
echo "  (Run 'npx -y @modelcontextprotocol/server-*' to install on first use)"

# Check if MCP packages resolve via npm
for PKG in \
    "@modelcontextprotocol/server-filesystem" \
    "@cyanheads/git-mcp-server" \
    "@modelcontextprotocol/server-github" \
    "@hypnosis/docker-mcp-server" \
    "@playwright/mcp"; do
    echo -n "  $PKG... "
    # --no-install skips download, just checks cache
    if npx --no-install "$PKG" --help >/dev/null 2>&1; then
        ok "cached"
    else
        warn "not cached (will download on first use)"
    fi
done

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# 7. Network Connectivity
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "--- Network ---"
echo -n "  Internet... "
if curl -s -m 5 "https://clients3.google.com/generate_204" >/dev/null 2>&1; then
    ok "Connected"
else
    warn "No internet connectivity detected (offline mode)"
fi

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
# Final Verdict
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo ""
echo "========================================="
if [ "$ALL_PASSED" = true ]; then
    echo "ðŸŽ‰ System is healthy and ready to use!"
else
    echo "âš ï¸  System has warnings or errors. Check suggestions above."
fi
echo "========================================="

