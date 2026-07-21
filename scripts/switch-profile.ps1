# Profile Switcher for Codex CLI
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProfileName
)

# Error policy: Stop — switching profile is a critical config operation
$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$profileFile = Join-Path $workspaceRoot "config\$ProfileName.toml"
$codexHome = Join-Path $env:USERPROFILE ".codex"
$configFile = Join-Path $codexHome "config.toml"
$backupFile = Join-Path $codexHome "config.toml.bak"

Write-Host "Switching Codex profile to: '$ProfileName'" -ForegroundColor Cyan

if (-not (Test-Path $profileFile)) {
    Write-Host "❌ Error: Profile '$ProfileName' does not exist at $profileFile" -ForegroundColor Red
    Write-Host "Available profiles:" -ForegroundColor Gray
    Get-ChildItem -Path (Join-Path $workspaceRoot "config") -Filter "*.toml" | ForEach-Object {
        Write-Host " - $($_.BaseName)" -ForegroundColor Yellow
    }
    exit 1
}

# Ensure .codex dir exists
if (-not (Test-Path $codexHome)) {
    New-Item -ItemType Directory -Path $codexHome -Force | Out-Null
}

# Backup existing config
if (Test-Path $configFile) {
    Copy-Item -Path $configFile -Destination $backupFile -Force
    Write-Host "Backup created at: $backupFile" -ForegroundColor Gray
}

# Copy new config
Copy-Item -Path $profileFile -Destination $configFile -Force

# Replace placeholders with actual workspace path (escape backslashes and special chars for TOML)
$configContent = Get-Content $configFile -Raw
$escapedRoot = $workspaceRoot.ToString().Replace('\', '\\').Replace('"', '\"').Replace('#', '\#')
$configContent = $configContent.Replace('__WORKSPACE_ROOT__', $escapedRoot)
Set-Content -Path $configFile -Value $configContent -Encoding UTF8 -Force

Write-Host "Successfully switched to '$ProfileName'!" -ForegroundColor Green
Write-Host "Active configuration updated at: $configFile" -ForegroundColor Green

# Print active model/provider info
$tomlContent = Get-Content $configFile -Raw
$model = ""
$provider = ""
if ($tomlContent -match 'model\s*=\s*"([^"]+)"') { $model = $Matches[1] }
if ($tomlContent -match 'model_provider\s*=\s*"([^"]+)"') { $provider = $Matches[1] }

Write-Host "Provider: $provider" -ForegroundColor Yellow
Write-Host "Model   : $model" -ForegroundColor Yellow

# Check for recommended agent
$profileFileContent = Get-Content $profileFile -Raw
if ($profileFileContent -match '# recommended_agent:\s*(\S+)') {
    $recommendedAgent = $Matches[1]
    Write-Host ""
    Write-Host "💡 Tip: Run 'codex agent $recommendedAgent' to load the recommended agent for this profile." -ForegroundColor Cyan
}
