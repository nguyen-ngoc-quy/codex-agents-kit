> Version: 0.1.6 | Last updated: 2026-07-17
# Clean Code & Refactoring Prompts

Thư viện prompt giúp tái cấu trúc code (Refactor), áp dụng nguyên lý Clean Code để tăng tính mạch lạc, dễ đọc.

---

## ✂️ 1. Code Refactor (/refactor)
Prompt tái cấu trúc phương thức dài hoặc phức tạp:
```text
Tôi muốn refactor đoạn code sau đây để tăng tính rõ ràng và giảm độ phức tạp (cyclomatic complexity):
[DÁN_CODE_CỦA_BẠN]

Hãy thực hiện:
- Tách các đoạn logic phức tạp thành các hàm nhỏ (Extract Method) với tên hàm mô tả rõ chức năng.
- Loại bỏ các câu lệnh lồng nhau nhiều tầng (Nested Ifs) bằng cách sử dụng Guard Clauses (Return Early).
- Đơn giản hóa các biểu thức điều kiện.
- Đảm bảo giữ nguyên hành vi gốc của code (no breaking changes).
```

---

## 🚫 2. DRY (Don't Repeat Yourself) Check
Prompt phát hiện và gom nhóm code trùng lặp:
```text
Hãy phân tích đoạn code/các file sau để tìm ra phần code bị trùng lặp (duplication):
[DÁN_CODE_CỦA_BẠN]

Đề xuất cách giải quyết theo nguyên lý DRY:
- Tạo ra hàm dùng chung, class helper hoặc sử dụng kế thừa/composition.
- Viết lại code sau khi đã loại bỏ trùng lặp.
```

---

## 📐 3. SOLID Principles Alignment
Prompt căn chỉnh thiết kế class theo SOLID:
```text
Hãy kiểm tra class [Tên_Class] dưới đây xem có vi phạm bất kỳ nguyên tắc SOLID nào không:
[DÁN_CODE_CỦA_BẠN]

Chi tiết:
- Single Responsibility: Class có đang làm quá nhiều việc không?
- Open/Closed: Khi thêm tính năng mới có cần sửa code cũ không?
- Liskov Substitution, Interface Segregation, Dependency Inversion.
Hãy tái cấu trúc lại class này để đạt điểm SOLID tối đa.
```
