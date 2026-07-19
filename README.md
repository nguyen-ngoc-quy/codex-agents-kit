# 🚀 Codex CLI Ultimate

> **A complete Starter Kit for OpenAI Codex CLI** — powered by OpenRouter, local LLMs (Ollama), MCP servers, and custom AI agents.
> Designed to deliver a Claude Code–like experience with **free** and **offline** options.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Codex Version](https://img.shields.io/badge/Codex-CLI-blue.svg)](https://openai.com)

**🌐 Language / Ngôn ngữ:** [English](docs/en/README.md) | [Tiếng Việt](README.md)

---

## 🌟 Giới thiệu (Introduction)

**Codex CLI Ultimate** là bộ Starter Kit tối ưu hóa cấu hình và môi trường cho Codex CLI, giúp lập trình viên tiếp cận coding agent mạnh mẽ với chi phí **0đ** thông qua OpenRouter Free hoặc Local LLM (Ollama), đồng thời dễ dàng chuyển đổi sang các mô hình Premium (GPT-4o, Claude).

---

## ⚙️ Key Features

| Tính năng | Mô tả |
|-----------|-------|
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

Detailed guides are in the [docs/](docs/) folder:

| Guide | English | Vietnamese |
|-------|---------|------------|
| Installation | [docs/en/Installation.md](docs/en/Installation.md) | [Installation.md](docs/Installation.md) |
| Profiles & Models | [docs/en/Profiles.md](docs/en/Profiles.md) | [Profiles.md](docs/Profiles.md) |
| MCP Configuration | [docs/en/MCP.md](docs/en/MCP.md) | [MCP.md](docs/MCP.md) |
| AI Agents | [docs/en/Agents.md](docs/en/Agents.md) | [Agents.md](docs/Agents.md) |
| Prompt Library | [docs/en/Prompt-Library.md](docs/en/Prompt-Library.md) | [Prompt-Library.md](docs/Prompt-Library.md) |
| FAQ | [docs/en/FAQ.md](docs/en/FAQ.md) | [FAQ.md](docs/FAQ.md) |
| Benchmark | [docs/en/Benchmark.md](docs/en/Benchmark.md) | [Benchmark.md](docs/Benchmark.md) |
| Init Command | [docs/en/Init.md](docs/en/Init.md) | [Init.md](docs/Init.md) |

---

## 📄 License

MIT License — see [LICENSE](LICENSE).
