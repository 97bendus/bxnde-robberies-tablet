import React from 'react';
import { createPortal } from 'react-dom';
import { AnimatePresence, motion } from 'framer-motion';
import { catOf, fmtDur, fmtTime, money, cdPct } from '../utils.js';
import { Ic } from './Icons.jsx';
import { Badge, Btn, IconBtn, Media } from './Common.jsx';

const stateBadge = (r, t) => r.available
  ? <Badge tone="green">{t('ready')}</Badge>
  : <Badge tone="gray">{fmtDur(r.cooldown)}</Badge>;

export function RobberyRow({ r, color, t, onOpen, i = 0 }) {
  return (
    <motion.div className="ecard" initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.28, ease: [0.22, 1, 0.36, 1], delay: Math.min(i, 10) * 0.025 }}>
      <div className="avatar" style={{ '--c': color }}>{r.image ? <Media r={r} /> : String(r.name || '?').charAt(0)}</div>
      <div className="ec-main">
        <div className="ec-name">{r.name}</div>
        <div className="ec-badges"><Badge tone="blue" style={{ '--c': color }}>{catOf(r)}</Badge>{stateBadge(r, t)}</div>
        <div className="ec-sub">{t('reward')}: {money(r.reward)}</div>
      </div>
      <IconBtn icon="info" title={t('details')} onClick={() => onOpen(r.id)} />
    </motion.div>
  );
}

export function RobberyCard({ r, color, t, onOpen, i = 0 }) {
  return (
    <motion.button
      className={`rcard${r.available ? '' : ' locked'}`}
      style={{ '--c': color }}
      initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1], delay: Math.min(i, 12) * 0.025 }}
      whileHover={{ y: -3 }} whileTap={{ scale: 0.985 }}
      onClick={() => onOpen(r.id)}
    >
      <div className="rc-img">
        <Media r={r} />
        <span className="rc-shade" />
        <span className="rc-cat"><i />{catOf(r)}</span>
        <span className="rc-state">{stateBadge(r, t)}</span>
      </div>
      <div className="rc-body">
        <div className="rc-name">{r.name}</div>
        <div className="rc-desc">{r.description || t('noDesc')}</div>
        <div className="rc-meta">
          <span><Ic n="users" size={13} />{r.police ?? '—'}</span>
          <span><Ic n="coin" size={13} />{money(r.reward)}</span>
          <span><Ic n="clock" size={13} />{fmtTime(r.estimatedTime)}</span>
        </div>
      </div>
    </motion.button>
  );
}

export function CooldownRow({ r, color, t, onOpen, i = 0 }) {
  const pct = cdPct(r);
  return (
    <motion.div className="cdrow" initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.28, ease: [0.22, 1, 0.36, 1], delay: Math.min(i, 12) * 0.02 }}>
      <div className="avatar" style={{ '--c': color }}>{r.image ? <Media r={r} /> : String(r.name || '?').charAt(0)}</div>
      <div className="cd-main">
        <div className="cd-top"><b>{r.name}</b><span className={r.available ? 'ok' : ''}>{r.available ? t('ready') : fmtDur(r.cooldown)}</span></div>
        <div className="bar"><motion.i initial={{ width: 0 }} animate={{ width: `${pct}%` }} transition={{ duration: 0.5, ease: 'easeOut' }} className={r.available ? 'ok' : ''} /></div>
      </div>
      <IconBtn icon="info" title={t('details')} onClick={() => onOpen(r.id)} />
    </motion.div>
  );
}

export function DetailModal({ r, color, t, L, onClose, onStart }) {
  return createPortal(
    <AnimatePresence>
      {r && (
        <motion.div className="ov" key="ov" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.32, ease: [0.22, 1, 0.36, 1] }} onMouseDown={(e) => { if (e.target === e.currentTarget) onClose(); }}>
          <motion.div className="modal" style={{ '--c': color }} initial={{ opacity: 0, scale: 0.9, y: 20 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.9, y: 20 }} transition={{ duration: 0.36, ease: [0.22, 1, 0.36, 1] }}>
            <div className="md-head">
              <div><h3>{r.name}</h3><p>{catOf(r)} · {r.available ? t('ready') : t('unavailable')}</p></div>
              <IconBtn icon="x" onClick={onClose} title={t('close')} />
            </div>
            <div className="md-banner"><Media r={r} /><span className="rc-shade" /><span className="md-state">{stateBadge(r, t)}</span></div>
            <p className="md-desc">{r.description || t('noDesc')}</p>
            <div className="md-stats">
              <div><small>{t('police')}</small><b><Ic n="users" size={14} />{r.police ?? '—'}</b></div>
              <div><small>{t('reward')}</small><b className="amber"><Ic n="coin" size={14} />{money(r.reward)}</b></div>
              <div><small>{t('estimatedTime')}</small><b><Ic n="clock" size={14} />{fmtTime(r.estimatedTime, L)}</b></div>
            </div>
            <div className="md-cd">
              <div className="cd-top"><b>{t('cooldown')}</b><span className={r.available ? 'ok' : ''}>{r.available ? t('ready') : fmtDur(r.cooldown)}</span></div>
              <div className="bar"><i className={r.available ? 'ok' : ''} style={{ width: `${cdPct(r)}%` }} /></div>
            </div>
            <div className="md-foot">
              <Btn variant="ghost" onClick={onClose}>{t('back')}</Btn>
              <Btn variant="primary" disabled={!r.available} onClick={() => onStart(r)}><Ic n="play" size={14} />{t('start')}</Btn>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>,
    document.body
  );
}

export function Countdown({ cd, t, L }) {
  const go = cd.phase === 'go';
  const hot = cd.number <= 2 && cd.phase === 'count';
  const total = Math.max(1, cd.steps || 5);
  const done = go ? total : total - cd.number;
  const stepMs = cd.stepMs || 1000;
  const key = `${cd.phase}-${cd.number}`;
  const r = cd.robbery || {};
  const label = go ? t('countdownGo') : String(cd.number);
  return (
    <div id="countdown" className={`on cdm${hot ? ' hot' : ''}${go ? ' go' : ''}`}>
      <div className="cdm-bg" />
      <div key={key} className={`cdm-num ${go ? 'go' : 'pop'}`} style={{ animationDuration: go ? undefined : `${stepMs}ms` }}>{label}</div>
      <div className="cdm-panel">
        <div className="cdm-top"><span className="cdm-dot" />{t('countdownTitle')}</div>
        <div className="cdm-name">{r.name}</div>
        <div className="cdm-segs">
          {Array.from({ length: total }, (_, i) => <i key={i} className={i < done ? 'on' : (i === done && !go ? 'cur' : '')} />)}
        </div>
        <div className="cdm-stats">
          <div><small>{t('police')}</small><b>{r.police ?? '—'}</b></div>
          <div><small>{t('reward')}</small><b>{money(r.reward)}</b></div>
          <div><small>{t('estimatedTime')}</small><b>{fmtTime(r.estimatedTime, L)}</b></div>
        </div>
      </div>
      <div className="cdm-hint">{t('cancelHint')}</div>
    </div>
  );
}
