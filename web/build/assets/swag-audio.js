(() => {
  let ctx = null;
  const play = (kind) => {
    try {
      const Ctx = window.AudioContext || window.webkitAudioContext;
      if (!Ctx) return;
      if (!ctx) ctx = new Ctx();
      if (ctx.state === 'suspended') ctx.resume();
      const now = ctx.currentTime;
      const master = ctx.createGain();
      master.gain.setValueAtTime(kind === 'countdown' || kind === 'countdownGo' ? 0.42 : 0.095, now);
      master.connect(ctx.destination);
      const voice = (type, from, to, duration, peak, delay = 0, cutoff = 4200) => {
        const osc = ctx.createOscillator(), gain = ctx.createGain(), filter = ctx.createBiquadFilter();
        osc.type = type;
        osc.frequency.setValueAtTime(Math.max(1, from), now + delay);
        osc.frequency.exponentialRampToValueAtTime(Math.max(1, to), now + delay + duration);
        filter.type = 'lowpass'; filter.frequency.setValueAtTime(cutoff, now + delay);
        gain.gain.setValueAtTime(0.0001, now + delay);
        gain.gain.exponentialRampToValueAtTime(peak, now + delay + Math.min(0.025, duration * 0.18));
        gain.gain.exponentialRampToValueAtTime(0.0001, now + delay + duration);
        osc.connect(filter); filter.connect(gain); gain.connect(master);
        osc.start(now + delay); osc.stop(now + delay + duration + 0.02);
      };
      if (kind === 'robberyHover') {
        voice('sine', 740, 520, 0.19, 0.13, 0, 2600);
        voice('triangle', 1110, 820, 0.22, 0.045, 0.018, 3400);
      } else if (kind === 'cooldownHover') {
        voice('sine', 390, 270, 0.23, 0.14, 0, 1500);
        voice('triangle', 585, 440, 0.19, 0.04, 0.025, 2100);
      } else if (kind === 'countdownGo') {
        voice('sine', 92, 38, 0.62, 0.7, 0, 420);
        voice('triangle', 220, 72, 0.48, 0.24, 0.015, 950);
        voice('sawtooth', 680, 155, 0.34, 0.11, 0.035, 1200);
      } else {
        voice('sine', 118, 54, 0.42, 0.55, 0, 520);
        voice('triangle', 360, 185, 0.25, 0.12, 0.015, 1500);
        voice('sine', 920, 510, 0.14, 0.045, 0.025, 2600);
      }
      master.gain.setTargetAtTime(0.0001, now + (kind === 'countdownGo' ? 0.52 : 0.3), 0.16);
      window.setTimeout(() => { try { master.disconnect(); } catch (_) {} }, 1100);
    } catch (_) {}
  };
  window.bxndePlayUiSound = play;
  document.addEventListener('pointerover', (event) => {
    const item = event.target && event.target.closest && event.target.closest('.rcard, .cdrow');
    if (!item) return;
    const previous = event.relatedTarget && event.relatedTarget.closest && event.relatedTarget.closest('.rcard, .cdrow');
    if (previous === item) return;
    play(item.classList.contains('rcard') ? 'robberyHover' : 'cooldownHover');
  }, { passive: true });
})();