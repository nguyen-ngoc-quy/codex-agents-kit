#!/usr/bin/env node
/**
 * Codex CLI Ultimate — Web Admin UI Server
 *
 * A local Express server that provides a web dashboard for managing
 * profiles, MCP servers, diagnostics, benchmarks, and agents.
 *
 * Usage:  node server.js [--port <num>]
 *         npm start
 */

const express = require('express');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const PORT = parseInt(process.argv.find(a => a.startsWith('--port='))?.split('=')[1] || process.env.CODEX_UI_PORT || 3456, 10);

// ── Resolve workspace root ─────────────────────────────────────
// Look for bin/codex.ps1 marker walking up from ui/
function findWorkspaceRoot() {
  let dir = __dirname;
  const root = path.parse(dir).root;
  while (dir !== root) {
    if (fs.existsSync(path.join(dir, 'bin', 'codex.ps1'))) return dir;
    dir = path.dirname(dir);
  }
  return null;
}
const WORKSPACE_ROOT = findWorkspaceRoot();
const CODEX_HOME = path.join(process.env.USERPROFILE || process.env.HOME || process.cwd(), '.codex');

// ── Middleware ──────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ── Load routes ────────────────────────────────────────────────
const routes = {
  system:      require('./routes/system'),
  config:      require('./routes/config'),
  diagnostics: require('./routes/diagnostics'),
  benchmark:   require('./routes/benchmark'),
  mcp:         require('./routes/mcp'),
  agents:      require('./routes/agents'),
  settings:    require('./routes/settings'),
  openrouter:  require('./routes/openrouter'),
};

// Inject shared context into each route
const ctx = { WORKSPACE_ROOT, CODEX_HOME, __dirname };
Object.values(routes).forEach(r => r(app, ctx));

// ── Serve index.html for all unmatched routes (SPA fallback) ──
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ── Start server ───────────────────────────────────────────────
app.listen(PORT, () => {
  const url = `http://localhost:${PORT}`;
  console.log(`\n  🚀 Codex CLI Ultimate — Admin UI`);
  console.log(`  ─────────────────────────────────`);
  console.log(`  📡 Server: ${url}`);
  console.log(`  📁 Root:   ${WORKSPACE_ROOT || 'not found'}`);
  console.log(`  ⚙  Config: ${CODEX_HOME}`);
  console.log();

  // Try to open browser
  const platform = process.platform;
  const cmd = platform === 'win32' ? 'start' : platform === 'darwin' ? 'open' : 'xdg-open';
  try { require('child_process').execSync(`${cmd} "${url}"`, { stdio: 'ignore' }); }
  catch (_) { /* browser open failed — non-critical */ }
});
