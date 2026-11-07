(() => {
  const SEL = '.rgrid,.ready-grid,.cdlist,.sb-cats,.mn,.modal,.overview-ready-panel,.cooldown-panel,.chart-card,.pn-list,.dd-list';
  const update = (el) => {
    const max = el.scrollHeight - el.clientHeight;
    el.classList.toggle('sf-t', el.scrollTop > 2);
    el.classList.toggle('sf-b', max > 2 && el.scrollTop < max - 2);
  };
  let queued = false;
  const scan = () => {
    queued = false;
    document.querySelectorAll(SEL).forEach(update);
  };
  const queue = () => {
    if (queued) return;
    queued = true;
    requestAnimationFrame(scan);
  };
  document.addEventListener('scroll', queue, true);
  window.addEventListener('resize', queue);
  new MutationObserver(queue).observe(document.documentElement, { childList: true, subtree: true });
  setInterval(queue, 400);
  queue();
})();

(() => {
  const SCROLLERS = '.rgrid,.ready-grid,.cdlist,.sb-cats,.modal,.mn,.pn-list,.dd-list,.overview-ready-panel';
  const states = new WeakMap();
  const canScroll = (el, dir) => {
    const max = el.scrollHeight - el.clientHeight;
    if (max <= 1) return false;
    return dir < 0 ? el.scrollTop > 0 : el.scrollTop < max - 1;
  };
  const findScroller = (node, dir) => {
    let el = node instanceof Element ? node.closest(SCROLLERS) : null;
    while (el) {
      if (canScroll(el, dir)) return el;
      el = el.parentElement ? el.parentElement.closest(SCROLLERS) : null;
    }
    return null;
  };
  const step = (el, state) => {
    const diff = state.target - el.scrollTop;
    if (Math.abs(diff) < 0.6) {
      el.scrollTop = state.target;
      state.raf = 0;
      return;
    }
    el.scrollTop += diff * 0.2;
    state.raf = requestAnimationFrame(() => step(el, state));
  };
  window.addEventListener('wheel', (event) => {
    if (event.ctrlKey || event.deltaY === 0) return;
    const dir = Math.sign(event.deltaY);
    const el = findScroller(event.target, dir);
    if (!el) return;
    event.preventDefault();
    event.stopPropagation();
    const unit = event.deltaMode === 1 ? 36 : event.deltaMode === 2 ? el.clientHeight : 1;
    let state = states.get(el);
    if (!state) {
      state = { target: el.scrollTop, raf: 0 };
      states.set(el, state);
    }
    const base = state.raf ? state.target : el.scrollTop;
    const max = el.scrollHeight - el.clientHeight;
    state.target = Math.max(0, Math.min(max, base + event.deltaY * unit * 1.1));
    if (!state.raf) state.raf = requestAnimationFrame(() => step(el, state));
  }, { capture: true, passive: false });
})();
