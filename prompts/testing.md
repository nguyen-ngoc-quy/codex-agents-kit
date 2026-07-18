> Version: 0.1.6 | Last updated: 2026-07-17
# Testing & Benchmark Prompts

Thư viện prompt tối ưu phục vụ viết Unit Test, Integration Test và viết kịch bản Benchmark kiểm thử hiệu năng.

---

## 🧪 1. Unit Test Generation (/testing)
Prompt sinh Unit Test tự động cho một Class hoặc Method:
```text
Hãy viết các unit tests toàn diện cho Class/Method sau sử dụng framework [Tên_Framework, ví dụ: xUnit, Moq, Flutter Test]:
[DÁN_CODE_CỦA_BẠN]

Yêu cầu bao gồm:
- Thiết lập Mock cho tất cả các phụ thuộc (Dependencies) đầu vào.
- Viết các test cases cho Happy Path (đầu vào hợp lệ, kết quả mong đợi).
- Viết các test cases cho Edge Cases (đầu vào null, chuỗi rỗng, số âm, giá trị biên).
- Viết các test cases kiểm tra xem hệ thống có quăng đúng Exception khi gặp lỗi không.
- Sử dụng mô hình AAA (Arrange - Act - Assert).
```

---

## ⛓️ 2. Integration Test Setup
Prompt sinh kiểm thử tích hợp (Integration Test) kiểm tra luồng đi qua nhiều lớp:
```text
Tôi muốn viết Integration Test cho API/Luồng nghiệp vụ [Tên_Nghiệp_Vụ]:
- Thiết lập DB context ảo (In-Memory DB hoặc Testcontainers) để kiểm tra tương tác với Database thực tế.
- Giả lập HTTP request đi qua lớp Middleware, Route và gọi tới Controller/Handler.
- Assert kết quả trả về (HTTP Status Code, Schema của JSON Body và dữ liệu thực tế được lưu vào DB).
```

---

## 🏎️ 3. Performance Benchmark Script
Prompt sinh benchmark code đo tốc độ thực thi:
```text
Hãy viết một Benchmark class sử dụng [Tên_Thư_Viện, ví dụ: BenchmarkDotNet cho C#, Benchmark cho Go] để đo hiệu năng của phương thức [Tên_Phương_Thức]:
- Đo thời gian thực hiện trung bình (Mean execution time).
- Đo lượng bộ nhớ cấp phát (Memory allocation).
- So sánh hiệu năng giữa hai cách tiếp cận: [Cách_1] và [Cách_2].
```
