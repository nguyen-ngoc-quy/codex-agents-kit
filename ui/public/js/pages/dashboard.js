/**
 * Dashboard page — system overview, active profile, quick actions.
 */
const PageDashboard = (() => {
  async function render(renderFn) {
    const [status, mcpStatus] = await Promise.all([
      API.getStatus(),
      API.getMcpStatus(),
    ]);

    const html = `
      <div class="grid grid-2" style="margin-bottom:24px">
        <div class="card">
          <div class="card-header"><h3>🖥️ System</h3></div>
          <div class="card-body">
            <div class="info-row"><span class="info-label">OS</span><span class="info-value">${status.os.platform} ${status.os.release}</span></div>
            <div class="info-row"><span class="info-label">Node.js</span><span class="info-value">${status.os.node}</span></div>
            <div class="info-row"><span class="info-label">Arch</span><span class="info-value">${status.os.arch}</span></div>
            <div class="info-row"><span class="info-label">Hostname</span><span class="info-value">${status.os.hostname}</span></div>
            <div class="info-row"><span class="info-label">Workspace</span><span class="info-value" style="font-size:0.85rem">${status.workspaceRoot}</span></div>
          </div>
        </div>

        <div class="card">
          <div class="card-header"><h3>⚙️ Active Profile</h3></div>
          <div class="card-body">
            ${status.config ? `
              <div class="info-row"><span class="info-label">Provider</span><span class="info-value">${status.config.provider}</span></div>
              <div class="info-row"><span class="info-label">Model</span><span class="info-value"><code>${status.config.model}</code></span></div>
              <div class="info-row">
                <span class="info-label">MCP Servers</span>
                <span class="info-value">${status.config.mcpServers.length > 0 ? status.config.mcpServers.map(s => `<span class="badge badge--info">${s}</span>`).join(' ') : '<span class="badge badge--inactive">None</span>'}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Plugins</span>
                <span class="info-value">${status.config.plugins.length > 0 ? status.config.plugins.map(s => `<span class="badge badge--info">${s}</span>`).join(' ') : '<span class="badge badge--inactive">None</span>'}</span>
              </div>
            ` : `<div class="empty-state__text">No active config found</div>`}
          </div>
        </div>
      </div>

      <div class="card" style="margin-bottom:24px">
        <div class="card-header">
          <h3>🔌 MCP Servers</h3>
          <a href="#/mcp" class="btn btn-sm">Manage</a>
        </div>
        <div class="card-body">
          <div class="grid grid-3">
            ${mcpStatus.servers.map(s => `
              <div class="agent-card" style="cursor:default">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                  <strong>${s.name}</strong>
                  ${s.configured && s.cached
                    ? '<span class="badge badge--pass">✓ Ready</span>'
                    : s.configured
                      ? '<span class="badge badge--warn">Not Cached</span>'
                      : '<span class="badge badge--inactive">Not Configured</span>'}
                </div>
                <div style="font-size:0.85rem;color:var(--text-secondary)">${s.description}</div>
              </div>
            `).join('')}
          </div>
        </div>
      </div>

      <div class="card" style="margin-bottom:24px">
        <div class="card-header">
          <h3>🔑 API Keys</h3>
        </div>
        <div class="card-body">
          <div class="grid grid-3">
            ${status.envKeys.map(k => `
              <div style="display:flex;align-items:center;gap:8px;padding:8px 0">
                ${k.set ? '<span class="badge badge--pass">✓ Set</span>' : '<span class="badge badge--inactive">✗ Not Set</span>'}
                <code style="font-size:0.85rem">${k.name}</code>
              </div>
            `).join('')}
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <h3>⚡ Quick Actions</h3>
        </div>
        <div class="card-body" style="display:flex;gap:12px;flex-wrap:wrap">
          <button class="btn btn-primary" onclick="window.location.hash='#/diagnostics'">🔍 Run Diagnostics</button>
          <button class="btn" onclick="window.location.hash='#/benchmark'">⚡ Run Benchmark</button>
          <button class="btn" onclick="window.location.hash='#/profiles'">⚙️ Switch Profile</button>
        </div>
      </div>
    `;

    renderFn(html);
  }

  return { render };
})();
