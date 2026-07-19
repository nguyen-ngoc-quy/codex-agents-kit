/**
 * Agents page — browse, view, and load agent instructions.
 */
const PageAgents = (() => {
  async function render(renderFn) {
    const agents = await API.getAgents();

    const html = `
      <p style="color:var(--text-secondary);margin-bottom:16px">${agents.length} agents available — click to view instructions</p>
      <div class="grid grid-4">
        ${agents.map(a => `
          <div class="agent-card" onclick="PageAgents.viewAgent('${a.key}')">
            <div class="agent-card__emoji">${a.emoji}</div>
            <div class="agent-card__name">${a.name}</div>
            <div class="agent-card__desc">${a.description || (a.exists ? 'Click to view instructions' : 'Not available')}</div>
            ${a.version ? `<div style="font-size:0.75rem;color:var(--text-muted);margin-top:4px">v${a.version}</div>` : ''}
          </div>
        `).join('')}
      </div>
    `;

    renderFn(html);
  }

  async function viewAgent(key) {
    try {
      const agent = await API.getAgent(key);
      const body = document.createElement('div');
      body.innerHTML = `
        <div style="display:flex;gap:8px;margin-bottom:16px">
          <span style="font-size:2rem">${agent.emoji}</span>
          <div>
            <strong style="font-size:1.1rem">${agent.name}</strong>
          </div>
        </div>
        <pre class="code-block" style="max-height:50vh;overflow-y:auto">${escapeHtml(agent.content)}</pre>
        <div style="display:flex;gap:8px;margin-top:16px">
          <button class="btn btn-sm" onclick="PageAgents.copyContent()">📋 Copy Instructions</button>
          <button class="btn btn-sm btn-primary" onclick="PageAgents.loadAgent('${key}')">▶ Load Agent</button>
        </div>
      `;

      Modal.open(`${agent.emoji} ${agent.name}`, body);
      // Store content for copy
      window.__agentContent = agent.content;
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  function copyContent() {
    const content = window.__agentContent;
    if (!content) return;

    navigator.clipboard.writeText(content).then(() => {
      API.showToast('Copied to clipboard!', 'success');
    }).catch(() => {
      // Fallback
      const ta = document.createElement('textarea');
      ta.value = content;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      ta.remove();
      API.showToast('Copied to clipboard!', 'success');
    });
  }

  async function loadAgent(key) {
    try {
      const result = await API.loadAgent(key);
      Modal.close();
      API.showToast(
        `Run this in your terminal:\n${result.command}`,
        'info'
      );
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  return { render, viewAgent, copyContent, loadAgent };
})();
