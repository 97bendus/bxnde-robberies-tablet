import React from 'react';
import { catOf } from '../utils.js';
import { Dropdown, Toggle } from '../components/Common.jsx';
import { Ic } from '../components/Icons.jsx';
import { RobberyCard } from '../components/RobberyViews.jsx';

export default function Robberies({ list, rows, cats, cat, setCat, q, setQ, sort, setSort, only, setOnly, colorOf, t, onOpen }) {
  const catOpts = [{ value: 'all', label: t('all'), count: rows.length }, ...cats.map((c) => ({ value: c, label: c, dot: colorOf(c), count: rows.filter((r) => catOf(r) === c).length }))];
  const sortOpts = [
    { value: 'name', label: t('sortName') }, { value: 'reward', label: t('reward') },
    { value: 'police', label: t('police') }, { value: 'time', label: t('estimatedTime') }
  ];
  return (
    <>
      <div className="ph-row">
        <div className="ph"><h2>{t('operations')}</h2><p>{t('dashSub')}</p></div>
        <div className="controls">
          <Dropdown value={cat} options={catOpts} onChange={setCat} prefix={t('category') + ':'} width={200} />
          <Dropdown value={sort} options={sortOpts} onChange={setSort} prefix={t('sortBy') + ':'} width={200} />
          <Toggle checked={only} onChange={setOnly} label={t('availableOnly')} />
          <span className="count">{list.length} / {rows.length}</span>
        </div>
      </div>
      {list.length
        ? <div className="rgrid">{list.map((r, i) => <RobberyCard key={r.id} r={r} i={i} color={colorOf(catOf(r))} t={t} onOpen={onOpen} />)}</div>
        : <div className="empty big">{t('noRobberies')}</div>}
    </>
  );
}