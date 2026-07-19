# ⚙️ Installation Guide

Detailed installation and configuration guide for **Codex CLI Ultimate**.

---

## 💻 1. Windows Installation (PowerShell)

### Step 1: Enable script execution
Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 2: Run the install script
Navigate to the project directory and run:
```powershell
.\scripts\install.ps1
```

The script will:
- Back up any existing config at `~/.codex/config.toml.bak`
- Copy the default profile (`config/free.toml`) to Codex's config directory
- Create a wrapper script at `bin/codex.ps1`

### Step 3: Auto PATH Setup
During installation, the script will prompt to add the `bin/` directory to your PATH automatically. If you choose **Y**, it adds this line to your PowerShell profile:
```powershell
$env:Path = "C:\path\to\codex-cli-ultimate\bin;$env:Path"
```

> **Tip**: In CI environments (GitHub Actions, Azure DevOps), the script skips the prompt and shows manual instructions.

Restart your terminal or run:
```powershell
. $PROFILE.CurrentUserAllHosts
```

> **Manual**: If you skip auto-PATH, add the line above to your PowerShell profile manually: `notepad $PROFILE.CurrentUserAllHosts`

---

## 🐧 2. Linux & macOS Installation (Bash)

### Step 1: Grant execute permissions
Open a terminal and run:
```bash
chmod +x ./scripts/install.sh ./scripts/switch-profile.sh ./scripts/doctor.sh ./scripts/update.sh ./scripts/benchmark.sh ./scripts/init-project.sh ./scripts/load-agent.sh
```

### Step 2: Run the install script
```bash
./scripts/install.sh
```

### Step 3: PATH setup
The script detects your shell profile (`.bashrc` or `.zshrc`) and asks whether to add `bin/` to your PATH automatically:
```bash
export PATH="/path/to/codex-cli-ultimate/bin:$PATH"
```

> **CI mode**: In CI environments (GitHub Actions, GitLab CI), the script skips the prompt automatically.

Reload your shell:
```bash
source ~/.zshrc
```

> **Manual**: If you skip auto-PATH, add the `export PATH="..."` line to `~/.bashrc` or `~/.zshrc` yourself.
