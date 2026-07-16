# 🔌 Model Context Protocol (MCP) Setup

Guide to integrating MCP Servers that extend Codex CLI's capabilities.

---

## 🚀 Available MCP Servers

| Server | Package | Function | Requirements |
|--------|---------|----------|-------------|
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Read/write files, create/delete projects | — |
| **Git** | `@modelcontextprotocol/server-git` | Git diff, log, blame, branch | Git installed |
| **GitHub** | `@modelcontextprotocol/server-github` | PR, issues, code review | GitHub token (env var) |
| **Docker** | `@modelcontextprotocol/server-docker` | Container management | Docker installed + running |
| **Playwright** | `@modelcontextprotocol/server-playwright` | Headless browser, E2E tests | — |
| **Context7** | `@context7/mcp-server` | Auto-fetch framework docs | — |

---

## 🔧 Auto-Register

Since v0.1.3, all profiles (`free`, `premium`, `local`, `ollama`, `openrouter`) include MCP server configurations. When you run:

```powershell
.\scripts\install.ps1
```

or:

```bash
./scripts/install.sh
```

All MCP servers are automatically added to `~/.codex/config.toml` with `__WORKSPACE_ROOT__` replaced by the actual project path.

When switching profiles:

```powershell
codex profile free
codex profile premium
codex profile local
```

MCP paths are also updated automatically.

---

## 🛠️ Per-Server Configuration

### Filesystem MCP
Let Codex read projects, create new files, rename, and refactor code safely.

```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "__WORKSPACE_ROOT__"]
```

> `__WORKSPACE_ROOT__` is automatically replaced with the project path during installation.

### Git MCP
Direct integration of version control commands:

```toml
[mcp_servers.git]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-git"]
```

Capabilities: `git diff`, `git log`, `git blame`, create branches.

### GitHub MCP
Create and review Pull Requests directly from chat.

```toml
[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
# [mcp_servers.github.env]
# GITHUB_PERSONAL_ACCESS_TOKEN = "${GITHUB_PERSONAL_ACCESS_TOKEN}"
```

> **Important**: Uncomment the last 2 lines and set the `GITHUB_PERSONAL_ACCESS_TOKEN` env var before use.

### Docker MCP
Manage containers, images, and docker-compose via AI:

```toml
[mcp_servers.docker]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-docker"]
```

Requires Docker daemon running.

### Playwright MCP
Let AI open headless Chrome/Firefox, click, type text, and take screenshots for frontend debugging and E2E tests:

```toml
[mcp_servers.playwright]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-playwright"]
```

First run auto-downloads browser binaries (~200MB).

### Context7 MCP
Auto-fetch latest framework documentation (ASP.NET, Flutter, Unity...):

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@context7/mcp-server"]
```

---

## 🔍 Check MCP Status

Run `codex doctor` to verify MCP server connectivity and npm cache:

```powershell
codex doctor
```

Results show:
- ✅ Whether each MCP server package is cached in npm
- ✅ Node.js and npx availability
- ✅ Git installation status

---

## ❌ Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `npx: command not found` | Node.js not installed | Install Node.js from [nodejs.org](https://nodejs.org) |
| GitHub MCP not working | Missing GitHub token | Set `GITHUB_PERSONAL_ACCESS_TOKEN` env var and uncomment config |
| Docker MCP error | Docker daemon not running | Run `docker info` to verify |
| Playwright can't open browser | Missing browser binaries | Run `npx playwright install chromium` |
| Filesystem wrong path | Workspace root not substituted | Re-run `codex profile free` |
| `EACCES` permission error | npm global permission | Use `npx -y` (always local mode) |
