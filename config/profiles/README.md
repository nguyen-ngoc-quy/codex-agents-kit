# Custom Profiles

Tạo profile cấu hình riêng cho Codex CLI bằng cách đặt file `.toml` vào thư mục này.

## Cách dùng

1. Copy file mẫu `custom.toml.example` → `my-profile.toml`
2. Sửa nội dung phù hợp với provider và model bạn muốn
3. Chạy lệnh:
   ```powershell
   .\scripts\switch-profile.ps1 my-profile
   ```
   hoặc:
   ```bash
   ./scripts/switch-profile.sh my-profile
   ```

## Lưu ý

- Tên profile là tên file (không có `.toml`)
- API keys luôn được đọc từ **environment variables**, không hardcode trong file `.toml`
- Các profile có sẵn: `free`, `premium`, `local`
