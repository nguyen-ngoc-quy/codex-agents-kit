<#
.SYNOPSIS
  Stop the Codex CLI Ultimate Admin UI server.
.DESCRIPTION
  Finds and kills the Node.js process running ui/server.js.
  Uses the server script path to identify the correct process,
  so it won't kill unrelated Node processes.
.EXAMPLE
  .\scripts\stop-ui.ps1
  Stops the UI server if running.
#>

$UI_SERVER = Join-Path $PSScriptRoot ".." "ui" "server.js"

# Find node processes running our server.js
$procs = Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" |
    Where-Object { $_.CommandLine -like "*server.js*" -and $_.CommandLine -like "*$PSScriptRoot*" }

if (-not $procs) {
    # Broader search — any node process with server.js from the ui dir
    $procs = Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" |
        Where-Object { $_.CommandLine -like "*server.js*" }
}

if (-not $procs) {
    Write-Host "ℹ️  UI server is not running." -ForegroundColor Yellow
    exit 0
}

$count = 0
foreach ($p in $procs) {
    $pid = $p.ProcessId
    $cmd = $p.CommandLine
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    if ($?) {
        Write-Host "⏹️  Stopped UI server (PID $pid)" -ForegroundColor Green
        $count++
    }
}

if ($count -eq 0) {
    Write-Host "⚠️  Could not stop UI server. Try running as Administrator." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ UI server stopped." -ForegroundColor Cyan
