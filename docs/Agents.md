# 👥 AI Agents Guide

Tài liệu hướng dẫn phối hợp và sử dụng các **AI Agent chuyên biệt** trong quy trình phát triển.

---

## 🤖 Danh sách các Agent

| Agent | File cấu hình | Vai trò chính |
| :--- | :--- | :--- |
| **Architect** | [architect.md](../agents/architect.md) | Thiết kế hệ thống, sơ đồ DB, vẽ sơ đồ luồng. |
| **Backend** | [backend.md](../agents/backend.md) | Phát triển API ASP.NET Core, tối ưu EF Core, Repository. |
| **Frontend** | [frontend.md](../agents/frontend.md) | Phát triển giao diện Flutter, React, Unity UI, Riverpod. |
| **DevOps** | [devops.md](../agents/devops.md) | Viết Dockerfile, Compose, cấu hình CI/CD Actions. |
| **Reviewer** | [reviewer.md](../agents/reviewer.md) | Review code, quét lỗ hổng bảo mật, kiểm tra clean code. |
| **Debugger** | [debugger.md](../agents/debugger.md) | Chuẩn đoán log lỗi, phân tích stack trace và đưa ra bản vá. |
| **Tester** | [tester.md](../agents/tester.md) | Viết xUnit, Moq, Flutter tests và đo đạc hiệu năng. |

---

## 💡 Cách sử dụng

### CLI Command (từ v0.1.4)
Sử dụng lệnh `codex agent` để load system instructions của agent tương ứng:

```powershell
# Load architect agent instructions
codex agent architect

# List available agents
codex agent
```

Kết quả là file hướng dẫn của Agent được in ra terminal — bạn có thể copy-paste vào Codex CLI làm context.

### Manual (truyền thống)
Trước khi bắt đầu một tác vụ lớn, hãy copy nội dung của file Agent tương ứng trong thư mục `agents/` và gửi làm System Prompt hoặc Context khởi đầu cho Codex CLI để định hình hành vi và quy tắc viết code của AI.
E.g., gửi kèm chỉ thị: `Sử dụng cấu hình Backend Agent tại agents/backend.md để triển khai tính năng sau:`
