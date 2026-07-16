#!/bin/bash
# Codex CLI Ultimate — Project Initializer
# Usage:   ./scripts/init-project.sh <project-name> [template]
# Example: ./scripts/init-project.sh my-app aspnet

set -e

PROJECT_NAME="$1"
TEMPLATE="${2:-basic}"

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Usage: $0 <project-name> [template]" >&2
    echo "   Templates: basic, aspnet, flutter" >&2
    exit 1
fi

echo "========================================="
echo "✨ Codex Init — Creating new project"
echo "========================================="

TARGET_DIR="$(pwd)/$PROJECT_NAME"

if [ -d "$TARGET_DIR" ]; then
    echo "❌ Directory '$TARGET_DIR' already exists." >&2
    exit 1
fi

echo "Project : $PROJECT_NAME"
echo "Template: $TEMPLATE"
echo "Target  : $TARGET_DIR"

# ── Create project directory ──────────────────────────────────
mkdir -p "$TARGET_DIR"

# ── Generate basic project files ──────────────────────────────
cat > "$TARGET_DIR/README.md" << README_EOF
# $PROJECT_NAME

Created with Codex CLI Ultimate.

## Getting Started

1. Switch to a Codex profile:
   \`\`\`
   codex profile free
   \`\`\`

2. Start coding!
README_EOF

cat > "$TARGET_DIR/.gitignore" << GITIGNORE_EOF
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
GITIGNORE_EOF

# ── Template-specific scaffolding ─────────────────────────────
case "$(echo "$TEMPLATE" | tr '[:upper:]' '[:lower:]')" in
    aspnet)
        mkdir -p "$TARGET_DIR/Properties"
        cat > "$TARGET_DIR/$PROJECT_NAME.csproj" << 'CSPROJ'
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
CSPROJ
        cat > "$TARGET_DIR/Program.cs" << PROGRAM
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello from ${PROJECT_NAME}!");
app.Run();
PROGRAM
        echo "  🏗️  ASP.NET Core template scaffolded (net9.0)"
        ;;
    flutter)
        echo "  📱 Flutter template selected. Run 'flutter create $PROJECT_NAME' manually."
        ;;
    basic|*)
        echo "  📄 Basic project created"
        ;;
esac

# ── Suggest switching profile ─────────────────────────────────
echo ""
echo "Tip: Run 'codex profile free' to use the free OpenRouter profile,"
echo "     or 'codex profile premium' for premium models."

echo "========================================="
echo "✅ Project '$PROJECT_NAME' created at:"
echo "   $TARGET_DIR"
echo "========================================="
