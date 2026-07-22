<#
.SYNOPSIS
  Generate/update auto-fallback model chain in Free OpenRouter profile.
.DESCRIPTION
  Fetches free models from OpenRouter API, prioritizes them (coding >
  reasoning > general), and injects a [model_providers.openrouter.query_params]
  block with route = "fallback" into the target TOML profile.

  When a free model hits a rate limit or error, OpenRouter automatically
  falls through to the next model in the chain.

  Run periodically (e.g. via 'codex update') to keep the model list fresh.
.PARAMETER ApiKey
  OpenRouter API key. Falls back to OPENROUTER_API_KEY environment variable.
.PARAMETER ProfileFile
  Path to the TOML profile to update. Default: free.toml in the config directory.
.PARAMETER DryRun
  Print the updated TOML to console without writing to file.
.PARAMETER MinContext
  Minimum context window size (tokens). Models below this are excluded.
.PARAMETER MaxModels
  Maximum number of models in the fallback chain.
.PARAMETER Offline
  Skip API call and use the hardcoded fallback list (for testing / no network).
#>

param(
    [string]$ApiKey = "",
    [string]$ProfileFile = "",
    [switch]$DryRun,
    [int]$MinContext = 8192,
    [int]$MaxModels = 10,
    [switch]$Offline
)

$ErrorActionPreference = "Stop"

# -- Path resolution --
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Resolve-Path (Join-Path $scriptDir "..")
$configDir = Join-Path $workspaceRoot "config"

if (-not $ProfileFile) {
    $ProfileFile = Join-Path $configDir "free.toml"
} elseif (-not [System.IO.Path]::IsPathRooted($ProfileFile)) {
    $ProfileFile = Join-Path $workspaceRoot $ProfileFile
}

# -- Hardcoded fallback list (used when API is unreachable) ---
$FallbackModels = @(
    "qwen/qwen-2.5-coder-32b-instruct:free",
    "deepseek/deepseek-r1:free",
    "google/gemini-2.5-flash:free",
    "meta-llama/llama-3.3-70b-instruct:free",
    "nvidia/nemotron-3-ultra-550b-a55b:free"
)

# -- Helper: prioritization scoring --
function Get-PriorityScore {
    param($Model)
    $id = $Model.id.ToLower()
    $ctx = if ($Model.context_length) { [int]$Model.context_length } else { 0 }
    $tier = 0

    # Tier 1: Coding-optimized models (highest priority)
    if ($id -match 'coder|code|qwen|deepseek-coder|codestral|starcoder') {
        $tier = 2
    }
    # Tier 2: Reasoning / large-context models
    elseif ($ctx -ge 32000 -and $id -match 'r1|reasoning|think|deepseek') {
        $tier = 1
    }
    # score = (tier * 1M) + context (capped at 999999) — tiers never overlap
    $score = ($tier * 1000000) + [math]::Min($ctx, 999999)

    return $score
}

# -- Helper: TOML validation --
function Test-TomlBalance {
    param([string]$Content)
    $openQuotes = ([regex]::Matches($Content, '"')).Count
    if ($openQuotes % 2 -ne 0) { throw "Unbalanced quotes in TOML" }
    $openBrackets = ([regex]::Matches($Content, '\[')).Count
    $closeBrackets = ([regex]::Matches($Content, '\]')).Count
    if ($openBrackets -ne $closeBrackets) { throw "Unbalanced brackets in TOML" }
}

# -- Step 1: Get free model list --
Write-Host "== Fetching free models from OpenRouter..." -ForegroundColor Cyan

$freeModels = @()

if (-not $Offline) {
    # Resolve API key
    if (-not $ApiKey) {
        $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Process")
        if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User") }
        if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Machine") }
    }

    if ($ApiKey) {
        try {
            $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/models" `
                -Headers @{ "Authorization" = "Bearer $ApiKey" } `
                -TimeoutSec 15

            $allModels = $response.data

            if ($allModels -and $allModels.Count -gt 0) {
                # Filter free models: :free suffix OR zero pricing
                $freeModels = $allModels | Where-Object {
                    $_.id -like "*:free" -or `
                    ($_.pricing.prompt -eq "0" -and $_.pricing.completion -eq "0")
                }
            }

            if ($freeModels.Count -eq 0) {
                Write-Host "Warning: No free models returned from API." -ForegroundColor Yellow
            } else {
                Write-Host "OK: Found $($freeModels.Count) free models via API." -ForegroundColor Green
            }
        } catch {
            Write-Host "Warning: API call failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Warning: OPENROUTER_API_KEY not set." -ForegroundColor Yellow
    }
}

# Fallback to hardcoded list if API returned nothing
if ($freeModels.Count -eq 0) {
    Write-Host "Using built-in fallback model list." -ForegroundColor Gray
    $freeModels = $FallbackModels | ForEach-Object {
        $id = $_
        [PSCustomObject]@{
            id = $id
            name = $id
            context_length = 0
            pricing = [PSCustomObject]@{ prompt = "0"; completion = "0" }
        }
    }
}

# -- Step 2: Apply filters and prioritization --
# Filter by minimum context length (skip for hardcoded fallback since we set ctx=0)
if (-not $Offline) {
    $freeModels = $freeModels | Where-Object {
        $ctx = if ($_.context_length) { [int]$_.context_length } else { 0 }
        $ctx -ge $MinContext -or $_.context_length -eq 0
    }
}

# Score and sort
$scored = $freeModels | ForEach-Object {
    $score = Get-PriorityScore -Model $_
    [PSCustomObject]@{
        id = $_.id
        score = $score
        context_length = if ($_.context_length) { [int]$_.context_length } else { 0 }
    }
} | Sort-Object -Property score -Descending

# Take top N
$topModels = $scored | Select-Object -First $MaxModels

if ($topModels.Count -eq 0) {
    Write-Host "ERROR: No models available for fallback chain." -ForegroundColor Red
    exit 1
}

$modelIds = $topModels | ForEach-Object { $_.id }

Write-Host ""
Write-Host "Fallback chain ($($modelIds.Count) models):" -ForegroundColor Green
for ($i = 0; $i -lt $modelIds.Count; $i++) {
    $label = if ($i -eq 0) { "Primary" } else { "Alt $i" }
    Write-Host "   $($i + 1). $($modelIds[$i])  [$label]" -ForegroundColor Cyan
}

# -- Step 3: Build the query_params TOML block --
# models is a comma-separated string per Codex CLI map<string,string> spec
$modelsStr = $modelIds -join ","
$queryParamsBlock = @"

[model_providers.openrouter.query_params]
models = "$modelsStr"
route = "fallback"
"@

if ($DryRun) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host " DRY RUN - Proposed changes to:" -ForegroundColor Magenta
    Write-Host " $ProfileFile" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host $queryParamsBlock
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Run without -DryRun to apply these changes." -ForegroundColor Yellow
    exit 0
}

# -- Step 4: Read and update the TOML profile --
if (-not (Test-Path $ProfileFile)) {
    Write-Host "ERROR: Profile not found: $ProfileFile" -ForegroundColor Red
    exit 1
}

# Read file with CRLF detection (pattern from config.ps1)
$bytes = [System.IO.File]::ReadAllBytes($ProfileFile)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$usesCrlf = $text.Contains("`r`n")
# Normalize to LF for regex work
$content = $text.Replace("`r`n", "`n")

# Check if query_params already exists
if ($content -match "(?m)^\[model_providers\.openrouter\.query_params\]") {
    Write-Host "Replacing existing query_params section..." -ForegroundColor Gray
    $content = $content -replace "(?s)\[model_providers\.openrouter\.query_params\].*?(\n\[|\Z)", "`$1"
    # Remove trailing blank lines before the insert point
    $content = $content -replace "`n{3,}", "`n`n"
}

# Find insertion point: after env_key line in [model_providers.openrouter] section
if ($content -match "(?m)^env_key\s*=\s*`"OPENROUTER_API_KEY`"") {
    $content = $content -replace "(?m)^(env_key\s*=\s*`"OPENROUTER_API_KEY`")", "`$1$queryParamsBlock"
} elseif ($content -match "(?m)^env_key\s*=\s*`"[^`"]*`"") {
    $content = $content -replace "(?m)^(env_key\s*=\s*`"[^`"]*`")", "`$1$queryParamsBlock"
} else {
    Write-Host "ERROR: Could not find [model_providers.openrouter] section in $ProfileFile" -ForegroundColor Red
    exit 1
}

# Validate TOML before writing
try {
    Test-TomlBalance $content
} catch {
    Write-Host "ERROR: Generated TOML is invalid: $_" -ForegroundColor Red
    Write-Host "   Changes NOT written to file." -ForegroundColor Yellow
    exit 1
}

# Preserve CRLF if the original used it
if ($usesCrlf) {
    $content = $content.Replace("`n", "`r`n")
}

# Write backup
$backupFile = "$ProfileFile.bak"
Copy-Item -Path $ProfileFile -Destination $backupFile -Force

# Strip any accumulated BOM characters from the string content.
# When using Encoding.UTF8.GetString(), the BOM bytes (EF BB BF) become a
# leading ﻿ character in the string.  Then WriteAllText with
# [System.Text.Encoding]::UTF8 (which emits a BOM preamble) writes that
# ﻿ back as EF BB BF *after* its own BOM preamble, doubling the BOMs.
# TrimStart removes them so only WriteAllText's preamble survives.
$bomChar = [char]0xFEFF
$content = $content.TrimStart($bomChar)

try {
    [System.IO.File]::WriteAllText($ProfileFile, $content, [System.Text.Encoding]::UTF8)
    Write-Host ""
    Write-Host "OK: Updated $ProfileFile" -ForegroundColor Green
    Write-Host "   Backup saved to $backupFile" -ForegroundColor Gray
    Write-Host "   $($modelIds.Count) models in fallback chain with route = `"fallback`"" -ForegroundColor Gray
} catch {
    # Rollback on write failure
    Copy-Item -Path $backupFile -Destination $ProfileFile -Force
    Write-Host "ERROR: Failed to write: $_" -ForegroundColor Red
    Write-Host "   Changes reverted from backup." -ForegroundColor Yellow
    exit 1
}
