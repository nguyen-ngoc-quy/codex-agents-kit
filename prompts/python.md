> Version: 0.1.6 | Last updated: 2026-07-17
# Python & Django Prompts

Thư viện prompt tối ưu cho phát triển ứng dụng Python với **Django** và **FastAPI**, tuân thủ Python best practices.

---

## 🏗️ 1. Django REST API (DRF)
Prompt tạo REST API endpoint hoàn chỉnh:
```text
Hãy tạo Django REST API cho model [Tên_Model] sử dụng Django Rest Framework:
- Model với các fields, Meta class, __str__, và related managers.
- Serializer với validation (field-level, object-level).
- ViewSet với pagination, filtering, searching, ordering.
- URL routing với DefaultRouter hoặc custom routes.
- Permissions: IsAuthenticated, custom permission classes.
- Unit test với pytest-django: test CRUD operations, permissions, edge cases.
```

---

## ⚡ 2. FastAPI Endpoint
Prompt tạo FastAPI endpoint hiệu năng cao:
```text
Hãy tạo FastAPI endpoint cho [tính_năng] với:
- Pydantic models cho request/response validation.
- Async database session (SQLAlchemy async + asyncpg).
- Dependency injection cho authentication, database session.
- Error handling với custom exception handlers.
- OpenAPI documentation với tags, summary, response models.
- Rate limiting và caching strategy.
- Background tasks cho heavy operations.
```

---

## 🗄️ 3. Database Design (SQLAlchemy)
Prompt thiết kế database models:
```text
Hãy thiết kế SQLAlchemy models cho hệ thống [tên_hệ_thống]:
- Declarative models với relationship và back_populates.
- Indexes, unique constraints, composite keys.
- Alembic migration setup (initial revision).
- Enum types, JSON fields, full-text search nếu cần.
- Soft delete pattern (is_active, deleted_at).
- Audit trail: created_at, updated_at, created_by, updated_by.
- Query optimization: select_related, prefetch_related, subquery.
```

---

## 🧪 4. Python Testing (pytest)
Prompt viết test với pytest:
```text
Hãy viết pytest test cho module [tên_module]:
- Fixtures: database session, test client, mock objects.
- Unit test: test từng function riêng biệt với mocking.
- Integration test: test API endpoints với test client.
- Parametrize: test nhiều input/output combinations.
- Coverage: đảm bảo test coverage > 80% cho critical paths.
- Async test: pytest-asyncio cho async functions.
- Cleanup: teardown fixtures đúng cách, không leak resources.
```

---

## 🐍 5. Python Package Structure
Prompt tạo cấu trúc Python package chuẩn:
```text
Hãy tạo cấu trúc Python package cho project [tên_project]:
- pyproject.toml với dependencies, scripts, metadata.
- src layout: src/[package_name]/ thay vì flat structure.
- Type hints cho tất cả functions.
- Logging configuration (structlog hoặc standard logging).
- CLI entry point với argparse hoặc click/typer.
- Docker setup: multi-stage build, .dockerignore.
- Pre-commit hooks: ruff, mypy, pytest, black.
```

---

## 🔐 6. Authentication & Authorization
Prompt thiết lập auth cho Django/FastAPI:
```text
Hãy thiết lập authentication/authorization cho [Django/FastAPI]:
- JWT token-based authentication (access + refresh tokens).
- OAuth2 integration (Google, GitHub login).
- Role-based access control (RBAC) với permissions.
- Password hashing và validation rules.
- Session management, token blacklist, rate limiting.
- 2FA/MFA support nếu là financial system.
```
