#!/usr/bin/env bash
# List free models from OpenRouter API.
# Usage: bash scripts/list-openrouter-models.sh [--json] [--all]
#
# Options:
#   --json     Output raw JSON instead of formatted table
#   --all      Show all models (not just free)

set -euo pipefail

API_KEY="${OPENROUTER_API_KEY:-}"

if [ -z "$API_KEY" ]; then
    echo "❌ OPENROUTER_API_KEY not set." >&2
    echo "   export OPENROUTER_API_KEY='sk-or-v1-...'" >&2
    exit 1
fi

echo "📡 Fetching models from OpenRouter..." >&2

RESPONSE=$(curl -s --max-time 15 \
    -H "Authorization: Bearer $API_KEY" \
    "https://openrouter.ai/api/v1/models")

if [ -z "$RESPONSE" ]; then
    echo "❌ No response from API." >&2
    exit 1
fi

# Parse options
JSON_MODE=false
ALL_MODE=false
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --all) ALL_MODE=true ;;
    esac
done

if $JSON_MODE; then
    if $ALL_MODE; then
        echo "$RESPONSE" | python3 -m json.tool
    else
        echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
free = [m for m in data.get('data', []) if m.get('id', '').endswith(':free')]
print(json.dumps(free, indent=2))
"
    fi
    exit 0
fi

# Format as table
if $ALL_MODE; then
    echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
models = data.get('data', [])
# Sort by context length desc
models.sort(key=lambda m: m.get('context_length', 0) or 0, reverse=True)
print(f'\n📋 Found {len(models)} models\n')
print(f'{\"Model ID\":<55} {\"Context\":>8} {\"Prompt $\":>10} {\"Completion $\":>12}')
print('-' * 85)
for m in models:
    ctx = str(m.get('context_length', '?'))
    pp = str(m.get('pricing', {}).get('prompt', '?'))
    cp = str(m.get('pricing', {}).get('completion', '?'))
    print(f'{m[\"id\"]:<55} {ctx:>8} {pp:>10} {cp:>12}')
"
else
    echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
free = [m for m in data.get('data', []) if m.get('id', '').endswith(':free')]
free.sort(key=lambda m: m.get('context_length', 0) or 0, reverse=True)
print(f'\n📋 Found {len(free)} free models\n')
print(f'{\"Model ID\":<55} {\"Context\":>8} {\"Prompt $\":>10} {\"Completion $\":>12}')
print('-' * 85)
for m in free:
    ctx = str(m.get('context_length', '?'))
    pp = str(m.get('pricing', {}).get('prompt', '?'))
    cp = str(m.get('pricing', {}).get('completion', '?'))
    print(f'{m[\"id\"]:<55} {ctx:>8} {pp:>10} {cp:>12}')
print()
# Recommended coding models
coding = [m for m in free if 'coder' in m['id'] or 'code' in m['id'] or 'qwen' in m['id']]
if coding:
    print('💡 Recommended for coding:')
    for m in coding:
        print(f'   {m[\"id\"]}')
"
fi
