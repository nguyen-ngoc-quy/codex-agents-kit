> Version: 0.1.6 | Last updated: 2026-07-17
# ASP.NET Core Prompts

Đây là thư viện prompt tối ưu dành cho việc phát triển phần mềm bằng **ASP.NET Core**, tuân thủ Clean Architecture và các best practices.

---

## 🏗️ 1. Clean Architecture Template
Sử dụng prompt này khi muốn tạo cấu trúc Solution/Project mới hoặc thêm mới Entity theo mô hình Clean Architecture:
```text
Tôi muốn phát triển một tính năng mới trong ASP.NET Core sử dụng Clean Architecture. Hãy thiết lập cấu trúc cho Entity [Tên_Entity] gồm:
1. Domain Layer: Khai báo Entity (gồm Id, Audit properties, domain events)
2. Application Layer: Định nghĩa DTOs, Mapping profile (AutoMapper), CQRS Commands/Queries, và Validation (FluentValidation).
3. Infrastructure Layer: Cấu hình DbContext, Migration và Repository.
4. Presentation Layer (API): Viết Minimal API Endpoint hoặc Controller, thiết lập Dependency Injection.

Hãy đảm bảo code tuân thủ SOLID, DRY và Clean Code.
```

---

## ⚡ 2. CQRS (MediatR) Implementation
Prompt thiết lập CQRS Handler cho một Operation cụ thể:
```text
Hãy sinh code cho Command/Query xử lý nghiệp vụ [Tên_Nghiệp_Vụ] sử dụng MediatR trong ASP.NET Core:
- Yêu cầu Command/Query record chứa các properties đầu vào.
- Viết Validator sử dụng FluentValidation.
- Viết RequestHandler xử lý logic (bao gồm Dependency Injection repository, logger, Mapper).
- Xử lý Exception một cách nhất quán (với Custom exceptions và Global Exception Handler).
```

---

## 🗄️ 3. Entity Framework Core (EF Core) Optimize
Prompt tối ưu hóa Database Context và Configurations:
```text
Tôi đang làm việc với EF Core. Hãy viết cấu hình Fluent API (IEntityTypeConfiguration) cho Entity [Tên_Entity]:
- Thiết lập Primary Key, Foreign Keys, Indexes cho các trường thường xuyên tìm kiếm.
- Cấu hình Soft Delete (Query Filter).
- Tối ưu hóa truy vấn (sử dụng .AsNoTracking() cho các truy vấn Read-Only).
- Sinh code cho Repository Pattern và Unit of Work để quản lý transaction.
```

---

## 🛡️ 4. Dependency Injection & Logging
Prompt thiết lập đăng ký dịch vụ và ghi log:
```text
Hãy hướng dẫn cách đăng ký các Services vào Dependency Injection Container của ASP.NET Core (Program.cs) một cách gọn gàng sử dụng Extension Methods.
Đồng thời, thêm tính năng Logging sử dụng Serilog/ILogger ghi lại log chi tiết về:
- Thời gian bắt đầu và kết thúc request
- Exception xảy ra và chi tiết stack trace
- Tham số đầu vào (nếu cần thiết)
```
