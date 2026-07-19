/**
 * Modal component — simple reusable modal dialog.
 */
const Modal = (() => {
  const overlay = document.getElementById('modal-overlay');
  const titleEl = document.getElementById('modal-title');
  const bodyEl = document.getElementById('modal-body');
  const closeBtn = document.getElementById('modal-close');

  let onClose = null;

  function open(title, content) {
    titleEl.textContent = title;
    bodyEl.innerHTML = '';
    if (typeof content === 'string') {
      bodyEl.innerHTML = content;
    } else if (content instanceof HTMLElement) {
      bodyEl.appendChild(content);
    }
    overlay.hidden = false;
    document.body.style.overflow = 'hidden';
  }

  function close() {
    overlay.hidden = true;
    document.body.style.overflow = '';
    if (onClose) { onClose(); onClose = null; }
  }

  // Event listeners
  closeBtn.addEventListener('click', close);
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) close();
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !overlay.hidden) close();
  });

  return {
    open,
    close,
    setOnClose(fn) { onClose = fn; },
  };
})();
