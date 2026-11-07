import React from 'react';
import { catOf } from '../utils.js';
import { CooldownRow } from '../components/RobberyViews.jsx';
import { StatCard } from '../components/Common.jsx';
import { Ic } from '../components/Icons.jsx';

export default function Cooldowns({ rows, colorOf, t, onOpen }) {
  const sorted = [...rows].sort((a, b) => (a.available === b.available ? (a.cooldown || 0) - (b.cooldown || 0) : a.available ? 1 : -1));
  return (
    <>
      <div className="ph cooldown-heading"><div><h2>{t('cooldown')}</h2><p>{t('cooldownSubtitle')}</p></div><div className="cooldown-heading-icon"><Ic n="timer" size={22} /></div></div>
      <div className="stats cooldown-stats">
        <StatCard label={t('total')} value={rows.length} icon="grid" tone="blue" />
        <StatCard label={t('ready')} value={rows.filter((r) => r.available).length} icon="check" tone="green" />
        <StatCard label={t('onCooldown')} value={rows.filter((r) => !r.available).length} icon="timer" tone="amber" />
        <StatCard label={t('categories')} value={new Set(rows.map((r) => catOf(r))).size} icon="layers" tone="purple" />
      </div>
      <section className="panel cooldown-panel">
        <div className="pn-title"><span>{t('cooldownStatus')}</span><em>{rows.length}</em></div>
        <div className="cdlist">{sorted.map((r, i) => <CooldownRow key={r.id} r={r} i={i} color={colorOf(catOf(r))} t={t} onOpen={onOpen} />)}</div>
      </section>
    </>
  );
}