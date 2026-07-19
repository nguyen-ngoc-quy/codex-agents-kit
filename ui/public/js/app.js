/**
 * App — SPA router and global state.
 */
const App = (() => {
  const PAGE_TITLES = {
    'dashboard':   'Dashboard',
    'profiles':    'Profiles',
    'mcp':         'MCP Servers',
    'diagnostics': 'Diagnostics',
    'benchmark':   'Benchmark',
    'agents':      'Agents',
    'settings':    'Settings',
    'openrouter':  'OpenRouter Models',
  };

  const PAGES = {
    dashboard:   PageDashboard,
    profiles:    PageProfiles,
    mcp:         PageMcp,
    diagnostics: PageDiagnostics,
    benchmark:   PageBenchmark,
    agents:      PageAgents,
    settings:    PageSettings,
    openrouter:  PageOpenRouter,
  };

  let currentPage = null;

  /**
   * Show loading spinner in the content area.
   */
  function showLoading() {
    const area = document.getElementById('content-area');
    area.innerHTML = `
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Loading...</p>
      </div>
    `;
  }

  /**
   * Render a page into the content area.
   */
  function render(html) {
    const area = document.getElementById('content-area');
    area.innerHTML = html;
  }

  /**
   * Navigate to a page by name (e.g., 'dashboard', 'profiles').
   */
  async function navigate(page) {
    if (page === currentPage) return;
    currentPage = page;

    Header.setTitle(PAGE_TITLES[page] || page);
    Sidebar.setActive(page);
    showLoading();

    try {
      const pageModule = PAGES[page];
      if (pageModule && pageModule.render) {
        await pageModule.render(render, showLoading);
      }
    } catch (err) {
      render(`
        <div class="empty-state">
          <div class="empty-state__icon">⚠️</div>
          <div class="empty-state__text">Failed to load page</div>
          <div class="empty-state__sub">${err.message}</div>
          <button class="btn btn-primary" onclick="location.reload()" style="margin-top:16px">Retry</button>
        </div>
      `);
    }
  }

  /**
   * Parse the hash to determine the current route.
   */
  function getRoute() {
    const hash = window.location.hash.replace(/^#\//, '') || 'dashboard';
    return hash.split('/')[0];
  }

  /**
   * Hash change handler.
   */
  function onHashChange() {
    const page = getRoute();
    navigate(page);
  }

  // === Init ===
  function init() {
    window.addEventListener('hashchange', onHashChange);
    onHashChange();

    // Theme toggle
    const toggle = document.getElementById('theme-toggle');
    const icon = document.getElementById('theme-icon');
    const html = document.documentElement;

    // Load saved theme
    const savedTheme = localStorage.getItem('codex-ui-theme') || 'dark';
    html.setAttribute('data-theme', savedTheme);
    icon.textContent = savedTheme === 'dark' ? '🌙' : '☀️';

    toggle.addEventListener('click', () => {
      const current = html.getAttribute('data-theme');
      const next = current === 'dark' ? 'light' : 'dark';
      html.setAttribute('data-theme', next);
      icon.textContent = next === 'dark' ? '🌙' : '☀️';
      localStorage.setItem('codex-ui-theme', next);
    });

    // Check connection periodically
    checkConnection();
    setInterval(checkConnection, 15000);
  }

  async function checkConnection() {
    try {
      const res = await fetch('/api/status');
      Header.setConnected(res.ok);
    } catch {
      Header.setConnected(false);
    }
  }

  // Wait for DOM
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  return { navigate, render, showLoading };
})();
