> Version: 0.1.6 | Last updated: 2026-07-17
# Docker & DevOps Prompts

Thư viện prompt tối ưu cho việc đóng gói ứng dụng bằng Docker, quản lý container bằng Docker Compose và tối ưu cấu hình deployment.

---

## 📦 1. Production Multi-stage Dockerfile
Prompt sinh Dockerfile tối ưu kích thước và bảo mật:
```text
Hãy viết một Dockerfile multi-stage cho ứng dụng [Tên_Công_Nghệ, ví dụ: ASP.NET Core, Flutter Web, Node.js]:
- Stage 1: Build source code sử dụng SDK đầy đủ.
- Stage 2: Publish ứng dụng sang Runtime Image gọn nhẹ (chỉ chứa runtime tối giản, không chứa SDK).
- Đảm bảo chạy ứng dụng dưới quyền Non-Root User để tăng cường bảo mật.
- Tối ưu hóa Docker Cache bằng cách copy các file dependency/package trước khi copy toàn bộ source code.
```

---

## 🎼 2. Docker Compose Production Stack
Prompt cấu hình môi trường chạy nhiều dịch vụ:
```text
Hãy thiết lập một file docker-compose.yml hoàn chỉnh cho hệ thống gồm các dịch vụ sau ở môi trường Production:
- API Service (ASP.NET Core / Node.js)
- Frontend (React / Flutter Web)
- Database (SQL Server / PostgreSQL)
- Reverse Proxy (Nginx / Caddy) để cấu hình SSL tự động.

Yêu cầu:
- Thiết lập volume lưu trữ dữ liệu database.
- Cấu hình restart policy và environment variables an toàn.
- Sử dụng Docker Networks để cô lập truy cập (DB không được public ra ngoài internet).
```

---

## 🏥 3. Container Health Checks
Prompt cấu hình giám sát trạng thái hoạt động của container:
```text
Hãy thêm cấu hình Health Check vào Dockerfile và docker-compose.yml cho service [Tên_Service]:
- Định nghĩa lệnh test sức khỏe (ví dụ: dùng curl/wget kiểm tra endpoint /healthz).
- Cấu hình các tham số: interval (chu kỳ chạy check), timeout (thời gian tối đa chờ phản hồi), retries (số lần thử lại trước khi coi container lỗi), và start_period.
- Hướng dẫn cấu hình dịch vụ khác phụ thuộc vào trạng thái Healthy của dịch vụ này (sử dụng depends_on với condition: service_healthy).
```
