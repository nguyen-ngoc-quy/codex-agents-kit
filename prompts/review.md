# Code Review Prompts

Thư viện prompt dành cho việc Review Code tự động, phát hiện lỗi bảo mật, lỗ hổng hiệu năng và vi phạm Coding Convention.

---

## 🔍 1. General Project Review (/review)
Prompt tổng quát quét qua dự án hoặc một file lớn:
```text
Hãy thực hiện một đợt Review Code toàn diện cho file/đoạn code dưới đây:
[DÁN_CODE_CỦA_BẠN]

Yêu cầu phân tích và báo cáo theo các khía cạnh:
1. Logic & Bugs: Có lỗi tiềm ẩn nào gây crash, NullReferenceException, race condition hoặc logic sai không?
2. Performance: Có vị trí nào gây lãng phí CPU/Memory (như cấp phát bộ nhớ thừa, truy vấn lặp, blocking call) không?
3. Readability: Code có dễ hiểu không? Đặt tên biến/hàm đã chuẩn chưa? Có cần tách hàm không?
```

---

## 🛡️ 2. Security Analysis (/security)
Prompt tập trung tìm lỗ hổng bảo mật:
```text
Hãy phân tích bảo mật cho đoạn code này:
[DÁN_CODE_CỦA_BẠN]

Hãy tìm và chỉ ra các nguy cơ bảo mật như:
- SQL Injection, XSS, CSRF.
- Lộ thông tin nhạy cảm (hardcoded passwords, API Keys, connection strings).
- Cơ chế phân quyền và mã hóa yếu.
- Đề xuất giải pháp và viết lại đoạn code đã sửa đổi bảo mật hơn.
```

---

## 📈 3. Best Practices & Design Patterns
Prompt đối chiếu code với các chuẩn thiết kế:
```text
Hãy đánh giá đoạn code sau dựa trên các Best Practices của ngôn ngữ/framework [Tên_Ngôn_Ngữ/Framework]:
- Code đã áp dụng đúng các Design Patterns thông dụng chưa?
- Có vi phạm antipatterns nào không?
- Đề xuất các cải tiến về mặt kiến trúc để code dễ mở rộng (scalable) và bảo trì (maintainable) hơn.
```
