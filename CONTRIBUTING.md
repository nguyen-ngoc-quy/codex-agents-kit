# Contributing to Codex CLI Ultimate

Cảm ơn bạn đã quan tâm đến việc đóng góp cho dự án! Dưới đây là hướng dẫn nhanh.

---

## 📋 Quy tắc cơ bản

1. **File pairs**: Mỗi script cần có cả bản `.ps1` (Windows PowerShell) và `.sh` (Linux/macOS Bash).
2. **API Keys**: Không bao giờ lưu API key trong code hoặc config files. Dùng environment variables.
3. **TOML changes**: Cập nhật cả 3 profiles (`free.toml`, `premium.toml`, `local.toml`) khi thêm/sửa cấu hình.
4. **Error policy**: Dùng `$ErrorActionPreference = "Stop"` cho critical operations, `"Continue"` cho diagnostic.
5. **Placeholder**: `__WORKSPACE_ROOT__` được dùng làm placeholder cho đường dẫn project.

## 🔧 Development Setup

```powershell
# Clone repo
git clone https://github.com/YOUR_USER/codex-agents-kit.git
cd codex-agents-kit

# Run install
.\scripts\install.ps1

# Verify
.\scripts\doctor.ps1
```

## 🧪 Kiểm tra trước khi commit

- **TOML**: Validate toàn bộ config files: `python -c "import tomllib; [tomllib.load(open(f, 'rb')) for f in __import__('glob').glob('config/*.toml')]"`
- **Shell scripts**: `shellcheck scripts/*.sh`
- **PowerShell**: `Invoke-ScriptAnalyzer -Path scripts/*.ps1`
- **CI**: Mọi thay đổi sẽ được kiểm tra qua GitHub Actions workflow (`.github/workflows/validate.yml`).

## 📝 Commit message format

```
<type>: <subject>

[optional body]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
```
feat: add python/django prompt template
fix: benchmark.sh date compatibility on macOS
docs: update MCP server configuration guide
```

## 📂 Project Structure

```
config/        # TOML profiles
  profiles/    # Custom profile templates
prompts/       # Framework-specific prompts
agents/        # AI Agent instructions
scripts/       # PowerShell + Bash scripts (paired)
bin/           # CLI wrappers
docs/          # Documentation
mcp/           # MCP server JSON definitions
.github/       # CI workflows
```

## 🚀 Release process

1. Update `VERSION` file
2. Update `CHANGELOG.md`
3. Tag commit: `git tag v$(cat VERSION)`
4. Push: `git push --tags`
