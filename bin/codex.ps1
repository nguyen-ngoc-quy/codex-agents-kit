# Codex CLI Ultimate wrapper script for PowerShell
# This file is a template; install.ps1 replaces placeholders on install.
# When run directly from the repo, it automatically resolves all paths.

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $RemainingArgs
)

# ── Resolve workspace root from script location ──────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkspaceRoot = Resolve-Path (Join-Path $ScriptDir "..")

# ── Resolve sub-script paths ─────────────────────────────────────
function Invoke-Script($Name) {
    $path = Join-Path (Join-Path $WorkspaceRoot "scripts") "$Name.ps1"
    if (-not (Test-Path $path)) {
        Write-Host "❌ Script not found: $path" -ForegroundColor Red
        exit 1
    }
    # Pass all args except the first (command name) to the sub-script
    if ($RemainingArgs.Count -gt 1) {
        $subArgs = $RemainingArgs[1..($RemainingArgs.Count - 1)]
        if ($subArgs -is [array]) {
            # Flatten array so each arg becomes its own parameter
            & $path @subArgs
        } else {
            & $path $subArgs
        }
    } else {
        & $path
    }
}

# ── Detect codex CLI executable ──────────────────────────────────
function Find-CodexExe {
    # 1. Environment variable override — Process scope first (highest priority)
    $envPath = [Environment]::GetEnvironmentVariable("CODEX_CLI_PATH", "Process")
    if ($envPath -and (Test-Path $envPath)) { return $envPath }
    $envPath = [Environment]::GetEnvironmentVariable("CODEX_CLI_PATH", "User")
    if ($envPath -and (Test-Path $envPath)) { return $envPath }
    $envPath = [Environment]::GetEnvironmentVariable("CODEX_CLI_PATH", "Machine")
    if ($envPath -and (Test-Path $envPath)) { return $envPath }

    # 2. PATH lookup — prefer .exe, then .cmd (npm global), then bare name
    foreach ($name in @("codex.exe", "codex.cmd")) {
        try { return (Get-Command $name -ErrorAction Stop).Source } catch {}
    }

    # 3. Common install locations
    $commonPaths = @(
        Join-Path $env:LOCALAPPDATA "OpenAI\Codex\bin"
        Join-Path $env:LOCALAPPDATA "Programs\OpenAI\Codex"
        "${env:ProgramFiles}\OpenAI\Codex"
        "${env:ProgramFiles(x86)}\OpenAI\Codex"
    )
    foreach ($dir in $commonPaths) {
        if (Test-Path $dir) {
            $found = Get-ChildItem -Path $dir -Recurse -Filter "codex.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }

    return $null
}

$CodexExe = Find-CodexExe

# ── Dispatch commands ────────────────────────────────────────────
if ($RemainingArgs.Count -gt 0) {
    switch ($RemainingArgs[0]) {
        "help" {
            Write-Host "Codex CLI Ultimate - Available Commands" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  codex profile <name>    Switch profile (free, premium, local, ollama, openrouter)" -ForegroundColor White
            Write-Host "  codex doctor            Run system diagnostics" -ForegroundColor White
            Write-Host "  codex benchmark         Benchmark active model latency" -ForegroundColor White
            Write-Host "  codex init <name> [tpl] Scaffold a new project" -ForegroundColor White
            Write-Host "  codex agent <name>      Load agent instructions (architect, backend, ...)" -ForegroundColor White
            Write-Host "  codex fetch-docs <fw>   Download framework docs for offline context" -ForegroundColor White
            Write-Host "  codex update            Pull latest configs and prompts from Git" -ForegroundColor White
            Write-Host "  codex help              Show this help message" -ForegroundColor White
            Write-Host ""
            Write-Host "  Any other arguments are passed directly to the Codex CLI binary." -ForegroundColor Gray
            return
        }
        "profile" {
            if ($RemainingArgs.Count -lt 2) {
                Write-Host "Usage: codex profile <name>" -ForegroundColor Yellow
                Write-Host "  Try: free, premium, local, ollama, openrouter" -ForegroundColor Gray
                Write-Host "Available profiles:" -ForegroundColor Gray
                Get-ChildItem (Join-Path $WorkspaceRoot "config") -Filter "*.toml" | ForEach-Object {
                    Write-Host "  - $($_.BaseName)" -ForegroundColor Cyan
                }
                return
            }
            Invoke-Script "switch-profile"
        }
        "doctor"   { Invoke-Script "doctor" }
        "update"   { Invoke-Script "update" }
        "benchmark" { Invoke-Script "benchmark" }
        "init"      { Invoke-Script "init-project" }
        "agent"     { Invoke-Script "load-agent" }
        "fetch-docs" { Invoke-Script "fetch-docs" }
        default {
            if (-not $CodexExe) {
                Write-Host "codex.exe not found. Please install Codex CLI or set CODEX_CLI_PATH." -ForegroundColor Red
                exit 1
            }
            & $CodexExe $RemainingArgs
        }
    }
} else {
    if (-not $CodexExe) {
        Write-Host "❌ codex.exe not found. Please install Codex CLI or set CODEX_CLI_PATH." -ForegroundColor Red
        exit 1
    }
    & $CodexExe
}
