/**
 * Sidebar component — navigation and mobile toggle.
 */
const Sidebar = (() => {
  const nav = document.getElementById('sidebar-nav');
  const sidebar = document.getElementById('sidebar');
  const mobileBtn = document.getElementById('mobile-menu-btn');

  function setActive(page) {
    nav.querySelectorAll('.nav-item').forEach(item => {
      item.classList.toggle('active', item.dataset.page === page);
    });
  }

  function toggleMobile() {
    sidebar.classList.toggle('open');
  }

  function closeMobile() {
    sidebar.classList.remove('open');
  }

  // Mobile menu toggle
  mobileBtn.addEventListener('click', toggleMobile);

  // Close sidebar on nav click (mobile)
  nav.addEventListener('click', (e) => {
    if (e.target.closest('.nav-item')) {
      closeMobile();
    }
  });

  // Close sidebar on Escape
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && sidebar.classList.contains('open')) {
      closeMobile();
    }
  });

  return { setActive };
})();
