<#
.SYNOPSIS
  Start the Codex CLI Ultimate Admin UI server.
.DESCRIPTION
  Launches the Express server from ui/server.js and opens the browser.
  Pass --port=<N> to override the default port (3456).
#>
param(
    [string]$Port = ""
)

$UI_DIR = Join-Path $PSScriptRoot ".." "ui"
$SERVER = Join-Path $UI_DIR "server.js"

if (-not (Test-Path $SERVER)) {
    Write-Host "❌ UI server not found at $SERVER" -ForegroundColor Red
    Write-Host "   Make sure you're running from the codex-cli-ultimate repository." -ForegroundColor Gray
    exit 1
}

# Check for Node.js
$nodeVer = node --version 2>$null
if (-not $nodeVer) {
    Write-Host "❌ Node.js is not installed. Please install Node.js from https://nodejs.org" -ForegroundColor Red
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
    # Try environment variable
    $envPort = [Environment]::GetEnvironmentVariable("CODEX_UI_PORT", "Process")
    if (-not $envPort) { $envPort = [Environment]::GetEnvironmentVariable("CODEX_UI_PORT", "User") }
    if ($envPort) { $nodeArgs += "--port=$envPort" }
}

Write-Host "🚀 Starting Codex CLI Ultimate Admin UI..." -ForegroundColor Cyan
Write-Host "   Server : http://localhost:${Port:-3456}" -ForegroundColor Green
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray

# Start the server (inherits current process — Ctrl+C works)
Push-Location $UI_DIR
node $nodeArgs
Pop-Location
