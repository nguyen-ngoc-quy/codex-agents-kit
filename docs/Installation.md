# ⚙️ Installation Guide

Hướng dẫn chi tiết cài đặt và cấu hình bộ Starter Kit **Codex CLI Ultimate**.

---

## 💻 1. Cài đặt trên Windows (PowerShell)

### Bước 1: Cho phép chạy script
Mở PowerShell dưới quyền Admin và chạy lệnh sau để cho phép chạy script cục bộ:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Bước 2: Chạy script cài đặt
Điều hướng tới thư mục dự án và chạy:
```powershell
.\scripts\install.ps1
```
Script sẽ thực hiện:
- Sao lưu cấu hình cũ tại `~/.codex/config.toml.bak`.
- Copy file cấu hình mặc định (`config/free.toml`) vào thư mục của Codex.
- Tạo wrapper script `bin/codex.ps1`.

### Bước 3: Tích hợp Command Line (Tự động)
Khi chạy `install.ps1`, script sẽ hỏi bạn có muốn tự động thêm thư mục `bin/` vào PATH không. Nếu chọn **Y**, dòng sau sẽ được thêm vào PowerShell profile của bạn:
```powershell
$env:Path = "C:\path\to\codex-cli-ultimate\bin;$env:Path"
```

> **Mẹo**: Nếu bạn chạy trong môi trường CI (GitHub Actions, Azure DevOps), script sẽ tự động bỏ qua bước này và chỉ hiển thị hướng dẫn.

Sau đó restart terminal hoặc chạy:
```powershell
. $PROFILE.CurrentUserAllHosts
```

> **Thủ công**: Nếu không muốn auto-PATH, bạn có thể tự thêm dòng trên vào file PowerShell profile.

---

## 🐧 2. Cài đặt trên Linux & macOS (Bash)

### Bước 1: Cấp quyền thực thi
Mở terminal và chạy lệnh:
```bash
chmod +x ./scripts/install.sh ./scripts/switch-profile.sh ./scripts/doctor.sh ./scripts/update.sh ./scripts/benchmark.sh
```

### Bước 2: Chạy script cài đặt
```bash
./scripts/install.sh
```

### Bước 3: Tích hợp PATH
Khi chạy `install.sh`, script sẽ phát hiện shell profile của bạn (`.bashrc` hoặc `.zshrc`) và hỏi có muốn tự động thêm `bin/` vào PATH không. Nếu chọn **Y**, dòng sau sẽ được thêm vào profile:
```bash
export PATH="/path/to/codex-cli-ultimate/bin:$PATH"
```

> **CI mode**: Trong môi trường CI (GitHub Actions, GitLab CI), script tự động bỏ qua prompt và chỉ hiển thị hướng dẫn.

Sau đó load lại shell:
```bash
source ~/.zshrc
```

> **Thủ công**: Nếu bạn không dùng auto-PATH, tự thêm dòng `export PATH="..."` vào `~/.bashrc` hoặc `~/.zshrc`.
