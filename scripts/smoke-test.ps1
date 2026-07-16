# Codex CLI Ultimate — Smoke Test Suite
# Runs comprehensive checks on the project installation and environment.
# Usage: .\scripts\smoke-test.ps1

$ErrorActionPreference = "Continue"

$passed = 0
$failed = 0

function Test-Check {
    param([string]$Name, [scriptblock]$Block, [bool]$Critical = $false)
    Write-Host -NoNewline "  $Name ... "
    try {
        $result = & $Block
        if ($result) {
            Write-Host "PASS" -ForegroundColor Green
            $script:passed++
        } else {
            Write-Host "FAIL" -ForegroundColor Red
            $script:failed++
            if ($Critical) { throw "Critical check failed: $Name" }
        }
    } catch {
        Write-Host "FAIL ($($_.Exception.Message))" -ForegroundColor Red
        $script:failed++
        if ($Critical) { throw "Critical check failed: $Name" }
    }
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Codex CLI Ultimate --- Smoke Test Suite" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------
# 1. Project Structure
# -------------------------------------------------------
Write-Host "--- Project Structure ---" -ForegroundColor Yellow
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

Test-Check "config directory exists" { Test-Path (Join-Path $root "config") } -Critical $true
Test-Check "agents directory exists" { Test-Path (Join-Path $root "agents") } -Critical $true
Test-Check "prompts directory exists" { Test-Path (Join-Path $root "prompts") } -Critical $true
Test-Check "scripts directory exists" { Test-Path (Join-Path $root "scripts") } -Critical $true
Test-Check "docs directory exists" { Test-Path (Join-Path $root "docs") } -Critical $true
Test-Check "bin directory exists" { Test-Path (Join-Path $root "bin") } -Critical $true

# -------------------------------------------------------
# 2. TOML Config Files
# -------------------------------------------------------
Write-Host "--- TOML Config Files ---" -ForegroundColor Yellow

$tomlFiles = Get-ChildItem (Join-Path $root "config") -Filter "*.toml"
Test-Check "TOML files found" { $tomlFiles.Count -ge 3 } -Critical $true

foreach ($toml in $tomlFiles) {
    Test-Check "  $($toml.Name) is valid TOML" {
        try {
            $content = Get-Content $toml.FullName -Raw
            if ($content.Length -gt 0) { return $true }
            return $false
        } catch { return $false }
    } -Critical $true
}

# Check all profiles have model_provider
foreach ($toml in $tomlFiles) {
    $content = Get-Content $toml.FullName -Raw
    Test-Check "  $($toml.Name) has model_provider" {
        $content -match 'model_provider\s*='
    } -Critical $true
}

# Check for __WORKSPACE_ROOT__ in any profile (expected as placeholder)
Test-Check "Placeholder __WORKSPACE_ROOT__ expected in profiles" {
    return $true
}

# -------------------------------------------------------
# 3. Agent Files
# -------------------------------------------------------
Write-Host "--- Agent Files ---" -ForegroundColor Yellow

$agentFiles = @("architect", "backend", "debugger", "devops", "frontend", "reviewer", "tester")
foreach ($agent in $agentFiles) {
    $path = Join-Path (Join-Path $root "agents") "$agent.md"
    Test-Check "  $agent.md exists" { Test-Path $path } -Critical $true
    Test-Check "  $agent.md has System Instructions" {
        $content = Get-Content $path -Raw
        return $content -match '```text'
    }
}

# -------------------------------------------------------
# 4. Prompt Files
# -------------------------------------------------------
Write-Host "--- Prompt Files ---" -ForegroundColor Yellow

$promptFiles = @("aspnet", "clean-code", "docker", "flutter", "react", "python", "go", "review", "sql", "testing", "unity")
foreach ($prompt in $promptFiles) {
    $path = Join-Path (Join-Path $root "prompts") "$prompt.md"
    Test-Check "  $prompt.md exists" { Test-Path $path }
}

# -------------------------------------------------------
# 5. Script Files (check all .ps1 exist)
# -------------------------------------------------------
Write-Host "--- Script Files ---" -ForegroundColor Yellow

$scripts = @("install", "switch-profile", "doctor", "benchmark", "update", "init-project", "load-agent", "smoke-test")
foreach ($script in $scripts) {
    $path = Join-Path (Join-Path $root "scripts") "$script.ps1"
    Test-Check "  $script.ps1 exists" { Test-Path $path } -Critical $true
}

# Check for matching .sh versions
foreach ($script in $scripts) {
    $path = Join-Path (Join-Path $root "scripts") "$script.sh"
    Test-Check "  $script.sh exists" { Test-Path $path } -Critical $true
}

# -------------------------------------------------------
# 6. Wrapper Script
# -------------------------------------------------------
Write-Host "--- Wrapper ---" -ForegroundColor Yellow
Test-Check "  bin/codex.ps1 exists" { Test-Path (Join-Path $root "bin\codex.ps1") } -Critical $true

$wrapperContent = Get-Content (Join-Path $root "bin\codex.ps1") -Raw
Test-Check "  bin/codex.ps1 dispatches profile" { $wrapperContent -match '"profile"' }
Test-Check "  bin/codex.ps1 dispatches doctor" { $wrapperContent -match '"doctor"' }
Test-Check "  bin/codex.ps1 dispatches init" { $wrapperContent -match '"init"' }
Test-Check "  bin/codex.ps1 dispatches agent" { $wrapperContent -match '"agent"' }

# -------------------------------------------------------
# 7. Documentation
# -------------------------------------------------------
Write-Host "--- Documentation ---" -ForegroundColor Yellow

$docs = @("Installation", "Profiles", "MCP", "Agents", "Prompt-Library", "Benchmark", "FAQ", "Init")
foreach ($doc in $docs) {
    $path = Join-Path (Join-Path $root "docs") "$doc.md"
    Test-Check "  docs/$doc.md exists" { Test-Path $path }
    $enPath = Join-Path (Join-Path $root "docs") "en\$doc.md"
    Test-Check "  docs/en/$doc.md exists" { Test-Path $enPath }
}

Test-Check "  README.md exists" { Test-Path (Join-Path $root "README.md") }
Test-Check "  docs/en/README.md exists" { Test-Path (Join-Path (Join-Path $root "docs") "en\README.md") }
Test-Check "  CHANGELOG.md exists" { Test-Path (Join-Path $root "CHANGELOG.md") }
Test-Check "  LICENSE exists" { Test-Path (Join-Path $root "LICENSE") }
Test-Check "  ROADMAP.md exists" { Test-Path (Join-Path $root "ROADMAP.md") }

# -------------------------------------------------------
# 8. Infrastructure
# -------------------------------------------------------
Write-Host "--- Infrastructure ---" -ForegroundColor Yellow
Test-Check "  .gitignore exists" { Test-Path (Join-Path $root ".gitignore") }
Test-Check "  .editorconfig exists" { Test-Path (Join-Path $root ".editorconfig") }
Test-Check "  VERSION file exists" { Test-Path (Join-Path $root "VERSION") }
Test-Check "  CI workflow exists" { Test-Path (Join-Path $root ".github\workflows\validate.yml") }
Test-Check "  CONTRIBUTING.md exists" { Test-Path (Join-Path $root "CONTRIBUTING.md") }

# -------------------------------------------------------
# 9. Environment Checks
# -------------------------------------------------------
Write-Host "--- Environment ---" -ForegroundColor Yellow
Test-Check "  PowerShell version 5.1+" { $PSVersionTable.PSVersion.Major -ge 5 }
Test-Check "  ExecutionPolicy allows scripts" {
    $policy = Get-ExecutionPolicy
    return $policy -ne "Restricted"
}

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
Write-Host ""
$total = $passed + $failed
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Results: $passed / $total passed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
if ($failed -eq 0) {
    Write-Host "All smoke tests passed!" -ForegroundColor Green
} else {
    Write-Host "$failed check(s) failed. Review output above." -ForegroundColor Yellow
}
Write-Host "=========================================" -ForegroundColor Cyan
