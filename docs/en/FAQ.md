# ❓ Frequently Asked Questions (FAQ)

Answers to common questions about using Codex CLI Ultimate.

---

## 🔑 1. Do I need to pay for OpenRouter?
**Not required.** The `free` profile is configured to use OpenRouter's free endpoints (Qwen Coder, DeepSeek R1, Gemini 2.5 Flash Free). Free models have rate limits that vary by demand.

---

## ⚡ 2. How do I handle rate limits on the Free plan?
We've configured an **Auto Fallback** mechanism in `config/free.toml`. When Qwen is overloaded, the call automatically falls through to Gemini 2.5 Flash Free, then DeepSeek R1 Free. If issues persist, switch to the `local` profile to run offline via Ollama.

---

## 💻 3. Ollama can't connect when using Local Profile?
Check the following:
- Make sure Ollama is running on your machine
- Run `ollama list` in a terminal to verify available models
- Run `ollama pull qwen2.5-coder:7b` (or the model specified in `config/local.toml`) to download the model before using Codex

---

## 🔄 4. How do I update Codex CLI Ultimate?
Run:
```powershell
codex update
```

The script performs a `git pull` to get the latest version. Then run `codex profile free` to apply new configurations.

---

## 🛡️ 5. Are my API keys safe?
**Yes.** Codex CLI Ultimate never stores API keys in configuration files. All API keys are read exclusively from environment variables. The `config.toml` only references the environment variable name via the `env_key` field — it never contains the actual key value.

For example, in the profile:
```toml
[model_providers.openrouter]
env_key = "OPENROUTER_API_KEY"
```

The actual key is set separately:
```powershell
$env:OPENROUTER_API_KEY = "sk-or-v1-..."
```

---

## 📦 6. What is an MCP Server and do I need to install anything extra?
MCP (Model Context Protocol) Servers are plugins that extend Codex CLI — read/write files, use Git, manage Docker, etc.

Since v0.1.3, all MCP servers are **auto-registered** during installation. You only need **Node.js** (to run `npx`). On first use, npx automatically downloads the required packages.

See [MCP.md](MCP.md) for details.

---

## 🐳 7. Is Docker MCP server mandatory?
**No.** Docker MCP is optional. If your machine doesn't have Docker, Codex CLI simply skips this server. Other MCP servers (Filesystem, Git) still work normally.

---

## 🍃 8. I use macOS — is it supported?
**Yes.** All scripts have `.sh` (Bash) versions compatible with macOS. Note:
- The benchmark script uses Python/Perl for timing instead of `date +%N` (not available on macOS)
- The default shell profile is `~/.zshrc` (Zsh is default since macOS Catalina)

---

## 🪟 9. How do I make `codex` available in every terminal?
During `install.ps1`, you'll be prompted to auto-add to PATH. If you choose Yes, the script adds it to your PowerShell profile.

For manual setup:
```powershell
# Open PowerShell profile
notepad $PROFILE.CurrentUserAllHosts
# Add this line:
$env:Path = "C:\path\to\codex-cli-ultimate\bin;$env:Path"
```

For Bash:
```bash
# Add to ~/.bashrc or ~/.zshrc:
export PATH="/path/to/codex-cli-ultimate/bin:$PATH"
```

---

## ❌ 10. Codex CLI reports "command not found" even after installation?
Check:
1. Run `codex doctor` for diagnostics
2. Verify `bin/` is in PATH: `echo $PATH` (Unix) or `$env:Path` (Windows)
3. Re-run `install.ps1` or `install.sh`
4. For PowerShell, restart terminal or run `. $PROFILE.CurrentUserAllHosts`

---

## 📁 11. Can I create my own profile?
Yes. See the guide at [config/profiles/README.md](../../config/profiles/README.md). Copy `custom.toml.example` and customize it.

---

## 🧪 12. How do I benchmark model speed?
Run:
```powershell
codex benchmark
```

This sends a test prompt to the active model and measures response latency and token generation speed (tokens/sec).

---

## 🌐 13. OpenRouter is not supported in my region?
Some countries are blocked by OpenRouter. Solutions:
- Use the **Local Profile**: `codex profile local` + Ollama (fully offline)
- Use a **VPN** if you need OpenRouter access
- Configure a different provider (OpenAI, Anthropic) in your profile
