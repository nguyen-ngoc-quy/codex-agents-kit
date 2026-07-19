/**
 * Profiles page — list, switch, view, create, and edit profiles.
 */
const PageProfiles = (() => {
  // ── State ────────────────────────────────────────────────────
  let editingProfile = null;   // { name, fields, raw } when editing
  let formDirty = false;

  // ── Main Render (list view) ──────────────────────────────────
  async function render(renderFn) {
    const data = await API.getProfiles();

    const html = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <p style="color:var(--text-secondary)">${data.profiles.length} profiles found</p>
        <button class="btn btn-primary" onclick="PageProfiles.showCreateModal()">+ New Profile</button>
      </div>
      <div class="grid grid-2">
        ${data.profiles.map(p => `
          <div class="card ${p.isActive ? 'active-profile' : ''}" style="${p.isActive ? 'border-color:var(--accent-green)' : ''}">
            <div class="card-header">
              <div style="display:flex;align-items:center;gap:8px">
                <h3>${p.name}</h3>
                ${p.isActive ? '<span class="badge badge--active">Active</span>' : ''}
              </div>
            </div>
            <div class="card-body">
              <div class="info-row"><span class="info-label">Provider</span><span class="info-value">${p.provider}</span></div>
              <div class="info-row"><span class="info-label">Model</span><span class="info-value"><code>${p.model}</code></span></div>
              ${p.recommendedAgent ? `<div class="info-row"><span class="info-label">Agent</span><span class="info-value">${p.recommendedAgent}</span></div>` : ''}
            </div>
            <div class="card-footer" style="display:flex;gap:8px">
              ${!p.isActive ? `<button class="btn btn-sm btn-success" onclick="PageProfiles.switchProfile('${p.name}')">Switch</button>` : ''}
              <button class="btn btn-sm" onclick="PageProfiles.editProfile('${p.name}')">Edit</button>
              <button class="btn btn-sm" onclick="PageProfiles.viewProfile('${p.name}')">View TOML</button>
            </div>
          </div>
        `).join('')}
      </div>
    `;

    renderFn(html);
  }

  // ── Edit Profile ─────────────────────────────────────────────
  async function editProfile(name) {
    try {
      const data = await API.getProfileFields(name);
      editingProfile = { name: data.name, fields: data.fields, raw: data.raw };
      formDirty = false;
      renderEditForm();
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  function renderEditForm() {
    const p = editingProfile;
    const f = p.fields;
    const area = document.getElementById('content-area');

    const providerOptions = ['openai', 'openrouter', 'anthropic', 'ollama'];

    const html = `
      <div class="edit-profile-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <h2 style="margin:0">✏️ Edit Profile: <code>${p.name}.toml</code></h2>
        <div style="display:flex;gap:8px">
          <button class="btn btn-success" onclick="PageProfiles.saveProfile()" ${formDirty ? '' : 'disabled'}>\u{1f4be} Save</button>
          <button class="btn" onclick="PageProfiles.cancelEdit()">Cancel</button>
        </div>
      </div>

      <div class="edit-form">
        <!-- Basic Settings -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Basic Settings</h3></div>
          <div class="card-body">
            <div class="form-row">
              <label class="form-label">Provider</label>
              <select class="form-input" id="edit-provider" onchange="PageProfiles.onFormChange()">
                ${providerOptions.map(opt => `<option value="${opt}" ${f.basicSettings.provider === opt ? 'selected' : ''}>${opt}</option>`).join('')}
              </select>
            </div>
            <div class="form-row">
              <label class="form-label">Model</label>
              <input class="form-input" id="edit-model" value="${escapeHtml(f.basicSettings.model)}" oninput="PageProfiles.onFormChange()">
            </div>
            <div class="form-row">
              <label class="form-label">Display Name</label>
              <input class="form-input" id="edit-display-name" value="${escapeHtml(f.basicSettings.displayName)}" oninput="PageProfiles.onFormChange()">
            </div>
            <div class="form-row">
              <label class="form-label">Base URL</label>
              <input class="form-input" id="edit-base-url" value="${escapeHtml(f.basicSettings.baseUrl)}" oninput="PageProfiles.onFormChange()">
            </div>
            <div class="form-row">
              <label class="form-label">API Env Var</label>
              <input class="form-input" id="edit-env-key" value="${escapeHtml(f.basicSettings.envKey)}" placeholder="OPENAI_API_KEY" oninput="PageProfiles.onFormChange()" style="text-transform:uppercase">
            </div>
          </div>
        </div>

        <!-- Tools -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Tools</h3></div>
          <div class="card-body">
            <label class="checkbox-row"><input type="checkbox" id="edit-web-search" ${f.tools.webSearch ? 'checked' : ''} onchange="PageProfiles.onFormChange()"> Web Search</label>
            <label class="checkbox-row"><input type="checkbox" id="edit-file-browser" ${f.tools.fileBrowser ? 'checked' : ''} onchange="PageProfiles.onFormChange()"> File Browser</label>
          </div>
        </div>

        <!-- Plugins -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Plugins (${f.plugins.length})</h3></div>
          <div class="card-body">
            <div class="grid grid-2">
              ${f.plugins.map((pl, i) => `
                <label class="checkbox-row">
                  <input type="checkbox" id="plugin-${i}" ${pl.enabled ? 'checked' : ''} onchange="PageProfiles.onFormChange()">
                  ${escapeHtml(pl.name)}
                </label>
              `).join('')}
            </div>
          </div>
        </div>

        <!-- MCP Servers -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header" style="display:flex;justify-content:space-between;align-items:center">
            <h3>MCP Servers</h3>
            <button class="btn btn-sm" onclick="PageProfiles.addMcpServer()">+ Add</button>
          </div>
          <div class="card-body" id="mcp-list">
            ${f.mcpServers.map((mcp, i) => renderMcpRow(mcp, i)).join('')}
          </div>
        </div>

        <!-- Raw TOML Preview -->
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>Raw TOML Preview (read-only)</h3></div>
          <div class="card-body">
            <pre class="code-block" id="raw-toml-preview" style="max-height:400px;overflow:auto;font-size:12px">${escapeHtml(p.raw)}</pre>
          </div>
        </div>
      </div>

      <div style="display:flex;justify-content:flex-end;gap:8px;margin-bottom:32px">
        <button class="btn btn-success" onclick="PageProfiles.saveProfile()" ${formDirty ? '' : 'disabled'}>\u{1f4be} Save</button>
        <button class="btn" onclick="PageProfiles.cancelEdit()">Cancel</button>
      </div>
    `;

    area.innerHTML = html;
  }

  function renderMcpRow(mcp, index) {
    const argsStr = Array.isArray(mcp.args) ? mcp.args.join(', ') : mcp.args || '';
    const envEntries = mcp.env && typeof mcp.env === 'object' ? Object.entries(mcp.env) : [];
    const envStr = envEntries.map(([k, v]) => `${k}=${v}`).join(', ');
    return `
      <div class="mcp-row" style="border:1px solid var(--border-color);border-radius:var(--radius-md);padding:12px;margin-bottom:8px">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
          <strong>${escapeHtml(mcp.name)}</strong>
          <button class="btn btn-sm btn-danger" onclick="PageProfiles.removeMcpServer(${index})">Remove</button>
        </div>
        <div class="form-row">
          <label class="form-label">Command</label>
          <input class="form-input mcp-cmd" value="${escapeHtml(mcp.command)}" oninput="PageProfiles.onMcpChange(${index}, 'command', this.value)">
        </div>
        <div class="form-row">
          <label class="form-label">Args (comma-separated)</label>
          <input class="form-input mcp-args" value="${escapeHtml(argsStr)}" oninput="PageProfiles.onMcpChange(${index}, 'args', this.value)">
        </div>
        ${envStr ? `<div class="form-row"><label class="form-label">Env</label><input class="form-input mcp-env" value="${escapeHtml(envStr)}" oninput="PageProfiles.onMcpChange(${index}, 'env', this.value)"></div>` : ''}
      </div>
    `;
  }

  // ── Form Handlers ────────────────────────────────────────────
  function onFormChange() {
    formDirty = true;
    document.querySelectorAll('.btn-success').forEach(b => b.disabled = false);
    updateRawPreview();
  }

  function onMcpChange(index, field, value) {
    if (!editingProfile) return;
    const mcp = editingProfile.fields.mcpServers[index];
    if (!mcp) return;
    if (field === 'args') {
      mcp.args = value.split(',').map(s => s.trim()).filter(Boolean);
    } else if (field === 'env') {
      const env = {};
      value.split(',').forEach(pair => {
        const parts = pair.trim().split('=');
        if (parts.length >= 2) env[parts[0].trim()] = parts.slice(1).join('=').trim();
      });
      mcp.env = env;
    } else if (field === 'command') {
      mcp.command = value;
    }
    formDirty = true;
    document.querySelectorAll('.btn-success').forEach(b => b.disabled = false);
  }

  function addMcpServer() {
    if (!editingProfile) return;
    const name = prompt('Enter MCP server name:');
    if (!name || !/^[a-zA-Z0-9_-]+$/.test(name)) return;
    editingProfile.fields.mcpServers.push({ name, command: 'npx', args: ['-y', 'package-name'], env: {} });
    renderEditForm();
  }

  function removeMcpServer(index) {
    if (!editingProfile) return;
    editingProfile.fields.mcpServers.splice(index, 1);
    formDirty = true;
    renderEditForm();
  }

  function updateRawPreview() {
    const f = editingProfile.fields;
    const provider = document.getElementById('edit-provider')?.value || f.basicSettings.provider;
    const model = document.getElementById('edit-model')?.value || f.basicSettings.model;
    const displayName = document.getElementById('edit-display-name')?.value || f.basicSettings.displayName;
    const baseUrl = document.getElementById('edit-base-url')?.value || f.basicSettings.baseUrl;
    const envKey = document.getElementById('edit-env-key')?.value || f.basicSettings.envKey;
    const webSearch = document.getElementById('edit-web-search')?.checked ?? f.tools.webSearch;
    const fileBrowser = document.getElementById('edit-file-browser')?.checked ?? f.tools.fileBrowser;

    let toml = `model_provider = "${provider}"\n`;
    toml += `model = "${model}"\n\n`;
    toml += `[model_providers.${provider}]\n`;
    toml += `name = "${displayName}"\n`;
    toml += `base_url = "${baseUrl}"\n`;
    toml += `env_key = "${envKey}"\n\n`;
    toml += `[tools]\nweb_search = ${webSearch}\nfile_browser = ${fileBrowser}\n\n`;
    toml += `[windows]\nsandbox = "unelevated"\n\n`;

    const pluginCheckboxes = document.querySelectorAll('[id^="plugin-"]');
    const pluginNames = f.plugins;
    pluginCheckboxes.forEach((cb, i) => {
      if (pluginNames[i]) {
        toml += `[plugins."${pluginNames[i].name}"]\nenabled = ${cb.checked}\n\n`;
      }
    });

    const mcpRows = document.querySelectorAll('.mcp-row');
    mcpRows.forEach((row, i) => {
      const mcp = f.mcpServers[i];
      if (!mcp) return;
      toml += `[mcp_servers.${mcp.name}]\n`;
      const cmd = row.querySelector('.mcp-cmd')?.value || mcp.command;
      const argsStr = row.querySelector('.mcp-args')?.value || (Array.isArray(mcp.args) ? mcp.args.join(', ') : mcp.args || '');
      const args = argsStr.split(',').map(s => `"${s.trim()}"`).join(', ');
      toml += `command = "${cmd}"\n`;
      toml += `args = [${args}]\n`;
      if (mcp.env && Object.keys(mcp.env).length > 0) {
        toml += `[mcp_servers.${mcp.name}.env]\n`;
        for (const [k, v] of Object.entries(mcp.env)) {
          toml += `${k} = "${v}"\n`;
        }
      }
      toml += '\n';
    });

    const preview = document.getElementById('raw-toml-preview');
    if (preview) {
      preview.textContent = toml;
    }
  }

  // ── Save / Cancel ────────────────────────────────────────────
  async function saveProfile() {
    if (!editingProfile || !formDirty) return;
    const model = document.getElementById('edit-model')?.value || '';
    if (!model.trim()) {
      API.showToast('Model name cannot be empty', 'error');
      return;
    }
    const rawPreview = document.getElementById('raw-toml-preview');
    const content = rawPreview ? rawPreview.textContent : '';
    try {
      await API.updateProfile(editingProfile.name, content);
      API.showToast(`Profile "${editingProfile.name}" saved`, 'success');
      editingProfile = null;
      formDirty = false;
      render(render);
    } catch (err) {
      API.showToast(`Save failed: ${err.message}`, 'error');
    }
  }

  function cancelEdit() {
    if (formDirty) {
      if (!confirm('Discard unsaved changes?')) return;
    }
    editingProfile = null;
    formDirty = false;
    render(render);
  }

  // ── Existing Methods ─────────────────────────────────────────
  async function switchProfile(name) {
    try {
      const result = await API.switchProfile(name);
      API.showToast(`Switched to ${name}`, 'success');
      render(render);
    } catch (err) {
      API.showToast(`Switch failed: ${err.message}`, 'error');
    }
  }

  async function viewProfile(name) {
    try {
      const data = await API.getProfile(name);
      Modal.open(`${name}.toml`, `<pre class="code-block">${escapeHtml(data.content)}</pre>`);
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  async function showCreateModal() {
    const body = `
      <form id="create-profile-form" onsubmit="PageProfiles.createProfile(event)">
        <div style="margin-bottom:12px">
          <label style="display:block;margin-bottom:4px;font-weight:500">Profile Name</label>
          <input type="text" name="name" required pattern="[a-zA-Z0-9._-]+"
                 style="width:100%;padding:8px 12px;border:1px solid var(--border-color);border-radius:var(--radius-md);background:var(--bg-secondary);color:var(--text-primary);font-family:inherit"
                 placeholder="my-custom-profile">
          <small style="color:var(--text-muted)">Alphanumeric, dots, hyphens, and underscores only</small>
        </div>
        <div style="margin-bottom:16px">
          <label style="display:block;margin-bottom:4px;font-weight:500">Base Profile (optional)</label>
          <select name="baseProfile"
                  style="width:100%;padding:8px 12px;border:1px solid var(--border-color);border-radius:var(--radius-md);background:var(--bg-secondary);color:var(--text-primary);font-family:inherit">
            <option value="">Custom template (profiles/custom.toml.example)</option>
          </select>
        </div>
        <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center">Create</button>
      </form>
    `;
    Modal.open('Create New Profile', body);

    const data = await API.getProfiles();
    const select = document.querySelector('[name="baseProfile"]');
    data.profiles.forEach(p => {
      const opt = document.createElement('option');
      opt.value = p.name;
      opt.textContent = `${p.name} (${p.provider}/${p.model})`;
      select.appendChild(opt);
    });
  }

  async function createProfile(event) {
    event.preventDefault();
    const form = event.target;
    const name = form.name.value.trim();
    const baseProfile = form.baseProfile.value || undefined;
    try {
      await API.createProfile({ name, baseProfile });
      Modal.close();
      API.showToast(`Profile "${name}" created`, 'success');
      render(render);
    } catch (err) {
      API.showToast(err.message, 'error');
    }
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  // ── Public API ───────────────────────────────────────────────
  return {
    render,
    switchProfile,
    viewProfile,
    editProfile,
    saveProfile,
    cancelEdit,
    showCreateModal,
    createProfile,
    onFormChange,
    onMcpChange,
    addMcpServer,
    removeMcpServer,
  };
})();
