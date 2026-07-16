# ⏱️ Model Performance Benchmarking

Guide to measuring connection performance and processing speed of AI models.

---

## 🚀 Introduction
Response latency and stability are critical when working with Coding Agents. This project includes built-in benchmarking tools to measure these metrics easily.

---

## 📊 Running Benchmark

### Windows (PowerShell)
```powershell
# Run benchmark on the active profile
.\scripts\benchmark.ps1
```

### Linux / macOS (Bash)
```bash
./scripts/benchmark.sh
```

---

## 📈 Metrics Explained
- **Total Latency**: Total time from request submission to complete response receipt (in milliseconds).
- **Speed (Est. tokens/sec)**: Estimated tokens generated per second. Higher means smoother model responses.
- **Connection Success**: Confirms whether the API Key and Network Route to the Provider (OpenRouter or Ollama) are working.
