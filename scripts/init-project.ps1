# Codex CLI Ultimate — Project Initializer
# Usage:   .\scripts\init-project.ps1 <project-name> [template]
# Example: .\scripts\init-project.ps1 my-app aspnet

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProjectName,

    [Parameter(Position = 1)]
    [string]$Template = "basic"
)

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✨ Codex Init — Creating new project" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# ── Resolve paths ──────────────────────────────────────────────
$targetDir = Join-Path (Get-Location) $ProjectName

if (Test-Path $targetDir) {
    Write-Error "Directory '$targetDir' already exists. Choose a different name or delete it first."
    exit 1
}

Write-Host "Project : $ProjectName" -ForegroundColor Yellow
Write-Host "Template: $Template" -ForegroundColor Yellow
Write-Host "Target  : $targetDir" -ForegroundColor Gray

# ── Create project directory ──────────────────────────────────
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# ── Generate basic project files ──────────────────────────────
$readmeContent = @"
# $ProjectName

Created with Codex CLI Ultimate.

## Getting Started

1. Switch to a Codex profile:
   \`\`\`
   codex profile free
   \`\`\`

2. Start coding!
"@
Set-Content -Path (Join-Path $targetDir "README.md") -Value $readmeContent -Encoding utf8

# Basic .gitignore
$gitignoreContent = @"
# Build
bin/
obj/
dist/
out/

# IDE
.vs/
.vscode/
*.suo
*.user

# OS
.DS_Store
Thumbs.db
"@
Set-Content -Path (Join-Path $targetDir ".gitignore") -Value $gitignoreContent -Encoding utf8

# ── Template-specific scaffolding ─────────────────────────────
switch ($Template.ToLower()) {
    "aspnet" {
        # ASP.NET Core minimal scaffolding
        $csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
"@
        New-Item -ItemType Directory -Path (Join-Path $targetDir "Properties") -Force | Out-Null
        Set-Content -Path (Join-Path $targetDir "$ProjectName.csproj") -Value $csprojContent -Encoding utf8

        $programContent = @"
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello from $ProjectName!");
app.Run();
"@
        Set-Content -Path (Join-Path $targetDir "Program.cs") -Value $programContent -Encoding utf8
        Write-Host "  🏗️  ASP.NET Core template scaffolded (net9.0)" -ForegroundColor Green
    }
    "flutter" {
        Write-Host "  📱 Flutter template selected. Run 'flutter create $ProjectName' manually." -ForegroundColor Yellow
    }
    "basic" {
        Write-Host "  📄 Basic project created" -ForegroundColor Gray
    }
    default {
        Write-Host "  ⚠️  Unknown template '$Template'. Using basic structure." -ForegroundColor Yellow
    }
}

# ── Suggest switching profile ─────────────────────────────────
Write-Host "`nTip: Run 'codex profile free' to use the free OpenRouter profile," -ForegroundColor Yellow
Write-Host "     or 'codex profile premium' for premium models." -ForegroundColor Yellow

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ Project '$ProjectName' created at:" -ForegroundColor Green
Write-Host "   $targetDir" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor Cyan
