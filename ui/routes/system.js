/**
 * System routes — OS info, environment status, provider connectivity.
 */
const { execFile } = require('child_process');
const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');
const toml = require('@iarna/toml');

function osInfo() {
  const os = require('os');
  const platform = process.platform;
  return {
    platform,
    arch: process.arch,
    node: process.version,
    hostname: os.hostname(),
    username: process.env.USERNAME || process.env.USER || 'unknown',
    shell: platform === 'win32' ? 'powershell' : process.env.SHELL || 'bash',
    release: os.release(),
  };
}

function checkCommand(cmd, args = ['--version']) {
  return new Promise((resolve) => {
    execFile(cmd, args, { timeout: 5000 }, (err, stdout) => {
      if (err) return resolve({ found: false, version: null });
      resolve({ found: true, version: (stdout || '').trim().split('\n')[0] });
    });
  });
}

function checkEnvKey(name) {
  return { name, set: !!process.env[name] };
}

function getActiveConfig(tomlPath) {
  try {
    const raw = fs.readFileSync(tomlPath, 'utf8');
    const data = toml.parse(raw);
    return {
      provider: data.model_provider || 'unknown',
      model: data.model || 'unknown',
      mcpServers: data.mcp_servers ? Object.keys(data.mcp_servers) : [],
      plugins: data.plugins ? Object.keys(data.plugins) : [],
    };
  } catch { return null; }
}

/**
 * Non-blocking HTTP connectivity check using native http/https modules.
 */
function checkEndpoint(url, timeoutMs = 5000) {
  return new Promise((resolve) => {
    const mod = url.startsWith('https') ? https : http;
    const req = mod.get(url, { timeout: timeoutMs }, (res) => {
      res.resume(); // drain response
      resolve({ reachable: true, statusCode: res.statusCode });
    });
    req.on('error', () => resolve({ reachable: false }));
    req.on('timeout', () => { req.destroy(); resolve({ reachable: false }); });
  });
}

function getProviderEndpoints() {
  return {
    openrouter: { url: 'https://openrouter.ai/api/v1/models', label: 'OpenRouter' },
    ollama: { url: 'http://localhost:11434/api/tags', label: 'Ollama (Local)' },
  };
}

module.exports = function (app, ctx) {
  const { WORKSPACE_ROOT, CODEX_HOME } = ctx;
  const ACTIVE_CONFIG = path.join(CODEX_HOME, 'config.toml');

  // GET /api/status — full system status (non-blocking)
  app.get('/api/status', async (req, res) => {
    try {
      const config = getActiveConfig(ACTIVE_CONFIG);
      const provider = config?.provider || 'unknown';
      const endpoints = getProviderEndpoints();

      // Run dependency checks and connectivity in parallel (non-blocking)
      const [node, npm, git, codex, connectivity] = await Promise.all([
        checkCommand('node', ['--version']),
        checkCommand('npm', ['--version']),
        checkCommand('git', ['--version']),
        checkCommand('codex', ['--version']),
        (async () => {
          const result = {};
          if (provider === 'openrouter' || provider === 'ollama') {
            const ep = endpoints[provider];
            const check = await checkEndpoint(ep.url);
            result[provider] = { reachable: check.reachable, label: ep.label };
          }
          return result;
        })(),
      ]);

      res.json({
        os: osInfo(),
        config,
        envKeys: [
          checkEnvKey('OPENROUTER_API_KEY'),
          checkEnvKey('OPENAI_API_KEY'),
          checkEnvKey('ANTHROPIC_API_KEY'),
          checkEnvKey('GITHUB_PERSONAL_ACCESS_TOKEN'),
        ],
        dependencies: { node, npm, git, codex },
        connectivity,
        workspaceRoot: WORKSPACE_ROOT,
        codexHome: CODEX_HOME,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // GET /api/env-keys — check which env keys are set (without exposing values)
  app.get('/api/env-keys', (req, res) => {
    const keys = [
      'OPENROUTER_API_KEY',
      'OPENAI_API_KEY',
      'ANTHROPIC_API_KEY',
      'GITHUB_PERSONAL_ACCESS_TOKEN',
      'CODEX_CLI_PATH',
    ];
    res.json(keys.map(k => ({ name: k, set: !!process.env[k] })));
  });
};
