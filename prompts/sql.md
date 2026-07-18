> Version: 0.1.6 | Last updated: 2026-07-17
# SQL Server & Database Prompts

Thư viện prompt tối ưu cho thiết kế database, tối ưu hóa truy vấn SQL và tạo các bản Migration.

---

## 🏎️ 1. SQL Query Optimization
Prompt phân tích và tăng tốc một truy vấn SQL chậm:
```text
Tôi có một truy vấn SQL Server chạy rất chậm:
[DÁN_TRUY_VẤN_SQL_CỦA_BẠN]

Hãy tối ưu hóa truy vấn này:
- Loại bỏ các phép so sánh tốn kém (như LIKE '%...', hàm ép kiểu ngầm định).
- Thay thế các subqueries không cần thiết bằng JOIN hoặc Common Table Expressions (CTE).
- Đề xuất tạo các Indexes (Clustered, Non-Clustered, Cover Index) phù hợp trên các bảng tham gia truy vấn.
```

---

## 🗂️ 2. Smart Index Design
Prompt tư vấn cấu trúc chỉ mục trên bảng lớn:
```text
Hãy thiết kế hệ thống Index cho bảng [Tên_Bảng] trong SQL Server. Bảng này có đặc điểm:
- Chứa khoảng [Số_Lượng_Bản_Ghi, ví dụ: 10 triệu] dòng.
- Các câu lệnh SELECT thường xuyên lọc theo các trường: [Danh_sách_trường_WHERE].
- Các câu lệnh JOIN thường dựa trên: [Danh_sách_trường_JOIN].

Hãy đề xuất các chiến lược Index cụ thể, bao gồm cách tránh Overhead khi INSERT/UPDATE/DELETE và cách xử lý Index Fragmentation.
```

---

## 🚀 3. Safe Database Migrations
Prompt sinh script cập nhật database an toàn cho môi trường Productive:
```text
Hãy viết một script SQL Migration để thực hiện các thay đổi sau trên database đang chạy:
[MÔ_TẢ_THAY_ĐỔI, ví dụ: Thêm cột mới, đổi kiểu dữ liệu cột, tách bảng]

Yêu cầu script phải:
- Không làm gián đoạn hệ thống (Zero Downtime).
- Chứa cơ chế Rollback (Undo script) khi gặp lỗi.
- Đảm bảo tính toàn vẹn dữ liệu (sử dụng Transactions và kiểm tra EXISTS trước khi ALTER).
```

---

## 🔬 4. Execution Plan Analyzer
Prompt hướng dẫn đọc và giải quyết các cảnh báo trong Execution Plan:
```text
Tôi đang phân tích Execution Plan trong SQL Server Management Studio (SSMS). Tôi thấy có các cảnh báo/nodes:
[MÔ_TẢ_HOẶC_DÁN_THÔNG_TIN, ví dụ: Index Scan, Table Scan, Key Lookup, Missing Index Alert]

Hãy giải thích nguyên nhân gây ra các nodes này và hướng dẫn từng bước để khắc phục chúng nhằm chuyển đổi từ Scan sang Seek và loại bỏ Lookup.
```
