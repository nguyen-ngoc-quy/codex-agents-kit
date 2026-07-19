# TOML Editor & OpenCode Zen Profile — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thêm form-based TOML Editor (Web UI + CLI) và OpenCode Zen profile cho Codex CLI Ultimate.

**Architecture:** Web UI dùng form editor với field groups (basic settings, tools, plugins, MCP servers) + raw TOML preview sync; CLI dùng regex-based TOML parse/set với backup & rollback. Backend Express.js mở rộng config route với PUT/GET fields endpoints.

**Tech Stack:** Node.js/Express, Vanilla JS, @iarna/toml, PowerShell 5.1+, Bash

## Global Constraints

- Profile name: chỉ chấp nhận `[a-zA-Z0-9._-]+`
- API keys luôn đọc từ env vars, không hardcode trong .toml
- Mọi thao tác ghi file .toml đều tạo backup `.bak` trước
- Syntax TOML được verify sau khi ghi; rollback nếu fail
- Backward-compatible: không thay đổi cấu trúc TOML hiện tại
- OpenCode Zen dùng `model_provider = "openai"` + custom `base_url`

---
### Task 1: OpenCode Zen Profile + Bug Fixes Còn Lại

**Files:**
- Create: `config/opencode-zen.toml`
- Modify: `config/profiles/custom.toml.example`

**Interfaces:**
- Consumes: Cấu trúc TOML của `config/free.toml` (làm template)
- Produces: File `config/opencode-zen.toml` có thể được switch-profile sử dụng; `custom.toml.example` hoàn chỉnh dùng làm template cho form "create profile"

**Ghi chú:** Các fix H9 (CI), H12-H15 (MCP package names) đã được áp dụng từ trước, không cần làm lại.

- [ ] **Step 1: Tạo file `config/opencode-zen.toml`**

```toml
# Codex Profile: opencode-zen
# Uses OpenCode Zen API — curated models for coding agents
# Website: https://opencode.ai/zen
# Base URL: https://opencode.ai/zen/v1
# recommended_agent: debugger

model_provider = "openai"
model = "deepseek-v4-flash-free"

[model_providers.openai]
name = "OpenCode Zen"
base_url = "https://opencode.ai/zen/v1"
env_key = "OPENCODE_API_KEY"

[tools]
web_search = true
file_browser = true

[windows]
sandbox = "unelevated"

[plugins."test-android-apps@openai-curated"]
enabled = true

[plugins."visualize@openai-bundled"]
enabled = true

[plugins."browser@openai-bundled"]
enabled = true

[plugins."documents@openai-primary-runtime"]
enabled = true

[plugins."pdf@openai-primary-runtime"]
enabled = true

[plugins."spreadsheets@openai-primary-runtime"]
enabled = true

[plugins."presentations@openai-primary-runtime"]
enabled = true

[plugins."template-creator@openai-primary-runtime"]
enabled = true

[plugins."mcp-servers@openai-primary-runtime"]
enabled = true

[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "__WORKSPACE_ROOT__"]

[mcp_servers.git]
command = "npx"
args = ["-y", "@cyanheads/git-mcp-server"]

[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]

[mcp_servers.docker]
command = "npx"
args = ["-y", "@hypnosis/docker-mcp-server"]

[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp"]

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
```

- [ ] **Step 2: Hoàn thiện `config/profiles/custom.toml.example`**

Đồng bộ template để có đầy đủ 8 plugins và 6 MCP servers (copy section plugins và MCP servers từ `free.toml`). Giữ nguyên phần header và cấu trúc hiện tại.

Write the full file content:

```toml
# Custom Profile Template for Codex CLI
# Copy this file, rename it, and adjust values below.
# ⚠️  Never paste API keys here — always use environment variables.

# ── Provider ─────────────────────────────────────────────────────
# Supported providers: openai, openrouter, anthropic, ollama
model_provider = "openrouter"
model = "qwen/qwen-2.5-coder-32b-instruct"  # Replace with your model name
# Examples: "gpt-4o", "claude-sonnet-4-20250514", "qwen/qwen-2.5-coder-32b-instruct", "gemini-2.0-flash"

[model_providers.openrouter]
name = "My Custom Profile"
base_url = "https://openrouter.ai/api/v1"
# Tên của environment variable chứa API key (không phải key value)
env_key = "OPENROUTER_API_KEY"

# ── Tools ────────────────────────────────────────────────────────
[tools]
web_search = true
file_browser = true

[windows]
sandbox = "unelevated"

# ── Plugins ──────────────────────────────────────────────────────
[plugins."test-android-apps@openai-curated"]
enabled = true

[plugins."visualize@openai-bundled"]
enabled = true

[plugins."browser@openai-bundled"]
enabled = true

[plugins."documents@openai-primary-runtime"]
enabled = true

[plugins."pdf@openai-primary-runtime"]
enabled = true

[plugins."spreadsheets@openai-primary-runtime"]
enabled = true

[plugins."presentations@openai-primary-runtime"]
enabled = true

[plugins."template-creator@openai-primary-runtime"]
enabled = true

# ── MCP Servers ──────────────────────────────────────────────────
# The __WORKSPACE_ROOT__ placeholder is replaced with your project path
# by switch-profile scripts automatically.

[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "__WORKSPACE_ROOT__"]

[mcp_servers.git]
command = "npx"
args = ["-y", "@cyanheads/git-mcp-server"]

[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
# Set your GitHub token via env var, then uncomment:
# [mcp_servers.github.env]
# GITHUB_PERSONAL_ACCESS_TOKEN = "${GITHUB_PERSONAL_ACCESS_TOKEN}"

[mcp_servers.docker]
command = "npx"
args = ["-y", "@hypnosis/docker-mcp-server"]

[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp"]

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
```

- [ ] **Step 3: Commit**

```bash
git add config/opencode-zen.toml config/profiles/custom.toml.example
git commit -m "feat: add opencode-zen profile and fix custom.toml.example template"
```

---

### Task 2: CLI Config Command — PowerShell

**Files:**
- Create: `scripts/config.ps1`
- Modify: `bin/codex.ps1`

**Interfaces:**
- Consumes: `bin/codex.ps1` dispatches `"config" { Invoke-Script "config" }`
- Produces: `scripts/config.ps1` with functions: `Get-ConfigPath`, `Get-ActiveConfig`, `Set-ConfigField`, `Backup-Config`

**Key behavior:**
- `codex config list` → in ra key=value của config đang active
- `codex config get <key>` → in ra giá trị
- `codex config set <key> <value>` → set field, backup trước, validate sau
- `codex config set-model <model>` → set model field
- `codex config set-provider <provider>` → set provider + env_key mapping
- `codex config edit [profile]` → mở editor mặc định
- Tất cả subcommand đều validate đầu vào

- [ ] **Step 1: Tạo `scripts/config.ps1`**

```powershell
# Config Manager for Codex CLI Ultimate
# Usage: .\scripts\config.ps1 <command> [args]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('list', 'get', 'set', 'set-model', 'set-provider', 'edit')]
    [string]$Command,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

# ── Path resolution ──────────────────────────────────────────────
$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$codexHome = Join-Path $env:USERPROFILE ".codex"
$activeConfig = Join-Path $codexHome "config.toml"

function Get-ConfigPath {
    return $activeConfig
}

function Get-ActiveConfig {
    if (-not (Test-Path $activeConfig)) {
        Write-Host "❌ No active config found at $activeConfig" -ForegroundColor Red
        Write-Host "  Run 'codex profile <name>' first to activate a profile." -ForegroundColor Yellow
        exit 1
    }
    return Get-Content $activeConfig -Raw
}

function Backup-Config {
    $backup = "$activeConfig.bak"
    Copy-Item -Path $activeConfig -Destination $backup -Force
    return $backup
}

function Set-ConfigField {
    param([string]$Key, [string]$Value)
    $content = Get-ActiveConfig
    Backup-Config

    # Escape backslashes and quotes for TOML
    $escapedValue = $Value.Replace('\', '\\').Replace('"', '\"')

    if ($content -match "(?m)^$Key\s*=\s*""[^""]*""") {
        $content = $content -replace "(?m)^($Key\s*=\s*)""[^""]*""", "`$1`"$escapedValue`""
    } elseif ($content -match "(?m)^$Key\s*=\s*(true|false)") {
        $content = $content -replace "(?m)^($Key\s*=\s*)(true|false)", "`$1`"$escapedValue`""
    } else {
        # Key doesn't exist — append after model_provider line
        $content = $content -replace "(?m)^(model_provider\s*=\s*""[^""]*"")", "`$1`n$Key = `"$escapedValue`""
    }

    # Validate TOML by re-parsing (basic check)
    try {
        # PowerShell doesn't have built-in TOML parser, do a basic quote balance check
        $openQuotes = [regex]::Matches($content, '"').Count
        if ($openQuotes % 2 -ne 0) {
            throw "Unbalanced quotes in TOML"
        }
        # Also check for common TOML errors: unclosed brackets
        $openBrackets = [regex]::Matches($content, '\[').Count
        $closeBrackets = [regex]::Matches($content, '\]').Count
        if ($openBrackets -ne $closeBrackets) {
            throw "Unbalanced brackets in TOML"
        }
    } catch {
        # Rollback
        Copy-Item -Path "$activeConfig.bak" -Destination $activeConfig -Force
        Write-Host "❌ Failed to write config: $_" -ForegroundColor Red
        Write-Host "  Changes reverted from backup." -ForegroundColor Yellow
        exit 1
    }

    Set-Content -Path $activeConfig -Value $content -Force
    Write-Host "✅ $Key set to '$Value'" -ForegroundColor Green
}

function Get-ProviderDefaults {
    param([string]$ProviderName)
    $defaults = @{
        "openai" = @{ base_url = "https://api.openai.com/v1"; env_key = "OPENAI_API_KEY" }
        "openrouter" = @{ base_url = "https://openrouter.ai/api/v1"; env_key = "OPENROUTER_API_KEY" }
        "anthropic" = @{ base_url = "https://api.anthropic.com/v1"; env_key = "ANTHROPIC_API_KEY" }
        "ollama" = @{ base_url = "http://localhost:11434/v1"; env_key = "OLLAMA_API_KEY" }
        "opencode-zen" = @{ base_url = "https://opencode.ai/zen/v1"; env_key = "OPENCODE_API_KEY" }
    }
    return $defaults[$ProviderName]
}

# ── Dispatch ─────────────────────────────────────────────────────
switch ($Command) {
    "list" {
        $content = Get-ActiveConfig
        Write-Host "Active config ($activeConfig):" -ForegroundColor Cyan
        Write-Host ""

        # Extract and display key fields
        $fields = @('model_provider', 'model')
        foreach ($f in $fields) {
            if ($content -match "(?m)^$f\s*=\s*""([^""]+)""") {
                Write-Host "  $f = $($Matches[1])" -ForegroundColor White
            }
        }

        # Provider block
        if ($content -match "(?m)^\[model_providers\.(\w+)\]") {
            $providerName = $Matches[1]
            Write-Host "  [model_providers.$providerName]" -ForegroundColor Gray
            if ($content -match "(?m)^name\s*=\s*""([^""]+)""") {
                Write-Host "    name = $($Matches[1])" -ForegroundColor White
            }
            if ($content -match "(?m)^base_url\s*=\s*""([^""]+)""") {
                Write-Host "    base_url = $($Matches[1])" -ForegroundColor White
            }
            if ($content -match "(?m)^env_key\s*=\s*""([^""]+)""") {
                $keyName = $Matches[1]
                $isSet = [Environment]::GetEnvironmentVariable($keyName)
                $status = if ($isSet) { "✅ set" } else { "❌ not set" }
                Write-Host "    env_key = $keyName  ($status)" -ForegroundColor White
            }
        }

        # Tools
        Write-Host "  [tools]" -ForegroundColor Gray
        if ($content -match "(?m)^web_search\s*=\s*(true|false)") {
            Write-Host "    web_search = $($Matches[1])" -ForegroundColor White
        }
        if ($content -match "(?m)^file_browser\s*=\s*(true|false)") {
            Write-Host "    file_browser = $($Matches[1])" -ForegroundColor White
        }

        # Plugins count
        $pluginCount = [regex]::Matches($content, '(?m)^\[plugins\."').Count
        Write-Host "  Plugins: $pluginCount enabled" -ForegroundColor Gray

        # MCP count
        $mcpCount = [regex]::Matches($content, '(?m)^\[mcp_servers\.\w+\]').Count
        Write-Host "  MCP Servers: $mcpCount configured" -ForegroundColor Gray
    }

    "get" {
        if ($Args.Count -lt 1) {
            Write-Host "Usage: codex config get <key>" -ForegroundColor Yellow
            Write-Host "  Example: codex config get model" -ForegroundColor Gray
            exit 1
        }
        $key = $Args[0]
        $content = Get-ActiveConfig

        # Try simple key first
        if ($content -match "(?m)^$key\s*=\s*""([^""]+)""") {
            Write-Host $Matches[1]
        } elseif ($content -match "(?m)^$key\s*=\s*(true|false)") {
            Write-Host $Matches[1]
        } else {
            Write-Host "❌ Key '$key' not found in active config" -ForegroundColor Red
            exit 1
        }
    }

    "set" {
        if ($Args.Count -lt 2) {
            Write-Host "Usage: codex config set <key> <value>" -ForegroundColor Yellow
            Write-Host "  Example: codex config set model gpt-4o" -ForegroundColor Gray
            exit 1
        }
        $key = $Args[0]
        $value = $Args[1]

        if ([string]::IsNullOrEmpty($value)) {
            Write-Host "❌ Cannot set '$key' to empty value" -ForegroundColor Red
            exit 1
        }

        Set-ConfigField -Key $key -Value $value
    }

    "set-model" {
        if ($Args.Count -lt 1) {
            Write-Host "Usage: codex config set-model <model>" -ForegroundColor Yellow
            Write-Host "  Example: codex config set-model gpt-4o" -ForegroundColor Gray
            exit 1
        }
        Set-ConfigField -Key "model" -Value $Args[0]
    }

    "set-provider" {
        if ($Args.Count -lt 1) {
            Write-Host "Usage: codex config set-provider <provider>" -ForegroundColor Yellow
            Write-Host "  Providers: openai, openrouter, anthropic, ollama, opencode-zen" -ForegroundColor Gray
            exit 1
        }
        $provider = $Args[0].ToLower()
        $defaults = Get-ProviderDefaults -ProviderName $provider
        if (-not $defaults) {
            Write-Host "❌ Unknown provider '$provider'" -ForegroundColor Red
            Write-Host "  Supported: openai, openrouter, anthropic, ollama, opencode-zen" -ForegroundColor Yellow
            exit 1
        }

        Backup-Config
        $content = Get-ActiveConfig

        # Set model_provider
        $content = $content -replace '(?m)^model_provider\s*=\s*"[^"]*"', "model_provider = `"$provider`""

        # Replace or add [model_providers.X] block
        $providerHeader = "[model_providers.$provider]"
        if ($content -match "(?m)^\[model_providers\.\w+\]") {
            # Replace existing provider block header
            $content = $content -replace '(?m)^\[model_providers\.\w+\]', $providerHeader
            # Update base_url and env_key inside the block
            $content = $content -replace "(?m)^(name\s*=\s*)"".*""", "`$1`"$($defaults.name)`""
            $content = $content -replace "(?m)^(base_url\s*=\s*)"".*""", "`$1`"$($defaults.base_url)`""
            $content = $content -replace "(?m)^(env_key\s*=\s*)"".*""", "`$1`"$($defaults.env_key)`""
        } else {
            # Append provider block at end of file
            $content += "`n$providerHeader`n"
            $content += "name = `"$provider`"`n"
            $content += "base_url = `"$($defaults.base_url)`"`n"
            $content += "env_key = `"$($defaults.env_key)`"`n"
        }

        Set-Content -Path $activeConfig -Value $content -Force
        Write-Host "✅ Provider switched to '$provider'" -ForegroundColor Green
        Write-Host "   base_url: $($defaults.base_url)" -ForegroundColor Gray
        Write-Host "   env_key:  $($defaults.env_key)" -ForegroundColor Gray
        Write-Host "   ℹ️  Make sure $($defaults.env_key) env var is set." -ForegroundColor Yellow
    }

    "edit" {
        $targetFile = $activeConfig
        if ($Args.Count -ge 1) {
            $profileFile = Join-Path $workspaceRoot "config" "$($Args[0]).toml"
            if (Test-Path $profileFile) {
                $targetFile = $profileFile
            } else {
                Write-Host "❌ Profile '$($Args[0])' not found" -ForegroundColor Red
                Write-Host "Available profiles:" -ForegroundColor Gray
                Get-ChildItem (Join-Path $workspaceRoot "config") -Filter "*.toml" | ForEach-Object {
                    Write-Host "  - $($_.BaseName)" -ForegroundColor Cyan
                }
                exit 1
            }
        }

        # Find editor
        $editor = $env:EDITOR
        if (-not $editor) {
            # Try VS Code first, then notepad
            $codeCmd = Get-Command "code" -ErrorAction SilentlyContinue
            if ($codeCmd) {
                $editor = "code"
            } else {
                $editor = "notepad.exe"
            }
        }

        Write-Host "Opening $targetFile with $editor..." -ForegroundColor Cyan
        & $editor $targetFile
        if ($LASTEXITCODE -ne 0 -and $editor -eq "notepad.exe") {
            # notepad always returns 0 on normal close, so this is fine
        }
    }
}
```

- [ ] **Step 2: Thêm "config" dispatch vào `bin/codex.ps1`**

Add `"config"` case after the `"openrouter"` case (around line 111):

Edit `bin/codex.ps1`:

old:
```powershell
        "openrouter" {
            & (Join-Path $WorkspaceRoot "scripts" "list-openrouter-models.ps1") $RemainingArgs[1..($RemainingArgs.Count - 1)]
        }
```

new:
```powershell
        "openrouter" {
            & (Join-Path $WorkspaceRoot "scripts" "list-openrouter-models.ps1") $RemainingArgs[1..($RemainingArgs.Count - 1)]
        }
        "config" { Invoke-Script "config" }
```

Also update the help text (around line 75-86). Add to the help:

old:
```powershell
            Write-Host "  codex openrouter [opts] List free models from OpenRouter" -ForegroundColor White
```

new:
```powershell
            Write-Host "  codex openrouter [opts] List free models from OpenRouter" -ForegroundColor White
            Write-Host "  codex config <cmd>    Manage config (list/get/set/set-model/set-provider/edit)" -ForegroundColor White
```

And update the profile list in profile command help (line 96):

old:
```powershell
                Get-ChildItem (Join-Path $WorkspaceRoot "config") -Filter "*.toml" | ForEach-Object {
```

new:
```powershell
                Write-Host "  Try: free, premium, local, ollama, openrouter, opencode-zen" -ForegroundColor Gray
                Get-ChildItem (Join-Path $WorkspaceRoot "config") -Filter "*.toml" | ForEach-Object {
```

- [ ] **Step 3: Commit**

```bash
git add scripts/config.ps1 bin/codex.ps1
git commit -m "feat: add CLI config command (PowerShell)"
```

---

### Task 3: CLI Config Command — Bash

**Files:**
- Create: `scripts/config.sh`

**Interfaces:**
- Consumes: Called directly or via `codex config` (Bash environment)
- Produces: Same interface as PowerShell version — `list`, `get`, `set`, `set-model`, `set-provider`, `edit`

**Note:** Bash version uses sed/awk for TOML manipulation. Must be POSIX-compatible.

- [ ] **Step 1: Tạo `scripts/config.sh`**

```bash
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
    # Escape backslashes and quotes for TOML string values
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

set_config_field() {
    local key="$1"
    local value="$2"
    local escaped
    escaped=$(toml_escape "$value")
    local content
    content=$(get_active_config)
    backup_config

    # Ubuntu has older sed that doesn't support -E well; use compatible pattern
    if echo "$content" | grep -q "^${key}[[:space:]]*="; then
        # Key exists — replace value
        content=$(echo "$content" | sed "s|^\(${key}[[:space:]]*=[[:space:]]*\)\"[^\"]*\"|\1\"${escaped}\"|")
    else
        # Key doesn't exist — append after model_provider
        content=$(echo "$content" | sed "s|^\(model_provider[[:space:]]*=[[:space:]]*\"[^\"]*\"\)|\1\n${key} = \"${escaped}\"|")
    fi

    # Basic TOML validation: check quote balance
    local quotes
    quotes=$(echo "$content" | tr -cd '"' | wc -c)
    if [ $((quotes % 2)) -ne 0 ]; then
        # Rollback
        cp "${ACTIVE_CONFIG}.bak" "$ACTIVE_CONFIG"
        echo "❌ Failed to write config: unbalanced quotes" >&2
        echo "  Changes reverted from backup." >&2
        exit 1
    fi

    echo "$content" > "$ACTIVE_CONFIG"
    echo "✅ $key set to '$value'"
}

get_provider_defaults() {
    case "$1" in
        openai)       echo "base_url=https://api.openai.com/v1 env_key=OPENAI_API_KEY" ;;
        openrouter)   echo "base_url=https://openrouter.ai/api/v1 env_key=OPENROUTER_API_KEY" ;;
        anthropic)    echo "base_url=https://api.anthropic.com/v1 env_key=ANTHROPIC_API_KEY" ;;
        ollama)       echo "base_url=http://localhost:11434/v1 env_key=OLLAMA_API_KEY" ;;
        opencode-zen) echo "base_url=https://opencode.ai/zen/v1 env_key=OPENCODE_API_KEY" ;;
        *) echo "" ;;
    esac
}

# ── Dispatch ─────────────────────────────────────────────────────

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    list)
        echo "Active config ($ACTIVE_CONFIG):"
        echo ""

        # Model provider and model
        grep -E '^(model_provider|model)[[:space:]]*=' "$ACTIVE_CONFIG" 2>/dev/null | while IFS='=' read -r k v; do
            k=$(echo "$k" | xargs)
            v=$(echo "$v" | xargs | tr -d '"')
            echo "  $k = $v"
        done

        # Provider block
        grep -E '^\[model_providers\.' "$ACTIVE_CONFIG" 2>/dev/null | while IFS= read -r line; do
            echo "  $line"
        done
        grep -E '^(name|base_url|env_key)[[:space:]]*=' "$ACTIVE_CONFIG" 2>/dev/null | while IFS='=' read -r k v; do
            k=$(echo "$k" | xargs)
            v=$(echo "$v" | xargs | tr -d '"')
            echo "    $k = $v"
        done

        # Tools
        echo "  [tools]"
        grep -E '^(web_search|file_browser)[[:space:]]*=' "$ACTIVE_CONFIG" 2>/dev/null | while IFS='=' read -r k v; do
            k=$(echo "$k" | xargs)
            v=$(echo "$v" | xargs)
            echo "    $k = $v"
        done

        # Count plugins and MCP servers
        local plugin_count mcp_count
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
            echo "  Supported: openai, openrouter, anthropic, ollama, opencode-zen" >&2
            exit 1
        fi

        backup_config
        local content
        content=$(get_active_config)

        # Parse defaults
        eval "$defaults"

        # Set model_provider
        content=$(echo "$content" | sed "s|^model_provider[[:space:]]*=[[:space:]]*\"[^\"]*\"|model_provider = \"${provider}\"|")

        # Replace or add provider block
        if echo "$content" | grep -qE '^\[model_providers\.'; then
            content=$(echo "$content" | sed "s|^\(\[model_providers\)\.\([^]]*\)\]|\1.${provider}]|")
            # We can't easily update multi-line blocks with sed, so use a temp approach
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

    help|--help|-h)
        echo "Usage: codex config <command> [args]"
        echo ""
        echo "Commands:"
        echo "  list                          Show all config fields"
        echo "  get <key>                     Get a config value"
        echo "  set <key> <value>             Set a config value"
        echo "  set-model <model>             Change model quickly"
        echo "  set-provider <provider>       Change provider (openai, openrouter, anthropic, ollama, opencode-zen)"
        echo "  edit [profile]                Edit profile in default editor"
        echo ""
        echo "Examples:"
        echo "  codex config set-model gpt-4o"
        echo "  codex config set-provider opencode-zen"
        ;;

    *)
        echo "Unknown command: $COMMAND" >&2
        echo "Usage: codex config <command>" >&2
        exit 1
        ;;
esac
```

- [ ] **Step 2: Commit**

```bash
chmod +x scripts/config.sh
git add scripts/config.sh
git commit -m "feat: add CLI config command (Bash)"
```

---

### Task 4: Backend — PUT and Fields Endpoints

**Files:**
- Modify: `ui/routes/config.js`

**Interfaces:**
- Consumes: `@iarna/toml` (already in dependencies)
- Produces:
  - `PUT /api/profiles/:name` — save edited profile, validate, backup, rollback
  - `GET /api/profiles/:name/fields` — return profile as structured field groups

**Key behavior for PUT:**
1. Backup profile `.toml` → `.toml.bak`
2. Parse incoming TOML string with `@iarna/toml.parse()`
3. If parse fails → return error 400 (don't write)
4. Write to file
5. Re-read and re-parse to verify
6. If re-parse fails → rollback from `.bak` → return error 500

**Key behavior for GET fields:**
1. Read `.toml` file
2. Parse with `@iarna/toml.parse()`
3. Return structured object with: basicSettings, tools, plugins, mcpServers

- [ ] **Step 1: Thêm GET fields endpoint vào `ui/routes/config.js`**

Add before the `module.exports` line:

```javascript
  // GET /api/profiles/:name/fields — get profile as structured field groups
  app.get('/api/profiles/:name/fields', (req, res) => {
    const profile = profiles().find(p => p.name === req.params.name);
    if (!profile) return res.status(404).json({ error: 'Profile not found' });

    try {
      const raw = fs.readFileSync(profile.path, 'utf8');
      const data = toml.parse(raw);

      const providerName = data.model_provider || 'openai';
      const providerConfig = data.model_providers ? data.model_providers[providerName] : {};

      const fields = {
        basicSettings: {
          provider: data.model_provider || 'openai',
          model: data.model || '',
          displayName: providerConfig?.name || '',
          baseUrl: providerConfig?.base_url || '',
          envKey: providerConfig?.env_key || '',
        },
        tools: {
          webSearch: data.tools?.web_search !== false,
          fileBrowser: data.tools?.file_browser !== false,
        },
        plugins: [],
        mcpServers: [],
      };

      // Plugins
      if (data.plugins) {
        for (const [key, val] of Object.entries(data.plugins)) {
          fields.plugins.push({ name: key, enabled: val.enabled !== false });
        }
      }

      // MCP Servers
      if (data.mcp_servers) {
        for (const [key, val] of Object.entries(data.mcp_servers)) {
          fields.mcpServers.push({
            name: key,
            command: val.command || '',
            args: Array.isArray(val.args) ? val.args : [],
            env: val.env || {},
          });
        }
      }

      res.json({ name: profile.name, fields, raw });
    } catch (err) {
      res.status(500).json({ error: `Failed to parse profile: ${err.message}` });
    }
  });
```

- [ ] **Step 2: Thêm PUT endpoint vào `ui/routes/config.js`**

Add after the GET fields endpoint:

```javascript
  // PUT /api/profiles/:name — save edited profile
  app.put('/api/profiles/:name', (req, res) => {
    const profile = profiles().find(p => p.name === req.params.name);
    if (!profile) return res.status(404).json({ error: 'Profile not found' });

    const { content } = req.body;
    if (!content || typeof content !== 'string') {
      return res.status(400).json({ error: 'Missing "content" field (TOML string)' });
    }

    // 1. Validate TOML syntax before writing
    try {
      toml.parse(content);
    } catch (err) {
      return res.status(400).json({
        error: `Invalid TOML syntax: ${err.message}`,
        line: err.line || null,
        col: err.col || null,
      });
    }

    // 2. Backup existing file
    const backupPath = profile.path + '.bak';
    try {
      fs.copyFileSync(profile.path, backupPath);
    } catch (err) {
      return res.status(500).json({ error: `Failed to backup profile: ${err.message}` });
    }

    // 3. Write new content
    try {
      fs.writeFileSync(profile.path, content, 'utf8');
    } catch (err) {
      // Restore backup
      try { fs.copyFileSync(backupPath, profile.path); } catch (_) {}
      return res.status(500).json({ error: `Failed to write profile: ${err.message}` });
    }

    // 4. Re-read and verify
    try {
      const written = fs.readFileSync(profile.path, 'utf8');
      toml.parse(written);
    } catch (err) {
      // Rollback
      try {
        fs.copyFileSync(backupPath, profile.path);
        fs.unlinkSync(backupPath);
      } catch (_) {}
      return res.status(500).json({
        error: `Saved profile has invalid TOML. Changes reverted: ${err.message}`,
      });
    }

    // Clean up backup on success
    try { fs.unlinkSync(backupPath); } catch (_) {}

    res.json({ success: true, name: profile.name });
  });
```

- [ ] **Step 3: Thêm require cho toml ở đầu file**

Add at top of `ui/routes/config.js` (after existing requires):

```javascript
const toml = require('@iarna/toml');
```

- [ ] **Step 4: Commit**

```bash
git add ui/routes/config.js
git commit -m "feat: add PUT and GET /fields endpoints for profile editor"
```

---

### Task 5: Web UI — API Client Mở Rộng

**Files:**
- Modify: `ui/public/js/api.js`

**Interfaces:**
- Consumes: Backend PUT and GET fields endpoints from Task 4
- Produces: `API.updateProfile(name, content)`, `API.getProfileFields(name)` — used by profiles.js page

**Key behavior:**
- `getProfileFields(name)` → GET `/api/profiles/:name/fields` → returns structured fields
- `updateProfile(name, content)` → PUT `/api/profiles/:name` with body `{ content }`

- [ ] **Step 1: Thêm API methods vào `ui/public/js/api.js`**

Add after the existing `createProfile` method (around line 48):

```javascript
    // === Profile Editor ===
    getProfileFields: (name) => request('GET', `/api/profiles/${encodeURIComponent(name)}/fields`),
    updateProfile: (name, content) => request('PUT', `/api/profiles/${encodeURIComponent(name)}`, { content }),
```

Also add `setConfigField` if needed (optional — primarily used by CLI, but can add here for future use):

```javascript
    setConfigField: (key, value) => request('PUT', '/api/config/set', { key, value }),
```

- [ ] **Step 2: Commit**

```bash
git add ui/public/js/api.js
git commit -m "feat: add profile editor API methods"
```

---

### Task 6: Web UI — Profile Editor Page

**Files:**
- Modify: `ui/public/js/pages/profiles.js`

**Interfaces:**
- Consumes: `API.getProfileFields()`, `API.updateProfile()`, `API.switchProfile()`, `API.getProfiles()`
- Produces: Form editor UI với 5 sections (basic settings, tools, plugins, MCP servers, raw TOML preview)

**Key behavior:**
- Click "Edit" button trên profile card → vào edit mode
- Form fields populated từ API fields response
- Raw TOML preview sync real-time khi form thay đổi
- Save → PUT API → toast success/error → back to list
- Cancel → confirmation dialog if dirty → back to list

- [ ] **Step 1: Thêm `PageProfiles` vào `ui/public/js/pages/profiles.js`**

Replace the entire file content with the expanded version:

```javascript
/**
 * Profiles page — list, switch, view, create, and edit profiles.
 */
const PageProfiles = (() => {
  // ── State ────────────────────────────────────────────────────
  let editingProfile = null;   // { name, fields, raw } when editing
  let formDirty = false;

  // ── Main Render (list view) ──────────────────────────────────
  async function render(renderFn) {
    const data = await API.getProfiles();

    const html = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <p style="color:var(--text-secondary)">${data.profiles.length} profiles found</p>
        <button class="btn btn-primary" onclick="PageProfiles.showCreateModal()">+ New Profile</button>
      </div>
      <div class="grid grid-2">
        ${data.profiles.map(p => `
          <div class="card ${p.isActive ? 'active-profile' : ''}" style="${p.isActive ? 'border-color:var(--accent-green)' : ''}">
            <div class="card-header">
              <div style="display:flex;align-items:center;gap:8px">
                <h3>${p.name}</h3>
                ${p.isActive ? '<span class="badge badge--active">Active</span>' : ''}
              </div>
            </div>
            <div class="card-body">
              <div class="info-row"><span class="info-label">Provider</span><span class="info-value">${p.provider}</span></div>
              <div class="info-row"><span class="info-label">Model</span><span class="info-value"><code>${p.model}</code></span></div>
              ${p.recommendedAgent ? `<div class="info-row"><span class="info-label">Agent</span><span class="info-value">${p.recommendedAgent}</span></div>` : ''}
            </div>
            <div class="card-footer" style="display:flex;gap:8px">
              ${!p.isActive ? `<button class="btn btn-sm btn-success" onclick="PageProfiles.switchProfile('${p.name}')">Switch</button>` : ''}
              <button class="btn btn-sm" onclick="PageProfiles.editProfile('${p.name}')">Edit</button>
              <button class="btn btn-sm" onclick="PageProfiles.viewProfile('${p.name}')">View TOML</button>
            </div>
          </div>
        `).join('')}
      </div>
    `;

    renderFn(html);
  }

  // ── Edit Profile ─────────────────────────────────────────────
  async function editProfile(name) {
    try {
      const data = await API.getProfileFields(name);
      editingProfile = { name: data.name, fields: data.fields, raw: data.raw };
      formDirty = false;
      renderEditForm();
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  function renderEditForm() {
    const p = editingProfile;
    const f = p.fields;
    const area = document.getElementById('content-area');

    const providerOptions = ['openai', 'openrouter', 'anthropic', 'ollama'];

    const html = `
      <div class="edit-profile-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <h2 style="margin:0">✏️ Edit Profile: <code>${p.name}.toml</code></h2>
        <div style="display:flex;gap:8px">
          <button class="btn btn-success" onclick="PageProfiles.saveProfile()" ${formDirty ? '' : 'disabled'}>💾 Save</button>
          <button class="btn" onclick="PageProfiles.cancelEdit()">Cancel</button>
        </div>
      </div>

      <div class="edit-form">
        <!-- Basic Settings -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Basic Settings</h3></div>
          <div class="card-body">
            <div class="form-row">
              <label class="form-label">Provider</label>
              <select class="form-input" id="edit-provider" onchange="PageProfiles.onFormChange()">
                ${providerOptions.map(opt => `<option value="${opt}" ${f.basicSettings.provider === opt ? 'selected' : ''}>${opt}</option>`).join('')}
              </select>
            </div>
            <div class="form-row">
              <label class="form-label">Model</label>
              <input class="form-input" id="edit-model" value="${escapeHtml(f.basicSettings.model)}" oninput="PageProfiles.onFormChange()">
            </div>
            <div class="form-row">
              <label class="form-label">Display Name</label>
              <input class="form-input" id="edit-display-name" value="${escapeHtml(f.basicSettings.displayName)}" oninput="PageProfiles.onFormChange()">
            </div>
            <div class="form-row">
              <label class="form-label">Base URL</label>
              <input class="form-input" id="edit-base-url" value="${escapeHtml(f.basicSettings.baseUrl)}" oninput="PageProfiles.onFormChange()">
            </div>
            <div class="form-row">
              <label class="form-label">API Env Var</label>
              <input class="form-input" id="edit-env-key" value="${escapeHtml(f.basicSettings.envKey)}" placeholder="OPENAI_API_KEY" oninput="PageProfiles.onFormChange()" style="text-transform:uppercase">
            </div>
          </div>
        </div>

        <!-- Tools -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Tools</h3></div>
          <div class="card-body">
            <label class="checkbox-row"><input type="checkbox" id="edit-web-search" ${f.tools.webSearch ? 'checked' : ''} onchange="PageProfiles.onFormChange()"> Web Search</label>
            <label class="checkbox-row"><input type="checkbox" id="edit-file-browser" ${f.tools.fileBrowser ? 'checked' : ''} onchange="PageProfiles.onFormChange()"> File Browser</label>
          </div>
        </div>

        <!-- Plugins -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Plugins (${f.plugins.length})</h3></div>
          <div class="card-body">
            <div class="grid grid-2">
              ${f.plugins.map((pl, i) => `
                <label class="checkbox-row">
                  <input type="checkbox" id="plugin-${i}" ${pl.enabled ? 'checked' : ''} onchange="PageProfiles.onFormChange()">
                  ${escapeHtml(pl.name)}
                </label>
              `).join('')}
            </div>
          </div>
        </div>

        <!-- MCP Servers -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header" style="display:flex;justify-content:space-between;align-items:center">
            <h3>MCP Servers</h3>
            <button class="btn btn-sm" onclick="PageProfiles.addMcpServer()">+ Add</button>
          </div>
          <div class="card-body" id="mcp-list">
            ${f.mcpServers.map((mcp, i) => renderMcpRow(mcp, i)).join('')}
          </div>
        </div>

        <!-- Raw TOML Preview -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Raw TOML Preview (read-only)</h3></div>
          <div class="card-body">
            <pre class="code-block" id="raw-toml-preview" style="max-height:400px;overflow:auto;font-size:12px">${escapeHtml(p.raw)}</pre>
          </div>
        </div>
      </div>

      <div style="display:flex;justify-content:flex-end;gap:8px;margin-bottom:32px">
        <button class="btn btn-success" onclick="PageProfiles.saveProfile()" ${formDirty ? '' : 'disabled'}>💾 Save</button>
        <button class="btn" onclick="PageProfiles.cancelEdit()">Cancel</button>
      </div>
    `;

    area.innerHTML = html;
  }

  function renderMcpRow(mcp, index) {
    const argsStr = Array.isArray(mcp.args) ? mcp.args.join(', ') : mcp.args || '';
    const envStr = mcp.env && typeof mcp.env === 'object'
      ? Object.entries(mcp.env).map(([k, v]) => `${k}=${v}`).join(', ')
      : '';
    return `
      <div class="mcp-row" style="border:1px solid var(--border-color);border-radius:var(--radius-md);padding:12px;margin-bottom:8px">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
          <strong>${escapeHtml(mcp.name)}</strong>
          <button class="btn btn-sm btn-danger" onclick="PageProfiles.removeMcpServer(${index})">Remove</button>
        </div>
        <div class="form-row">
          <label class="form-label">Command</label>
          <input class="form-input mcp-cmd" value="${escapeHtml(mcp.command)}" oninput="PageProfiles.onMcpChange(${index}, 'command', this.value)">
        </div>
        <div class="form-row">
          <label class="form-label">Args (comma-separated)</label>
          <input class="form-input mcp-args" value="${escapeHtml(argsStr)}" oninput="PageProfiles.onMcpChange(${index}, 'args', this.value)">
        </div>
        ${envStr ? `<div class="form-row"><label class="form-label">Env</label><input class="form-input mcp-env" value="${escapeHtml(envStr)}" oninput="PageProfiles.onMcpChange(${index}, 'env', this.value)"></div>` : ''}
      </div>
    `;
  }

  // ── Form Handlers ────────────────────────────────────────────
  function onFormChange() {
    formDirty = true;
    // Re-enable save button
    document.querySelectorAll('.btn-success').forEach(b => b.disabled = false);
    updateRawPreview();
  }

  function onMcpChange(index, field, value) {
    if (!editingProfile) return;
    const mcp = editingProfile.fields.mcpServers[index];
    if (!mcp) return;

    if (field === 'args') {
      mcp.args = value.split(',').map(s => s.trim()).filter(Boolean);
    } else if (field === 'env') {
      const env = {};
      value.split(',').forEach(pair => {
        const parts = pair.trim().split('=');
        if (parts.length >= 2) env[parts[0].trim()] = parts.slice(1).join('=').trim();
      });
      mcp.env = env;
    } else if (field === 'command') {
      mcp.command = value;
    }
    formDirty = true;
    document.querySelectorAll('.btn-success').forEach(b => b.disabled = false);
  }

  function addMcpServer() {
    if (!editingProfile) return;
    const name = prompt('Enter MCP server name:');
    if (!name || !/^[a-zA-Z0-9_-]+$/.test(name)) return;
    editingProfile.fields.mcpServers.push({ name, command: 'npx', args: ['-y', 'package-name'], env: {} });
    renderEditForm();
  }

  function removeMcpServer(index) {
    if (!editingProfile) return;
    editingProfile.fields.mcpServers.splice(index, 1);
    formDirty = true;
    renderEditForm();
  }

  function updateRawPreview() {
    // Generate TOML from form state
    const f = editingProfile.fields;
    const provider = document.getElementById('edit-provider')?.value || f.basicSettings.provider;
    const model = document.getElementById('edit-model')?.value || f.basicSettings.model;
    const displayName = document.getElementById('edit-display-name')?.value || f.basicSettings.displayName;
    const baseUrl = document.getElementById('edit-base-url')?.value || f.basicSettings.baseUrl;
    const envKey = document.getElementById('edit-env-key')?.value || f.basicSettings.envKey;
    const webSearch = document.getElementById('edit-web-search')?.checked ?? f.tools.webSearch;
    const fileBrowser = document.getElementById('edit-file-browser')?.checked ?? f.tools.fileBrowser;

    let toml = `model_provider = "${provider}"\n`;
    toml += `model = "${model}"\n\n`;
    toml += `[model_providers.${provider}]\n`;
    toml += `name = "${displayName}"\n`;
    toml += `base_url = "${baseUrl}"\n`;
    toml += `env_key = "${envKey}"\n\n`;
    toml += `[tools]\nweb_search = ${webSearch}\nfile_browser = ${fileBrowser}\n\n`;
    toml += `[windows]\nsandbox = "unelevated"\n\n`;

    // Plugins
    const pluginCheckboxes = document.querySelectorAll('[id^="plugin-"]');
    const pluginNames = f.plugins;
    pluginCheckboxes.forEach((cb, i) => {
      if (pluginNames[i]) {
        toml += `[plugins."${pluginNames[i].name}"]\nenabled = ${cb.checked}\n\n`;
      }
    });

    // MCP Servers
    const mcpRows = document.querySelectorAll('.mcp-row');
    mcpRows.forEach((row, i) => {
      const mcp = f.mcpServers[i];
      if (!mcp) return;
      toml += `[mcp_servers.${mcp.name}]\n`;
      const cmd = row.querySelector('.mcp-cmd')?.value || mcp.command;
      const argsStr = row.querySelector('.mcp-args')?.value || mcp.args.join(', ');
      const args = argsStr.split(',').map(s => `"${s.trim()}"`).join(', ');
      toml += `command = "${cmd}"\n`;
      toml += `args = [${args}]\n`;
      if (mcp.env && Object.keys(mcp.env).length > 0) {
        toml += `[mcp_servers.${mcp.name}.env]\n`;
        for (const [k, v] of Object.entries(mcp.env)) {
          toml += `${k} = "${v}"\n`;
        }
      }
      toml += '\n';
    });

    const preview = document.getElementById('raw-toml-preview');
    if (preview) {
      preview.textContent = toml;
    }
  }

  // ── Save / Cancel ────────────────────────────────────────────
  async function saveProfile() {
    if (!editingProfile || !formDirty) return;

    // Collect form state into TOML
    const f = editingProfile.fields;
    const provider = document.getElementById('edit-provider')?.value || f.basicSettings.provider;
    const model = document.getElementById('edit-model')?.value || f.basicSettings.model;

    // Basic validation
    if (!model.trim()) {
      API.showToast('Model name cannot be empty', 'error');
      return;
    }

    const rawPreview = document.getElementById('raw-toml-preview');
    const content = rawPreview ? rawPreview.textContent : '';

    try {
      await API.updateProfile(editingProfile.name, content);
      API.showToast(`Profile "${editingProfile.name}" saved`, 'success');
      editingProfile = null;
      formDirty = false;
      render(render);
    } catch (err) {
      API.showToast(`Save failed: ${err.message}`, 'error');
    }
  }

  function cancelEdit() {
    if (formDirty) {
      if (!confirm('Discard unsaved changes?')) return;
    }
    editingProfile = null;
    formDirty = false;
    render(render);
  }

  // ── Existing Methods ─────────────────────────────────────────
  async function switchProfile(name) {
    try {
      const result = await API.switchProfile(name);
      API.showToast(`Switched to ${name}`, 'success');
      render(render);
    } catch (err) {
      API.showToast(`Switch failed: ${err.message}`, 'error');
    }
  }

  async function viewProfile(name) {
    try {
      const data = await API.getProfile(name);
      Modal.open(`${name}.toml`, `<pre class="code-block">${escapeHtml(data.content)}</pre>`);
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  async function showCreateModal() {
    const body = `
      <form id="create-profile-form" onsubmit="PageProfiles.createProfile(event)">
        <div style="margin-bottom:12px">
          <label style="display:block;margin-bottom:4px;font-weight:500">Profile Name</label>
          <input type="text" name="name" required pattern="[a-zA-Z0-9._-]+"
                 style="width:100%;padding:8px 12px;border:1px solid var(--border-color);border-radius:var(--radius-md);background:var(--bg-secondary);color:var(--text-primary);font-family:inherit"
                 placeholder="my-custom-profile">
          <small style="color:var(--text-muted)">Alphanumeric, dots, hyphens, and underscores only</small>
        </div>
        <div style="margin-bottom:16px">
          <label style="display:block;margin-bottom:4px;font-weight:500">Base Profile (optional)</label>
          <select name="baseProfile"
                  style="width:100%;padding:8px 12px;border:1px solid var(--border-color);border-radius:var(--radius-md);background:var(--bg-secondary);color:var(--text-primary);font-family:inherit">
            <option value="">Custom template (profiles/custom.toml.example)</option>
          </select>
        </div>
        <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center">Create</button>
      </form>
    `;
    Modal.open('Create New Profile', body);

    const data = await API.getProfiles();
    const select = document.querySelector('[name="baseProfile"]');
    data.profiles.forEach(p => {
      const opt = document.createElement('option');
      opt.value = p.name;
      opt.textContent = `${p.name} (${p.provider}/${p.model})`;
      select.appendChild(opt);
    });
  }

  async function createProfile(event) {
    event.preventDefault();
    const form = event.target;
    const name = form.name.value.trim();
    const baseProfile = form.baseProfile.value || undefined;

    try {
      await API.createProfile({ name, baseProfile });
      Modal.close();
      API.showToast(`Profile "${name}" created`, 'success');
      render(render);
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  // ── Public API ───────────────────────────────────────────────
  return {
    render,
    switchProfile,
    viewProfile,
    editProfile,
    saveProfile,
    cancelEdit,
    showCreateModal,
    createProfile,
    onFormChange,
    onMcpChange,
    addMcpServer,
    removeMcpServer,
  };
})();
```

- [ ] **Step 2: Commit**

```bash
git add ui/public/js/pages/profiles.js
git commit -m "feat: add form-based profile editor in Web UI"
```

---

### Task 7: Web UI — CSS cho Form Editor

**Files:**
- Modify: `ui/public/css/app.css`

**Interfaces:**
- Consumes: New HTML elements from profiles.js (form rows, checkboxes, MCP rows)
- Produces: Styled form editor UI matching existing dark/light theme

- [ ] **Step 1: Thêm CSS rules cho form editor**

Append to `ui/public/css/app.css`:

```css
/* ── Form Editor ──────────────────────────────────────────── */
.form-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.form-label {
  min-width: 130px;
  font-size: 0.875rem;
  color: var(--text-secondary);
  flex-shrink: 0;
}

.form-input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  background: var(--bg-secondary);
  color: var(--text-primary);
  font-family: inherit;
  font-size: 0.875rem;
  transition: border-color 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: var(--accent-blue);
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
}

.form-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

select.form-input {
  cursor: pointer;
  appearance: auto;
}

.checkbox-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 0;
  cursor: pointer;
  font-size: 0.875rem;
  color: var(--text-primary);
}

.checkbox-row input[type="checkbox"] {
  width: 16px;
  height: 16px;
  cursor: pointer;
  accent-color: var(--accent-blue);
}

.btn-danger {
  background: var(--danger-bg, #dc2626);
  color: white;
}

.btn-danger:hover {
  background: var(--danger-hover, #b91c1c);
}

.edit-form .card {
  border: 1px solid var(--border-color);
}

.edit-form .card-header {
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 8px;
  margin-bottom: 12px;
}

.mcp-row {
  transition: background-color 0.2s;
}

.mcp-row:hover {
  background: var(--bg-hover, rgba(128, 128, 128, 0.05));
}
```

- [ ] **Step 2: Commit**

```bash
git add ui/public/css/app.css
git commit -m "style: add form editor CSS classes"
```

---

### Task 8: Web UI — System Integration (Env Key Check)

**Files:**
- Modify: `ui/routes/system.js`
- Modify: `scripts/install.ps1`

- [ ] **Step 1: Thêm OPENCODE_API_KEY vào env key check trong `ui/routes/system.js`**

Find the env key list (around line 105-108) and add:

```javascript
          checkEnvKey('OPENCODE_API_KEY'),
```

- [ ] **Step 2: Thêm opencode-zen vào completion message trong `scripts/install.ps1`**

Find the Available commands section (around line 253-258) and add:

```powershell
Write-Host "  codex profile opencode-zen - Switch to OpenCode Zen (free)" -ForegroundColor White
```

- [ ] **Step 3: Commit**

```bash
git add ui/routes/system.js scripts/install.ps1
git commit -m "feat: add OPENCODE_API_KEY env check and opencode-zen profile help"
```

---

### Task 9: Smoke Test & Verification

**Files:**
- Modify: `scripts/smoke-test.ps1`
- Modify: `scripts/smoke-test.sh`

**Note:** The smoke tests should verify the new config command and profile work.

- [ ] **Step 1: Verify CLI config command (manual smoke test)**

```powershell
# 1. Activate any profile first
.\bin\codex.ps1 profile free

# 2. List config
.\scripts\config.ps1 list

# 3. Get a field
.\scripts\config.ps1 get model

# 4. Set a field
.\scripts\config.ps1 set-model test-model

# 5. Verify it changed
.\scripts\config.ps1 get model
# Expected: test-model

# 6. Reset back
.\scripts\config.ps1 set-model "qwen/qwen-2.5-coder-32b-instruct:free"

# 7. Test set-provider
.\scripts\config.ps1 set-provider opencode-zen
.\scripts\config.ps1 list
# Expected: provider = opencode-zen, base_url = https://opencode.ai/zen/v1

# 8. Switch back
.\bin\codex.ps1 profile free
```

- [ ] **Step 2: Verify Web UI endpoints**

```powershell
# Start UI server
cd ui
npm start

# In another terminal, test the endpoints
curl -s http://localhost:3456/api/profiles/free/fields | head -50

# Test save
$content = Get-Content "../config/free.toml" -Raw
curl -s -X PUT http://localhost:3456/api/profiles/free -H "Content-Type: application/json" -Body '{"content":"test"}'
# Expected: 400 error for invalid TOML

# Proper save test
curl -s -X PUT http://localhost:3456/api/profiles/free -H "Content-Type: application/json" -Body "{`"content`": `"$($content.Replace('"','\"'))`"}"
# Expected: {"success":true,"name":"free"}
```

- [ ] **Step 3: Verify OpenCode Zen profile**

```powershell
# Switch to opencode-zen
.\bin\codex.ps1 profile opencode-zen

# Check config
.\scripts\config.ps1 list

# Expected output:
#   model_provider = openai
#   model = deepseek-v4-flash-free
#   [model_providers.openai]
#   name = OpenCode Zen
#   base_url = https://opencode.ai/zen/v1
#   env_key = OPENCODE_API_KEY

# Verify env key check (user will set this themselves)
.\scripts\config.ps1 get env_key
# Expected: OPENCODE_API_KEY
```

- [ ] **Step 4: Commit smoke test updates if any**

```bash
git add -A
git commit -m "chore: final cleanup and smoke test verification"
```
