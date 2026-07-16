# React & Next.js Prompts

Thư viện prompt tối ưu cho phát triển ứng dụng web với **React** và **Next.js**, tuân thủ best practices hiện đại.

---

## ⚛️ 1. Component với TypeScript
Prompt tạo React component theo chuẩn TypeScript + best practices:
```text
Hãy tạo một React component [Tên_Component] với các yêu cầu sau:
- Sử dụng TypeScript với interface/type cho props.
- Component là functional component với hooks.
- Bao gồm loading state, empty state, error state.
- Sử dụng CSS Modules hoặc Tailwind classes (không dùng inline styles).
- Tuân thủ accessibility (role, aria-label, keyboard navigation).
- Unit test với React Testing Library (render, user events, edge cases).
```

---

## 🏗️ 2. Next.js App Router Page
Prompt tạo page hoặc route handler cho Next.js App Router:
```text
Hãy tạo một Next.js page tại [đường_dẫn]/page.tsx sử dụng App Router:
- Server Component mặc định, chỉ dùng 'use client' khi cần interactivity.
- Fetch dữ liệu với server-side fetch (caching, revalidation, error handling).
- Tạo loading.tsx và error.tsx cho route segment.
- Metadata API cho SEO (generateMetadata).
- Use SearchParams cho filter/pagination nếu cần.
```

---

## 🔄 3. State Management (Zustand / Context)
Prompt quản lý state toàn cục:
```text
Hãy thiết lập state management cho [tính_năng] sử dụng [Zustand / React Context]:
- Định nghĩa store/context với TypeScript types.
- Actions: fetch data từ API, update local state, optimistic updates.
- Middleware: logger, persist (localStorage) nếu cần.
- Custom hooks để truy cập state một cách clean, tránh re-render không cần thiết.
- Handle race conditions và abort pending requests.
```

---

## 🎨 4. Tailwind CSS Theming
Prompt thiết lập theme toàn cục:
```text
Hãy thiết lập Tailwind CSS theme cho dự án React/Next.js:
- Cấu hình tailwind.config.ts với custom colors, fonts, spacing.
- Dark mode support (class strategy) với CSS variables.
- Thiết lập global CSS variables cho theme tokens.
- Responsive design với breakpoints tùy chỉnh.
- Animation keyframes và utility classes tái sử dụng.
```

---

## 🧪 5. Testing React Components
Prompt viết test cho component:
```text
Hãy viết test cho component [Tên_Component] với:
- Render test: component render đúng với default props.
- Interaction test: click, change, submit hoạt động đúng.
- Edge case test: empty data, loading state, error boundary.
- Accessibility test: jest-axe kiểm tra a11y violations.
- Mock API calls với MSW (Mock Service Worker).
```

---

## 📱 6. Responsive Layout
Prompt tạo responsive layout:
```text
Hãy tạo layout responsive cho [màn_hình]:
- Mobile-first approach.
- Sidebar/ Navigation: collapsible trên mobile, persistent trên desktop.
- Data table: horizontal scroll trên mobile, đầy đủ columns trên desktop.
- Form: single column (mobile), multi-column (desktop) với grid.
- Sử dụng CSS Grid và Flexbox, không dùng framework UI có sẵn.
```
