<#
.SYNOPSIS
  Start / stop the Codex CLI Ultimate Admin UI server.
.DESCRIPTION
  Launches the Express server from ui/server.js.

  Usage:
    .\scripts\start-ui.ps1            Start (foreground, Ctrl+C to stop)
    .\scripts\start-ui.ps1 -d         Start in background (daemon mode)
    .\scripts\start-ui.ps1 --stop     Stop the server
    .\scripts\start-ui.ps1 --port=3457 Use a custom port
#>
param(
    [Alias('d')][switch]$Daemon,
    [Alias('s')][string]$Port = "",
    [switch]$Stop
)

# ── Stop ──────────────────────────────────────────────────────────
if ($Stop) {
    & "$PSScriptRoot\stop-ui.ps1"
    return
}

$UI_DIR = Join-Path $PSScriptRoot ".." "ui"
$SERVER = Join-Path $UI_DIR "server.js"

if (-not (Test-Path $SERVER)) {
    Write-Host "❌ UI server not found at $SERVER" -ForegroundColor Red
    exit 1
}

# Check for Node.js
$nodeVer = node --version 2>$null
if (-not $nodeVer) {
    Write-Host "❌ Node.js is not installed." -ForegroundColor Red
    exit 1
}

# Check if dependencies are installed
$modDir = Join-Path $UI_DIR "node_modules"
if (-not (Test-Path $modDir)) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    Push-Location $UI_DIR
    npm install
    Pop-Location
    if (-not (Test-Path $modDir)) {
        Write-Host "❌ Failed to install dependencies." -ForegroundColor Red
        exit 1
    }
}

# Build argument list
$nodeArgs = @($SERVER)
if ($Port) {
    $nodeArgs += "--port=$Port"
} else {
    $envPort = [Environment]::GetEnvironmentVariable("CODEX_UI_PORT", "Process")
    if (-not $envPort) { $envPort = [Environment]::GetEnvironmentVariable("CODEX_UI_PORT", "User") }
    if ($envPort) { $nodeArgs += "--port=$envPort" }
}

$port = if ($Port) { $Port } else { $envPort ?? "3456" }

# ── Daemon mode (background) ─────────────────────────────────────
if ($Daemon) {
    Write-Host "🚀 Starting Codex CLI Ultimate Admin UI (background)..." -ForegroundColor Cyan
    Write-Host "   Server : http://localhost:$port" -ForegroundColor Green
    Write-Host "   Use 'codex ui stop' to stop it" -ForegroundColor Gray
    Push-Location $UI_DIR
    Start-Process -NoNewWindow node -ArgumentList $nodeArgs
    Pop-Location
    return
}

# ── Foreground mode ──────────────────────────────────────────────
Write-Host "🚀 Starting Codex CLI Ultimate Admin UI..." -ForegroundColor Cyan
Write-Host "   Server : http://localhost:$port" -ForegroundColor Green
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray

Push-Location $UI_DIR
node $nodeArgs
Pop-Location
