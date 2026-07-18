# Diagnostics Script for Codex CLI
# Checks environment, API keys, endpoints, CLI pathing, and MCP dependencies

# Error policy: Continue — each check reports independently; one failure shouldn't skip others
$ErrorActionPreference = "Continue"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "👨‍⚕️ Codex CLI Ultimate Health Diagnostics" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$allPassed = $true

# ── Helper functions ──────────────────────────────────────────────
function Write-Check {
    param([string]$Message)
    Write-Host -NoNewline $Message
}

function Write-Pass {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    $script:allPassed = $false
}

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

# ═══════════════════════════════════════════════════════════════════
# 1. System Information
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n--- System Info ---" -ForegroundColor Cyan
Write-Host "  OS         : $([Environment]::OSVersion.VersionString)" -ForegroundColor Gray
Write-Host "  PowerShell : $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "  User       : $env:USERNAME" -ForegroundColor Gray

# ═══════════════════════════════════════════════════════════════════
# 2. Active Config File
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n--- Active Configuration ---" -ForegroundColor Cyan
$configFile = Join-Path $env:USERPROFILE ".codex\config.toml"
Write-Check "  Config file... "
if (Test-Path $configFile) {
    Write-Pass "Found"
    Write-Host "    Path: $configFile" -ForegroundColor Gray

    $content = Get-Content $configFile -Raw
    $provider = ""
    $model = ""
    if ($content -match 'model_provider\s*=\s*"([^"]+)"') { $provider = $Matches[1] }
    if ($content -match 'model\s*=\s*"([^"]+)"') { $model = $Matches[1] }
    Write-Host "    Provider: $provider" -ForegroundColor Yellow
    Write-Host "    Model   : $model" -ForegroundColor Yellow
} else {
    Write-Fail "Config file not found at $configFile"
    Write-Host "    -> Run install.ps1 first" -ForegroundColor Gray
}

# ═══════════════════════════════════════════════════════════════════
# 3. Codex CLI Availability
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n--- Codex CLI ---" -ForegroundColor Cyan
Write-Check "  Binary detection... "
$codexPath = $null

# Check CODEX_CLI_PATH env var
$codexPath = [Environment]::GetEnvironmentVariable("CODEX_CLI_PATH", "User")
if (-not $codexPath -or -not (Test-Path $codexPath)) {
    $codexPath = [Environment]::GetEnvironmentVariable("CODEX_CLI_PATH", "Machine")
}
if (-not $codexPath -or -not (Test-Path $codexPath)) {
    # Try codex.exe first, then codex.cmd (npm global install)
    foreach ($name in @("codex.exe", "codex.cmd")) {
        try { $codexPath = (Get-Command $name -ErrorAction Stop).Source; break } catch {}
    }
}

if ($codexPath -and (Test-Path $codexPath)) {
    Write-Pass "Found"
    Write-Host "    Path: $codexPath" -ForegroundColor Gray

    # Try to get version
    Write-Check "  Version... "
    try {
        $versionOutput = & $codexPath --version 2>&1
        Write-Pass "$($versionOutput -join ' ')"
    } catch {
        Write-Warn "Could not determine version"
    }
} else {
    Write-Fail "Codex CLI binary not found"
    Write-Host "    -> Ensure Codex CLI is installed and in PATH" -ForegroundColor Gray
}

# ═══════════════════════════════════════════════════════════════════
# 4. Runtime Dependencies
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n--- Runtime Dependencies ---" -ForegroundColor Cyan

# Node.js
Write-Check "  Node.js... "
try {
    $nodeVer = (node --version 2>&1)
    Write-Pass "$($nodeVer -join '')"
} catch {
    Write-Fail "Node.js not found (required for MCP servers via npx)"
}

# npm / npx
Write-Check "  npx... "
try {
    $npxVer = (npx --version 2>&1)
    Write-Pass "$($npxVer -join '')"
} catch {
    Write-Fail "npx not found (required to run MCP servers)"
}

# Git
Write-Check "  Git... "
try {
    $gitVer = (git --version 2>&1)
    Write-Pass "$($gitVer -join '')"
} catch {
    Write-Warn "Git not found (some MCP features will be unavailable)"
}

# ═══════════════════════════════════════════════════════════════════
# 5. Provider Connectivity
# ═══════════════════════════════════════════════════════════════════
if ($provider -eq "openrouter") {
    Write-Host "`n--- OpenRouter ---" -ForegroundColor Cyan

    # API Key (env only)
    Write-Check "  API Key... "
    $envKeyName = "OPENROUTER_API_KEY"
    if ($content -match 'env_key\s*=\s*"([^"]+)"') {
        $envKeyName = $Matches[1]
    }

    $apiKey = [System.Environment]::GetEnvironmentVariable($envKeyName)
    if (-not $apiKey -or $apiKey -eq "OPENROUTER_API_KEY") {
        Write-Fail "Environment variable '$envKeyName' is empty or not set"
        Write-Host "    -> Set it: `$env:$envKeyName = 'sk-or-v1-...'" -ForegroundColor Gray
    } else {
        $maskedKey = $apiKey.Substring(0, [Math]::Min(12, $apiKey.Length)) + "..."
        Write-Pass "Configured ($maskedKey)"
    }

    # Connectivity
    Write-Check "  API connectivity... "
    try {
        $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/models" -Method Get -TimeoutSec 5
        if ($response -and $response.data) {
            Write-Pass "Connected ($($response.data.Count) models available)"
        } else {
            Write-Fail "Response structure invalid"
        }
    } catch {
        Write-Fail "Cannot reach OpenRouter API — $($_.Exception.Message)"
        Write-Host "    -> Check internet connection or proxy" -ForegroundColor Gray
    }
} elseif ($provider -eq "ollama") {
    Write-Host "`n--- Ollama (Local LLM) ---" -ForegroundColor Cyan

    Write-Check "  Service... "
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 3
        if ($response -and $response.models) {
            $localModels = $response.models | ForEach-Object { $_.name }
            Write-Pass "Connected"
            Write-Host "    Local models:" -ForegroundColor Gray
            foreach ($m in $localModels) {
                Write-Host "      - $m" -ForegroundColor Gray
            }

            if ($localModels -contains $model) {
                Write-Host "    ✅ Model '$model' is ready" -ForegroundColor Green
            } else {
                Write-Warn "Active model '$model' is not pulled"
                Write-Host "    -> Run 'ollama pull $model'" -ForegroundColor Gray
            }
        } else {
            Write-Fail "Unexpected API response"
        }
    } catch {
        Write-Fail "Ollama is not running"
        Write-Host "    -> Start Ollama or run 'ollama serve'" -ForegroundColor Gray
    }
}

# ═══════════════════════════════════════════════════════════════════
# 6. MCP Server Dependencies (quick check)
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n--- MCP Servers (cached) ---" -ForegroundColor Cyan
Write-Host "  (Run 'npx -y @modelcontextprotocol/server-*' to install on first use)" -ForegroundColor Gray

# Check if MCP packages are already cached in npm
$mcpPackages = @(
    "@modelcontextprotocol/server-filesystem",
    "@modelcontextprotocol/server-git",
    "@modelcontextprotocol/server-github",
    "@modelcontextprotocol/server-docker",
    "@modelcontextprotocol/server-playwright"
)

foreach ($pkg in $mcpPackages) {
    Write-Check "  $pkg... "
    $pkgName = $pkg.Split('/')[-1]
    # Check npm cache for the package (fast, doesn't install)
    $cacheResult = npx -y --no-install $pkg --help 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "cached"
    } else {
        Write-Warn "not cached (will download on first use)"
    }
}

# ═══════════════════════════════════════════════════════════════════
# 7. Network Connectivity
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n--- Network ---" -ForegroundColor Cyan
Write-Check "  Internet... "
try {
    $null = Invoke-WebRequest -Uri "https://clients3.google.com/generate_204" -TimeoutSec 5 -UseBasicParsing
    Write-Pass "Connected"
} catch {
    Write-Warn "No internet connectivity detected (offline mode)"
}

# ═══════════════════════════════════════════════════════════════════
# Final Verdict
# ═══════════════════════════════════════════════════════════════════
Write-Host "`n=========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "🎉 System is healthy and ready to use!" -ForegroundColor Green
} else {
    Write-Host "⚠️  System has warnings or errors. Check suggestions above." -ForegroundColor Yellow
}
Write-Host "=========================================" -ForegroundColor Cyan
