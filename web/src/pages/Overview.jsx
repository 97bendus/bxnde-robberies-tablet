import React from 'react';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { catOf, num, money } from '../utils.js';
import { StatCard } from '../components/Common.jsx';
import { RobberyRow } from '../components/RobberyViews.jsx';

const Tip = ({ active, payload, label, t }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="tip">
      <b>{label}</b>
      {payload.map((p) => <div key={p.dataKey}><i style={{ background: p.color }} />{p.dataKey === 'reward' ? t('reward') : t('police')}: <strong>{p.dataKey === 'reward' ? money(p.value) : num(p.value)}</strong></div>)}
    </div>
  );
};

const SlantTick = ({ x, y, payload }) => {
  const v = String(payload.value);
  return (
    <g transform={`translate(${x - 6},${y + 78})`}>
      <text transform="rotate(-40)" textAnchor="start" fill="#9CA3AF" fontSize={11}>{v.length > 14 ? v.slice(0, 13) + '…' : v}</text>
    </g>
  );
};

export default function Overview({ rows, ready, cd, total, avg, pool, accent, colorOf, t, onOpen }) {
  const data = rows.map((r) => ({ name: r.name, reward: Number(r.reward) || 0, police: Number(r.police) || 0 }));
  const readyRows = rows.filter((r) => r.available);
  const bs = data.length > 8 ? 14 : 24;
  return (
    <>
      <div className="ph"><h2>{t('overview')}</h2><p>{t('subtitle')}</p></div>
      <div className="stats overview-stats">
        <StatCard label={t('ready')} value={ready} suffix={` / ${total}`} icon="check" tone="green" />
        <StatCard label={t('avgPolice')} value={avg} icon="users" tone="purple" />
        <StatCard label={t('reward')} value={pool} cash icon="coin" tone="blue" />
        <StatCard label={t('onCooldown')} value={cd} icon="timer" tone="amber" />
      </div>
      <div className="chart-card">
        <div className="cc-head"><span>{t('operations')}</span><div className="legend"><i style={{ background: accent }} />{t('reward')}<i style={{ background: '#A855F7' }} />{t('police')}</div></div>
        <div className="cc-body">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data} margin={{ top: 6, right: 4, left: 0, bottom: 4 }} barGap={4}>
              <CartesianGrid stroke="rgba(255,255,255,.05)" vertical={false} />
              <XAxis dataKey="name" tick={<SlantTick />} axisLine={false} tickLine={false} interval={0} height={84} />
              <YAxis yAxisId="l" tick={{ fill: '#6B7280', fontSize: 10 }} axisLine={false} tickLine={false} width={50} tickFormatter={(v) => (v >= 1000000 ? `${+(v / 1000000).toFixed(1)}M` : v >= 1000 ? `${+(v / 1000).toFixed(1)}k` : v)} />
              <YAxis yAxisId="r" orientation="right" tick={{ fill: '#6B7280', fontSize: 10 }} axisLine={false} tickLine={false} width={24} allowDecimals={false} />
              <Tooltip cursor={{ fill: 'rgba(255,255,255,.04)' }} content={<Tip t={t} />} />
              <Bar yAxisId="l" dataKey="reward" fill={accent} barSize={bs} radius={[6, 6, 0, 0]} isAnimationActive={false} />
              <Bar yAxisId="r" dataKey="police" fill="#A855F7" barSize={bs} radius={[6, 6, 0, 0]} isAnimationActive={false} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
      <section className="panel overview-ready-panel">
        <div className="pn-title"><span>{t('availableRobberies')}</span><em>{readyRows.length}</em></div>
        <div className="pn-list ready-grid">{readyRows.length ? readyRows.map((r, i) => <RobberyRow key={r.id} r={r} i={i} color={colorOf(catOf(r))} t={t} onOpen={onOpen} />) : <div className="empty">{t('noRobberies')}</div>}</div>
      </section>
    </>
  );
}