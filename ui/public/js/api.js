/**
 * API client — fetch wrapper for the local REST API.
 */
const API = (() => {
  const BASE = '';

  /**
   * Generic request with error handling.
   */
  async function request(method, path, body) {
    const opts = {
      method,
      headers: { 'Accept': 'application/json' },
    };
    if (body) {
      opts.headers['Content-Type'] = 'application/json';
      opts.body = JSON.stringify(body);
    }
    try {
      const res = await fetch(`${BASE}${path}`, opts);
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || `HTTP ${res.status}`);
      }
      return data;
    } catch (err) {
      if (err.name === 'TypeError' && err.message.includes('fetch')) {
        throw new Error('Cannot connect to server. Is the UI server running?');
      }
      throw err;
    }
  }

  return {
    get: (path) => request('GET', path),
    post: (path, body) => request('POST', path, body),
    put: (path, body) => request('PUT', path, body),
    del: (path) => request('DELETE', path),

    // === System ===
    getStatus: () => request('GET', '/api/status'),
    getEnvKeys: () => request('GET', '/api/env-keys'),

    // === Profiles ===
    getProfiles: () => request('GET', '/api/profiles'),
    getProfile: (name) => request('GET', `/api/profiles/${encodeURIComponent(name)}`),
    switchProfile: (name) => request('POST', `/api/profiles/${encodeURIComponent(name)}/switch`),
    createProfile: (data) => request('POST', '/api/profiles', data),

    // === Profile Editor ===
    getProfileFields: (name) => request('GET', `/api/profiles/${encodeURIComponent(name)}/fields`),
    updateProfile: (name, content) => request('PUT', `/api/profiles/${encodeURIComponent(name)}`, { content }),

    // === MCP ===
    getMcpStatus: () => request('GET', '/api/mcp/status'),
    retryMcp: (name) => request('POST', `/api/mcp/retry/${encodeURIComponent(name)}`),

    // === Diagnostics ===
    getDiagnostics: () => request('GET', '/api/diagnostics'),

    // === Benchmark ===
    runBenchmark: () => request('POST', '/api/benchmark'),
    getBenchmarkHistory: () => request('GET', '/api/benchmark/history'),

    // === Agents ===
    getAgents: () => request('GET', '/api/agents'),
    getAgent: (name) => request('GET', `/api/agents/${encodeURIComponent(name)}`),
    loadAgent: (name) => request('POST', `/api/agents/${encodeURIComponent(name)}/load`),

    // === OpenRouter ===
    getOpenRouterModels: () => request('GET', '/api/openrouter/models'),
    refreshOpenRouterModels: () => request('POST', '/api/openrouter/models/refresh'),

    // === Settings ===
    getSettings: () => request('GET', '/api/settings'),
    updateSettings: (data) => request('PUT', '/api/settings', data),

    // === Toast helper ===
    showToast(message, type = 'info') {
      const container = document.getElementById('toast-container');
      const toast = document.createElement('div');
      toast.className = `toast toast--${type}`;
      const icons = { success: '✅', error: '❌', info: 'ℹ️' };
      toast.innerHTML = `<span>${icons[type] || 'ℹ️'}</span><span>${message}</span>`;
      container.appendChild(toast);
      setTimeout(() => { toast.remove(); }, 4000);
    },
  };
})();
