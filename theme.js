// Hell-/Dunkelmodus wie in den Apps (gleicher localStorage-Key "theme", gilt für alle Apps der Domain)

function applyTheme(theme) {
  const html = document.documentElement;
  html.setAttribute('data-theme', theme);
  const bg = getComputedStyle(html).getPropertyValue('--bg-page').trim();
  document.querySelector('meta[name="theme-color"]')?.setAttribute('content', bg);
}

async function toggleTheme(event) {
  const theme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  localStorage.setItem('theme', theme);
  const update = () => applyTheme(theme);

  if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
    update();
    return;
  }

  // Kreis-Reveal ab dem Toggle-Button (View Transitions API)
  if (document.startViewTransition) {
    const rect = event.currentTarget.getBoundingClientRect();
    const x = rect.left + rect.width / 2;
    const y = rect.top + rect.height / 2;
    const feather = 160;
    const radius = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y)) + feather;
    document.documentElement.style.setProperty('--vt-x', `${x}px`);
    document.documentElement.style.setProperty('--vt-y', `${y}px`);

    const transition = document.startViewTransition(update);
    await transition.ready.catch(() => {});
    document.documentElement.animate(
      { '--vt-r': ['0px', `${radius}px`] },
      { duration: 600, easing: 'ease-in-out', fill: 'forwards', pseudoElement: '::view-transition-new(root)' },
    );
    return;
  }

  // Fallback: weiches Überblenden der Farben
  const html = document.documentElement;
  html.classList.add('theme-fade');
  update();
  setTimeout(() => html.classList.remove('theme-fade'), 300);
}

applyTheme(document.documentElement.getAttribute('data-theme'));
document.querySelector('.theme-toggle').addEventListener('click', toggleTheme);
