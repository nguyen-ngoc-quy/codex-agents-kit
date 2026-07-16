#!/bin/bash
# Codex CLI Ultimate — Documentation Fetcher
# Downloads framework documentation for offline AI context.
# Usage:   ./scripts/fetch-docs.sh [framework]
# Example: ./scripts/fetch-docs.sh aspnet
#          ./scripts/fetch-docs.sh list

set -e

FRAMEWORK="${1:-list}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$WORKSPACE_ROOT/docs/fetched"

# ── Framework sources ──────────────────────────────────────
declare -A SOURCES
SOURCES[aspnet]="ASP.NET Core"
SOURCES[flutter]="Flutter"
SOURCES[unity]="Unity"

# ── List available frameworks ──────────────────────────────
if [ "$FRAMEWORK" = "list" ]; then
    echo "Available frameworks:"
    for key in aspnet flutter unity; do
        echo "  - $key  (${SOURCES[$key]})"
    done
    echo ""
    echo "Usage: ./scripts/fetch-docs.sh <framework>"
    echo "Example: ./scripts/fetch-docs.sh aspnet"
    exit 0
fi

# ── Validate framework ─────────────────────────────────────
if [ -z "${SOURCES[$FRAMEWORK]:-}" ]; then
    echo "❌ Unknown framework: '$FRAMEWORK'"
    echo "Available frameworks:"
    for key in aspnet flutter unity; do echo "  - $key"; done
    exit 1
fi

FULL_NAME="${SOURCES[$FRAMEWORK]}"

# ── URLs per framework ─────────────────────────────────────
ASPNET_URLS=(
    "https://learn.microsoft.com/en-us/aspnet/core/fundamentals/?view=aspnetcore-9.0"
    "https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-9.0"
)

FLUTTER_URLS=(
    "https://docs.flutter.dev/reference/widgets"
    "https://api.flutter.dev/flutter/material/material-library.html"
)

UNITY_URLS=(
    "https://docs.unity3d.com/Manual/index.html"
    "https://docs.unity3d.com/ScriptReference/index.html"
)

# Pick the right URL list
case "$FRAMEWORK" in
    aspnet)   URLS=("${ASPNET_URLS[@]}") ;;
    flutter)  URLS=("${FLUTTER_URLS[@]}") ;;
    unity)    URLS=("${UNITY_URLS[@]}") ;;
esac

# ── Create output dir ──────────────────────────────────────
mkdir -p "$DOCS_DIR/$FRAMEWORK"
OUT_DIR="$DOCS_DIR/$FRAMEWORK"

# ── Fetch docs ─────────────────────────────────────────────
echo "📥 Fetching $FULL_NAME documentation..."
SUCCESS=0
FAILED=0

for URL in "${URLS[@]}"; do
    FILENAME=$(basename "${URL%%\?*}")
    if [ -z "$FILENAME" ]; then FILENAME="index.html"; fi
    if [[ "$FILENAME" != *.html ]]; then FILENAME="${FILENAME}.html"; fi
    OUTFILE="$OUT_DIR/$FILENAME"

    echo "  Fetching: $URL"
    if curl -sL -o "$OUTFILE" --max-time 30 "$URL" 2>/dev/null; then
        echo "    ✅ Saved to: $OUTFILE"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "    ❌ Error downloading $URL"
        FAILED=$((FAILED + 1))
    fi
done

# ── Summary ────────────────────────────────────────────────
TOTAL=$((SUCCESS + FAILED))
echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "✅ $SUCCESS / $TOTAL files fetched for '$FRAMEWORK'"
else
    echo "⚠️  $SUCCESS / $TOTAL files fetched for '$FRAMEWORK' ($FAILED failed)"
fi

if [ "$SUCCESS" -gt 0 ]; then
    echo ""
    echo "📂 Docs saved to: $OUT_DIR"
    echo ""
    echo "💡 Use these docs as AI context:"
    echo "   Add the files under docs/fetched/ as context when working with Codex CLI."
fi
