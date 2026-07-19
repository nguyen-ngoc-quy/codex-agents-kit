/**
 * MCP Servers page — status, configuration, and retry.
 */
const PageMcp = (() => {
  async function render(renderFn) {
    const data = await API.getMcpStatus();

    const html = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <p style="color:var(--text-secondary)">${data.servers.length} MCP servers defined</p>
        <button class="btn btn-primary" onclick="PageMcp.checkAll()">🔄 Check All</button>
      </div>
      <div class="grid grid-2">
        ${data.servers.map(s => {
          let status;
          if (s.configured && s.cached) status = { badge: 'badge--pass', label: 'Ready', icon: '✅' };
          else if (s.configured) status = { badge: 'badge--warn', label: 'Not Cached (will auto-install)', icon: '⚠️' };
          else status = { badge: 'badge--inactive', label: 'Not Configured', icon: '⏹' };

          return `
            <div class="mcp-card">
              <div class="mcp-card__header">
                <span class="mcp-card__name">${s.name}</span>
                <span class="badge ${status.badge}">${status.icon} ${status.label}</span>
              </div>
              <div class="mcp-card__desc">${s.description}</div>
              <div class="mcp-card__package">${s.package}</div>
              <div style="display:flex;gap:8px;margin-top:4px">
                ${s.configured ? `<button class="btn btn-sm" onclick="PageMcp.retry('${s.key}')">📦 Cache Package</button>` : ''}
              </div>
            </div>
          `;
        }).join('')}
      </div>
    `;

    renderFn(html);
  }

  async function retry(key) {
    try {
      const result = await API.retryMcp(key);
      API.showToast(`${result.message}: ${key}`, 'success');
      render(render);
    } catch (err) {
      API.showToast(`Failed: ${err.message}`, 'error');
    }
  }

  async function checkAll() {
    API.showToast('Checking all MCP servers...', 'info');
    render(render);
  }

  return { render, retry, checkAll };
})();
