# 🚀 Codex CLI Ultimate

> A complete starter kit for Codex CLI powered by OpenRouter, Local LLMs, MCP Servers and AI Agents.

---

## Vision
Xây dựng một bộ Starter Kit hoàn chỉnh cho Codex CLI giúp:
- Thay thế phần lớn trải nghiệm Claude Code
- Hoạt động với OpenRouter Free
- Hỗ trợ Local LLM
- Có thể mở rộng thành AI Coding Platform
- Hoàn toàn Open Source

---

## Mục tiêu
- **Chi phí**: Ưu tiên miễn phí, dùng OpenRouter Free. Có thể chuyển sang GPT/Claude khi cần.
- **Khả năng**: ASP.NET Core, Flutter, Unity, SQL Server, Docker, Git, DevOps.
- **Khả năng mở rộng**: Local LLM, MCP, AI Agents, Plugin System.

---

## Repository Structure
```text
codex-cli-ultimate/
├── README.md
├── ROADMAP.md
├── LICENSE
├── CHANGELOG.md
│
├── config/
│   ├── free.toml
│   ├── premium.toml
│   ├── local.toml
│   ├── openrouter.toml
│   ├── ollama.toml
│   └── profiles/
│
├── prompts/
│   ├── aspnet.md
│   ├── flutter.md
│   ├── unity.md
│   ├── sql.md
│   ├── docker.md
│   ├── review.md
│   ├── clean-code.md
│   └── testing.md
│
├── agents/
│   ├── architect.md
│   ├── backend.md
│   ├── frontend.md
│   ├── devops.md
│   ├── reviewer.md
│   ├── debugger.md
│   └── tester.md
│
├── mcp/
│   ├── filesystem.json
│   ├── git.json
│   ├── github.json
│   ├── context7.json
│   ├── playwright.json
│   └── docker.json
│
├── scripts/
│   ├── install.ps1
│   ├── install.sh
│   ├── switch-profile.ps1
│   ├── benchmark.ps1
│   ├── doctor.ps1
│   └── update.ps1
│
└── docs/
    ├── Installation.md
    ├── Profiles.md
    ├── MCP.md
    ├── Agents.md
    ├── Prompt-Library.md
    ├── Benchmark.md
    └── FAQ.md
```

---

## Roadmap & Phases

### Phase 1 — Foundation (v0.1)
- Multi Provider (OpenRouter, OpenAI, Ollama, LM Studio, vLLM)
- Profile System: `free`, `premium`, `local`, `high-quality`, `fast`
- One Command Switch: `codex profile free`, `codex profile local`, `codex profile premium`
- Multi Model Mapping: Coding (Qwen Coder), Reasoning (DeepSeek R1), Long Context (Gemma), Fast (Llama)
- Auto Fallback Chain: Qwen Free -> Gemma -> DeepSeek -> GPT -> Claude
- Health Check: `codex doctor` (check API Key, Provider, PATH, MCP, Version, Config)

### Phase 2 — MCP Ecosystem (v0.2)
- Filesystem MCP: read project, edit files, rename, refactor.
- Git MCP: git diff, blame, commit, history, branch.
- GitHub MCP: review PR, issues, search, commit.
- Context7 MCP: fetch latest documentation (ASP.NET, Flutter, Unity, Docker, EF Core).
- Playwright MCP: browser control, click, test, screenshots.

### Phase 3 — AI Agents (v0.3)
- Architect, Backend Agent, Frontend Agent, DevOps Agent, Reviewer, Debugger, Tester.

### Phase 4 — Prompt Library (v0.4)
- ASP.NET (Clean Architecture, CQRS, EF Core, validation...)
- Flutter (Riverpod, GoRouter, Freezed, Feature First...)
- Unity (SOLID, Addressables, ScriptableObject, Zenject...)
- SQL (Optimization, Indexes, Migrations...)
- Docker (Compose, Production builds, Multi-stage...)

### Phase 5 — Commands & Phase 6 — Automation (v0.5)
- Custom CLI tools / commands (`/review`, `/refactor`, `/optimize`, `/security`, `/benchmark`, `/explain`).
- Automation tools (`codex init`, `codex doctor`, `codex benchmark`, `codex update`).

### Phase 7 — VSCode Integration (v0.8)
- Context menu, command palette.

### Phase 8 — Documentation (v1.0)
- Official documentation, tutorials, FAQs.
