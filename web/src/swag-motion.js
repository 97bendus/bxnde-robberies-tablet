(() => {
  if (window.__bxndeswagMotionInstalled) return;
  window.__bxndeswagMotionInstalled = true;

  const clickable = 'button, [role="button"], .nav, .sb-cat, .ibtn, .ecard, .rcard, .cdrow, .btn, .theme-sw, .dd-item, .toggle, .dd-btn';
  document.addEventListener('pointerdown', (event) => {
    if (event.button !== 0 || !event.isPrimary) return;
    const app = document.getElementById('app');
    if (!app || !app.contains(event.target)) return;
    const target = event.target instanceof Element ? event.target.closest(clickable) : null;
    if (!target || !app.contains(target)) return;

    const rect = target.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const size = Math.ceil(Math.max(rect.width, rect.height) * 2.25);
    const bloom = document.createElement('span');
    bloom.className = 'swag-click-bloom';
    bloom.style.setProperty('--bloom-x', `${x}px`);
    bloom.style.setProperty('--bloom-y', `${y}px`);
    bloom.style.setProperty('--bloom-size', `${size}px`);

    const computed = window.getComputedStyle(target);
    if (computed.position === 'static') target.style.position = 'relative';
    if (computed.overflow === 'visible') target.style.overflow = 'hidden';
    target.appendChild(bloom);
    bloom.addEventListener('animationend', () => bloom.remove(), { once: true });
    window.setTimeout(() => bloom.remove(), 1400);
  }, true);

  const scrollStates = new WeakMap();
  const scrollSelector = '.rgrid, .ready-grid, .cdlist, .sb-cats, .modal, .mn';
  document.addEventListener('wheel', (event) => {
    if (event.ctrlKey || Math.abs(event.deltaY) < 1) return;
    const scroller = event.target instanceof Element ? event.target.closest(scrollSelector) : null;
    if (!scroller || !scroller.contains(event.target)) return;
    const max = scroller.scrollHeight - scroller.clientHeight;
    if (max <= 1) return;
    const direction = Math.sign(event.deltaY);
    if ((direction < 0 && scroller.scrollTop <= 0) || (direction > 0 && scroller.scrollTop >= max - 1)) return;
    event.preventDefault();
    const previous = scrollStates.get(scroller);
    if (previous?.raf) cancelAnimationFrame(previous.raf);
    const start = scroller.scrollTop;
    const target = Math.max(0, Math.min(max, start + event.deltaY * 1.08));
    const state = { raf: 0 };
    scrollStates.set(scroller, state);
    let started = 0;
    const duration = 620;
    const frame = (now) => {
      if (!started) started = now;
      const t = Math.min(1, (now - started) / duration);
      const eased = 1 - Math.pow(1 - t, 4);
      scroller.scrollTop = start + (target - start) * eased;
      if (t < 1) state.raf = requestAnimationFrame(frame);
      else state.raf = 0;
    };
    state.raf = requestAnimationFrame(frame);
  }, { passive: false });
})();