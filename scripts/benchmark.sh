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

PROVIDER=$(grep -E '^model_provider[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 || echo "unknown")
MODEL=$(grep -E '^model[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 || echo "unknown")

echo "Benchmark target:"
echo "  -> Provider: $PROVIDER"
echo "  -> Model   : $MODEL"

if [ "$PROVIDER" = "openrouter" ]; then
    BASE_URL="https://openrouter.ai/api/v1/chat/completions"
    ENV_KEY_NAME=$(grep -E '^env_key[[:space:]]*=[[:space:]]*' "$CONFIG_FILE" | head -n1 | cut -d'"' -f2 || echo "OPENROUTER_API_KEY")
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

if [ "$PROVIDER" = "openrouter" ]; then
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d '{
        "model": "'"$MODEL"'",
        "messages": [{"role": "user", "content": "Write a 1-sentence hello world in C#."}],
        "max_tokens": 50,
        "temperature": 0
      }')
else
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "'"$MODEL"'",
        "messages": [{"role": "user", "content": "Write a 1-sentence hello world in C#."}],
        "max_tokens": 50,
        "temperature": 0
      }')
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
RESPONSE_TEXT=$(echo "$BODY" | grep -o '"content":"[^"]*"' | head -n1 | cut -d'"' -f4 || echo "")

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
