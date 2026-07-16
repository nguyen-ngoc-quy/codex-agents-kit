# Flutter Prompts

Thư viện prompt tối ưu cho phát triển ứng dụng di động bằng **Flutter**, tuân thủ mô hình Feature First và Clean Code.

---

## 📂 1. Feature First Directory Structure
Prompt hướng dẫn sinh cấu trúc thư mục theo tính năng (Feature First):
```text
Tôi muốn tạo một feature mới có tên là [Tên_Feature] trong dự án Flutter theo mô hình Feature First. Hãy thiết lập cấu trúc thư mục bao gồm:
- data/ (repositories, data sources, models)
- domain/ (entities, value objects, repository interfaces)
- presentation/ (controllers/providers, views, widgets)

Hãy viết code mẫu cho file repository interface ở domain layer và class implementation ở data layer sử dụng Dio hoặc Http client.
```

---

## 🌊 2. Riverpod State Management
Prompt sinh state controller / notifier sử dụng Riverpod Generator:
```text
Hãy sinh một StateNotifier / AsyncNotifier sử dụng flutter_riverpod và riverpod_generator cho feature [Tên_Feature]:
- Quản lý trạng thái [Tên_Trạng_Thái] (gồm Loading, Success, Error).
- Triển khai các phương thức chính: fetch, update, delete.
- Hướng dẫn cách Widget (ConsumerWidget) lắng nghe và hiển thị UI tương ứng với từng trạng thái.
```

---

## ❄️ 3. Freezed Models & JSON Serialization
Prompt tạo Immutable Model sử dụng Freezed package:
```text
Hãy viết model class [Tên_Model] sử dụng gói 'freezed' và 'json_serializable':
- Định nghĩa các thuộc tính: [Danh_sách_thuộc_tính].
- Hỗ trợ deep copy (copyWith) và chuyển đổi sang JSON (fromJson, toJson).
- Tích hợp các hàm helper hoặc custom getters tiện ích.
- Viết lệnh chạy build_runner để sinh code tự động.
```

---

## 🗺️ 4. GoRouter Configuration
Prompt thiết lập định tuyến trong ứng dụng:
```text
Hãy cấu hình định tuyến trong Flutter sử dụng GoRouter:
- Tạo danh sách Routes cho ứng dụng (Home, Login, Detail).
- Cấu hình Route Guards để check Authentication (chuyển hướng người dùng về trang Login nếu chưa đăng nhập).
- Hướng dẫn truyền parameters (path parameters, query parameters) giữa các screens.
```
