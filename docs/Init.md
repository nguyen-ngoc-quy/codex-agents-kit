# 🏗️ Codex Init — Quick Project Scaffolding

Tài liệu hướng dẫn sử dụng lệnh `codex init` để khởi tạo project mới nhanh chóng.

---

## 🚀 Cách sử dụng

```powershell
codex init <project-name> [template]
```

### Ví dụ

```powershell
# Basic project
codex init my-app

# ASP.NET Core web app
codex init my-api aspnet

# Flutter project (hướng dẫn chạy flutter create)
codex init my-flutter-app flutter
```

### Templates có sẵn

| Template | Mô tả | Files tạo ra |
|----------|-------|-------------|
| `basic` (mặc định) | Cấu trúc project cơ bản | README.md, .gitignore |
| `aspnet` | ASP.NET Core Web API (net9.0) | README.md, .gitignore, .csproj, Program.cs, Properties/ |
| `flutter` | Flutter project | README.md, .gitignore + hướng dẫn chạy `flutter create` |

---

## 📦 Output structure

### Basic template

```
my-app/
├── README.md
└── .gitignore
```

### ASP.NET Core template

```
my-api/
├── Properties/
├── README.md
├── .gitignore
├── my-api.csproj
└── Program.cs
```

### Flutter template

```
my-flutter-app/
├── README.md
└── .gitignore
```

Sau đó chạy `flutter create my-flutter-app` để sinh cấu trúc Flutter đầy đủ.

---

## 💡 Tips

- Chạy `codex profile free` sau khi init để chọn provider.
- Dùng `codex doctor` để kiểm tra system readiness.
- Template `aspnet` dùng .NET 9.0 — nếu bạn dùng .NET 8, sửa `TargetFramework` trong `.csproj` thành `net8.0`.
