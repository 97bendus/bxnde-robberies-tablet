export const THEMES = [
  ['Quasar blue', 'blue', '#168CFF', '#9564F5'],
  ['Night violet', 'violet', '#A855F7', '#7fd4ff'],
  ['Emerald', 'emerald', '#10B981', '#5eead4'],
  ['Crimson', 'crimson', '#EF4444', '#fbbf24'],
  ['Orange', 'orange', '#F97316', '#fbbf24'],
  ['Gold', 'gold', '#EAB308', '#fb923c'],
  ['Pink', 'pink', '#EC4899', '#c4a1ff'],
  ['Teal', 'teal', '#14B8A6', '#7fd4ff'],
  ['Lime', 'lime', '#84CC16', '#5eead4'],
  ['Indigo', 'indigo', '#6366F1', '#f9a8d4'],
  ['Steel', 'steel', '#94A3B8', '#cbd5e1'],
  ['Magenta', 'magenta', '#D946EF', '#fb7185']
];

export const PALETTE = ['#168CFF', '#168CFF', '#168CFF', '#168CFF', '#168CFF', '#168CFF', '#168CFF', '#168CFF'];

const ICONS = [['bank', 'bank'], ['jewel', 'gem'], ['gem', 'gem'], ['store', 'store'], ['shop', 'store'], ['market', 'store'], ['truck', 'truck'], ['van', 'truck'], ['convoy', 'truck']];
export const iconOf = (c) => {
  c = String(c || '').toLowerCase();
  for (const [k, v] of ICONS) if (c.includes(k)) return v;
  return 'lock';
};

export const hexToRgb = (hex) => {
  const h = String(hex).replace('#', '');
  const n = parseInt(h.length === 3 ? h.split('').map((x) => x + x).join('') : h, 16);
  return `${(n >> 16) & 255},${(n >> 8) & 255},${n & 255}`;
};

let LOC = {};
export const setLocale = (L) => { LOC = L || {}; };
export const num = (n) => Number(n || 0).toLocaleString(LOC.numberLocale || undefined);
export const money = (n) => {
  const sym = LOC.currencySymbol ?? '$';
  const v = num(n);
  return LOC.currencyPosition === 'after' ? `${v} ${sym}` : `${sym}${v}`;
};
export const catOf = (r) => r.category || 'general';

export const fmtDur = (s) => {
  s = Math.max(0, Math.ceil(Number(s) || 0));
  if (!s) return '—';
  const h = Math.floor(s / 3600), m = Math.ceil((s % 3600) / 60);
  const hl = LOC.timeHour || 'h', ml = LOC.timeMinute || 'min';
  return h ? `${h} ${hl} ${m} ${ml}` : `${m} ${ml}`;
};

export const fmtTime = (v, L = LOC) => {
  if (!L || !Object.keys(L).length) L = LOC;
  v = Math.max(0, Math.round(Number(v) || 0));
  if (!v) return '—';
  const h = Math.floor(v / 3600), m = Math.floor((v % 3600) / 60), s = v % 60;
  const parts = [];
  if (h) parts.push(`${h} ${L.timeHour || 'h'}`);
  if (m) parts.push(`${m} ${L.timeMinute || 'min'}`);
  if (s && !h) parts.push(`${s} ${L.timeSecond || 'sec'}`);
  return parts.join(' ');
};

export const cdPct = (r) => (r.available ? 100 : Math.max(6, 100 - Math.min(94, (Number(r.cooldown) || 0) / 36)));

export const post = (name, body = {}) => {
  const r = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bxnde-robberies-tablet';
  fetch(`https://${r}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body)
  }).catch(() => {});
};

export const DEMO_L = {
  title: 'Robberies Tablet', subtitle: 'OPERATIONS CENTER // SECURE CONNECTION', online: 'SYSTEM ONLINE',
  ready: 'Ready', onCooldown: 'On cooldown', total: 'Total', avgPolice: 'Avg. police', availableOnly: 'Available only',
  categories: 'Categories', all: 'All', search: 'Search robberies...', theme: 'Theme', refresh: 'Refresh', close: 'Close',
  noRobberies: 'No robberies found.', noDesc: 'Review the operation details, then start it once every requirement is met.',
  start: 'START OPERATION', countdownTitle: 'Robbery starting', countdownGo: 'GO!', cancelHint: 'DEMO MODE',
  police: 'Required police', reward: 'Estimated reward', estimatedTime: 'Estimated time', items: 'Required items',
  security: 'Security systems', cooldown: 'Cooldown remaining', unavailable: 'UNAVAILABLE', noRequirements: 'No requirements configured',
  cooldowns: 'Cooldowns', sortBy: 'Sort', sortName: 'Name', details: 'Details', back: 'Back', overview: 'Overview', operations: 'Operations', category: 'Category', dashSub: 'Browse and start available operations', cooldownSubtitle: 'Track operation availability and remaining wait times in one place.', cooldownStatus: 'Robbery status', timeHour: 'hr', timeMinute: 'min', timeSecond: 'sec'
};

export const DEMO_ROWS = [
  { id: 'd1', name: 'Fleeca Bank', category: 'Bank', description: 'Quiet branch with a reinforced vault and a single security guard.', image: 'build/images/fleeca.png', available: true, cooldown: 0, police: 4, reward: 12500, estimatedTime: 900, items: [{ name: 'Thermite', count: 1 }, { name: 'Laptop', count: 1 }], security: ['Alarm panel', 'Vault door'] },
  { id: 'd2', name: 'Pacific Standard', category: 'Bank', description: 'The biggest score in the city. Heavy security and a long response.', image: 'build/images/pacific.png', available: false, cooldown: 1800, police: 8, reward: 50000, estimatedTime: 1800, items: [{ name: 'Thermite', count: 3 }, { name: 'Hacking device', count: 1 }], security: ['Alarm panel', 'Cameras', 'Vault door'] },
  { id: 'd3', name: 'Vangelico Jewelry', category: 'Store', description: 'Smash the cases, grab the gems, get out before the alarm brings help.', image: 'build/images/jewelry.png', available: true, cooldown: 0, police: 3, reward: 8500, estimatedTime: 600, items: [{ name: 'Glass cutter', count: 1 }], security: ['Alarm panel'] },
  { id: 'd4', name: 'Cash Exchange', category: 'Store', description: 'Back-room cash handling with a keypad lock.', image: 'build/images/cashexchange.png', available: true, cooldown: 0, police: 2, reward: 6200, estimatedTime: 480, items: [{ name: 'Lockpick', count: 2 }], security: ['Keypad'] },
  { id: 'd5', name: 'Cargo Truck', category: 'Truck', description: 'Intercept an armoured truck on its route.', image: 'build/images/cargo.png', available: false, cooldown: 640, police: 5, reward: 18000, estimatedTime: 1200, items: [{ name: 'Explosives', count: 1 }], security: ['Armour plating'] },
  { id: 'd6', name: 'Casino Vault', category: 'Casino', description: 'High-stakes heist on the casino cash room.', image: 'build/images/casino.png', available: true, cooldown: 0, police: 6, reward: 32000, estimatedTime: 1500, items: [{ name: 'Hacking device', count: 1 }], security: ['Cameras', 'Guards', 'Vault door'] },
  { id: 'd7', name: 'Maze Bank', category: 'Bank', description: 'Downtown tower with a rooftop approach.', image: 'build/images/mazebank.png', available: false, cooldown: 3200, police: 7, reward: 41000, estimatedTime: 1700, items: [], security: [] },
  { id: 'd8', name: 'Laundromat', category: 'Store', description: 'Small-time cash laundering front.', image: 'build/images/laundromat.png', available: true, cooldown: 0, police: 1, reward: 3200, estimatedTime: 300, items: [], security: [] }
];
