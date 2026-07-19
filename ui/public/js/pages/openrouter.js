/**
 * OpenRouter Models page — browse free models and copy model IDs.
 */
const PageOpenRouter = (() => {
  async function render(renderFn) {
    const html = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;flex-wrap:wrap;gap:8px">
        <div>
          <p style="color:var(--text-secondary)">
            Browse models available via <strong>OpenRouter</strong>
            <span id="or-api-status"></span>
          </p>
        </div>
        <button class="btn btn-primary" onclick="PageOpenRouter.refresh()">🔄 Refresh</button>
      </div>

      <div class="tabs" id="or-tabs">
        <button class="tab active" data-tab="free" onclick="PageOpenRouter.switchTab('free')">✨ Free Models</button>
        <button class="tab" data-tab="all" onclick="PageOpenRouter.switchTab('all')">📦 All Models</button>
      </div>

      <div id="or-loading" class="loading-spinner">
        <div class="spinner"></div>
        <p>Fetching models from OpenRouter...</p>
      </div>

      <div id="or-content" style="display:none"></div>
    `;

    renderFn(html);
    await loadModels();
  }

  async function loadModels() {
    const loading = document.getElementById('or-loading');
    const content = document.getElementById('or-content');

    try {
      const data = await API.getOpenRouterModels();
      loading.style.display = 'none';
      content.style.display = 'block';

      // API key status
      const statusEl = document.getElementById('or-api-status');
      if (data.apiKeySet) {
        statusEl.innerHTML = ' <span class="badge badge--pass">✓ API Key Set</span>';
      } else {
        statusEl.innerHTML = ' <span class="badge badge--fail">✗ No API Key</span>';
      }

      if (data.cached) {
        content.innerHTML = `<div class="empty-state"><div class="empty-state__sub">${data.stale ? '⚠️ Using stale cache (API unavailable)' : '📦 Using cached data (refreshes every 5 min)'}</div></div>`;
      }

      // Render free models
      renderTabContent('free', data.models.free, data.models.free_count);
    } catch (err) {
      loading.style.display = 'none';
      content.style.display = 'block';
      content.innerHTML = `
        <div class="card" style="border-color:var(--accent-red)">
          <div class="card-header"><h3>❌ Error</h3></div>
          <div class="card-body">${escapeHtml(err.message)}</div>
        </div>
      `;
    }
  }

  function renderTabContent(tab, models, count) {
    const container = document.getElementById('or-content');
    if (!models || models.length === 0) {
      container.innerHTML = `
        <div class="empty-state">
          <div class="empty-state__icon">📭</div>
          <div class="empty-state__text">No models found</div>
        </div>
      `;
      return;
    }

    // Summary stats
    const totalCtx = models.reduce((sum, m) => sum + (m.context_length || 0), 0);
    const avgCtx = Math.round(totalCtx / models.length);

    container.innerHTML = `
      <div style="display:flex;gap:16px;margin-bottom:16px;flex-wrap:wrap">
        <div class="badge badge--info">📋 ${count} models</div>
        <div class="badge badge--info">📏 Avg context: ${formatNumber(avgCtx)}</div>
        <div class="badge badge--info">
          🎯 Max context: ${formatNumber(Math.max(...models.map(m => m.context_length || 0)))}
        </div>
      </div>

      <div class="card">
        <div class="card-body" style="padding:0;overflow-x:auto">
          <table style="width:100%;border-collapse:collapse">
            <thead>
              <tr style="text-align:left;border-bottom:2px solid var(--border-color)">
                <th style="padding:10px 12px">Model ID</th>
                <th style="padding:10px 12px">Name</th>
                <th style="padding:10px 12px;text-align:right">Context</th>
                <th style="padding:10px 12px;text-align:right">Prompt $</th>
                <th style="padding:10px 12px;text-align:right">Completion $</th>
                ${tab === 'all' ? '<th style="padding:10px 12px">Status</th>' : ''}
                <th style="padding:10px 12px"></th>
              </tr>
            </thead>
            <tbody>
              ${models.map(m => {
                const isFree = m.id.endsWith(':free');
                return `
                  <tr style="border-bottom:1px solid var(--border-light)">
                    <td style="padding:10px 12px"><code>${escapeHtml(m.id)}</code></td>
                    <td style="padding:10px 12px;font-size:0.9rem">${escapeHtml(m.name || '')}</td>
                    <td style="padding:10px 12px;text-align:right;font-size:0.9rem">${formatNumber(m.context_length || 0)}</td>
                    <td style="padding:10px 12px;text-align:right;font-size:0.9rem">${m.pricing?.prompt || '0'}</td>
                    <td style="padding:10px 12px;text-align:right;font-size:0.9rem">${m.pricing?.completion || '0'}</td>
                    ${tab === 'all' ? `<td style="padding:10px 12px">${isFree ? '<span class="badge badge--pass">Free</span>' : '<span class="badge badge--inactive">Paid</span>'}</td>` : ''}
                    <td style="padding:10px 12px">
                      <button class="btn btn-sm" onclick="PageOpenRouter.copyModel('${escapeHtml(m.id)}')">📋 Copy ID</button>
                    </td>
                  </tr>
                `;
              }).join('')}
            </tbody>
          </table>
        </div>
      </div>

      <div style="margin-top:16px;display:flex;gap:8px;flex-wrap:wrap">
        <span style="color:var(--text-secondary);font-size:0.85rem;padding:4px 0">💡 Click "Copy ID" to copy a model ID, then use it in your profile config:</span>
        <pre class="code-block" style="font-size:0.8rem;padding:6px 12px">model = "model-id-here:free"</pre>
      </div>
    `;
  }

  function switchTab(tab) {
    document.querySelectorAll('#or-tabs .tab').forEach(t => {
      t.classList.toggle('active', t.dataset.tab === tab);
    });
    // Re-render with the right data
    API.getOpenRouterModels().then(data => {
      const models = tab === 'free' ? data.models.free : data.models.all;
      const count = tab === 'free' ? data.models.free_count : data.models.total;
      renderTabContent(tab, models, count);
    }).catch(err => {
      API.showToast(err.message, 'error');
    });
  }

  async function refresh() {
    const loading = document.getElementById('or-loading');
    const content = document.getElementById('or-content');
    loading.style.display = 'flex';
    content.style.display = 'none';

    try {
      const data = await API.refreshOpenRouterModels();
      loading.style.display = 'none';
      content.style.display = 'block';
      renderTabContent('free', data.free, data.free_count);
      API.showToast(`Found ${data.free_count} free models`, 'success');
    } catch (err) {
      loading.style.display = 'none';
      content.style.display = 'block';
      API.showToast(err.message, 'error');
    }
  }

  function copyModel(id) {
    navigator.clipboard.writeText(id).then(() => {
      API.showToast(`Copied: ${id}`, 'success');
    }).catch(() => {
      const ta = document.createElement('textarea');
      ta.value = id;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      ta.remove();
      API.showToast(`Copied: ${id}`, 'success');
    });
  }

  function formatNumber(n) {
    if (!n) return '0';
    if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
    if (n >= 1000) return (n / 1000).toFixed(1) + 'K';
    return n.toString();
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  return { render, switchTab, refresh, copyModel };
})();
