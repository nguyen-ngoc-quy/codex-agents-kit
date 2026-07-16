#!/bin/bash
# Codex CLI Ultimate — Smoke Test Suite (Bash version)
# Runs comprehensive checks on the project installation and environment.
# Usage: ./scripts/smoke-test.sh

PASSED=0
FAILED=0

ok()   { echo "  ✅ $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  ❌ $1"; FAILED=$((FAILED + 1)); }

check() {
    local name="$1"
    shift
    echo -n "  🔍 $name ... "
    if "$@" 2>/dev/null; then
        ok ""
    else
        fail ""
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "🧪 Codex CLI Ultimate — Smoke Test Suite"
echo "========================================="
echo ""

# ══════════════════════════════════════════════════════════════
# 1. Project Structure
# ══════════════════════════════════════════════════════════════
echo "--- Project Structure ---"
check "config directory" test -d "$ROOT/config"
check "agents directory" test -d "$ROOT/agents"
check "prompts directory" test -d "$ROOT/prompts"
check "scripts directory" test -d "$ROOT/scripts"
check "docs directory" test -d "$ROOT/docs"
check "bin directory" test -d "$ROOT/bin"
check "mcp directory" test -d "$ROOT/mcp"

# ══════════════════════════════════════════════════════════════
# 2. TOML Config Files
# ══════════════════════════════════════════════════════════════
echo "--- TOML Config Files ---"

COUNT=$(find "$ROOT/config" -name '*.toml' | wc -l)
check "At least 3 TOML files" test "$COUNT" -ge 3

for f in "$ROOT/config"/*.toml; do
    NAME=$(basename "$f")
    check "$NAME is not empty" test -s "$f"
    # Basic TOML check: must have a key=value or section
    check "$NAME has valid content" grep -q '^\[' "$f"
done

# ══════════════════════════════════════════════════════════════
# 3. Agent Files
# ══════════════════════════════════════════════════════════════
echo "--- Agent Files ---"

for AGENT in architect backend debugger devops frontend reviewer tester; do
    check "agents/$AGENT.md exists" test -f "$ROOT/agents/$AGENT.md"
    check "agents/$AGENT.md has instructions" grep -q '```text' "$ROOT/agents/$AGENT.md" 2>/dev/null
done

# ══════════════════════════════════════════════════════════════
# 4. Prompt Files
# ══════════════════════════════════════════════════════════════
echo "--- Prompt Files ---"

for PROMPT in aspnet clean-code docker flutter react python go review sql testing unity; do
    check "prompts/$PROMPT.md exists" test -f "$ROOT/prompts/$PROMPT.md"
done

# ══════════════════════════════════════════════════════════════
# 5. Script Files
# ══════════════════════════════════════════════════════════════
echo "--- Script Files ---"

for SCRIPT in install switch-profile doctor benchmark update init-project load-agent smoke-test; do
    check "scripts/$SCRIPT.sh exists" test -f "$ROOT/scripts/$SCRIPT.sh"
    check "scripts/$SCRIPT.sh is executable" test -x "$ROOT/scripts/$SCRIPT.sh"
done

# ══════════════════════════════════════════════════════════════
# 6. Documentation
# ══════════════════════════════════════════════════════════════
echo "--- Documentation ---"

for DOC in Installation Profiles MCP Agents Prompt-Library Benchmark FAQ Init; do
    check "docs/$DOC.md exists" test -f "$ROOT/docs/$DOC.md"
    check "docs/en/$DOC.md exists" test -f "$ROOT/docs/en/$DOC.md"
done

check "README.md exists" test -f "$ROOT/README.md"
check "docs/en/README.md exists" test -f "$ROOT/docs/en/README.md"
check "CHANGELOG.md exists" test -f "$ROOT/CHANGELOG.md"
check "LICENSE exists" test -f "$ROOT/LICENSE"
check "ROADMAP.md exists" test -f "$ROOT/ROADMAP.md"

# ══════════════════════════════════════════════════════════════
# 7. Infrastructure
# ══════════════════════════════════════════════════════════════
echo "--- Infrastructure ---"
check ".gitignore exists" test -f "$ROOT/.gitignore"
check ".editorconfig exists" test -f "$ROOT/.editorconfig"
check "VERSION exists" test -f "$ROOT/VERSION"
check "CI workflow exists" test -f "$ROOT/.github/workflows/validate.yml"
check "Release workflow exists" test -f "$ROOT/.github/workflows/release.yml"
check "Bug report template exists" test -f "$ROOT/.github/ISSUE_TEMPLATE/bug_report.md"
check "Feature request template exists" test -f "$ROOT/.github/ISSUE_TEMPLATE/feature_request.md"
check "PR template exists" test -f "$ROOT/.github/PULL_REQUEST_TEMPLATE.md"
check "CONTRIBUTING.md exists" test -f "$ROOT/CONTRIBUTING.md"

# ══════════════════════════════════════════════════════════════
# Summary
# ══════════════════════════════════════════════════════════════
echo ""
TOTAL=$((PASSED + FAILED))
echo "========================================="
echo "📊 Results: $PASSED / $TOTAL passed"
if [ "$FAILED" -eq 0 ]; then
    echo "🎉 All smoke tests passed!"
else
    echo "⚠️  $FAILED check(s) failed. Review output above."
fi
echo "========================================="
