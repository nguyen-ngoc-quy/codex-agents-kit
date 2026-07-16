# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.6] - 2026-07-16
### Added
- **P6.1 — Bilingual documentation**: Created `docs/en/` with full English translations of all 9 docs (Installation, Profiles, MCP, Agents, FAQ, Benchmark, Init, Prompt-Library, README). Language switcher in root README.
- **P6.2 — GitHub Issue/PR Templates**: `ISSUE_TEMPLATE/bug_report.md`, `feature_request.md`, `config.yml`, and `PULL_REQUEST_TEMPLATE.md` with structured forms and cross-platform checklist.
- **P6.3 — CI Expansion**: Added smoke-test job to CI workflow (runs `smoke-test.sh`). Added macOS (`macos-latest`) to install-test matrix. New `release.yml` workflow auto-creates GitHub Release on tag push (extracts changelog from CHANGELOG.md).
- **P6.4 — Context7 Auto-Fetch**: `scripts/fetch-docs.ps1` + `scripts/fetch-docs.sh` — downloads framework docs (ASP.NET, Flutter, Unity) for offline AI context. Registered as `codex fetch-docs <framework>`.
- **P6.5 — Agent Injection vào Profiles**: Added `# recommended_agent:` to all 5 TOML profiles. `switch-profile` scripts now detect and display the recommended agent after switching.
- **P6.6 — Prompt Versioning**: Added `> Version: 0.1.5 | Last updated: 2026-07-16` headers to all 11 prompt files and 7 agent files. Smoke tests validate version headers exist.
- **P6.7 — VSCode Extension (scaffold)**: Basic extension with 6 commands (doctor, profile switch, benchmark, init, agent, update) — accessible via Command Palette and Explorer context menu.

### Changed
- **scripts/smoke-test.sh**: Expanded from 76 to 91 checks
- **scripts/smoke-test.ps1**: Expanded from 83 to 118 checks
- **README.md**: Updated profile list (5 profiles), added English docs table, updated available commands
- **docs/en/**: 9 new English documentation files
- **Repo rename**: `codex-cli-ultimate` → `codex-agents-kit`. Updated all GitHub URL references, VS Code extension IDs, README tree, and CONTRIBUTING.md clone URL.

## [0.1.5] - 2026-07-16
### Added
- **P5.1 — Agent integration**: New `codex agent <name>` sub-command in all wrappers. `load-agent.ps1` and `load-agent.sh` extract System Instructions from `agents/<name>.md` and output formatted prompts for Codex CLI. Supports 7 agent roles.
- **P5.2 — New prompts**: Added `prompts/react.md` (6 sections: TypeScript component, Next.js, state management, Tailwind, testing, responsive layout), `prompts/python.md` (Django REST, FastAPI, SQLAlchemy, pytest, package structure, auth), and `prompts/go.md` (REST API, database, concurrency, testing, CLI, module structure).
- **P5.3 — Smoke test suite**: `scripts/smoke-test.ps1` (83 checks) and `scripts/smoke-test.sh` (76 checks) covering project structure, TOML configs, agent/prompt/script/doc files, wrapper dispatch, infrastructure, and environment.
- **P5.4 — Ollama + OpenRouter profiles**: `config/ollama.toml` (local Qwen 2.5 Coder 7B via localhost:11434) and `config/openrouter.toml` (free models with fallback routing via `route = "fallback"`). Automatically discoverable by `codex profile <name>`.
- **docs/Agents.md**: Documented `codex agent` CLI command and usage.
- **docs/Prompt-Library.md**: Added React, Python, Go entries.
- **docs/Installation.md**: Updated profiles list to include ollama and openrouter.

### Fixed
- **scripts/smoke-test.ps1**: Fixed UTF-8 BOM encoding for PowerShell 5.1 compatibility (previously caused "string missing terminator" parser error). Fixed 3-argument `Join-Path` calls — PS 5.1 only accepts 2 positional parameters; switched to nested calls.

## [0.1.4] - 2026-07-16
### Fixed
- **scripts/benchmark.sh**: macOS compatibility — replaced `date +%s%N` (Linux-only) with cross-platform `get_ms()` using Python/Perl/date fallback.
- **scripts/benchmark.sh**: Added missing tokens/sec calculation (was present in PS version only).
- **scripts/install.ps1**: Added CI detection (`$env:CI`, `$env:GITHUB_ACTIONS`, etc.) — skips `Read-Host` prompt and PATH auto-config in non-interactive mode.
- **scripts/install.sh**: Added CI detection (`$CI`, `$GITHUB_ACTIONS`, `$TF_BUILD`) — skips `read </dev/tty` prompt in non-interactive mode.
- **scripts/init-project.ps1**: Replaced invalid empty `.sln` with proper ASP.NET Core scaffold (.csproj + Program.cs + Properties/). No longer forces switch to free profile.
- **scripts/init-project.sh**: Same fix — proper scaffold instead of empty `.sln`. Uses shell variable expansion for project name.
- **scripts/doctor.sh**: No longer uses `ping` for network check (unavailable on some systems) — HTTPS check only.

### Added
- **docs/MCP.md**: Expanded from skeleton to full guide — per-server config, troubleshooting table, CI mode notes.
- **docs/Init.md**: New documentation for the `codex init` command with template details and examples.
- **docs/FAQ.md**: Expanded from 3 to 13 questions covering API key safety, MCP servers, macOS support, OpenRouter geo-restrictions, and more.
- **docs/Installation.md**: Updated both Windows and Linux sections to document the new auto-PATH feature.
- **.editorconfig**: Consistent coding style across PowerShell, Bash, TOML, and Markdown files.
- **CONTRIBUTING.md**: Contribution guidelines with setup instructions, commit format, and release process.
- **VERSION**: Single-file version tracking (`VERSION=0.1.3`).

### Changed
- **scripts/doctor.sh**: Added MCP npm cache status check (parity with doctor.ps1).
- **README.md**: Integrated into docs index with proper links.

## [0.1.3] - 2026-07-16
### Added
- **P3.1 — MCP auto-register**: All 3 profile TOMLs (free, premium, local) now include 6 MCP server configurations (Filesystem, Git, GitHub, Docker, Playwright, Context7). Placeholder `__WORKSPACE_ROOT__` gets replaced at install and switch-profile time.
- **P3.2 — `codex init` command**: New `codex init <name> [template]` sub-command in all wrappers. Scaffolds projects with templates: `basic`, `aspnet`, `flutter`. Creates README.md, .gitignore and auto-switches to free profile.
- **P3.4 — Enhanced `codex doctor`**: Added checks for Codex CLI version, Node.js/npx/Git availability, MCP server npm cache status, network connectivity, and system information (OS, PowerShell version, user). Both PowerShell and Bash versions updated.
- **P3.5 — Auto-PATH in install scripts**: Install.ps1 now prompts to add `bin/` to the PowerShell profile. Install.sh prompts to add to `.bashrc`/`.zshrc`. Both scripts also add to the current session PATH.
- **P3.6 — GitHub Actions CI**: New `.github/workflows/validate.yml` with 5 jobs: TOML validation, ShellCheck, PowerShell Script Analyzer, cross-platform install test (Linux + Windows), and markdown link check.

### Fixed
- **scripts/switch-profile.{ps1,sh}**: Now replace `__WORKSPACE_ROOT__` placeholders after copying a profile to the active config.
- **ROADMAP.md**: Marked v0.2 MCP auto-register, v0.5 codex init as completed.

## [0.1.2] - 2026-07-15
### Changed
- **All PowerShell scripts**: Standardized `$ErrorActionPreference` — `"Stop"` for install/switch/benchmark/update, `"Continue"` for doctor. Each script now has a comment explaining the policy rationale.
- **config/ollama.toml**: Clarified that Ollama does not require an API key but Codex requires the `env_key` field to be present; added explicit instruction to set any non-empty placeholder.
- **scripts/install.ps1**: Generated wrapper now writes to `bin/codex-installed.ps1` instead of overwriting the template `bin/codex.ps1`.

### Added
- **.gitignore**: Ignores `*.bak` (backup files), `bin/codex` (Bash wrapper generated by install.sh), `bin/codex-installed.ps1` (generated by install.ps1), and common OS/editor junk files.
- **config/profiles/**: Directory for custom user profiles with `README.md` (usage instructions) and `custom.toml.example` (annotated template showing all supported fields).

### Fixed
- **scripts/install.{ps1,sh}**: Added warning before config overwrite alerting users that custom MCP server configurations will need to be re-added.

## [0.1.1] - 2026-07-15
### Fixed
- **bin/codex.ps1**: Removed hardcoded `C:\Users\QUY\...` paths. Wrapper now auto-detects codex.exe via PATH, environment variable (`CODEX_CLI_PATH`), or common install locations. Also available as a template that `install.ps1` customizes at setup time.
- **scripts/install.sh**: Bash wrapper now stores the detected codex binary path at install time and uses `exec` to delegate, preventing infinite-loop recursion when the wrapper's `bin/` directory is on `PATH`.
- **scripts/install.ps1**: Generated wrapper now uses the same dynamic-resolution approach as `bin/codex.ps1` and includes a persistent `$CodexExe` path detected during setup.
- **README.md, docs/Agents.md, docs/Prompt-Library.md**: Replaced all `file:///c:/Users/QUY/...` absolute links with relative paths (`docs/...`, `../agents/...`, etc.) so links work on any machine and on GitHub.
- **docs/Installation.md**: Fixed Linux/macOS PATH example that incorrectly showed a Windows `C:\đường_dẫn_dự_án\...` path, and the Windows example using the same placeholder.
- **ROADMAP.md**: Updated `[ ]` markers to `[x]` for v0.2 (MCP) and v0.3 (Agents) items that already have scaffold files. Added finer-grained sub-items to distinguish "scaffolded" from "fully implemented".

### Security
- **bin/codex.ps1, scripts/install.ps1**: Wrapper now only reads API keys from environment variables, never from config file contents.
- **scripts/doctor.{ps1,sh}, scripts/benchmark.{ps1,sh}**: Removed code that attempted to extract raw API keys from `config.toml` via regex matching on `sk-or-v1-*` patterns. Keys are now read exclusively from environment variables.
