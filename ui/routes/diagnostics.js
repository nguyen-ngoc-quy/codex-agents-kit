/**
 * Diagnostics routes — run doctor script and return structured results.
 */
const { execFile } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * Run doctor script and collect output.
 */
function runDoctor(root, codexHome) {
  return new Promise((resolve) => {
    const isWin = process.platform === 'win32';
    const script = path.join(root, 'scripts', isWin ? 'doctor.ps1' : 'doctor.sh');

    if (!fs.existsSync(script)) {
      return resolve({ error: `Doctor script not found at ${script}`, checks: [] });
    }

    const cmd = isWin ? 'powershell' : 'bash';
    const args = isWin
      ? ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script]
      : [script];

    execFile(cmd, args, { timeout: 30000, encoding: 'utf8', cwd: root }, (err, stdout, stderr) => {
      const output = stdout || (err && err.stdout) || '';

      // Parse structured info from the output
      const info = {};
      const osMatch = output.match(/OS\s*:\s*(.+)/);
      if (osMatch) info.os = osMatch[1].trim();
      const pwshMatch = output.match(/PowerShell\s*:\s*(.+)/);
      if (pwshMatch) info.powershell = pwshMatch[1].trim();
      const configMatch = output.match(/Config file.*?\n.*?Path:\s*(.+)/);
      if (configMatch) info.configPath = configMatch[1].trim();
      const providerMatch = output.match(/Provider:\s*(.+)/);
      if (providerMatch) info.provider = providerMatch[1].trim();
      const modelMatch = output.match(/Model\s*:\s*(.+)/);
      if (modelMatch) info.model = modelMatch[1].trim();

      if (err) {
        resolve({
          raw: output,
          info,
          checks: parseChecks(output),
          exitCode: err.code,
          error: stderr?.trim() || null,
        });
      } else {
        resolve({
          raw: output,
          info,
          checks: parseChecks(output),
        });
      }
    });
  });
}

function parseChecks(output) {
  const checks = [];
  const lines = output.split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('✅')) checks.push({ status: 'pass', message: trimmed.replace('✅', '').trim() });
    else if (trimmed.startsWith('❌')) checks.push({ status: 'fail', message: trimmed.replace('❌', '').trim() });
    else if (trimmed.startsWith('⚠')) checks.push({ status: 'warn', message: trimmed.replace(/⚠\s*/, '').trim() });
  }
  return checks;
}

module.exports = function (app, ctx) {
  const { WORKSPACE_ROOT, CODEX_HOME } = ctx;

  // GET /api/diagnostics — run doctor
  app.get('/api/diagnostics', async (req, res) => {
    try {
      const results = await runDoctor(WORKSPACE_ROOT, CODEX_HOME);
      res.json(results);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
};
