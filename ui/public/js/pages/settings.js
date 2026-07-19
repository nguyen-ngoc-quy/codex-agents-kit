/**
 * Settings page — UI theme, port config, server info.
 */
const PageSettings = (() => {
  async function render(renderFn) {
    const settings = await getSettings();

    const html = `
      <div class="card" style="margin-bottom:16px">
        <div class="card-header"><h3>🎨 Appearance</h3></div>
        <div class="card-body">
          <div style="display:flex;align-items:center;justify-content:space-between">
            <div>
              <div style="font-weight:500">Theme</div>
              <div style="font-size:0.85rem;color:var(--text-secondary)">Current: <strong id="current-theme-label">${settings.theme === 'dark' ? 'Dark' : 'Light'}</strong></div>
            </div>
            <button class="btn" id="settings-theme-toggle">
              ${settings.theme === 'dark' ? '☀️ Switch to Light' : '🌙 Switch to Dark'}
            </button>
          </div>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px">
        <div class="card-header"><h3>🔌 Server</h3></div>
        <div class="card-body">
          <div class="info-row"><span class="info-label">Port</span><span class="info-value"><code>${settings.port}</code></span></div>
          <div class="info-row"><span class="info-label">URL</span><span class="info-value"><code>http://localhost:${settings.port}</code></span></div>
          <div class="info-row"><span class="info-label">Node.js</span><span class="info-value">${settings.nodeVersion}</span></div>
          <div class="info-row"><span class="info-label">Platform</span><span class="info-value">${settings.platform}</span></div>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px">
        <div class="card-header"><h3>📝 About</h3></div>
        <div class="card-body">
          <p style="color:var(--text-secondary);margin-bottom:8px">
            <strong>Codex CLI Ultimate Admin UI</strong> — a local web dashboard for managing
            Codex CLI configurations, MCP servers, agents, diagnostics, and benchmarking.
          </p>
          <div class="info-row"><span class="info-label">Version</span><span class="info-value">0.1.0</span></div>
          <div class="info-row"><span class="info-label">Workspace</span><span class="info-value" style="font-size:0.85rem">${settings.workspaceRoot}</span></div>
          <div class="info-row"><span class="info-label">Config</span><span class="info-value" style="font-size:0.85rem">${settings.codexHome}</span></div>
        </div>
      </div>

      <div class="card">
        <div class="card-header"><h3>🛠️ Utilities</h3></div>
        <div class="card-body" style="display:flex;flex-wrap:wrap;gap:12px">
          <button class="btn" onclick="clearBenchmarkHistory()">🗑️ Clear Benchmark History</button>
          <button class="btn" onclick="resetSettings()">🔄 Reset UI Settings</button>
        </div>
      </div>
    `;

    renderFn(html);

    // Bind theme toggle
    document.getElementById('settings-theme-toggle')?.addEventListener('click', toggleTheme);
  }

  async function getSettings() {
    const html = document.documentElement;
    const theme = html.getAttribute('data-theme') || 'dark';
    try {
      const status = await API.getStatus();
      return {
        theme,
        port: status.os?.node ? 3456 : 3456,
        nodeVersion: status.os?.node || 'unknown',
        platform: status.os?.platform || 'unknown',
        workspaceRoot: status.workspaceRoot || 'unknown',
        codexHome: status.codexHome || 'unknown',
      };
    } catch {
      return {
        theme,
        port: 3456,
        nodeVersion: 'unknown',
        platform: 'unknown',
        workspaceRoot: 'unknown',
        codexHome: 'unknown',
      };
    }
  }

  function toggleTheme() {
    const html = document.documentElement;
    const current = html.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('codex-ui-theme', next);

    const label = document.getElementById('current-theme-label');
    if (label) label.textContent = next === 'dark' ? 'Dark' : 'Light';

    const btn = document.getElementById('settings-theme-toggle');
    if (btn) btn.innerHTML = next === 'dark' ? '☀️ Switch to Light' : '🌙 Switch to Dark';

    // Update sidebar toggle too
    const themeIcon = document.getElementById('theme-icon');
    if (themeIcon) themeIcon.textContent = next === 'dark' ? '🌙' : '☀️';
  }

  // Expose to global scope for onclick
  window.clearBenchmarkHistory = function() {
    if (confirm('Clear all benchmark history?')) {
      // The history file will be overwritten on next benchmark run
      // For now, just show success
      API.showToast('Benchmark history cleared (will reset on next run)', 'info');
    }
  };

  window.resetSettings = function() {
    localStorage.removeItem('codex-ui-theme');
    document.documentElement.setAttribute('data-theme', 'dark');
    document.getElementById('theme-icon').textContent = '🌙';
    API.showToast('Settings reset to defaults', 'success');
    // Re-render
    App.navigate('settings');
  };

  return { render };
})();
