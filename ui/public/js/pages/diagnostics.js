/**
 * Diagnostics page — run doctor and display structured results.
 */
const PageDiagnostics = (() => {
  async function render(renderFn) {
    const html = `
      <div style="margin-bottom:16px">
        <button class="btn btn-primary" onclick="PageDiagnostics.run()">🔍 Run Diagnostics</button>
        <span style="color:var(--text-muted);margin-left:12px;font-size:0.9rem">
          Runs <code>codex doctor</code> and parses the output
        </span>
      </div>
      <div class="card">
        <div class="card-header"><h3>Diagnostic Results</h3></div>
        <div class="card-body">
          <p style="color:var(--text-secondary)">Click "Run Diagnostics" to start.</p>
        </div>
      </div>
    `;
    renderFn(html);
  }

  async function run() {
    const area = document.getElementById('content-area');
    area.innerHTML = `
      <div style="margin-bottom:16px">
        <button class="btn btn-primary" onclick="PageDiagnostics.run()" disabled>🔍 Running...</button>
      </div>
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Running diagnostics...</p>
      </div>
    `;

    try {
      const data = await API.getDiagnostics();

      let checksHtml = '';
      if (data.checks && data.checks.length > 0) {
        checksHtml = data.checks.map(c => {
          const icon = c.status === 'pass' ? '✅' : c.status === 'fail' ? '❌' : '⚠️';
          const cls = c.status === 'pass' ? 'badge--pass' : c.status === 'fail' ? 'badge--fail' : 'badge--warn';
          return `<div style="padding:8px 0;border-bottom:1px solid var(--border-light);display:flex;align-items:center;gap:8px">
            <span class="badge ${cls}">${icon}</span>
            <span>${escapeHtml(c.message)}</span>
          </div>`;
        }).join('');
      }

      let infoHtml = '';
      if (data.info && Object.keys(data.info).length > 0) {
        infoHtml = Object.entries(data.info).map(([k, v]) => `
          <div class="info-row"><span class="info-label">${k}</span><span class="info-value">${escapeHtml(String(v))}</span></div>
        `).join('');
      }

      const html = `
        <div style="margin-bottom:16px">
          <button class="btn btn-primary" onclick="PageDiagnostics.run()">🔍 Run Again</button>
        </div>

        ${data.error ? `<div class="card" style="margin-bottom:16px;border-color:var(--accent-red)">
          <div class="card-header"><h3>⚠️ Non-Zero Exit</h3></div>
          <div class="card-body">${escapeHtml(data.error)}</div>
        </div>` : ''}

        ${infoHtml ? `
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>📋 System Info</h3></div>
          <div class="card-body">${infoHtml}</div>
        </div>` : ''}

        ${checksHtml ? `
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>✅ Checks (${data.checks.length})</h3></div>
          <div class="card-body">${checksHtml}</div>
        </div>` : ''}

        <div class="card">
          <div class="card-header"><h3>📄 Raw Output</h3></div>
          <div class="card-body">
            <pre class="code-block">${escapeHtml(data.raw || '(no output)')}</pre>
          </div>
        </div>
      `;

      area.innerHTML = html;
    } catch (err) {
      area.innerHTML = `
        <div style="margin-bottom:16px">
          <button class="btn btn-primary" onclick="PageDiagnostics.run()">🔍 Retry</button>
        </div>
        <div class="card" style="border-color:var(--accent-red)">
          <div class="card-header"><h3>❌ Error</h3></div>
          <div class="card-body">
            <p>${escapeHtml(err.message)}</p>
          </div>
        </div>
      `;
    }
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  return { render, run };
})();
