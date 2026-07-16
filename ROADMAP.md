# 🗺️ Codex CLI Ultimate Roadmap

Bản lộ trình phát triển và hoàn thiện Codex CLI Ultimate Starter Kit qua các giai đoạn.

---

## 📅 Lộ trình các phiên bản (Version Release Schedule)

### v0.1 — Foundation ✅
- [x] Thiết lập cấu trúc thư mục chuẩn.
- [x] Tạo file cấu hình Profile: `free.toml`, `premium.toml`, `local.toml`.
- [x] Viết script chuyển đổi nhanh `switch-profile.ps1` và `switch-profile.sh`.
- [x] Viết script kiểm tra hệ thống `doctor.ps1`.
- [x] Định nghĩa cấu trúc Fallback Model của OpenRouter.

### v0.2 — MCP Ecosystem ⚡
- [x] Xây dựng file cấu hình MCP mẫu cho Filesystem, Git, GitHub, Docker, Playwright, Context7.
- [x] **Tự động đăng ký MCP servers** vào config.toml khi chạy `install.ps1` / `install.sh`.
- [ ] Tích hợp Context7 lấy tài liệu tự động (ASP.NET, Flutter, Unity...).
- [ ] Hướng dẫn cài đặt và thiết lập MCP chi tiết (sẵn có `docs/MCP.md` — cần bổ sung video/screenshot).

### v0.3 — AI Agents Config ⚡
- [x] Tạo System Instructions cho các Agent chuyên biệt (Architect, Backend, Frontend, DevOps, Reviewer, Debugger, Tester).
- [ ] **Tích hợp agent instructions vào profile** — tự động inject system prompt khi switch profile.
- [ ] Thêm cơ chế loading agent config từ CLI (ví dụ: `codex agent architect`).

### v0.4 — Prompt Library ⚡
- [x] Phát triển các prompt mẫu cho ASP.NET, Flutter, Unity, SQL, Docker & DevOps, Clean Code, Testing.
- [x] Bổ sung prompt cho React/Next.js, Python/Django, Go.
- [x] Áp dụng prompt versioning và tự động cập nhật từ repo.

### v0.5 — Automation & Benchmark
- [x] Tạo script `benchmark.ps1` / `benchmark.sh` đo lường hiệu năng của các model.
- [x] Tạo script `update.ps1` / `update.sh` tự động kéo prompt/config mới nhất từ repo.
- [x] Tạo tool `codex init` để khởi tạo project nhanh.

### v0.8 — VSCode Extension
- [x] Tạo VSCode Extension cung cấp menu chuột phải (scaffold).
- [x] Tích hợp Command Palette chạy các script Codex nhanh chóng (scaffold).

### v1.0 — Official Release
- [x] Hoàn thiện hệ thống tài liệu song ngữ (EN + VI).
- [x] Smoke test trên Windows, Linux, macOS (CI).
- [x] Đóng gói và phát hành chính thức bản v0.1.6.

---

## 🎯 Mục tiêu dài hạn (Long-term Goals)
- Giúp Codex CLI trở nên phổ biến và dễ dùng nhất cho các developer Việt Nam.
- Thay thế 90% nhu cầu Claude Code bằng giải pháp miễn phí hoặc local.
- Hỗ trợ đầy đủ các tác vụ DevOps & Cài đặt hệ thống tự động qua AI Agent.
