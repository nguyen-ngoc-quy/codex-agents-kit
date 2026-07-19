/**
 * Header component — updates page title and connection status.
 */
const Header = (() => {
  const titleEl = document.getElementById('page-title');
  const statusDot = document.querySelector('#connection-status .status-dot');
  const statusText = document.querySelector('#connection-status .status-text');

  function setTitle(text) {
    titleEl.textContent = text;
    document.title = `${text} — Codex CLI Ultimate`;
  }

  function setConnected(connected) {
    if (connected) {
      statusDot.className = 'status-dot status-dot--green';
      statusText.textContent = 'Connected';
    } else {
      statusDot.className = 'status-dot status-dot--red';
      statusText.textContent = 'Disconnected';
    }
  }

  return { setTitle, setConnected };
})();
