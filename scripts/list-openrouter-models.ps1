<#
.SYNOPSIS
  List free models from OpenRouter API.
.DESCRIPTION
  Fetches the model catalog from OpenRouter and filters for free models.
  Outputs a formatted table sorted by context length (descending).
.PARAMETER ApiKey
  OpenRouter API key. Falls back to OPENROUTER_API_KEY environment variable.
.PARAMETER Json
  Output raw JSON instead of formatted table.
.PARAMETER All
  Show all models (not just free).
#>

param(
    [string]$ApiKey = "",
    [switch]$Json,
    [switch]$All
)

# Resolve API key
if (-not $ApiKey) {
    $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Process")
    if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User") }
    if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Machine") }
}

if (-not $ApiKey) {
    Write-Host "❌ OPENROUTER_API_KEY not found." -ForegroundColor Red
    Write-Host "   Set it via: `$env:OPENROUTER_API_KEY = 'sk-or-v1-...'" -ForegroundColor Gray
    Write-Host "   Or pass: -ApiKey 'sk-or-v1-...'" -ForegroundColor Gray
    exit 1
}

Write-Host "📡 Fetching models from OpenRouter..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/models" `
        -Headers @{ "Authorization" = "Bearer $ApiKey" } `
        -TimeoutSec 15

    $models = $response.data

    if (-not $models -or $models.Count -eq 0) {
        Write-Host "❌ No models returned from API." -ForegroundColor Red
        exit 1
    }

    # Filter for free models
    if (-not $All) {
        $models = $models | Where-Object { $_.id -like "*:free" }
    }

    if ($models.Count -eq 0) {
        Write-Host "⚠️  No free models found." -ForegroundColor Yellow
        exit 0
    }

    if ($Json) {
        $models | ConvertTo-Json -Depth 3
        return
    }

    # Sort by context length descending
    $sorted = $models | Sort-Object -Property context_length -Descending

    Write-Host ""
    Write-Host "📋 Found $($sorted.Count) models" -ForegroundColor Green
    Write-Host ""

    # Table header
    Write-Host ("{0,-50} {1,8} {2,12} {3,15}" -f "Model ID", "Context", "Prompt Price", "Completion Price")
    Write-Host ("{0,-50} {1,8} {2,12} {3,15}" -f ("-"*50), ("-"*8), ("-"*12), ("-"*15))

    foreach ($m in $sorted) {
        $ctx = if ($m.context_length) { "$($m.context_length)" } else { "?" }
        $pp = if ($m.pricing.prompt) { "$($m.pricing.prompt)" } else { "?" }
        $cp = if ($m.pricing.completion) { "$($m.pricing.completion)" } else { "?" }
        Write-Host ("{0,-50} {1,8} {2,12} {3,15}" -f $m.id, $ctx, $pp, $cp)
    }

    Write-Host ""
    Write-Host "💡 Recommended for coding:" -ForegroundColor Yellow
    $codingModels = $sorted | Where-Object { $_.id -match "coder|code|qwen" }
    foreach ($m in $codingModels) {
        Write-Host "   $($m.id) — $($m.name)" -ForegroundColor Cyan
    }

} catch {
    Write-Host "❌ Failed to fetch models: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $body = $reader.ReadToEnd()
        Write-Host "   Response: $body" -ForegroundColor Gray
    }
    exit 1
}
