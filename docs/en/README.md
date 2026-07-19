# 🚀 Codex CLI Ultimate

> **A complete Starter Kit for OpenAI Codex CLI** — powered by OpenRouter, local LLMs (Ollama), MCP servers, and custom AI agents.
> Designed to deliver a Claude Code–like experience with **free** and **offline** options.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)

**🌐 Language / Ngôn ngữ:** [English](README.md) | [Tiếng Việt](../../README.md)

---

## 🌟 Introduction

**Codex CLI Ultimate** is a Starter Kit that optimizes configuration and environment for Codex CLI, giving developers access to powerful coding agents at **zero cost** through OpenRouter Free or Local LLMs (Ollama), while making it easy to switch to Premium models (GPT-4o, Claude) when needed.

---

## ⚙️ Key Features

| Feature | Description |
|---------|-------------|
| **Multi-Provider** | OpenRouter, OpenAI, Anthropic, Ollama, LM Studio, vLLM |
| **Profile System** | Switch configs with one command: `free`, `premium`, `local`, `ollama`, `openrouter` |
| **Auto Fallback** | Chain multiple free models — if one hits rate limit, the next takes over |
| **MCP Auto-Register** | Filesystem, Git, GitHub, Docker, Playwright, Context7 — configured at install time |
| **Init Command** | `codex init my-project aspnet` — scaffold new projects quickly |
| **Custom Agents** | Architect, Backend, Frontend, DevOps, Reviewer, Debugger, Tester |
| **Prompt Library** | Optimized prompts for ASP.NET, Flutter, Unity, SQL, React, Python, Go, Docker, Testing |

---

## 📁 Folder Structure

```text
codex-cli-ultimate/
├── config/                 # Profile configurations (.toml)
│   └── profiles/           # Custom user profiles
├── prompts/                # Prompt library per language/framework
├── agents/                 # AI Agent system instructions
├── mcp/                    # MCP server definitions
├── scripts/                # Install, switch, doctor, benchmark, update, init
├── bin/                    # CLI wrapper scripts
└── docs/                   # Detailed documentation
    ├── en/                 # English docs
    └── ...                 # Vietnamese docs
```

---

## 🚀 Quick Start

### 1. Prerequisites

- [OpenAI Codex CLI](https://openai.com) installed
- PowerShell 7+ (Windows) or Bash (Linux/macOS)
- [Ollama](https://ollama.ai) (optional — for local profile)

### 2. Install

```powershell
# Windows (PowerShell)
.\scripts\install.ps1
```

```bash
# Linux / macOS
chmod +x ./scripts/install.sh
./scripts/install.sh
```

Install automatically:
- Deploys the `free` profile as your active config
- Replaces `__WORKSPACE_ROOT__` placeholders with your project path
- Creates a `codex` wrapper script in `bin/`
- Adds `bin/` to your shell PATH

### 3. Available Commands

| Command | Description |
|---------|-------------|
| `codex profile <name>` | Switch profile (`free`, `premium`, `local`, `ollama`, `openrouter`) |
| `codex doctor` | Run system diagnostics |
| `codex init <name> [template]` | Scaffold a new project |
| `codex benchmark` | Benchmark active model latency |
| `codex update` | Pull latest configs and prompts from Git |
| `codex agent <name>` | Load agent system instructions |

### 4. Configure API Keys

Set your API keys as **environment variables** (never embed them in config files):

```powershell
# Windows
$env:OPENROUTER_API_KEY = "sk-or-v1-..."
```

```bash
# Linux / macOS
export OPENROUTER_API_KEY="sk-or-v1-..."
```

For the `local` profile (Ollama), no API key is needed.

---

## 📖 Documentation

| Guide | Link |
|-------|------|
| Installation | [Installation.md](Installation.md) |
| Profiles & Models | [Profiles.md](Profiles.md) |
| MCP Configuration | [MCP.md](MCP.md) |
| AI Agents | [Agents.md](Agents.md) |
| Prompt Library | [Prompt-Library.md](Prompt-Library.md) |
| FAQ | [FAQ.md](FAQ.md) |
| Benchmark | [Benchmark.md](Benchmark.md) |
| Init Command | [Init.md](Init.md) |

---

## 📄 License

MIT License — see [LICENSE](../LICENSE).
