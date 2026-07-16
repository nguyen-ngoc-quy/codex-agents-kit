# ⏱️ Model Performance Benchmarking

Tài liệu hướng dẫn sử dụng công cụ đo đạc hiệu năng kết nối và xử lý của mô hình AI.

---

## 🚀 Giới thiệu
Tốc độ phản hồi (Latency) và độ ổn định là yếu tố sống còn khi làm việc với Coding Agents. Dự án tích hợp sẵn công cụ benchmark giúp bạn đo đạc các chỉ số này một cách dễ dàng.

---

## 📊 Cách chạy Benchmark

### Trên Windows (PowerShell)
```powershell
# Chạy benchmark trên profile đang hoạt động
.\scripts\benchmark.ps1
```

### Trên Linux / macOS (Bash)
```bash
./scripts/benchmark.sh
```

---

## 📈 Các chỉ số đo lường (Metrics Explained)
- **Total Latency**: Tổng thời gian từ khi gửi yêu cầu tới khi nhận được phản hồi hoàn chỉnh (tính bằng mili-giây).
- **Speed (Est. tokens/sec)**: Số lượng token ước lượng sinh ra trên mỗi giây. Chỉ số này càng cao nghĩa là mô hình phản hồi càng mượt mà.
- **Connection Success**: Xác nhận xem API Key và Network Route tới Provider (OpenRouter hoặc Ollama) có thông suốt không.
