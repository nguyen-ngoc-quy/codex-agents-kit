> Version: 0.1.6 | Last updated: 2026-07-17
# Unity (C#) Prompts

Thư viện prompt tối ưu cho lập trình viên phát triển game trên nền tảng **Unity**, hướng tới code sạch, module hóa và tối ưu hiệu năng.

---

## 🧼 1. SOLID Unity Architectures
Prompt thiết kế script game tuân thủ SOLID, tránh phụ thuộc chặt chẽ (tight coupling):
```text
Tôi muốn viết một hệ thống [Tên_Hệ_Thống, ví dụ: Health System, Inventory] trong Unity. Hãy sinh code C# tuân thủ nguyên tắc SOLID:
- Sử dụng Interfaces để giao tiếp giữa các components.
- Không sử dụng trực tiếp Singleton (nếu không cần thiết), thay vào đó dùng Event-Driven Architecture (C# Actions/Events).
- Tách biệt logic nghiệp vụ khỏi MonoBehaviour (chỉ kế thừa MonoBehaviour ở phần hiển thị/nhận Input).
```

---

## 🗃️ 2. ScriptableObjects for Data & Config
Prompt sử dụng ScriptableObject quản lý dữ liệu game:
```text
Hãy tạo một kiến trúc ScriptableObject để lưu trữ cấu hình cho [Tên_Đối_Tượng, ví dụ: EnemyStats, ItemData]:
- Khai báo các biến cấu hình (Health, Speed, Damage, Icon, Prefab).
- Tạo phương thức helper để đọc hoặc tính toán các chỉ số động.
- Hướng dẫn thiết kế Custom Inspector bằng cách viết Editor Script hoặc sử dụng Sirenix Odin (nếu cần) giúp Designer dễ dàng nhập dữ liệu.
```

---

## ♻️ 3. High Performance Object Pooling
Prompt thiết kế Object Pool tối ưu hóa việc tạo/hủy Prefab liên tục:
```text
Hãy viết một Class Object Pool generic trong Unity để quản lý việc Spawn/Recycle của [Tên_Prefab, ví dụ: Bullet]:
- Sử dụng UnityEngine.Pool (được giới thiệu từ Unity 2021+) hoặc viết một Pool Class thủ công.
- Tối ưu hóa bộ nhớ, tránh sinh rác GC (Garbage Collection).
- Trả về đối tượng về Pool khi không sử dụng (OnRelease) và khởi tạo lại trạng thái ban đầu khi lấy ra (OnGet).
```

---

## 🔌 4. Zenject / Extenject Dependency Injection
Prompt sử dụng Dependency Injection trong Unity:
```text
Hãy hướng dẫn cài đặt và thiết lập Zenject/Extenject trong một Scene Unity:
- Tạo một MonoInstaller và đăng ký (Bind) các Services/Interfaces (ví dụ: IInputService, IGameManager).
- Viết script Injection [Inject] vào các MonoBehaviour components thay vì dùng FindObjectOfType hoặc Singleton.
- Thiết lập cách bind Prefab từ Addressables hoặc Resources thông qua Zenject Factory.
```
