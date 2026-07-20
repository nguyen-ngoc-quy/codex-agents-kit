# TOML Editor & OpenCode Zen Profile — Design Spec

> **Ngày:** 2026-07-19
> **Dự án:** Codex CLI Ultimate
> **Phiên bản:** v0.1.6 → v0.2.0
> **Trạng thái:** Approved ✅

---

## 1. Summary

Thêm hai tính năng chính:
1. **Form-based TOML Editor** — Web UI form + CLI command để chỉnh sửa file `.toml` cấu hình profile, cho phép thay đổi model, provider, tools, plugins, MCP servers mà không cần edit thủ công.
2. **OpenCode Zen Profile** — Profile mới cho OpenCode Zen (AI provider với curated coding models), mặc định dùng model free.

Kèm theo fix 4 issues liên quan: H9 (CI scan), M18 (template thiếu), H12–H15 (MCP package names sai).

---

## 2. Architecture

### 2.1 Tổng quan hệ thống

```
┌─────────────────────────────────────────────────────────┐
│                    Người dùng                            │
├────────────────────┬────────────────────────────────────┤
│   Web UI Form      │   CLI (terminal)                   │
│   (profiles page)  │   codex config <subcommand>        │
└─────────┬──────────┴──────────┬─────────────────────────┘
          │                     │
          ▼                     ▼
┌─────────────────────────────────────────────────────────┐
│              Backend (Node.js Express)                   │
│  routes/config.js         scripts/config.ps1/sh         │
│  - GET/PUT /api/profiles  - list/get/set/edit           │
│  - Validate TOML          - Backup & rollback           │
└─────────┬───────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│              File System                                │
│  config/*.toml           ~/.codex/config.toml           │
│  (profile definitions)   (active profile)               │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Components

| Component | Vai trò | Công nghệ |
|-----------|---------|-----------|
| Web UI Profile Editor | Form-based editor cho profile fields | Vanilla JS, no framework |
| Backend Config API | REST endpoints cho profile CRUD | Express.js + @iarna/toml |
| CLI Config Command | Terminal-based config management | PowerShell 5.1+ / Bash |
| Switch Profile Logic | Copy profile → active config (existing) | Reuse `switch-profile.ps1/sh` |
| MCP Package Fixes | Sửa tên package không tồn tại | Update JSON files |

---

## 3. Web UI — Form Editor

### 3.1 Pages & Routes

| Route | Mô tả | Status |
|-------|-------|--------|
| `#/profiles` | List profiles (existing) | Existing |
| `#/profiles/:name/edit` | Edit profile form | **New** |
| `#/profiles/:name/raw` | View raw TOML (existing) | Rename from `viewProfile` |

### 3.2 API Endpoints (mới + sửa)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `PUT` | `/api/profiles/:name` | Save edited profile (full TOML content) |
| `GET` | `/api/profiles/:name/fields` | Get profile as structured field groups |
| `PUT` | `/api/config/set` | CLI helper: set a single field by key=value |

### 3.3 Form UI Layout

```
Edit Profile: free.toml                         [Save] [Cancel]
┌─────────────────────────────────────────────────────────────┐
│ Basic Settings                                              │
│  Provider:     [openrouter     ▼]                           │
│  Model:        [qwen/qwen-2.5-coder-32b-instruct:free]     │
│  Display Name: [OpenRouter AI (Free)]                       │
│  Base URL:     [https://openrouter.ai/api/v1]              │
│  Env Key:      [OPENROUTER_API_KEY                        ] │
├─────────────────────────────────────────────────────────────┤
│ Tools                                                       │
│  ☑ Web Search     ☑ File Browser                           │
├─────────────────────────────────────────────────────────────┤
│ Plugins (8)                                                 │
│  ☑ test-android-apps  ☑ visualize  ☑ browser               │
│  ☑ documents  ☑ pdf  ☑ spreadsheets  ☑ presentations       │
│  ☑ template-creator                                         │
├─────────────────────────────────────────────────────────────┤
│ MCP Servers (6)                                             │
│  [filesystem] [git] [github] [docker] [playwright] [context7]│
│  ────────────────────────────────────────                   │
│  Click to edit → command: [npx                      ]       │
│                   args:   [@pkg, arg1, arg2         ]       │
│                   env:    [KEY=VALUE                ]       │
│                                                             │
│  [+ Add MCP Server]  [Remove Selected]                     │
├─────────────────────────────────────────────────────────────┤
│ Advanced: Raw TOML                                          │
│  [─── TOML content synced in real-time ───]                │
│  (Read-only, mirror of form state above)                    │
└─────────────────────────────────────────────────────────────┘
```

### 3.4 Form → TOML Mapping

```
Form Field                    TOML Key
───────────────────────────────────────────────────────
Provider                      model_provider
Model                         model
Display Name                  [model_providers.X].name
Base URL                      [model_providers.X].base_url
Env Key                       [model_providers.X].env_key
Web Search                    [tools].web_search
File Browser                  [tools].file_browser
Plugins                       [plugins."name"].enabled
MCP Servers                   [mcp_servers.name].command + args + env
```

### 3.5 Data Flow

```
[User edits form]
       │
       ▼
[JS updates local state (object)]
       │
       ▼
[Render raw TOML preview] ← [@iarna/toml.stringify(state)]
       │
       ▼
[User clicks Save]
       │
       ▼
[PUT /api/profiles/:name] ──→ [Backend parse & validate]
                                    │
                                    ▼
                          [Backup .toml → .toml.bak]
                                    │
                                    ▼
                          [Write new content → .toml]
                                    │
                                    ▼
                          [Re-parse to verify syntax]
                                    │
                          ┌─────────┴─────────┐
                          ▼                   ▼
                      Success             Fail → rollback
```

---

## 4. CLI — Config Command

### 4.1 Command Spec

```
codex config list
  → Output: danh sách key=value của profile đang active (model_provider, model, base_url, env_key, tools)

codex config get <key>
→ Output: giá trị của key (VD: "model": "qwen/qwen-2.5-coder-32b-instruct:free")

codex config set <key> <value>
  → Set key/value vào active profile (~/.codex/config.toml)
  → Backup + validate trước khi ghi
  → Hỗ trợ dot notation: mcp_servers.filesystem.command

codex config set-model <model>
  → Shortcut: set model <model>

codex config set-provider <provider>
  → Shortcut: set model_provider + tự động config env_key tương ứng
  → Mapping:
    openai       → base_url=https://api.openai.com/v1, env_key=OPENAI_API_KEY
    openrouter   → base_url=https://openrouter.ai/api/v1, env_key=OPENROUTER_API_KEY
    anthropic    → base_url=https://api.anthropic.com/v1, env_key=ANTHROPIC_API_KEY
    ollama       → base_url=http://localhost:11434/v1, env_key=OLLAMA_API_KEY
    opencode-zen → base_url=https://opencode.ai/zen/v1, env_key=OPENCODE_API_KEY

codex config edit [profile-name]
  → Mở file .toml trong editor mặc định
  → Windows: notepad.exe (fallback) hoặc $env:EDITOR → code
  → macOS/Linux: $EDITOR → vi/nano/code
```

### 4.2 Script Architecture

**`scripts/config.ps1`** (PowerShell):

```powershell
param(
    [Parameter(Position=0)] [string]$Action,
    [Parameter(ValueFromRemainingArguments=$true)] $Args
)

# Functions:
# - Get-ConfigPath() → resolve ~/.codex/config.toml
# - Get-ActiveConfig() → parse & return config object (regex-based TOML parse)
# - Set-ConfigField($path, $key, $value) → regex replace
# - Backup-Config($path) → copy .toml → .toml.bak
# - Validate-Toml($path) → try codex --dry-run or basic syntax check
# - Find-Editor() → locate editor (code, notepad, vim...)
```

**`scripts/config.sh`** (Bash):

```bash
# Same logic, uses sed/awk/grep for TOML manipulation
# Uses $EDITOR or falls back to vi
```

### 4.3 Help Output

```
$ codex config --help
Usage: codex config <command> [args]

Commands:
  list                          Show all config fields
  get <key>                     Get a config value
  set <key> <value>             Set a config value
  set-model <model>             Change model quickly
  set-provider <provider>       Change provider (openai, openrouter, anthropic, ollama, opencode-zen)
  edit [profile]                Edit profile in default editor

Examples:
  codex config set-model gpt-4o
  codex config set-provider opencode-zen
  codex config set mcp_servers.filesystem.args '@modelcontextprotocol/server-filesystem, C:\\Projects'
```

---

## 5. OpenCode Zen Profile

### 5.1 Profile Config

File: `config/opencode-zen.toml`

```toml
# Codex Profile: opencode-zen
# Uses OpenCode Zen API — curated models for coding agents
# Website: https://opencode.ai/zen
# Base URL: https://opencode.ai/zen/v1
# recommended_agent: debugger

model_provider = "openai"
model = "deepseek-v4-flash-free"

[model_providers.openai]
name = "OpenCode Zen"
base_url = "https://opencode.ai/zen/v1"
env_key = "OPENCODE_API_KEY"
```

(Full file includes all 8 plugins and 6 MCP servers — see template in Section 7.3)

### 5.2 OpenCode Zen — Available Models

| Model ID | Type | Input Price / 1M tok | Output Price / 1M tok |
|----------|------|---------------------|----------------------|
| `deepseek-v4-flash-free` | Free | $0 | $0 |
| `mimo-v2.5-free` | Free | $0 | $0 |
| `north-mini-code-free` | Free | $0 | $0 |
| `nemotron-3-ultra-free` | Free | $0 | $0 |
| `gpt-5.5` | Paid | ~$2.00 | ~$10.00 |
| `gpt-5.5-pro` | Paid | ~$5.00 | ~$25.00 |
| `claude-sonnet-4-5` | Paid | ~$3.00 | ~$15.00 |
| `claude-opus-4.8` | Paid | ~$5.00 | ~$25.00 |
| `gemini-3.5-flash` | Paid | ~$0.10 | ~$0.40 |
| `opencode/qwen-3.7-max` | Paid | ~$1.50 | ~$7.00 |

> **Lưu ý:** OpenCode Zen cung cấp cả free model (rate limit thấp hơn) và paid model.
> API key được lấy từ env var `OPENCODE_API_KEY`. Đăng ký tại https://opencode.ai/auth

### 5.3 CLI Integration

Cập nhật help text trong:
- `bin/codex.ps1` — dòng 76: thêm "opencode-zen" vào danh sách profile
- `scripts/install.ps1` — dòng 253-258: thêm "opencode-zen" vào completion message

### 5.4 Web UI Integration

- Thêm `OPENCODE_API_KEY` vào env key check list trong `ui/routes/system.js` (dòng 105-109)
- Thêm env key check trong `ui/public/js/api.js` (nếu cần)

---

## 6. Validation & Error Handling

### 6.1 Web UI Validation

| Field | Rule | Error Message |
|-------|------|---------------|
| model_provider | Must be one of: openai, openrouter, anthropic, ollama | "Provider không hợp lệ" |
| model | Not empty, no leading/trailing spaces | "Model name không được để trống" |
| base_url | Must be valid HTTP/HTTPS URL | "URL không hợp lệ" |
| env_key | Uppercase, underscores, numbers | "env_key phải là chữ in hoa, underscore và số" |
| TOML syntax | Parseable by @iarna/toml | "Lỗi cú pháp TOML tại dòng X" |

### 6.2 CLI Validation

| Situation | Behavior |
|-----------|----------|
| Key không tồn tại | "Unknown config key: X. Available keys: ..." |
| Giá trị empty | "Cannot set X to empty value" |
| File không tồn tại | "Profile 'X' not found" |
| TOML parse fail sau khi ghi | Rollback + "Failed to parse saved config. Changes reverted." |

### 6.3 Safety

- **Backup trước ghi**: Mọi thao tác ghi đều tạo `.bak`
- **Rollback tự động**: Nếu parse fail sau ghi → restore từ `.bak`
- **Read-only mode**: Khi không có quyền ghi file → báo lỗi rõ ràng

---

## 7. Bug Fixes Included

### 7.1 H9 — CI Workspace Root Scan False Positive

**File:** `.github/workflows/validate.yml` (dòng 67)

**Fix:** Exclude `config/profiles/` từ `grep` scan:

```bash
found_leaks=$(grep -rn '__WORKSPACE_ROOT__' config/ --include='*.toml' --exclude-dir='profiles' 2>/dev/null || true)
```

### 7.2 H12–H15 — MCP Package Name Fixes

| File | Old | New |
|------|-----|-----|
| `mcp/context7.json` | `@context7/mcp-server` | `@upstash/context7-mcp` |
| `mcp/docker.json` | `@modelcontextprotocol/server-docker` | `@hypnosis/docker-mcp-server` |
| `mcp/git.json` | `@modelcontextprotocol/server-git` | `@cyanheads/git-mcp-server` |
| `mcp/playwright.json` | `@modelcontextprotocol/server-playwright` | `@playwright/mcp` |

### 7.3 M18 — Template Thiếu Plugins & MCP Servers

**File:** `config/profiles/custom.toml.example`

**Fix:** Đồng bộ template với tất cả 8 plugins và 6 MCP servers (như trong `free.toml`).

---

## 8. Files Changed

### Files Created (3)
| File | Mô tả |
|------|-------|
| `config/opencode-zen.toml` | OpenCode Zen profile |
| `scripts/config.ps1` | CLI config command (PowerShell) |
| `scripts/config.sh` | CLI config command (Bash) |

### Files Modified (~10)
| File | Thay đổi |
|------|----------|
| `bin/codex.ps1` | Add "config" dispatch + "opencode-zen" in help |
| `ui/routes/config.js` | Add PUT /api/profiles/:name, GET fields endpoint |
| `ui/routes/system.js` | Add OPENCODE_API_KEY to env check |
| `ui/public/js/api.js` | Add updateProfile(), setConfigField() |
| `ui/public/js/pages/profiles.js` | Add edit mode (form + raw TOML) |
| `.github/workflows/validate.yml` | Fix H9: exclude profiles/ from scan |
| `mcp/context7.json` | Fix H12: update package name |
| `mcp/docker.json` | Fix H13: update package name |
| `mcp/git.json` | Fix H14: update package name |
| `mcp/playwright.json` | Fix H15: update package name |
| `config/profiles/custom.toml.example` | Fix M18: add all plugins + MCP servers |

---

## 9. Non-Goals

- ❌ Không thêm drag-drop reorder cho MCP servers
- ❌ Không thêm autocomplete cho model names (API call phụ thuộc vào provider)
- ❌ Không thêm profile comparison/diff view
- ❌ Không thêm OpenCode Zen model list auto-fetch (có thể làm sau)
- ❌ Không thay đổi cấu trúc TOML hiện tại (backward-compatible)
