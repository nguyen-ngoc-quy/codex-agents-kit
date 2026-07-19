# Performance Benchmarking for Codex CLI Ultimate
# Measures response latency and connection speed for active profile

# Error policy: Stop — benchmark should fail fast if connection or config is broken
$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "⏱️ Codex CLI Ultimate Model Benchmark" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Parse active config
$configFile = Join-Path $env:USERPROFILE ".codex\config.toml"
if (-not (Test-Path $configFile)) {
    Write-Host "❌ Error: config.toml not found! Please run installation first." -ForegroundColor Red
    exit 1
}

$content = Get-Content $configFile -Raw
$provider = ""
$model = ""
$baseUrl = ""
$apiKey = ""

if ($content -match 'model_provider\s*=\s*"([^"]+)"') { $provider = $Matches[1] }
if ($content -match 'model\s*=\s*"([^"]+)"') { $model = $Matches[1] }

Write-Host "Benchmark target:" -ForegroundColor Gray
Write-Host "  -> Provider: $provider" -ForegroundColor Yellow
Write-Host "  -> Model   : $model" -ForegroundColor Yellow

if ($provider -eq "openrouter") {
    $baseUrl = "https://openrouter.ai/api/v1/chat/completions"
    $envKeyName = "OPENROUTER_API_KEY"
    if ($content -match 'env_key\s*=\s*"([^"]+)"') { $envKeyName = $Matches[1] }
    $apiKey = [System.Environment]::GetEnvironmentVariable($envKeyName)
} elseif ($provider -eq "ollama") {
    $baseUrl = "http://localhost:11434/v1/chat/completions"
    $apiKey = "ollama" # Dummy key
} else {
    Write-Host "❌ Benchmark only supports OpenRouter and Ollama profiles at the moment." -ForegroundColor Red
    exit 1
}

if (-not $apiKey -and $provider -eq "openrouter") {
    Write-Host "❌ Error: API Key not set. Please set the environment variable $envKeyName" -ForegroundColor Red
    exit 1
}

# 2. Benchmark test request
Write-Host "Sending benchmark prompt to model..." -ForegroundColor Gray
$headers = @{
    "Content-Type" = "application/json"
}
if ($provider -eq "openrouter") {
    $headers.Add("Authorization", "Bearer $apiKey")
}

$body = @{
    model = $model
    messages = @(
        @{ role = "user"; content = "Write a 1-sentence hello world in C#." }
    )
    max_tokens = 50
    temperature = 0.0
} | ConvertTo-Json

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Headers $headers -Body $body -TimeoutSec 30
    $stopwatch.Stop()
    
    $duration = $stopwatch.ElapsedMilliseconds
    $responseText = $response.choices[0].message.content.Trim()
    
    Write-Host "`n=== Benchmark Results ===" -ForegroundColor Green
    Write-Host "  ✅ Connection Success!" -ForegroundColor Green
    Write-Host "  ⏱️ Total Latency : $duration ms ($([Math]::Round($duration/1000, 2)) seconds)" -ForegroundColor Yellow
    Write-Host "  📝 Response text  : `"$responseText`"" -ForegroundColor Gray
    
    # Calculate approximate metrics
    $tokens = $responseText.Split(" ").Count + 5 # Rough estimate
    if ($duration -gt 0) {
        $tokensPerSec = [Math]::Round(($tokens / ($duration / 1000)), 1)
    } else {
        $tokensPerSec = 0
    }
    Write-Host "  🚀 Speed (Est.)   : $tokensPerSec tokens/sec" -ForegroundColor Yellow
} catch {
    $stopwatch.Stop()
    Write-Host "❌ Benchmark failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=========================================" -ForegroundColor Cyan
