import React, { useEffect, useRef, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { catOf, iconOf, num, money } from '../utils.js';
import { Ic } from './Icons.jsx';

export function Clock() {
  const [d, setD] = useState(new Date());
  useEffect(() => { const i = setInterval(() => setD(new Date()), 1000); return () => clearInterval(i); }, []);
  const p = (n) => String(n).padStart(2, '0');
  return <>{`${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`}</>;
}

export function Count({ value, prefix = '', cash = false }) {
  const n = Number(value);
  const [v, setV] = useState(Number.isFinite(n) ? 0 : value);
  useEffect(() => {
    if (!Number.isFinite(n)) { setV(value); return; }
    let raf; const t0 = performance.now();
    const f = (now) => { const p = Math.min(1, (now - t0) / 700); setV(Math.round(n * (1 - Math.pow(1 - p, 3)))); if (p < 1) raf = requestAnimationFrame(f); };
    raf = requestAnimationFrame(f);
    return () => cancelAnimationFrame(raf);
  }, [value]);
  return <>{Number.isFinite(n) ? (cash ? money(v) : prefix + num(v)) : v}</>;
}

export function Media({ r, className = '' }) {
  const [bad, setBad] = useState(false);
  useEffect(() => setBad(false), [r.image]);
  return r.image && !bad
    ? <img className={className} src={r.image} alt="" loading="lazy" onError={() => setBad(true)} />
    : <div className={`media-fallback ${className}`}><Ic n={iconOf(catOf(r))} size={30} /></div>;
}

export const Btn = ({ variant = 'ghost', className = '', children, ...p }) => (
  <motion.button whileHover={p.disabled ? undefined : { scale: 1.01 }} whileTap={p.disabled ? undefined : { scale: 0.985 }} className={`btn ${variant} ${className}`} {...p}>{children}</motion.button>
);

export const IconBtn = ({ icon, className = '', ...p }) => (
  <motion.button whileHover={{ scale: 1.025 }} whileTap={{ scale: 0.985 }} className={`ibtn ${className}`} {...p}><Ic n={icon} size={16} /></motion.button>
);

export const Badge = ({ tone = 'blue', children, style }) => <span className={`bdg ${tone}`} style={style}>{children}</span>;

export function Toggle({ checked, onChange, label }) {
  return (
    <button className={`toggle${checked ? ' on' : ''}`} onClick={() => onChange(!checked)} type="button">
      <span className="track"><i /></span>{label}
    </button>
  );
}

export function Dropdown({ value, options, onChange, prefix, width }) {
  const [open, setOpen] = useState(false);
  const ref = useRef(null);
  useEffect(() => {
    const f = (e) => { if (ref.current && !ref.current.contains(e.target)) setOpen(false); };
    document.addEventListener('mousedown', f);
    return () => document.removeEventListener('mousedown', f);
  }, []);
  const cur = options.find((o) => o.value === value) || options[0];
  return (
    <div className="dd" ref={ref} style={{ width }}>
      <button type="button" className={`dd-btn${open ? ' open' : ''}`} onClick={() => setOpen((o) => !o)}>
        {prefix && <span className="dd-prefix">{prefix}</span>}
        <span className="dd-val">{cur?.label}</span>
        <Ic n="down" size={14} className="dd-chev" />
      </button>
      <AnimatePresence>
        {open && (
          <motion.div className="dd-list" initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -6 }} transition={{ duration: 0.24, ease: [0.22, 1, 0.36, 1] }}>
            {options.map((o) => (
              <button type="button" key={o.value} className={`dd-item${o.value === value ? ' on' : ''}`} onClick={() => { onChange(o.value); setOpen(false); }}>
                {o.dot && <i style={{ background: o.dot }} />}{o.label}{o.count != null && <em>{o.count}</em>}
              </button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export const StatCard = ({ label, value, icon, tone = 'blue', prefix = '', suffix = '', cash = false }) => (
  <motion.div className="stat" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.34, ease: [0.22, 1, 0.36, 1] }}>
    <div className="stat-top"><span className="stat-label">{label}</span><span className={`stat-ic ${tone}`}><Ic n={icon} size={16} /></span></div>
    <div className="stat-value"><Count value={value} prefix={prefix} cash={cash} />{suffix}</div>
  </motion.div>
);