/**
 * Settings routes — persistent UI settings stored in a JSON file.
 */
const fs = require('fs');
const path = require('path');

function getSettingsPath(codexHome) {
  return path.join(codexHome, 'ui-settings.json');
}

function loadSettings(codexHome) {
  const file = getSettingsPath(codexHome);
  try {
    if (fs.existsSync(file)) {
      return JSON.parse(fs.readFileSync(file, 'utf8'));
    }
  } catch { /* ignore */ }
  return { theme: 'dark', port: 3456 };
}

function saveSettings(codexHome, data) {
  const file = getSettingsPath(codexHome);
  const dir = path.dirname(file);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(file, JSON.stringify(data, null, 2), 'utf8');
}

module.exports = function (app, ctx) {
  const { CODEX_HOME } = ctx;

  // GET /api/settings — load UI settings
  app.get('/api/settings', (req, res) => {
    const settings = loadSettings(CODEX_HOME);
    res.json(settings);
  });

  // PUT /api/settings — update UI settings
  app.put('/api/settings', (req, res) => {
    const current = loadSettings(CODEX_HOME);
    const updated = { ...current, ...req.body };
    saveSettings(CODEX_HOME, updated);
    res.json({ success: true, settings: updated });
  });
};
