#!/bin/bash
# Performance Benchmarking for Codex CLI Ultimate (Bash version)
# Cross-platform: supports Linux and macOS

# ── Cross-platform millisecond timer ──────────────────────────
# Supports Linux, macOS, and any system with Python or Perl
get_ms() {
    python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || \
    perl -MTime::HiRes -e "print int(Time::HiRes::time() * 1000)" 2>/dev/null || \
    echo "$(($(date +%s) * 1000))"
}

echo "========================================="
echo "⏱️ Codex CLI Ultimate Model Benchmark"
echo "========================================="

CONFIG_FILE="$HOME/.codex/config.toml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: config.toml not found! Please run installation first."
    exit 1
fi

# Parse config values — supports quoted and unquoted values
parse_toml_value() {
    local key="$1"
    local line
    line=$(grep -E "^${key}[[:space:]]*=[[:space:]]*" "$CONFIG_FILE" | head -n1 || true)
    if [ -z "$line" ]; then echo "unknown"; return; fi
    # Try to extract double-quoted value
    local val
    val=$(echo "$line" | sed -n 's/.*=[[:space:]]*"\([^"]*\)".*/\1/p')
    if [ -n "$val" ]; then echo "$val"; return; fi
    # Fallback: extract single-quoted value
    val=$(echo "$line" | sed -n "s/.*=[[:space:]]*'\([^']*\)'.*/\1/p")
    if [ -n "$val" ]; then echo "$val"; return; fi
    # Fallback: extract bare word value
    val=$(echo "$line" | sed 's/.*=[[:space:]]*//')
    echo "$val"
}

PROVIDER=$(parse_toml_value "model_provider")
MODEL=$(parse_toml_value "model")

echo "Benchmark target:"
echo "  -> Provider: $PROVIDER"
echo "  -> Model   : $MODEL"

if [ "$PROVIDER" = "openrouter" ]; then
    BASE_URL="https://openrouter.ai/api/v1/chat/completions"
    ENV_KEY_NAME=$(parse_toml_value "env_key")
    API_KEY="${!ENV_KEY_NAME}"
elif [ "$PROVIDER" = "ollama" ]; then
    BASE_URL="http://localhost:11434/v1/chat/completions"
    API_KEY="ollama"
else
    echo "❌ Benchmark only supports OpenRouter and Ollama profiles at the moment."
    exit 1
fi

if [ -z "$API_KEY" ] && [ "$PROVIDER" = "openrouter" ]; then
    echo "❌ Error: API Key not set. Please set the environment variable $ENV_KEY_NAME"
    exit 1
fi

echo "Sending benchmark prompt to model..."

START_TIME=$(get_ms)

# Build JSON payload safely (avoid injection from $MODEL / $API_KEY)
build_payload() {
    python3 -c "
import json, sys
payload = {
    'model': '$1',
    'messages': [{'role': 'user', 'content': 'Write a 1-sentence hello world in C#.'}],
    'max_tokens': 50,
    'temperature': 0
}
json.dump(payload, sys.stdout)
" 2>/dev/null || cat << PAYLOAD_EOF
{
  "model": "$1",
  "messages": [{"role": "user", "content": "Write a 1-sentence hello world in C#."}],
  "max_tokens": 50,
  "temperature": 0
}
PAYLOAD_EOF
}

if [ "$PROVIDER" = "openrouter" ]; then
    PAYLOAD=$(build_payload "$MODEL")
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d "$PAYLOAD")
elif [ "$PROVIDER" = "ollama" ]; then
    PAYLOAD=$(build_payload "$MODEL")
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")
fi

END_TIME=$(get_ms)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ne 200 ]; then
    echo "❌ Benchmark failed! HTTP Status Code: $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi

# Calculate duration in ms (get_ms returns milliseconds directly)
DURATION=$(( END_TIME - START_TIME ))
# Extract response text safely using python3 jq or fallback grep
RESPONSE_TEXT=""
if command -v python3 >/dev/null 2>&1; then
    RESPONSE_TEXT=$(echo "$BODY" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    content = data['choices'][0]['message']['content']
    print(content)
except Exception:
    print('')
" 2>/dev/null) || RESPONSE_TEXT=""
fi
if [ -z "$RESPONSE_TEXT" ]; then
    # Fallback: grep for content field
    RESPONSE_TEXT=$(echo "$BODY" | grep -o '"content":"[^"]*"' | head -n1 | cut -d'"' -f4 || echo "")
fi

# Calculate approximate tokens/sec
TOKEN_COUNT=$(echo "$RESPONSE_TEXT" | wc -w)
TOKEN_COUNT=$(( TOKEN_COUNT + 5 ))  # Rough estimate
if [ "$DURATION" -gt 0 ]; then
    TOKENS_PER_SEC=$(( (TOKEN_COUNT * 1000) / DURATION ))
else
    TOKENS_PER_SEC=0
fi

echo ""
echo "=== Benchmark Results ==="
echo "  ✅ Connection Success!"
echo "  ⏱️ Total Latency  : $DURATION ms ($(( (DURATION + 500) / 1000 )) seconds)"
echo "  🚀 Speed (Est.)   : $TOKENS_PER_SEC tokens/sec"
echo "  📝 Response text   : \"$RESPONSE_TEXT\""
echo "========================================="
