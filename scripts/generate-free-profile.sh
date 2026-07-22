#!/usr/bin/env bash
# Generate/update auto-fallback model chain in Free OpenRouter profile.
# Bash equivalent of generate-free-profile.ps1
# Usage: bash scripts/generate-free-profile.sh [--dry-run] [--offline] [--max-models 10] [--min-context 8192]

set -euo pipefail

# -- Path resolution --
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILE_FILE="${WORKSPACE_ROOT}/config/free.toml"
DRY_RUN=false
OFFLINE=false
MIN_CONTEXT=8192
MAX_MODELS=10

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --offline) OFFLINE=true; shift ;;
    --min-context) MIN_CONTEXT="$2"; shift 2 ;;
    --max-models) MAX_MODELS="$2"; shift 2 ;;
    --profile-file) PROFILE_FILE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Hardcoded fallback list
FALLBACK_MODELS=(
  "qwen/qwen-2.5-coder-32b-instruct:free"
  "deepseek/deepseek-r1:free"
  "google/gemini-2.5-flash:free"
  "meta-llama/llama-3.3-70b-instruct:free"
  "nvidia/nemotron-3-ultra-550b-a55b:free"
)

echo "== Fetching free models from OpenRouter..."

MODEL_IDS=()

if [ "$OFFLINE" = false ]; then
  API_KEY="${OPENROUTER_API_KEY:-}"
  if [ -n "$API_KEY" ]; then
    RESPONSE=$(curl -s --max-time 15 \
      -H "Authorization: Bearer $API_KEY" \
      "https://openrouter.ai/api/v1/models" 2>/dev/null || echo "")

    if [ -n "$RESPONSE" ]; then
      # Use python3 to parse JSON, filter free models, and prioritize
      # tr -d '\r' strips carriage returns from Windows-style python3 output
      PRIORITIZED=$(python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
models = data.get('data', [])
free = []
for m in models:
    mid = m.get('id', '')
    pricing = m.get('pricing', {})
    ctx = m.get('context_length', 0) or 0
    # Filter free: :free suffix OR zero pricing
    if mid.endswith(':free') or (pricing.get('prompt') == '0' and pricing.get('completion') == '0'):
        score = 0
        mid_lower = mid.lower()
        tier = 0
        if any(kw in mid_lower for kw in ['coder', 'code', 'qwen', 'deepseek-coder', 'codestral', 'starcoder']):
            tier = 2
        elif ctx >= 32000 and any(kw in mid_lower for kw in ['r1', 'reasoning', 'think', 'deepseek']):
            tier = 1
        score = (tier * 1000000) + min(ctx, 999999)
        free.append((score, mid))

free.sort(key=lambda x: -x[0])
for _, mid in free:
    print(mid)
" <<< "$RESPONSE" 2>/dev/null | tr -d '\r' || true)

      if [ -n "$PRIORITIZED" ]; then
        while IFS= read -r line; do
          [ -n "$line" ] && MODEL_IDS+=("$line")
        done <<< "$PRIORITIZED"
        echo "OK: Found ${#MODEL_IDS[@]} free models via API."
      fi
    fi

    if [ ${#MODEL_IDS[@]} -eq 0 ]; then
      echo "Warning: API call failed or returned no free models." >&2
    fi
  else
    echo "Warning: OPENROUTER_API_KEY not set." >&2
  fi
fi

# Fallback to hardcoded list
if [ ${#MODEL_IDS[@]} -eq 0 ]; then
  echo "Using built-in fallback model list."
  MODEL_IDS=("${FALLBACK_MODELS[@]}")
fi

# Take top N
MODEL_IDS=("${MODEL_IDS[@]:0:$MAX_MODELS}")

if [ ${#MODEL_IDS[@]} -eq 0 ]; then
  echo "ERROR: No models available for fallback chain." >&2
  exit 1
fi

echo ""
echo "Fallback chain (${#MODEL_IDS[@]} models):"
for i in "${!MODEL_IDS[@]}"; do
  LABEL="Alt $i"
  [ "$i" -eq 0 ] && LABEL="Primary"
  echo "   $((i+1)). ${MODEL_IDS[$i]}  [$LABEL]"
done

# Build TOML block (models as comma-separated string per Codex CLI map<string,string> spec)
QUERY_PARAMS_BLOCK=$(cat <<EOF

[model_providers.openrouter.query_params]
models = "$(
  IFS=,
  printf '%s' "${MODEL_IDS[*]}"
)"
route = "fallback"
EOF
)

if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "========================================"
  echo " DRY RUN - Proposed changes to:"
  echo " $PROFILE_FILE"
  echo "========================================"
  echo "$QUERY_PARAMS_BLOCK"
  echo "========================================"
  echo ""
  echo "Run without --dry-run to apply these changes."
  exit 0
fi

# Read and update file
if [ ! -f "$PROFILE_FILE" ]; then
  echo "ERROR: Profile not found: $PROFILE_FILE" >&2
  exit 1
fi

# Backup
cp "$PROFILE_FILE" "$PROFILE_FILE.bak"

# Check if query_params already exists
if grep -q '\[model_providers\.openrouter\.query_params\]' "$PROFILE_FILE" 2>/dev/null; then
  echo "Replacing existing query_params section..."
  # Remove existing query_params block
  sed -i '/^\[model_providers\.openrouter\.query_params\]/,/^\[/ { /^\[model_providers\.openrouter\.query_params\]/d; /^\[/!d; }' "$PROFILE_FILE"
  # Clean up trailing blank lines
  sed -i '/^$/N;/^\n$/D' "$PROFILE_FILE"
  sed -i '${/^$/d;}' "$PROFILE_FILE"
fi

# Find env_key line and insert after it
if grep -q 'env_key = "OPENROUTER_API_KEY"' "$PROFILE_FILE"; then
  sed -i '/env_key = "OPENROUTER_API_KEY"/r /dev/stdin' "$PROFILE_FILE" <<< "$QUERY_PARAMS_BLOCK"
else
  echo "ERROR: Could not find [model_providers.openrouter] section in $PROFILE_FILE" >&2
  exit 1
fi

echo ""
echo "OK: Updated $PROFILE_FILE"
echo "   Backup saved to $PROFILE_FILE.bak"
echo "   ${#MODEL_IDS[@]} models in fallback chain with route = 'fallback'"
