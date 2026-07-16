# ❓ Frequently Asked Questions (FAQ)

Giải đáp các câu hỏi thường gặp khi sử dụng Codex CLI Ultimate.

---

## 🔑 1. Tôi có cần nạp tiền vào OpenRouter không?
**Không bắt buộc.** Profile `free` được cấu hình mặc định để sử dụng các endpoint miễn phí của OpenRouter (như Qwen Coder, DeepSeek R1, Gemini 2.5 Flash Free). Tuy nhiên, các mô hình miễn phí sẽ bị giới hạn lượt gọi (Rate limits) tùy thời điểm.

---

## ⚡ 2. Làm thế nào để giải quyết lỗi hết lượt gọi (Rate Limit) ở bản Free?
Chúng tôi đã thiết lập cơ chế **Auto Fallback** trong file `config/free.toml`. Khi mô hình Qwen bị quá tải, cuộc gọi sẽ tự động được chuyển tiếp sang Gemini 2.5 Flash Free, rồi đến DeepSeek R1 Free. Nếu vẫn gặp lỗi, bạn có thể chuyển tạm thời sang Profile `local` để chạy offline thông qua Ollama.

---

## 💻 3. Ollama báo lỗi không kết nối được khi chạy Local Profile?
Hãy kiểm tra các yếu tố sau:
- Đảm bảo ứng dụng Ollama đã được khởi động trên máy tính của bạn.
- Mở Terminal/Command Prompt và chạy lệnh `ollama list` để kiểm tra danh sách model.
- Chạy lệnh `ollama pull qwen2.5-coder:7b` (hoặc tên model tương ứng trong file `config/local.toml`) để tải mô hình về trước khi chạy Codex.

---

## 🔄 4. Làm thế nào để cập nhật Codex CLI Ultimate lên phiên bản mới nhất?
Chạy lệnh:
```powershell
codex update
```
Script sẽ tự động `git pull` phiên bản mới nhất. Sau đó chạy lại `codex profile free` để áp dụng cấu hình mới.

---

## 🛡️ 5. API Key của tôi có an toàn không?
**Có.** Codex CLI Ultimate không bao giờ lưu API key trong file cấu hình. Tất cả API keys chỉ được đọc từ biến môi trường (environment variables). File `config.toml` chỉ tham chiếu đến tên biến môi trường qua trường `env_key`, không chứa giá trị key thật.

Ví dụ, trong profile:
```toml
[model_providers.openrouter]
env_key = "OPENROUTER_API_KEY"
```
Giá trị key thật được set riêng:
```powershell
$env:OPENROUTER_API_KEY = "sk-or-v1-..."
```

---

## 📦 6. MCP Server là gì và tôi có cần cài đặt gì thêm không?
MCP (Model Context Protocol) Servers là các plugin mở rộng khả năng của Codex CLI — đọc/ghi file, dùng Git, quản lý Docker, v.v.

Từ phiên bản v0.1.3, tất cả MCP servers được **tự động đăng ký** khi cài đặt. Bạn chỉ cần có **Node.js** (để chạy `npx`) là đủ. Lần đầu Codex gọi MCP server, npx sẽ tự động tải package về.

Xem chi tiết tại [docs/MCP.md](MCP.md).

---

## 🐳 7. Docker MCP server có bắt buộc không?
**Không.** Docker MCP server là optional. Nếu máy bạn không có Docker, Codex CLI sẽ bỏ qua MCP server này. Các MCP server khác (Filesystem, Git) vẫn hoạt động bình thường.

---

## 🍃 8. Tôi dùng macOS — có hỗ trợ không?
**Có.** Tất cả scripts đều có phiên bản `.sh` (Bash) tương thích với macOS. Tuy nhiên, lưu ý:
- Benchmark script dùng Python/Perl để tính thời gian thay vì `date +%N` (không có trên macOS).
- Shell profile mặc định là `~/.zshrc` (Zsh là shell mặc định từ macOS Catalina).

---

## 🪟 9. Làm sao để kích hoạt `codex` command trong mọi terminal?
Khi chạy `install.ps1`, bạn sẽ được hỏi có muốn auto-add vào PATH không. Nếu chọn Yes, script sẽ tự động thêm vào PowerShell profile.

Nếu bạn muốn làm thủ công:
```powershell
# Mở PowerShell profile
notepad $PROFILE.CurrentUserAllHosts
# Thêm dòng:
$env:Path = "C:\path\to\codex-cli-ultimate\bin;$env:Path"
```

Với Bash:
```bash
# Thêm vào ~/.bashrc hoặc ~/.zshrc:
export PATH="/path/to/codex-cli-ultimate/bin:$PATH"
```

---

## ❌ 10. Codex CLI báo lỗi "command not found" dù đã cài?
Kiểm tra:
1. Chạy `codex doctor` để chẩn đoán.
2. Đảm bảo `bin/` đã có trong PATH: `echo $PATH` (Unix) hoặc `$env:Path` (Windows).
3. Chạy lại `install.ps1` hoặc `install.sh`.
4. Nếu dùng PowerShell, restart terminal hoặc chạy `. $PROFILE.CurrentUserAllHosts`.

---

## 📁 11. Tôi có thể tạo profile riêng không?
Có. Xem hướng dẫn tại [config/profiles/README.md](../config/profiles/README.md). Copy file `custom.toml.example` và chỉnh sửa theo nhu cầu.

---

## 🧪 12. Làm sao để benchmark tốc độ model?
Chạy:
```powershell
codex benchmark
```
Lệnh này gửi một prompt test đến model đang active và đo thời gian phản hồi (latency) cùng tốc độ sinh token (tokens/sec).

---

## 🌐 13. OpenRouter không hỗ trợ ở khu vực của tôi?
Một số quốc gia bị OpenRouter chặn. Giải pháp:
- Dùng **Local Profile**: `codex profile local` + Ollama (hoàn toàn offline, không cần internet).
- Dùng **VPN** nếu cần truy cập OpenRouter.
- Cấu hình provider khác (OpenAI, Anthropic) trong file profile.
