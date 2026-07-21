#!/bin/bash
# Config Manager for Codex CLI Ultimate (Bash)
# Usage: ./scripts/config.sh <command> [args]

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_HOME="${HOME}/.codex"
ACTIVE_CONFIG="${CODEX_HOME}/config.toml"

get_active_config() {
    if [ ! -f "$ACTIVE_CONFIG" ]; then
        echo "❌ No active config found at $ACTIVE_CONFIG" >&2
        echo "  Run 'codex profile <name>' first to activate a profile." >&2
        exit 1
    fi
    cat "$ACTIVE_CONFIG"
}

backup_config() {
    cp "$ACTIVE_CONFIG" "${ACTIVE_CONFIG}.bak"
}

toml_escape() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

toml_validate() {
    local content="$1"
    local quotes
    quotes=$(echo "$content" | tr -cd '"' | wc -c)
    if [ $((quotes % 2)) -ne 0 ]; then
        return 1
    fi
    local open_brackets close_brackets
    open_brackets=$(echo "$content" | tr -cd '[' | wc -c)
    close_brackets=$(echo "$content" | tr -cd ']' | wc -c)
    if [ "$open_brackets" -ne "$close_brackets" ]; then
        return 1
    fi
    return 0
}

set_config_field() {
    local key="$1"
    local value="$2"
    local escaped
    escaped=$(toml_escape "$value")
    local content
    content=$(get_active_config)
    backup_config

    if echo "$content" | grep -q "^${key}[[:space:]]*="; then
        content=$(echo "$content" | sed "s|^\(${key}[[:space:]]*=[[:space:]]*\)\"[^\"]*\"|\1\"${escaped}\"|")
    elif echo "$content" | grep -q "^model_provider[[:space:]]*="; then
        content=$(echo "$content" | sed "s|^\(model_provider[[:space:]]*=[[:space:]]*\"[^\"]*\"\)|\1\n${key} = \"${escaped}\"|")
    else
        echo "❌ Cannot set '$key': no 'model_provider' line found in config" >&2
        echo "  The config file may be corrupted or improperly formatted." >&2
        exit 1
    fi

    if ! toml_validate "$content"; then
        cp "${ACTIVE_CONFIG}.bak" "$ACTIVE_CONFIG"
        echo "❌ Failed to write config: unbalanced quotes or brackets" >&2
        echo "  Changes reverted from backup." >&2
        exit 1
    fi

    echo "$content" > "$ACTIVE_CONFIG"
    echo "✅ $key set to '$value'"
}

get_provider_defaults() {
    case "$1" in
        openai)       echo "base_url=https://api.openai.com/v1 env_key=OPENAI_API_KEY name=OpenAI" ;;
        openrouter)   echo "base_url=https://openrouter.ai/api/v1 env_key=OPENROUTER_API_KEY name=OpenRouter" ;;
        anthropic)    echo "base_url=https://api.anthropic.com/v1 env_key=ANTHROPIC_API_KEY name=Anthropic" ;;
        ollama)       echo "base_url=http://localhost:11434/v1 env_key=OLLAMA_API_KEY name=Ollama" ;;
        opencode-zen) echo "base_url=https://opencode.ai/zen/v1 env_key=OPENCODE_API_KEY name=OpenCode Zen" ;;
        *) echo "" ;;
    esac
}

to_section_name() {
    # For opencode-zen, section name must be "openai" (OpenAI-compatible)
    if [ "$1" = "opencode-zen" ]; then
        echo "openai"
    else
        echo "$1"
    fi
}

# ── Dispatch ─────────────────────────────────────────────────────

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    list)
        echo "Active config ($ACTIVE_CONFIG):"
        echo ""

        grep -E '^(model_provider|model)[[:space:]]*=' "$ACTIVE_CONFIG" 2>/dev/null | while IFS='=' read -r k v; do
            k=$(echo "$k" | xargs)
            v=$(echo "$v" | xargs | tr -d '"')
            echo "  $k = $v"
        done

        grep -E '^\[model_providers\.' "$ACTIVE_CONFIG" 2>/dev/null | while IFS= read -r line; do
            echo "  $line"
        done
        grep -E '^(name|base_url|env_key)[[:space:]]*=' "$ACTIVE_CONFIG" 2>/dev/null | while IFS='=' read -r k v; do
            k=$(echo "$k" | xargs)
            v=$(echo "$v" | xargs | tr -d '"')
            echo "    $k = $v"
        done

        echo "  [tools]"
        grep -E '^(web_search|file_browser)[[:space:]]*=' "$ACTIVE_CONFIG" 2>/dev/null | while IFS='=' read -r k v; do
            k=$(echo "$k" | xargs)
            v=$(echo "$v" | xargs)
            echo "    $k = $v"
        done

        plugin_count=$(grep -cE '^\[plugins\.' "$ACTIVE_CONFIG" 2>/dev/null || echo 0)
        mcp_count=$(grep -cE '^\[mcp_servers\.' "$ACTIVE_CONFIG" 2>/dev/null || echo 0)
        echo "  Plugins: $plugin_count enabled"
        echo "  MCP Servers: $mcp_count configured"
        ;;

    get)
        if [ $# -lt 1 ]; then
            echo "Usage: codex config get <key>" >&2
            exit 1
        fi
        key="$1"
        value=$(grep -E "^${key}[[:space:]]*=" "$ACTIVE_CONFIG" 2>/dev/null | head -1 | sed 's/^[^=]*=[[:space:]]*"*\([^"]*\)"*/\1/' | xargs)
        if [ -z "$value" ]; then
            echo "❌ Key '$key' not found in active config" >&2
            exit 1
        fi
        echo "$value"
        ;;

    set)
        if [ $# -lt 2 ]; then
            echo "Usage: codex config set <key> <value>" >&2
            exit 1
        fi
        set_config_field "$1" "$2"
        ;;

    set-model)
        if [ $# -lt 1 ]; then
            echo "Usage: codex config set-model <model>" >&2
            exit 1
        fi
        set_config_field "model" "$1"
        ;;

    set-provider)
        if [ $# -lt 1 ]; then
            echo "Usage: codex config set-provider <provider>" >&2
            echo "  Providers: openai, openrouter, anthropic, ollama, opencode-zen" >&2
            exit 1
        fi
        provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        defaults=$(get_provider_defaults "$provider")
        if [ -z "$defaults" ]; then
            echo "❌ Unknown provider '$provider'" >&2
            exit 1
        fi

        # Parse defaults
        eval "$defaults"
        section_name=$(to_section_name "$provider")

        content=$(get_active_config)
        backup_config

        # Capture the OLD provider BEFORE modifying model_provider
        local current_provider
        current_provider=$(echo "$content" | grep -E '^model_provider[[:space:]]*=' | head -1 | sed 's/^[^"]*"\([^"]*\)".*/\1/')

        # Set model_provider (use section_name for opencode-zen → openai)
        content=$(echo "$content" | sed "s|^model_provider[[:space:]]*=[[:space:]]*\"[^\"]*\"|model_provider = \"${section_name}\"|")

        # Replace or add provider block
        if echo "$content" | grep -qE '^\[model_providers\.'; then
            # Only rename the section matching the current provider, not all sections
            local old_section
            old_section=$(to_section_name "$current_provider")
            content=$(echo "$content" | sed "s|^\[model_providers\.${old_section}\]|[model_providers.${section_name}]|")
            # Update name, base_url, env_key only inside the model_providers block
            content=$(echo "$content" | sed "/^\[model_providers\.${section_name}\]/,/^\[/ s|^name[[:space:]]*=[[:space:]]*\"[^\"]*\"|name = \"${name}\"|")
            content=$(echo "$content" | sed "/^\[model_providers\.${section_name}\]/,/^\[/ s|^base_url[[:space:]]*=[[:space:]]*\"[^\"]*\"|base_url = \"${base_url}\"|")
            content=$(echo "$content" | sed "/^\[model_providers\.${section_name}\]/,/^\[/ s|^env_key[[:space:]]*=[[:space:]]*\"[^\"]*\"|env_key = \"${env_key}\"|")
        else
            content="$content
[model_providers.${section_name}]
name = \"${name}\"
base_url = \"${base_url}\"
env_key = \"${env_key}\""
        fi

        # Validate TOML and rollback on failure
        if ! toml_validate "$content"; then
            cp "${ACTIVE_CONFIG}.bak" "$ACTIVE_CONFIG"
            echo "❌ Failed to write config: unbalanced quotes or brackets" >&2
            echo "  Changes reverted from backup." >&2
            exit 1
        fi

        echo "$content" > "$ACTIVE_CONFIG"
        echo "✅ Provider switched to '$provider'"
        echo "   base_url: $base_url"
        echo "   env_key:  $env_key"
        echo "   ℹ️  Make sure $env_key env var is set."
        ;;

    edit)
        target="$ACTIVE_CONFIG"
        if [ $# -ge 1 ]; then
            profile_file="${WORKSPACE_ROOT}/config/${1}.toml"
            if [ -f "$profile_file" ]; then
                target="$profile_file"
            else
                echo "❌ Profile '$1' not found" >&2
                echo "Available profiles:" >&2
                ls "${WORKSPACE_ROOT}/config/"*.toml 2>/dev/null | while IFS= read -r f; do
                    echo "  - $(basename "$f" .toml)"
                done
                exit 1
            fi
        fi

        editor="${EDITOR:-vi}"
        echo "Opening $target with $editor..."
        $editor "$target"
        ;;

    update-free)
        echo "Refreshing free model fallback chain..."
        bash "${WORKSPACE_ROOT}/scripts/generate-free-profile.sh"
        ;;

    help|--help|-h)
        echo "Usage: codex config <command> [args]"
        echo ""
        echo "Commands:"
        echo "  update-free                   Refresh free model fallback chain from OpenRouter"
        echo "  list                          Show all config fields"
        echo "  get <key>                     Get a config value"
        echo "  set <key> <value>             Set a config value"
        echo "  set-model <model>             Change model quickly"
        echo "  set-provider <provider>       Change provider (openai, openrouter, anthropic, ollama, opencode-zen)"
        echo "  edit [profile]                Edit profile in default editor"
        ;;

    *)
        echo "Unknown command: $COMMAND" >&2
        echo "Usage: codex config <command>" >&2
        exit 1
        ;;
esac
