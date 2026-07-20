# Config Manager for Codex CLI Ultimate
# Usage: .\scripts\config.ps1 <command> [args]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('list', 'get', 'set', 'set-model', 'set-provider', 'edit')]
    [string]$Command,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

# --- Path resolution ---
$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$codexHome = Join-Path $env:USERPROFILE ".codex"
$activeConfig = Join-Path $codexHome "config.toml"

function Get-ConfigPath {
    return $activeConfig
}

function Get-ActiveConfig {
    param([switch]$AsBytes)
    if (-not (Test-Path $activeConfig)) {
        Write-Host "No active config found at $activeConfig" -ForegroundColor Red
        Write-Host "  Run 'codex profile <name>' first to activate a profile." -ForegroundColor Yellow
        exit 1
    }
    if ($AsBytes) {
        return [System.IO.File]::ReadAllBytes($activeConfig)
    }
    return Get-Content $activeConfig -Raw
}

# The active config is normally CRLF (Git for Windows / switch-profile.ps1).
# Read the raw bytes, detect CRLF vs LF, normalize to LF for regex work,
# and restore the original ending on write so we never mix line endings.
function Get-ConfigLines {
    $bytes = Get-ActiveConfig -AsBytes
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $script:ConfigUsesCrlf = $text.Contains("`r`n")
    return $text.Replace("`r`n", "`n")
}

function Write-ConfigLines {
    param([string]$Content)
    if ($script:ConfigUsesCrlf) {
        $Content = $Content.Replace("`n", "`r`n")
    }
    [System.IO.File]::WriteAllText($activeConfig, $Content, [System.Text.Encoding]::UTF8)
}

function Backup-Config {
    $backup = "$activeConfig.bak"
    Copy-Item -Path $activeConfig -Destination $backup -Force
    return $backup
}

function Test-TomlBalance {
    param([string]$Content)
    $openQuotes = ([regex]::Matches($Content, '"')).Count
    if ($openQuotes % 2 -ne 0) {
        throw "Unbalanced quotes in TOML"
    }
    $openBrackets = ([regex]::Matches($Content, '\[')).Count
    $closeBrackets = ([regex]::Matches($Content, '\]')).Count
    if ($openBrackets -ne $closeBrackets) {
        throw "Unbalanced brackets in TOML"
    }
}

function Set-ConfigField {
    param([string]$Key, [string]$Value)
    $content = Get-ConfigLines
    Backup-Config

    # Escape backslashes and quotes for TOML
    $escapedValue = $Value.Replace('\', '\\').Replace('"', '\"')

    if ($content -match "(?m)^$Key\s*=\s*`"[^`"]*`"") {
        $content = $content -replace "(?m)^($Key\s*=\s*)`"[^`"]*`"", "`$1`"$escapedValue`""
    } elseif ($content -match "(?m)^$Key\s*=\s*(true|false)") {
        $content = $content -replace "(?m)^($Key\s*=\s*)(true|false)", "`$1`"$escapedValue`""
    } elseif ($content -match "(?m)^model_provider\s*=\s*`"[^`"]*`"") {
        # Key doesn't exist — append after model_provider line
        $content = $content -replace "(?m)^(model_provider\s*=\s*`"[^`"]*`")", "`$1`n$Key = `"$escapedValue`""
    } else {
        Write-Host "Cannot set '$Key': no 'model_provider' line found in config" -ForegroundColor Red
        Write-Host "  The config file may be corrupted or improperly formatted." -ForegroundColor Yellow
        exit 1
    }

    # Validate TOML by re-parsing (basic check)
    try {
        Test-TomlBalance $content
    } catch {
        Copy-Item -Path "$activeConfig.bak" -Destination $activeConfig -Force
        Write-Host "Failed to write config: $_" -ForegroundColor Red
        Write-Host "  Changes reverted from backup." -ForegroundColor Yellow
        exit 1
    }

    Write-ConfigLines $content
    Write-Host "$Key set to '$Value'" -ForegroundColor Green
}

function Get-ProviderDefaults {
    param([string]$ProviderName)
    $defaults = @{
        "openai"     = @{ base_url = "https://api.openai.com/v1"; env_key = "OPENAI_API_KEY"; name = "OpenAI" }
        "openrouter" = @{ base_url = "https://openrouter.ai/api/v1"; env_key = "OPENROUTER_API_KEY"; name = "OpenRouter" }
        "anthropic"  = @{ base_url = "https://api.anthropic.com/v1"; env_key = "ANTHROPIC_API_KEY"; name = "Anthropic" }
        "ollama"     = @{ base_url = "http://localhost:11434/v1"; env_key = "OLLAMA_API_KEY"; name = "Ollama" }
        "opencode-zen" = @{ base_url = "https://opencode.ai/zen/v1"; env_key = "OPENCODE_API_KEY"; name = "OpenCode Zen" }
    }
    return $defaults[$ProviderName]
}

# --- Dispatch ---
switch ($Command) {
    "list" {
        $content = Get-ConfigLines
        Write-Host "Active config ($activeConfig):" -ForegroundColor Cyan
        Write-Host ""

        $fields = @('model_provider', 'model')
        foreach ($f in $fields) {
            if ($content -match "(?m)^$f\s*=\s*`"([^`"]+)`"") {
                Write-Host "  $f = $($Matches[1])" -ForegroundColor White
            }
        }

        if ($content -match "(?m)^\[model_providers\.([a-zA-Z0-9._-]+)\]") {
            $providerName = $Matches[1]
            Write-Host "  [model_providers.$providerName]" -ForegroundColor Gray
            if ($content -match "(?m)^name\s*=\s*`"([^`"]+)`"") {
                Write-Host "    name = $($Matches[1])" -ForegroundColor White
            }
            if ($content -match "(?m)^base_url\s*=\s*`"([^`"]+)`"") {
                Write-Host "    base_url = $($Matches[1])" -ForegroundColor White
            }
            if ($content -match "(?m)^env_key\s*=\s*`"([^`"]+)`"") {
                $keyName = $Matches[1]
                $isSet = [Environment]::GetEnvironmentVariable($keyName)
                $status = if ($isSet) { "set" } else { "not set" }
                Write-Host "    env_key = $keyName  ($status)" -ForegroundColor White
            }
        }
        Write-Host "  [tools]" -ForegroundColor Gray
        if ($content -match "(?m)^web_search\s*=\s*(true|false)") {
            Write-Host "    web_search = $($Matches[1])" -ForegroundColor White
        }
        if ($content -match "(?m)^file_browser\s*=\s*(true|false)") {
            Write-Host "    file_browser = $($Matches[1])" -ForegroundColor White
        }
        $pluginCount = ([regex]::Matches($content, '(?m)^\[plugins\."')).Count
        Write-Host "  Plugins: $pluginCount enabled" -ForegroundColor Gray
        $mcpCount = ([regex]::Matches($content, '(?m)^\[mcp_servers\.[a-zA-Z0-9._-]+\]')).Count
        Write-Host "  MCP Servers: $mcpCount configured" -ForegroundColor Gray
    }

    "get" {
        if ($Args.Count -lt 1) {
            Write-Host "Usage: codex config get <key>" -ForegroundColor Yellow; exit 1
        }
        $key = $Args[0]; $content = Get-ConfigLines
        if ($content -match "(?m)^$key\s*=\s*`"([^`"]+)`"") {
            Write-Host $Matches[1]
        } elseif ($content -match "(?m)^$key\s*=\s*(true|false)") {
            Write-Host $Matches[1]
        } else {
            Write-Host "Key '$key' not found in active config" -ForegroundColor Red; exit 1
        }
    }

    "set" {
        if ($Args.Count -lt 2) { Write-Host "Usage: codex config set <key> <value>" -ForegroundColor Yellow; exit 1 }
        if ([string]::IsNullOrEmpty($Args[1])) { Write-Host "Cannot set '$($Args[0])' to empty value" -ForegroundColor Red; exit 1 }
        Set-ConfigField -Key $Args[0] -Value $Args[1]
    }

    "set-model" {
        if ($Args.Count -lt 1) { Write-Host "Usage: codex config set-model <model>" -ForegroundColor Yellow; exit 1 }
        Set-ConfigField -Key "model" -Value $Args[0]
    }

    "set-provider" {
        if ($Args.Count -lt 1) { Write-Host "Usage: codex config set-provider <provider>" -ForegroundColor Yellow; exit 1 }
        $provider = $Args[0].ToLower()
        $defaults = Get-ProviderDefaults -ProviderName $provider
        if (-not $defaults) { Write-Host "Unknown provider '$provider'" -ForegroundColor Red; exit 1 }
        # Check file exists first (Get-ActiveConfig has friendly error)
        $content = Get-ConfigLines
        Backup-Config

        # Capture the OLD provider BEFORE modifying model_provider
        $oldProvider = $null
        if ($content -match '(?m)^model_provider\s*=\s*"([^"]+)"') {
            $oldProvider = $Matches[1]
        }
        $oldSection = if ($oldProvider -eq "opencode-zen") { "openai" } else { $oldProvider }

        # For opencode-zen, model_provider value and section name must be "openai"
        $sectionProvider = if ($provider -eq "opencode-zen") { "openai" } else { $provider }
        $content = $content -replace '(?m)^model_provider\s*=\s*"[^"]*"', "model_provider = `"$sectionProvider`""

        $providerHeader = "[model_providers.$sectionProvider]"
        if ($content -match "(?m)^\[model_providers\.$oldSection\]") {
            $content = $content -replace "(?m)^\[model_providers\.$oldSection\]", $providerHeader
            # Also update name, base_url, env_key inside the existing block
            $content = $content -replace '(?m)^name\s*=\s*"[^"]*"', "name = `"$($defaults.name)`""
            $content = $content -replace '(?m)^base_url\s*=\s*"[^"]*"', "base_url = `"$($defaults.base_url)`""
            $content = $content -replace '(?m)^env_key\s*=\s*"[^"]*"', "env_key = `"$($defaults.env_key)`""
        } else {
            $content += "`n$providerHeader`n"
            $content += "name = `"$($defaults.name)`"`n"
            $content += "base_url = `"$($defaults.base_url)`"`n"
            $content += "env_key = `"$($defaults.env_key)`"`n"
        }
        # Validate TOML before writing
        try {
            Test-TomlBalance $content
        } catch {
            Copy-Item -Path "$activeConfig.bak" -Destination $activeConfig -Force
            Write-Host "Failed to write config: $_" -ForegroundColor Red
            Write-Host "  Changes reverted from backup." -ForegroundColor Yellow
            exit 1
        }
        Write-ConfigLines $content
        Write-Host "Provider switched to '$provider'" -ForegroundColor Green
        Write-Host "   base_url: $($defaults.base_url)" -ForegroundColor Gray
        Write-Host "   env_key:  $($defaults.env_key)" -ForegroundColor Gray
        Write-Host "   Make sure $($defaults.env_key) env var is set." -ForegroundColor Yellow
    }

    "edit" {
        $targetFile = $activeConfig
        if ($Args.Count -ge 1) {
            $profileFile = Join-Path $workspaceRoot "config" "$($Args[0]).toml"
            if (Test-Path $profileFile) {
                $targetFile = $profileFile
            } else {
                Write-Host "Profile '$($Args[0])' not found" -ForegroundColor Red
                Get-ChildItem (Join-Path $workspaceRoot "config") -Filter "*.toml" | ForEach-Object {
                    Write-Host "  - $($_.BaseName)" -ForegroundColor Cyan
                }; exit 1
            }
        }
        $editor = $env:EDITOR
        if (-not $editor) {
            $codeCmd = Get-Command "code" -ErrorAction SilentlyContinue
            if ($codeCmd) { $editor = "code" } else { $editor = "notepad.exe" }
        }
        Write-Host "Opening $targetFile with $editor..." -ForegroundColor Cyan
        & $editor $targetFile
    }
}
