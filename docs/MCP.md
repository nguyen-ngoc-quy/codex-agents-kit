# 🔌 Model Context Protocol (MCP) Setup

Hướng dẫn tích hợp các MCP Servers giúp mở rộng năng lực của Codex CLI.

---

## 🚀 Các MCP Server có sẵn

| Server | Package | Chức năng | Yêu cầu |
|--------|---------|-----------|---------|
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Đọc/ghi file, tạo/xoá project | — |
| **Git** | `@modelcontextprotocol/server-git` | Git diff, log, blame, branch | Git installed |
| **GitHub** | `@modelcontextprotocol/server-github` | PR, issues, code review | GitHub token (env var) |
| **Docker** | `@modelcontextprotocol/server-docker` | Container management | Docker installed + running |
| **Playwright** | `@modelcontextprotocol/server-playwright` | Headless browser, E2E tests | — |
| **Context7** | `@context7/mcp-server` | Tự động lấy tài liệu framework | — |

---

## 🔧 Tự động đăng ký (Auto-Register)

Từ phiên bản v0.1.3, cả 3 profile (`free`, `premium`, `local`) đều đã tích hợp sẵn cấu hình MCP servers. Khi bạn chạy:

```powershell
.\scripts\install.ps1
```

hoặc:

```bash
./scripts/install.sh
```

Tất cả MCP servers được tự động thêm vào `~/.codex/config.toml` với placeholder `__WORKSPACE_ROOT__` được thay thế bằng đường dẫn thực tế.

Khi chuyển đổi profile:

```powershell
codex profile free
codex profile premium
codex profile local
```

Cũng tự động thay thế MCP paths.

---

## 🛠️ Cấu hình từng server

### Filesystem MCP
Cho phép Codex đọc dự án, tạo file mới, đổi tên và refactor code an toàn.

```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "__WORKSPACE_ROOT__"]
```

> `__WORKSPACE_ROOT__` được tự động thay bằng đường dẫn project khi cài đặt.

### Git MCP
Tích hợp trực tiếp các lệnh kiểm soát phiên bản:

```toml
[mcp_servers.git]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-git"]
```

Chức năng: `git diff`, `git log`, `git blame`, tạo branch mới.

### GitHub MCP
Tạo và review Pull Requests trực tiếp từ chat.

```toml
[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
# [mcp_servers.github.env]
# GITHUB_PERSONAL_ACCESS_TOKEN = "${GITHUB_PERSONAL_ACCESS_TOKEN}"
```

> **Important**: Uncomment 2 dòng cuối và set env var `GITHUB_PERSONAL_ACCESS_TOKEN` trước khi dùng.

### Docker MCP
Quản lý container, image, docker-compose qua AI:

```toml
[mcp_servers.docker]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-docker"]
```

Yêu cầu Docker daemon đang chạy.

### Playwright MCP
Cho phép AI mở trình duyệt ảo Chrome/Firefox, thực hiện các thao tác click, nhập text, chụp ảnh màn hình để debug frontend và E2E tests:

```toml
[mcp_servers.playwright]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-playwright"]
```

Lần chạy đầu tiên sẽ tự động tải browser binaries (~200MB).

### Context7 MCP
Tự động lấy tài liệu framework mới nhất (ASP.NET, Flutter, Unity...):

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@context7/mcp-server"]
```

---

## 🔍 Kiểm tra trạng thái MCP

Chạy `codex doctor` để kiểm tra trạng thái kết nối của các MCP Servers và npm cache:

```powershell
codex doctor
```

Kết quả sẽ hiển thị:
- ✅ Mỗi MCP server đã cached npm package hay chưa
- ✅ Node.js và npx có sẵn không
- ✅ Git có được cài đặt không

---

## ❌ Troubleshooting

| Vấn đề | Nguyên nhân | Cách fix |
|--------|-------------|----------|
| `npx: command not found` | Node.js chưa cài | Cài Node.js từ [nodejs.org](https://nodejs.org) |
| GitHub MCP không hoạt động | Thiếu GitHub token | Set `GITHUB_PERSONAL_ACCESS_TOKEN` env var và uncomment config |
| Docker MCP lỗi | Docker daemon không chạy | `docker info` để kiểm tra |
| Playwright không mở browser | Thiếu browser binaries | Chạy `npx playwright install chromium` |
| Filesystem sai đường dẫn | Workspace root chưa được thay thế | Chạy lại `codex profile free` |
| `EACCES` permission error | npm global permission | Dùng `npx -y` (luôn ở chế độ local) |
