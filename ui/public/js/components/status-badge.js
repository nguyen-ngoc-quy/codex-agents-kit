/**
 * StatusBadge component — renders consistent status indicators.
 */
const StatusBadge = (() => {
  const STATUS_MAP = {
    pass:    { cls: 'badge--pass',    icon: '✅', label: 'Pass' },
    fail:    { cls: 'badge--fail',    icon: '❌', label: 'Fail' },
    warn:    { cls: 'badge--warn',    icon: '⚠️', label: 'Warning' },
    active:  { cls: 'badge--active',  icon: '●',  label: 'Active' },
    inactive:{ cls: 'badge--inactive', icon: '○',  label: 'Inactive' },
    running: { cls: 'badge--pass',    icon: '▶',  label: 'Running' },
    stopped: { cls: 'badge--inactive', icon: '⏹',  label: 'Stopped' },
    error:   { cls: 'badge--fail',    icon: '✕',  label: 'Error' },
    cached:  { cls: 'badge--pass',    icon: '📦', label: 'Cached' },
    missing: { cls: 'badge--inactive', icon: '📭', label: 'Not Found' },
    info:    { cls: 'badge--info',    icon: 'ℹ️', label: 'Info' },
  };

  /**
   * Render a status badge element.
   * @param {string} status — key from STATUS_MAP
   * @param {string} [customLabel] — override default label text
   * @returns {HTMLElement}
   */
  function render(status, customLabel) {
    const def = STATUS_MAP[status] || STATUS_MAP.info;
    const el = document.createElement('span');
    el.className = `badge ${def.cls}`;
    el.innerHTML = `${def.icon} ${customLabel || def.label}`;
    return el;
  }

  return { render };
})();
