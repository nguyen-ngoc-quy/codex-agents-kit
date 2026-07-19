/**
 * Config routes — profile management (list, switch, view, create, edit).
 */
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const toml = require('@iarna/toml');

/**
 * List .toml files in config/ directory (exclude profiles/ subfolder).
 */
function listProfiles(root) {
  const configDir = path.join(root, 'config');
  if (!fs.existsSync(configDir)) return [];
  return fs.readdirSync(configDir)
    .filter(f => f.endsWith('.toml') && fs.statSync(path.join(configDir, f)).isFile())
    .map(f => ({
      name: f.replace(/\.toml$/, ''),
      path: path.join(configDir, f),
    }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

/**
 * Parse TOML, tolerating CRLF line endings.
 * @iarna/toml rejects lone \r as a control character inside comments,
 * so normalize CRLF → LF before parsing. This does not touch the file
 * on disk — only the in-memory string handed to the parser.
 */
function parseToml(raw) {
  return toml.parse(raw.replace(/\r\n/g, '\n'));
}

function getActiveProfile(codexHome) {
  const configFile = path.join(codexHome, 'config.toml');
  if (!fs.existsSync(configFile)) return null;
  const raw = fs.readFileSync(configFile, 'utf8');
  try {
    const data = parseToml(raw);
    return {
      provider: data.model_provider || 'unknown',
      model: data.model || 'unknown',
    };
  } catch { return null; }
}

module.exports = function (app, ctx) {
  const { WORKSPACE_ROOT, CODEX_HOME } = ctx;
  const profiles = () => listProfiles(WORKSPACE_ROOT);
  const activeProfile = () => getActiveProfile(CODEX_HOME);

  // GET /api/profiles — list all profiles
  app.get('/api/profiles', (req, res) => {
    const active = activeProfile();
    res.json({
      profiles: profiles().map(p => {
        const raw = fs.readFileSync(p.path, 'utf8');
        const provider = raw.match(/model_provider\s*=\s*"([^"]+)"/)?.[1] || 'unknown';
        const model = raw.match(/^model\s*=\s*"([^"]+)"/m)?.[1] || 'unknown';
        const agent = raw.match(/#\s*recommended_agent:\s*(\S+)/)?.[1] || null;
        const isActive = active &&
          active.provider === provider &&
          active.model === model;
        return { name: p.name, provider, model, recommendedAgent: agent, isActive };
      }),
    });
  });

  // GET /api/profiles/:name — get profile TOML content
  app.get('/api/profiles/:name', (req, res) => {
    const profile = profiles().find(p => p.name === req.params.name);
    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    const raw = fs.readFileSync(profile.path, 'utf8');
    res.json({ name: profile.name, content: raw });
  });

  // GET /api/profiles/:name/fields — get profile as structured field groups
  app.get('/api/profiles/:name/fields', (req, res) => {
    const profile = profiles().find(p => p.name === req.params.name);
    if (!profile) return res.status(404).json({ error: 'Profile not found' });

    try {
      const raw = fs.readFileSync(profile.path, 'utf8');
      const data = parseToml(raw);

      const providerName = data.model_provider || 'openai';
      const providerConfig = data.model_providers ? data.model_providers[providerName] : {};

      const fields = {
        basicSettings: {
          provider: data.model_provider || 'openai',
          model: data.model || '',
          displayName: providerConfig?.name || '',
          baseUrl: providerConfig?.base_url || '',
          envKey: providerConfig?.env_key || '',
        },
        tools: {
          webSearch: data.tools?.web_search !== false,
          fileBrowser: data.tools?.file_browser !== false,
        },
        plugins: [],
        mcpServers: [],
      };

      if (data.plugins) {
        for (const [key, val] of Object.entries(data.plugins)) {
          fields.plugins.push({ name: key, enabled: val.enabled !== false });
        }
      }

      if (data.mcp_servers) {
        for (const [key, val] of Object.entries(data.mcp_servers)) {
          fields.mcpServers.push({
            name: key,
            command: val.command || '',
            args: Array.isArray(val.args) ? val.args : [],
            env: val.env || {},
          });
        }
      }

      res.json({ name: profile.name, fields, raw });
    } catch (err) {
      res.status(500).json({ error: `Failed to parse profile: ${err.message}` });
    }
  });

  // PUT /api/profiles/:name — save edited profile
  app.put('/api/profiles/:name', (req, res) => {
    const profile = profiles().find(p => p.name === req.params.name);
    if (!profile) return res.status(404).json({ error: 'Profile not found' });

    const { content } = req.body;
    if (!content || typeof content !== 'string') {
      return res.status(400).json({ error: 'Missing "content" field (TOML string)' });
    }

    // 1. Validate TOML syntax before writing
    try {
      parseToml(content);
    } catch (err) {
      return res.status(400).json({
        error: `Invalid TOML syntax: ${err.message}`,
        line: err.line || null,
        col: err.col || null,
      });
    }

    // 2. Backup existing file
    const backupPath = profile.path + '.bak';
    try {
      fs.copyFileSync(profile.path, backupPath);
    } catch (err) {
      return res.status(500).json({ error: `Failed to backup profile: ${err.message}` });
    }

    // 3. Write new content
    try {
      fs.writeFileSync(profile.path, content, 'utf8');
    } catch (err) {
      try { fs.copyFileSync(backupPath, profile.path); } catch (_) {}
      return res.status(500).json({ error: `Failed to write profile: ${err.message}` });
    }

    // 4. Re-read and verify
    try {
      const written = fs.readFileSync(profile.path, 'utf8');
      parseToml(written);
    } catch (err) {
      try {
        fs.copyFileSync(backupPath, profile.path);
        fs.unlinkSync(backupPath);
      } catch (_) {}
      return res.status(500).json({
        error: `Saved profile has invalid TOML. Changes reverted: ${err.message}`,
      });
    }

    try { fs.unlinkSync(backupPath); } catch (_) {}

    res.json({ success: true, name: profile.name });
  });

  // POST /api/profiles/:name/switch — switch to a profile
  app.post('/api/profiles/:name/switch', (req, res) => {
    const profile = profiles().find(p => p.name === req.params.name);
    if (!profile) return res.status(404).json({ error: 'Profile not found' });

    const isWin = process.platform === 'win32';
    const script = path.join(WORKSPACE_ROOT, 'scripts', isWin ? 'switch-profile.ps1' : 'switch-profile.sh');
    if (!fs.existsSync(script)) return res.status(500).json({ error: 'switch-profile script not found' });

    try {
      const cmd = isWin
        ? `powershell -NoProfile -File "${script}" "${profile.name}"`
        : `bash "${script}" "${profile.name}"`;
      const output = execSync(cmd, { timeout: 15000, encoding: 'utf8', cwd: WORKSPACE_ROOT });
      const active = activeProfile();
      res.json({ success: true, output: output.trim(), active: active || null });
    } catch (e) {
      res.status(500).json({ error: `Switch failed: ${e.stderr || e.message}` });
    }
  });

  // POST /api/profiles — create new profile
  app.post('/api/profiles', (req, res) => {
    const { name, baseProfile } = req.body;
    if (!name || !/^[a-zA-Z0-9._-]+$/.test(name)) {
      return res.status(400).json({ error: 'Invalid profile name (alphanumeric, dots, hyphens, underscores only)' });
    }
    const configDir = path.join(WORKSPACE_ROOT, 'config');
    const targetPath = path.join(configDir, `${name}.toml`);
    if (fs.existsSync(targetPath)) {
      return res.status(409).json({ error: 'Profile already exists' });
    }

    // Copy from custom template or a base profile
    const source = baseProfile
      ? profiles().find(p => p.name === baseProfile)?.path
      : path.join(configDir, 'profiles', 'custom.toml.example');
    if (!source || !fs.existsSync(source)) {
      return res.status(400).json({ error: 'Source profile not found' });
    }

    const content = fs.readFileSync(source, 'utf8');
    fs.writeFileSync(targetPath, content, 'utf8');
    res.json({ success: true, name, path: targetPath });
  });
};
