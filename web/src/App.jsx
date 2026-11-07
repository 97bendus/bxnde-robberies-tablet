import React, { useEffect, useMemo, useRef, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { THEMES, PALETTE, DEMO_L, DEMO_ROWS, catOf, hexToRgb, num, post, setLocale } from './utils.js';
import { Ic } from './components/Icons.jsx';
import { Clock, IconBtn } from './components/Common.jsx';
import { playUiSound } from './sounds.js';
import { Countdown, DetailModal } from './components/RobberyViews.jsx';
import Overview from './pages/Overview.jsx';
import Robberies from './pages/Robberies.jsx';
import Cooldowns from './pages/Cooldowns.jsx';

const isDemo = typeof window !== 'undefined' && typeof window.GetParentResourceName !== 'function';

const SORTS = {
  name: (a, b) => String(a.name).localeCompare(String(b.name)),
  reward: (a, b) => (Number(b.reward) || 0) - (Number(a.reward) || 0),
  police: (a, b) => (Number(b.police) || 0) - (Number(a.police) || 0),
  time: (a, b) => (Number(a.estimatedTime) || 0) - (Number(b.estimatedTime) || 0)
};

export default function App() {
  const [visible, setVisible] = useState(false);
  const [closing, setClosing] = useState(false);
  const [countdown, setCountdown] = useState(null);
  const countdownConfig = useRef({ steps: 5, stepMs: 1000 });
  const timers = useRef([]);
  const busy = useRef(false);

  const [L, setL] = useState({});
  const [brand, setBrand] = useState({ name: 'BXNDE', logo: '' });
  const [rows, setRows] = useState([]);
  const [scene, setScene] = useState(false);
  const [tab, setTab] = useState('robberies');
  const [selId, setSelId] = useState(null);
  const [q, setQ] = useState('');
  const [cat, setCat] = useState('all');
  const [sort, setSort] = useState('name');
  const [only, setOnly] = useState(false);

  const [theme, setTheme] = useState('blue');
  const [themeOpen, setThemeOpen] = useState(false);
  const th = THEMES.find((x) => x[1] === theme) || THEMES[0];

  const winRef = useRef(null);
  const [compact, setCompact] = useState(false);

  const colors = useRef({});
  const colorOf = (c) => colors.current[c] || (colors.current[c] = PALETTE[Object.keys(colors.current).length % PALETTE.length]);
  setLocale(L);
  const t = (k) => L[k] || ({ sortBy: 'Sort', sortName: 'Name', overview: 'Overview', operations: 'Operations', category: 'Category', availableRobberies: 'Available robberies' }[k]) || k;
  const selRef = useRef(null); selRef.current = selId;

  useEffect(() => {
    const s = document.documentElement.style;
    s.setProperty('--a1', th[2]); s.setProperty('--a2', th[3]);
    s.setProperty('--a1-rgb', hexToRgb(th[2])); s.setProperty('--a2-rgb', hexToRgb(th[3]));
    s.setProperty('--theme-surface', `linear-gradient(135deg, rgba(${hexToRgb(th[2])},.12), rgba(${hexToRgb(th[3])},.035) 48%, transparent 82%)`);
    try { localStorage.setItem('bxndeTheme', theme); } catch (e) {}
  }, [theme]);
  useEffect(() => { document.body.classList.toggle('scene', scene); }, [scene]);
  useEffect(() => {
    if (!countdown) return;
    playUiSound(countdown.phase === 'go' ? 'countdownGo' : 'countdown', { hot: countdown.number <= 2 });
  }, [countdown?.phase, countdown?.number]);

  useEffect(() => {
    const hoverSel = '.rcard, .cdrow, .ecard';
    let hoverTimer = null;
    const onPointerOver = (e) => {
      const item = e.target?.closest?.(hoverSel);
      if (!item) return;
      const previous = e.relatedTarget?.closest?.(hoverSel);
      if (previous === item) return;
      clearTimeout(hoverTimer);
      hoverTimer = setTimeout(() => playUiSound(item.classList.contains('rcard') ? 'hover' : 'rowHover'), 110);
    };
    const onPointerOut = (e) => { if (!e.relatedTarget?.closest?.(hoverSel)) clearTimeout(hoverTimer); };
    const onDown = (e) => {
      if (e.button !== 0) return;
      if (e.target?.closest?.('.nav, .sb-cat, .dd-btn, .dd-item, .toggle')) playUiSound('click');
    };
    document.addEventListener('pointerover', onPointerOver, { passive: true });
    document.addEventListener('pointerout', onPointerOut, { passive: true });
    document.addEventListener('pointerdown', onDown, { passive: true });
    return () => { clearTimeout(hoverTimer); document.removeEventListener('pointerout', onPointerOut); document.removeEventListener('pointerover', onPointerOver); document.removeEventListener('pointerdown', onDown); };
  }, []);

  const prevSel = useRef(null);
  useEffect(() => {
    if (selId != null && prevSel.current == null) playUiSound('open');
    else if (selId == null && prevSel.current != null && !busy.current) playUiSound('close');
    prevSel.current = selId;
  }, [selId]);

  useEffect(() => {
    const f = (e) => { if (!e.target.closest('.theme-pop,#themeBtn')) setThemeOpen(false); };
    document.addEventListener('click', f);
    return () => document.removeEventListener('click', f);
  }, []);
  useEffect(() => {
    if (!winRef.current) return;
    const ro = new ResizeObserver(([e]) => setCompact(e.contentRect.width < 1000));
    ro.observe(winRef.current);
    return () => ro.disconnect();
  }, [visible]);

  const clearTimers = () => { timers.current.forEach(clearTimeout); timers.current = []; };
  const close = () => { setScene(false); setVisible(false); post('bxnde-robberies-tablet:ui:close'); };

  const beginRobbery = (robbery) => {
    if (!robbery || !robbery.available || busy.current) return;
    busy.current = true;
    playUiSound('start');
    const steps = Math.max(1, Number(countdownConfig.current.steps) || 5);
    const stepMs = Math.max(500, Number(countdownConfig.current.stepMs) || 1000);
    clearTimers();
    document.body.classList.add('cine');
    setSelId(null);
    setClosing(true);
    post('bxnde-robberies-tablet:ui:begin', { id: robbery.id });
    timers.current.push(setTimeout(() => {
      setVisible(false); setScene(false);
      post('bxnde-robberies-tablet:ui:cinestart');
      setCountdown({ phase: 'count', number: steps, steps, stepMs, robbery });
      for (let i = 0; i < steps; i++) {
        timers.current.push(setTimeout(() => {
          setCountdown({ phase: 'count', number: steps - i, steps, stepMs, robbery });
          if (i < steps - 1) post('bxnde-robberies-tablet:ui:beat');
        }, i * stepMs));
      }
      timers.current.push(setTimeout(() => {
        setCountdown({ phase: 'go', number: 0, steps, stepMs, robbery });
        post('bxnde-robberies-tablet:ui:start', { id: robbery.id });
        document.body.classList.remove('cine');
        timers.current.push(setTimeout(() => { setCountdown(null); setClosing(false); busy.current = false; }, 700));
      }, steps * stepMs));
    }, 950));
  };

  useEffect(() => {
    if (isDemo) { setL(DEMO_L); setBrand({ name: 'BXNDE', logo: '' }); setRows(DEMO_ROWS); setVisible(true); }
    const onMsg = (e) => {
      const d = e.data || {};
      if (d.action === 'forceClose') { document.body.classList.remove('cine'); setScene(false); setVisible(false); setCountdown(null); setClosing(false); setSelId(null); busy.current = false; return; }
      if (d.action === 'cancelCountdown') { clearTimers(); document.body.classList.remove('cine'); setCountdown(null); setClosing(false); busy.current = false; return; }
      if (d.action !== 'open' || busy.current) return;
      setScene(!!d.scene);
      if (d.countdown) countdownConfig.current = { steps: Number(d.countdown.steps) || 5, stepMs: Number(d.countdown.stepMs) || 1000 };
      setClosing(false);
      setL(d.locale || {});
      setBrand({ name: d.servername || 'BXNDE', logo: d.serverlogo || '' });
      setRows(d.payload || []);
      setCat('all'); setQ(''); setOnly(false); setTab('robberies');
      setSelId((id) => ((d.payload || []).some((r) => String(r.id) === String(id)) ? id : null));
      setVisible(true);
    };
    const onKey = (e) => { if (e.key !== 'Escape') return; if (selRef.current != null) setSelId(null); else if (!isDemo) close(); };
    window.addEventListener('message', onMsg); window.addEventListener('keydown', onKey);
    return () => { window.removeEventListener('message', onMsg); window.removeEventListener('keydown', onKey); };
  }, []);

  const cats = useMemo(() => [...new Set(rows.map(catOf))], [rows]);
  const list = useMemo(() => rows
    .filter((r) => (r.name || '').toLowerCase().includes(q.toLowerCase()) && (cat === 'all' || catOf(r) === cat) && (!only || r.available))
    .sort(SORTS[sort] || SORTS.name), [rows, q, cat, only, sort]);
  const sel = rows.find((r) => String(r.id) === String(selId)) || null;

  const total = rows.length, ready = rows.filter((r) => r.available).length, cd = total - ready;
  const avg = total ? Math.round(rows.reduce((a, r) => a + (Number(r.police) || 0), 0) / total) : 0;
  const pool = rows.reduce((a, r) => a + (Number(r.reward) || 0), 0);

  const nav = [['overview', 'dash', t('overview'), null], ['robberies', 'grid', t('operations'), total], ['cooldowns', 'timer', t('cooldowns'), cd]];
  const goCat = (c) => { setCat(c); setTab('robberies'); };

  const page = tab === 'overview'
    ? <Overview rows={rows} ready={ready} cd={cd} total={total} avg={avg} pool={pool} accent={th[2]} colorOf={colorOf} t={t} onOpen={setSelId} />
    : tab === 'robberies'
      ? <Robberies list={list} rows={rows} cats={cats} cat={cat} setCat={setCat} q={q} setQ={setQ} sort={sort} setSort={setSort} only={only} setOnly={setOnly} colorOf={colorOf} t={t} onOpen={setSelId} />
      : <Cooldowns rows={rows} colorOf={colorOf} t={t} onOpen={setSelId} />;

  return (
    <>
      <AnimatePresence>
        {visible && (
          <div id="app" key="app">
            <motion.div
              ref={winRef}
              className={`win${compact ? ' compact' : ''}`}
              initial={{ opacity: 0, scale: 0.96, y: 16 }}
              animate={closing ? { opacity: 0, scale: 0.92, y: 30, filter: 'blur(8px)' } : { opacity: 1, scale: 1, y: 0, filter: 'blur(0px)' }}
              exit={{ opacity: 0, scale: 0.985, transition: { duration: 0.34, ease: [0.22, 1, 0.36, 1] } }}
              transition={closing ? { duration: 0.9, ease: [0.65, 0, 0.25, 1] } : { duration: 0.42, ease: [0.22, 1, 0.36, 1] }}
              style={{ pointerEvents: closing ? 'none' : 'auto' }}
            >
              <div className="bd">
                <aside className="sb">
                  <div className="brand sb-brand">
                    <div className="brand-ic">{brand.logo ? <img src={brand.logo} alt="" /> : <Ic n="shield" size={18} />}</div>
                    <div className="brand-tx"><b>{brand.name}</b><small>{t('title')}</small></div>
                  </div>
                  <label className="sidebar-search search"><Ic n="search" size={16} /><input value={q} onChange={(e) => setQ(e.target.value)} placeholder={t('search')} autoComplete="off" /></label>
                  <nav>
                    {nav.map(([k, ic, label, n]) => (
                      <button key={k} className={`nav${tab === k ? ' active' : ''}`} title={label} onClick={() => setTab(k)}>
                        <Ic n={ic} size={18} /><span className="nav-l">{label}</span>{n != null && <em>{n}</em>}{tab === k && <u />}
                      </button>
                    ))}
                  </nav>
                  <div className="sb-label">{t('categories')}</div>
                  <div className="sb-cats">
                    {cats.map((c) => (
                      <button key={c} className={`sb-cat${tab === 'robberies' && cat === c ? ' on' : ''}`} onClick={() => goCat(c)} title={c}>
                        <i style={{ background: colorOf(c) }} /><span>{c}</span><em>{rows.filter((r) => catOf(r) === c).length}</em>
                      </button>
                    ))}
                  </div>
                  <div className="sb-foot">
                    <div className="sf-row"><span>{t('ready')}</span><b>{ready} / {total}</b></div>
                    <div className="bar"><i className="ok" style={{ width: `${total ? (ready / total) * 100 : 0}%` }} /></div>
                  </div>
                </aside>

                <main className="mn">
                  <IconBtn icon="x" className="danger win-close" title={t('close')} onClick={close} />
                  <AnimatePresence mode="wait" initial={false}>
                    <motion.div key={tab} initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 10 }} transition={{ duration: 0.42, ease: [0.22, 1, 0.36, 1] }}>
                      {page}
                    </motion.div>
                  </AnimatePresence>
                </main>
              </div>

              <div className={`theme-pop${themeOpen ? ' open' : ''}`}>
                <h4>{t('theme')}</h4>
                <div className="theme-grid">
                  {THEMES.map((x) => <button key={x[1]} className={`theme-sw${theme === x[1] ? ' on' : ''}`} onClick={() => setTheme(x[1])} style={{ background: `linear-gradient(135deg,${x[2]},${x[3]})` }}><span>{L['theme_' + x[1]] || x[0]}</span></button>)}
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      <DetailModal r={visible ? sel : null} color={sel ? colorOf(catOf(sel)) : '#0078FF'} t={t} L={L} onClose={() => setSelId(null)} onStart={beginRobbery} />
      {countdown && <Countdown cd={countdown} t={t} L={L} />}
    </>
  );
}