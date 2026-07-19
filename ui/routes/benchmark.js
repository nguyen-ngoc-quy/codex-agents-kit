/**
 * Benchmark routes — run benchmark script and return results.
 */
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const HISTORY_FILE = path.join(
  process.env.USERPROFILE || process.env.HOME || process.cwd(),
  '.codex',
  'benchmark-history.json'
);

/**
 * Run the benchmark script and parse its output.
 */
function runBenchmark(root) {
  const isWin = process.platform === 'win32';
  const script = path.join(root, 'scripts', isWin ? 'benchmark.ps1' : 'benchmark.sh');

  if (!fs.existsSync(script)) {
    return { error: `Benchmark script not found at ${script}` };
  }

  try {
    const cmd = isWin
      ? `powershell -NoProfile -ExecutionPolicy Bypass -File "${script}"`
      : `bash "${script}"`;
    const stdout = execSync(cmd, { timeout: 60000, encoding: 'utf8', cwd: root });

    const latencyMatch = stdout.match(/Latency\s*:?\s*([\d.]+)\s*ms/);
    const speedMatch = stdout.match(/Speed.*?([\d.]+)\s*tokens/);
    const responseMatch = stdout.match(/Response text.*?"(.*)"/s);
    const providerMatch = stdout.match(/Provider:\s*(.+)/);
    const modelMatch = stdout.match(/Model\s*:\s*(.+)/);

    const result = {
      timestamp: new Date().toISOString(),
      latencyMs: latencyMatch ? parseFloat(latencyMatch[1]) : null,
      tokensPerSec: speedMatch ? parseFloat(speedMatch[1]) : null,
      responseText: responseMatch ? responseMatch[1].trim() : null,
      provider: providerMatch ? providerMatch[1].trim() : null,
      model: modelMatch ? modelMatch[1].trim() : null,
      raw: stdout,
    };

    // Save to history
    saveHistory(result);

    return result;
  } catch (e) {
    return { error: `Benchmark failed: ${e.stderr || e.message}`, raw: e.stdout || '' };
  }
}

function loadHistory() {
  try {
    if (fs.existsSync(HISTORY_FILE)) {
      const data = fs.readFileSync(HISTORY_FILE, 'utf8');
      return JSON.parse(data);
    }
  } catch { /* ignore */ }
  return [];
}

function saveHistory(entry) {
  try {
    const history = loadHistory();
    history.push({ ...entry, raw: undefined });
    // Keep last 20 entries
    const trimmed = history.slice(-20);
    const dir = path.dirname(HISTORY_FILE);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(HISTORY_FILE, JSON.stringify(trimmed, null, 2), 'utf8');
  } catch { /* save best-effort */ }
}

module.exports = function (app, ctx) {
  const { WORKSPACE_ROOT } = ctx;

  // POST /api/benchmark — run benchmark now
  app.post('/api/benchmark', (req, res) => {
    const result = runBenchmark(WORKSPACE_ROOT);
    if (result.error) return res.status(500).json(result);
    res.json(result);
  });

  // GET /api/benchmark/history — get past benchmark results
  app.get('/api/benchmark/history', (req, res) => {
    res.json(loadHistory());
  });
};
