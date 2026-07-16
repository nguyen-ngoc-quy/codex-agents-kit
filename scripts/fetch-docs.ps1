# Codex CLI Ultimate — Documentation Fetcher
# Downloads framework documentation for offline AI context.
# Usage:   .\scripts\fetch-docs.ps1 [framework]
# Example: .\scripts\fetch-docs.ps1 aspnet
#          .\scripts\fetch-docs.ps1 list

param(
    [string]$Framework = "list"
)

$ErrorActionPreference = "Continue"
$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$docsDir = Join-Path $workspaceRoot "docs" "fetched"

# ── Framework sources ──────────────────────────────────────
$sources = @{
    aspnet = @{
        name = "ASP.NET Core"
        urls  = @(
            "https://learn.microsoft.com/en-us/aspnet/core/fundamentals/?view=aspnetcore-9.0"
            "https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-9.0"
        )
    }
    flutter = @{
        name = "Flutter"
        urls  = @(
            "https://docs.flutter.dev/reference/widgets"
            "https://api.flutter.dev/flutter/material/material-library.html"
        )
    }
    unity = @{
        name = "Unity"
        urls  = @(
            "https://docs.unity3d.com/Manual/index.html"
            "https://docs.unity3d.com/ScriptReference/index.html"
        )
    }
}

# ── List available frameworks ──────────────────────────────
if ($Framework -eq "list") {
    Write-Host "Available frameworks:" -ForegroundColor Cyan
    foreach ($key in $sources.Keys | Sort-Object) {
        $fw = $sources[$key]
        Write-Host "  - $key  ($($fw.name)) - $($fw.urls.Count) source(s)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Usage: .\scripts\fetch-docs.ps1 <framework>" -ForegroundColor Gray
    Write-Host "Example: .\scripts\fetch-docs.ps1 aspnet" -ForegroundColor Gray
    return
}

# ── Validate framework ─────────────────────────────────────
if (-not $sources.ContainsKey($Framework)) {
    Write-Host "❌ Unknown framework: '$Framework'" -ForegroundColor Red
    Write-Host "Available frameworks:" -ForegroundColor Gray
    foreach ($key in $sources.Keys | Sort-Object) { Write-Host "  - $key" -ForegroundColor Yellow }
    exit 1
}

$fw = $sources[$Framework]

# ── Create output dir ──────────────────────────────────────
if (-not (Test-Path $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir -Force | Out-Null
}

$outDir = Join-Path $docsDir $Framework
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# ── Fetch docs ─────────────────────────────────────────────
Write-Host "📥 Fetching $($fw.name) documentation..." -ForegroundColor Cyan
$success = 0
$failed = 0

foreach ($url in $fw.urls) {
    $filename = [System.IO.Path]::GetFileName($url.Split('?')[0])
    if ([string]::IsNullOrEmpty($filename)) { $filename = "index.html" }
    if (-not $filename.EndsWith(".html")) { $filename += ".html" }
    $outFile = Join-Path $outDir $filename

    Write-Host "  Fetching: $url" -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        # Save as text/html
        Set-Content -Path $outFile -Value $response.Content -Encoding utf8 -Force
        Write-Host "    ✅ Saved to: $outFile" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "    ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

# ── Summary ────────────────────────────────────────────────
Write-Host ""
Write-Host "✅ $success / $($success + $failed) files fetched for '$Framework'" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })

if ($success -gt 0) {
    Write-Host ""
    Write-Host "📂 Docs saved to: $outDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 Use these docs as AI context:" -ForegroundColor Yellow
    Write-Host "   Add the files under docs/fetched/ as context when working with Codex CLI." -ForegroundColor Gray
}
