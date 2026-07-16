# 🏗️ Codex Init — Quick Project Scaffolding

Guide to using the `codex init` command to quickly create new projects.

---

## 🚀 Usage

```powershell
codex init <project-name> [template]
```

### Examples

```powershell
# Basic project
codex init my-app

# ASP.NET Core web app
codex init my-api aspnet

# Flutter project (shows flutter create instructions)
codex init my-flutter-app flutter
```

### Available Templates

| Template | Description | Files Created |
|----------|-------------|---------------|
| `basic` (default) | Basic project structure | README.md, .gitignore |
| `aspnet` | ASP.NET Core Web API (net9.0) | README.md, .gitignore, .csproj, Program.cs, Properties/ |
| `flutter` | Flutter project | README.md, .gitignore + instructions to run `flutter create` |

---

## 📦 Output Structure

### Basic Template

```
my-app/
├── README.md
└── .gitignore
```

### ASP.NET Core Template

```
my-api/
├── Properties/
├── README.md
├── .gitignore
├── my-api.csproj
└── Program.cs
```

### Flutter Template

```
my-flutter-app/
├── README.md
└── .gitignore
```

Then run `flutter create my-flutter-app` to generate the full Flutter structure.

---

## 💡 Tips

- Run `codex profile free` after init to select a provider
- Use `codex doctor` to check system readiness
- The `aspnet` template uses .NET 9.0 — if you're on .NET 8, change `TargetFramework` in `.csproj` to `net8.0`
