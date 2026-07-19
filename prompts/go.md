> Version: 0.1.6 | Last updated: 2026-07-17
# Go (Golang) Prompts

Thư viện prompt tối ưu cho phát triển ứng dụng với **Go**, tuân thủ Go idioms và best practices.

---

## 🏗️ 1. REST API Server
Prompt tạo REST API server với Go:
```text
Hãy tạo REST API server cho [tính_năng] bằng Go:
- Sử dụng chi + middleware (logging, recovery, CORS, rate limiting).
- Project layout theo chuẩn: cmd/, internal/, pkg/, api/.
- Handler -> Service -> Repository pattern.
- Request validation với go-playground/validator.
- JSON response chuẩn (error envelope, pagination meta).
- Graceful shutdown (signal.NotifyContext, http.Server.Shutdown).
- Config management (env vars, viper, struct mapping).
- Unit test với httptest, testify/suite.
```

---

## 🗄️ 2. Database Operations
Prompt thao tác database với Go:
```text
Hãy viết database layer cho [tính_năng] bằng Go:
- sqlx hoặc pgx cho PostgreSQL driver (ưu tiên pgx).
- Migration tools: golang-migrate hoặc goose.
- Repository pattern: interface-based cho testability.
- Transaction support: context-based transaction propagation.
- Query optimization: prepared statements, connection pooling.
- Error handling: sql.ErrNoRows, unique violation, foreign key.
- Batch operations: COPY protocol cho large inserts.
- Pagination: cursor-based hoặc offset-based.
```

---

## 🔄 3. Concurrency & Goroutines
Prompt xử lý concurrent tasks:
```text
Hãy thiết kế concurrent workflow cho [tác_vụ] bằng Go:
- Worker pool pattern với bounded goroutines.
- Context propagation (timeout, cancellation, deadlines).
- Error handling: errgroup hoặc channel-based error collection.
- Fan-out / Fan-in pattern cho parallel processing.
- Rate limiting với golang.org/x/time/rate.
- Graceful shutdown: drain channels, wait for workers.
- Race condition prevention: mutex, atomic, channels.
- Benchmark với sync.Pool cho object reuse.
```

---

## ✅ 4. Testing & Mocking
Prompt viết test cho Go code:
```text
Hãy viết test cho package [tên_package]:
- Unit test: table-driven tests (t *testing.T).
- Mocking: testify/mock hoặc mockgen cho interfaces.
- Integration test: testcontainers-go cho database/Redis.
- HTTP test: httptest.NewServer, httptest.NewRequest.
- Fuzz testing: Go 1.18+ fuzzing.
- Benchmark: testing.B, benchmem, profiling.
- Race detection: go test -race.
- Coverage: go test -coverprofile và hướng dẫn tăng coverage.
```

---

## 📦 5. CLI Application (cobra)
Prompt tạo CLI app với Go:
```text
Hãy tạo CLI application bằng Go sử dụng cobra + viper:
- Root command với global flags (--verbose, --config, --output).
- Subcommands: create, list, delete, update với cobra.Command.
- Config: viper đọc từ file YAML/JSON + env vars.
- Color output: fatih/color hoặc mộtterm cho styled output.
- Progress bar: cheggaaa/pb cho long-running tasks.
- Error handling: cobra.Command.RunE, SilenceErrors.
- Completion script: cobra.Command.GenBashCompletion.
```

---

## 🔧 6. Go Module & Package Structure
Prompt setup project structure:
```text
Hãy tạo Go project structure cho [tên_project]:
- go.mod với module path và Go version (1.22+).
- cmd/[name]/main.go: entry point, dependency wiring.
- internal/: private packages (not importable outside).
- pkg/: public packages (reusable libraries).
- Makefile: build, test, lint, migration commands.
- Docker: multi-stage build (builder pattern, distroless).
- CI: golangci-lint, govulncheck, go test ./....
- Air (github.com/air-verse/air) cho hot reload development.
```
