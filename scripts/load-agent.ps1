# Codex CLI Ultimate — Agent Loader
# Usage:  .\scripts\load-agent.ps1 <agent-name>
# Example: .\scripts\load-agent.ps1 architect
# Outputs the agent's system instructions to use as context for Codex CLI

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$AgentName
)

$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$agentFile = Join-Path $workspaceRoot "agents\$AgentName.md"

# ── Validate ─────────────────────────────────────────────────────
if (-not (Test-Path $agentFile)) {
    Write-Host "❌ Agent '$AgentName' not found at: $agentFile" -ForegroundColor Red
    Write-Host "Available agents:" -ForegroundColor Gray
    Get-ChildItem (Join-Path $workspaceRoot "agents") -Filter "*.md" | ForEach-Object {
        Write-Host "  - $($_.BaseName)" -ForegroundColor Cyan
    }
    exit 1
}

# ── Read agent file ──────────────────────────────────────────────
$content = Get-Content $agentFile -Raw

# Extract system instructions block between ```text and ```
$extracted = $false
if ($content -match '(?s)```text\s*\n(.*?)```') {
    $instructions = $Matches[1].Trim()
    $extracted = $true
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🤖 Agent: $AgentName" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

if ($extracted) {
    Write-Host ""
    Write-Host "📋 System Instructions:" -ForegroundColor Yellow
    Write-Host $instructions
    Write-Host ""
    Write-Host "--- Full context ---" -ForegroundColor Gray
    Write-Host ""
}

# Show full agent file content (minus the header if we extracted)
$content = $content.Trim()
Write-Host $content
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "💡 Send the text above to Codex CLI as context" -ForegroundColor Yellow
Write-Host "   to activate the $AgentName agent." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
