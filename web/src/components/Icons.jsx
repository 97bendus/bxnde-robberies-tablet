import React from 'react';

const P = {
  shield: <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />,
  dash: <><rect x="3" y="3" width="7" height="9" rx="1.5" /><rect x="14" y="3" width="7" height="5" rx="1.5" /><rect x="14" y="12" width="7" height="9" rx="1.5" /><rect x="3" y="16" width="7" height="5" rx="1.5" /></>,
  grid: <><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></>,
  timer: <><circle cx="12" cy="13" r="8" /><path d="M12 9v4l2.5 2M9 2h6" /></>,
  refresh: <><path d="M21 12a9 9 0 0 0-15-6.7L3 8" /><path d="M3 3v5h5" /><path d="M3 12a9 9 0 0 0 15 6.7L21 16" /><path d="M16 16h5v5" /></>,
  x: <path d="M18 6 6 18M6 6l12 12" />,
  users: <><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.9M16 3.1a4 4 0 0 1 0 7.8" /></>,
  coin: <><circle cx="12" cy="12" r="9" /><path d="M14.5 9.5C14 8.7 13.2 8.3 12 8.3c-1.5 0-2.5.8-2.5 1.7S10.5 11.5 12 12s2.5.9 2.5 1.8-1 1.7-2.5 1.7c-1.2 0-2-.4-2.5-1.2M12 6.5v1.8m0 7.2v2" /></>,
  clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
  box: <><path d="M21 8 12 3 3 8v8l9 5 9-5z" /><path d="m3 8 9 5 9-5M12 13v8" /></>,
  lock: <><rect x="4" y="11" width="16" height="10" rx="2" /><path d="M8 11V7a4 4 0 0 1 8 0v4" /></>,
  play: <path d="m6 4 14 8-14 8z" />,
  bank: <path d="m3 9 9-6 9 6M5 9v9m4-9v9m6-9v9m4-9v9M3 21h18" />,
  store: <path d="M4 9h16l-1-5H5zM5 9v11h14V9M9 20v-6h6v6" />,
  truck: <><path d="M2 5h12v11H2zM14 9h4l4 4v3h-8" /><circle cx="7" cy="18" r="2" /><circle cx="17" cy="18" r="2" /></>,
  gem: <><path d="M6 3h12l4 6-10 12L2 9z" /><path d="M2 9h20M10 3 8 9l4 12 4-12-2-6" /></>,
  search: <><circle cx="11" cy="11" r="7" /><path d="m21 21-4.3-4.3" /></>,
  check: <path d="m5 12 5 5L20 7" />,
  down: <path d="m6 9 6 6 6-6" />,
  bolt: <path d="M13 2 4 14h7l-1 8 9-12h-7z" />,
  palette: <><circle cx="13.5" cy="6.5" r="1" /><circle cx="17.5" cy="10.5" r="1" /><circle cx="8.5" cy="7.5" r="1" /><circle cx="6.5" cy="12.5" r="1" /><path d="M12 2a10 10 0 1 0 0 20c1.1 0 2-.9 2-2 0-.5-.2-1-.5-1.3-.3-.4-.5-.8-.5-1.3 0-1.1.9-2 2-2h2.4c3 0 5.6-2.5 5.6-5.5C23 6 18 2 12 2z" /></>,
  filter: <path d="M3 5h18l-7 8v6l-4 2v-8z" />,
  info: <><circle cx="12" cy="12" r="9" /><path d="M12 11v5M12 8h.01" /></>
};

export const Ic = ({ n, size = 18, className = '' }) => (
  <svg className={`ic ${className}`} width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
    {P[n] || P.lock}
  </svg>
);