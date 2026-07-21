<#
.SYNOPSIS
  List free models from OpenRouter API.
.DESCRIPTION
  Fetches the model catalog from OpenRouter and filters for free models.
  Outputs a formatted table sorted by context length (descending).
  Use -GenerateToml to output a TOML models array for fallback config.
.PARAMETER ApiKey
  OpenRouter API key. Falls back to OPENROUTER_API_KEY environment variable.
.PARAMETER Json
  Output raw JSON instead of formatted table.
.PARAMETER All
  Show all models (not just free).
.PARAMETER GenerateToml
  Output a TOML-formatted models array for [model_providers.openrouter.query_params].
.PARAMETER MaxFallback
  Max models in TOML output (default: 10). Only used with -GenerateToml.
#>

param(
    [string]$ApiKey = "",
    [switch]$Json,
    [switch]$All,
    [switch]$GenerateToml,
    [int]$MaxFallback = 10
)

# Resolve API key
if (-not $ApiKey) {
    $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Process")
    if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User") }
    if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Machine") }
}

if (-not $ApiKey) {
    Write-Host "OPENROUTER_API_KEY not found." -ForegroundColor Red
    Write-Host "   Set it via: `$env:OPENROUTER_API_KEY = 'sk-or-v1-...'" -ForegroundColor Gray
    Write-Host "   Or pass: -ApiKey 'sk-or-v1-...'" -ForegroundColor Gray
    exit 1
}

Write-Host "Fetching models from OpenRouter..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/models" `
        -Headers @{ "Authorization" = "Bearer $ApiKey" } `
        -TimeoutSec 15

    $models = $response.data

    if (-not $models -or $models.Count -eq 0) {
        Write-Host "No models returned from API." -ForegroundColor Red
        exit 1
    }

    # Filter for free models
    if (-not $All) {
        $models = $models | Where-Object { $_.id -like "*:free" }
    }

    if ($models.Count -eq 0) {
        Write-Host "No free models found." -ForegroundColor Yellow
        exit 0
    }

    if ($Json) {
        $models | ConvertTo-Json -Depth 3
        return
    }

    if ($GenerateToml) {
        # Prioritize: coding > reasoning > general
        $scored = $models | ForEach-Object {
            $id = $_.id.ToLower()
            $ctx = if ($_.context_length) { [int]$_.context_length } else { 0 }
            $tier = 0
            if ($id -match 'coder|code|qwen|deepseek-coder|codestral|starcoder') { $tier = 2 }
            elseif ($ctx -ge 32000 -and $id -match 'r1|reasoning|think|deepseek') { $tier = 1 }
            $score = ($tier * 1000000) + [math]::Min($ctx, 999999)
            [PSCustomObject]@{ id = $_.id; score = $score }
        } | Sort-Object -Property score -Descending | Select-Object -First $MaxFallback

        Write-Host "# Auto-generated fallback model list"
        Write-Host "models = ["
        $scored | ForEach-Object { Write-Host "  `"$($_.id)`"," }
        Write-Host "]"
        Write-Host "route = `"fallback`""
        return
    }

    # Sort by context length descending
    $sorted = $models | Sort-Object -Property context_length -Descending

    Write-Host ""
    Write-Host "Found $($sorted.Count) models" -ForegroundColor Green
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
    Write-Host "Recommended for coding:" -ForegroundColor Yellow
    $codingModels = $sorted | Where-Object { $_.id -match "coder|code|qwen" }
    foreach ($m in $codingModels) {
        Write-Host "   $($m.id) - $($m.name)" -ForegroundColor Cyan
    }

} catch {
    Write-Host "Failed to fetch models: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $body = $reader.ReadToEnd()
        Write-Host "   Response: $body" -ForegroundColor Gray
    }
    exit 1
}
