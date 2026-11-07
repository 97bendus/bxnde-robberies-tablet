const MASTER = 3.2;
let ctx = null;
let bus = null;
let verb = null;
let lastHover = 0;

const SCALE = [523.25, 587.33, 659.25, 783.99, 880.0, 1046.5];

function init() {
  if (ctx) return ctx;
  const AC = window.AudioContext || window.webkitAudioContext;
  if (!AC) return null;
  ctx = new AC();

  const comp = ctx.createDynamicsCompressor();
  comp.threshold.value = -20; comp.knee.value = 24; comp.ratio.value = 3;
  comp.attack.value = 0.01; comp.release.value = 0.3;

  const lp = ctx.createBiquadFilter();
  lp.type = 'lowpass'; lp.frequency.value = 3800; lp.Q.value = 0.2;

  bus = ctx.createGain(); bus.gain.value = 0.7 * MASTER;
  bus.connect(lp); lp.connect(comp); comp.connect(ctx.destination);

  const len = Math.floor(ctx.sampleRate * 1.5);
  const ir = ctx.createBuffer(2, len, ctx.sampleRate);
  for (let c = 0; c < 2; c++) {
    const d = ir.getChannelData(c);
    for (let i = 0; i < len; i++) d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 3.4);
  }
  const conv = ctx.createConvolver(); conv.buffer = ir;
  const wet = ctx.createGain(); wet.gain.value = 0.5;
  verb = ctx.createGain(); verb.gain.value = 1;
  verb.connect(conv); conv.connect(wet); wet.connect(lp);
  return ctx;
}

function tone({ f, to, dur = 0.4, vol = 0.05, at = 0, attack = 0.015, type = 'sine', send = 0.35 }) {
  const t0 = ctx.currentTime + at;
  const osc = ctx.createOscillator();
  const g = ctx.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(f, t0);
  if (to) osc.frequency.exponentialRampToValueAtTime(to, t0 + dur);
  g.gain.setValueAtTime(0.0001, t0);
  g.gain.linearRampToValueAtTime(vol, t0 + attack);
  g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
  osc.connect(g); g.connect(bus);
  if (send > 0) { const s = ctx.createGain(); s.gain.value = send; g.connect(s); s.connect(verb); }
  osc.start(t0); osc.stop(t0 + dur + 0.05);
}

function bell(f, vol, at = 0, dur = 0.55) {
  tone({ f, dur, vol, at, attack: 0.012 });
  tone({ f: f * 2, dur: dur * 0.6, vol: vol * 0.22, at, attack: 0.012, send: 0.5 });
}

export function playUiSound(kind, o = {}) {
  try {
    if (!init()) return;
    if (ctx.state === 'suspended') ctx.resume();

    switch (kind) {
      case 'hover':
      case 'rowHover': {
        const now = performance.now();
        if (now - lastHover < 600) return;
        lastHover = now;
        tone({ f: 440, to: 415, dur: 0.38, vol: 0.011, attack: 0.04, send: 0.5 });
        break;
      }
      case 'click':
        tone({ f: 300, to: 250, dur: 0.16, vol: 0.04, attack: 0.012, send: 0.25 });
        break;
      case 'open':
        bell(659.25, 0.05, 0, 0.6);
        bell(880, 0.045, 0.08, 0.7);
        break;
      case 'close':
        bell(783.99, 0.04, 0, 0.45);
        bell(587.33, 0.04, 0.08, 0.5);
        break;
      case 'start':
        bell(523.25, 0.05, 0, 0.7);
        bell(659.25, 0.05, 0.07, 0.7);
        bell(783.99, 0.05, 0.14, 0.9);
        break;
      case 'countdown': {
        tone({ f: 120, to: 62, dur: 0.5, vol: 0.1, attack: 0.03, send: 0.2 });
        bell(o.hot ? 659.25 : 440, 0.028, 0.02, 0.9);
        break;
      }
      case 'countdownGo': {
        tone({ f: 98, to: 55, dur: 1.0, vol: 0.12, attack: 0.04, send: 0.25 });
        [261.63, 329.63, 392.0, 523.25].forEach((f, i) => tone({ f, dur: 1.6, vol: 0.04, at: i * 0.05, attack: 0.09, send: 0.6 }));
        break;
      }
      default:
        break;
    }
  } catch (_) {}
}