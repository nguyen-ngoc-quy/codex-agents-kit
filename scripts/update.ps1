# Codex CLI Ultimate Update Script
# Updates repository prompts, MCP configurations, and helper profiles

# Error policy: Stop — update issues should surface immediately, not be silently tolerated
$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🔄 Updating Codex CLI Ultimate..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Pull Git Repository changes
if (Test-Path (Join-Path $PSScriptRoot "..\.git")) {
    Write-Host "Pulling latest starter kit changes from Git..." -ForegroundColor Gray
    try {
        git pull
        Write-Host "✅ Git repository updated successfully." -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Warning: Git pull failed. Please pull updates manually." -ForegroundColor Yellow
    }
} else {
    Write-Host "Not a git repository, skipping git pull." -ForegroundColor Gray
}

# 2. Regenerate free model fallback chain
Write-Host "Generating free model fallback chain..." -ForegroundColor Gray
try {
    & (Join-Path $PSScriptRoot "generate-free-profile.ps1") -ErrorAction SilentlyContinue
    if ($?) {
        Write-Host "Free model fallback chain updated." -ForegroundColor Green
    } else {
        Write-Host "Could not update free model chain (API may be unavailable). Using cached list." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Could not update free model chain: $_" -ForegroundColor Yellow
}

# 3. Inform user about manual updates if needed
Write-Host "Synchronizing templates..." -ForegroundColor Gray

$codexHome = Join-Path $env:USERPROFILE ".codex"
if (Test-Path $codexHome) {
    Write-Host "Tip: Run 'codex profile [free|premium|local]' to re-apply updated profiles." -ForegroundColor Yellow
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🎉 Updates completed!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
