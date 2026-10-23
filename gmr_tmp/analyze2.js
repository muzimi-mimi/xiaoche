const fs = require('fs');
const D = require('./analysis.json');
const { GMR, ANGLE, RECORD, CURR, SW } = D;

const r = (x, n = 4) => { const p = 10 ** n; return Math.round(x * p) / p; };
const mean = a => a.reduce((x, y) => x + y, 0) / a.length;

function design(xs, w, nh) { // sin/cos 各 nh 次 + 常数项
  const cols = [];
  for (let n = 1; n <= nh; n++) { cols.push(xs.map(x => Math.sin(n * w * x))); cols.push(xs.map(x => Math.cos(n * w * x))); }
  cols.push(xs.map(() => 1));
  return cols;
}
function lstsq(cols, ys) {
  const k = cols.length;
  const M = Array.from({ length: k }, () => new Array(k).fill(0)), v = new Array(k).fill(0);
  for (let i = 0; i < k; i++) { for (let j = 0; j < k; j++) { let s = 0; for (let n = 0; n < ys.length; n++) s += cols[i][n] * cols[j][n]; M[i][j] = s; } v[i] = cols[i].reduce((a, c, n) => a + c * ys[n], 0); }
  const a = M.map((row, i) => [...row, v[i]]);
  for (let c = 0; c < k; c++) {
    let p = c; for (let rr = c + 1; rr < k; rr++) if (Math.abs(a[rr][c]) > Math.abs(a[p][c])) p = rr;
    if (Math.abs(a[p][c]) < 1e-11) return null;
    [a[c], a[p]] = [a[p], a[c]];
    for (let rr = 0; rr < k; rr++) { if (rr === c) continue; const f = a[rr][c] / a[c][c]; for (let q = c; q <= k; q++) a[rr][q] -= f * a[c][q]; }
  }
  return a.map((row, i) => row[k] / row[i]);
}
function scan(data, nh, Tlo, Thi) {
  const ys = data.map(d => d[1]);
  const sst = ys.reduce((a, y) => a + (y - mean(ys)) ** 2, 0);
  let best = null;
  for (let T = Tlo; T <= Thi; T += 0.01) {
    const s = lstsq(design(data.map(d => d[0]), 2 * Math.PI / T, nh), ys);
    if (!s) continue;
    const ssr = ys.reduce((a, y, n) => a + (y - evalModel(s, data[n][0], 2 * Math.PI / T, nh)) ** 2, 0);
    if (!best || ssr < best.ssr) best = { T, ssr, s };
  }
  best.r2 = 1 - best.ssr / sst;
  best.rms = Math.sqrt(best.ssr / ys.length);
  best.w = 2 * Math.PI / best.T;
  best.harm = [];
  for (let n = 0; n < nh; n++) best.harm.push({ n: 2 * n + 1, A: Math.hypot(best.s[2 * n], best.s[2 * n + 1]), ph: Math.atan2(best.s[2 * n + 1], best.s[2 * n]) });
  best.off = best.s[2 * nh];
  best.A1 = best.harm[0].A;
  best.thd = Math.sqrt(best.harm.slice(1).reduce((a, h) => a + h.A ** 2, 0)) / best.A1 * 100;
  best.pred = data.map(d => evalModel(best.s, d[0], best.w, nh));
  best.resid = data.map((d, i) => d[1] - best.pred[i]);
  return best;
}
function evalModel(s, x, w, nh) { let y = s[2 * nh]; for (let n = 0; n < nh; n++) y += s[2 * n] * Math.sin((2 * n + 1) * w * x) + s[2 * n + 1] * Math.cos((2 * n + 1) * w * x); return y; }

/* ===== 角位移：单正弦 vs 基波+3次 vs +5次 ===== */
const a1 = scan(ANGLE, 1, 15, 40), a2 = scan(ANGLE, 2, 15, 40), a3 = scan(ANGLE, 3, 15, 40);
// 自相关定周期（3° 网格）
const acf = [];
for (let lag = 4; lag <= 14; lag++) {
  const m = ANGLE.map(d => d[1] - mean(ANGLE.map(x => x[1])));
  let num = 0, den = 0;
  for (let i = 0; i + lag < m.length; i++) num += m[i] * m[i + lag];
  for (let i = 0; i < m.length; i++) den += m[i] * m[i];
  acf.push({ lag, steps: lag, deg: lag * 3, rho: r(num / den, 3) });
}
const acfMax = acf.reduce((b, x) => x.rho > b.rho ? x : b, acf[0]);
const pmax = Math.max(...ANGLE.map(d => d[1])), pmin = Math.min(...ANGLE.map(d => d[1]));
// 过零斜率（模型导数最大值）
const dmax = (() => { let m = 0; for (let t = 0; t <= a2.T; t += 0.01) { const h = 0.01; const d = Math.abs((evalModel(a2.s, t + h, a2.w, 2) - evalModel(a2.s, t - h, a2.w, 2)) / (2 * h)); if (d > m) m = d; } return m; })();

/* ===== 巨磁阻：细化 ===== */
const X0 = 1.594, X0up = 1.596;
const pct = x => (x - X0) / X0 * 100;
const at = (k, I) => { const p = GMR[k].pts.find(q => q[0] === I); return p ? p[1] : null; };
const pairs = [];
for (let I = 10; I <= 100; I += 10) pairs.push({ I, down: at('seg1', I), up: at('seg4', I) });
for (let I = -10; I >= -100; I -= 10) pairs.push({ I, down: at('seg2', I), up: at('seg3', I) });
pairs.forEach(p => { p.d = r(p.down - p.up, 4); p.pct = r(Math.abs(p.d) / X0 * 100, 3); });
const maxH = pairs.reduce((b, p) => Math.abs(p.d) > Math.abs(b.d) ? p : b, pairs[0]);
const symErr = [];
for (let I = 10; I <= 100; I += 10) symErr.push({ I, d: r(at('seg1', I) - at('seg2', -I), 4) });
const maxS = symErr.reduce((b, p) => Math.abs(p.d) > Math.abs(b.d) ? p : b, symErr[0]);
const maxMR = Math.max(...[].concat(GMR.seg1.pts, GMR.seg2.pts, GMR.seg3.pts, GMR.seg4.pts).map(p => pct(p[1])));
// 灵敏度 dX/dI 在低场段
const lowSlope = r((at('seg1', 30) - at('seg1', 0)) / 30, 5);
const highSlope = r((at('seg1', 100) - at('seg1', 70)) / 30, 5);

/* ===== 测量电流 ===== */
function linfit(xs, ys) {
  const n = xs.length, sx = mean(xs), sy = mean(ys);
  let sxy = 0, sxx = 0; for (let i = 0; i < n; i++) { sxy += (xs[i] - sx) * (ys[i] - sy); sxx += (xs[i] - sx) ** 2; }
  const slope = sxy / sxx, inter = sy - slope * sx;
  const resid = ys.map((y, i) => y - (slope * xs[i] + inter));
  const ssr = resid.reduce((a, x) => a + x * x, 0), sst = ys.reduce((a, y) => a + (y - sy) ** 2, 0);
  return { slope: r(slope, 6), inter: r(inter, 4), r2: r(1 - ssr / sst, 6), maxdev: r(Math.max(...resid.map(Math.abs)), 4), resid: resid.map(x => r(x, 3)) };
}
const fL = linfit(CURR.I, CURR.low), fH = linfit(CURR.I, CURR.high);
const spanL = Math.max(...CURR.low) - Math.min(...CURR.low), spanH = Math.max(...CURR.high) - Math.min(...CURR.high);

/* ===== 磁记录 ===== */
const vL = RECORD.volts.filter((_, i) => RECORD.bits[i] === 0), vH = RECORD.volts.filter((_, i) => RECORD.bits[i] === 1);
const Vth = (Math.max(...vL) + Math.min(...vH)) / 2;

const out = {
  angle: {
    single: { T: r(a1.T, 3), A: r(a1.A1, 2), r2: r(a1.r2, 4), rms: r(a1.rms, 2), maxResid: r(Math.max(...a1.resid.map(Math.abs)), 2) },
    h2: { T: r(a2.T, 3), A1: r(a2.A1, 2), A3: r(a2.harm[1].A, 2), off: r(a2.off, 2), r2: r(a2.r2, 4), rms: r(a2.rms, 2), thd: r(a2.thd, 1), maxResid: r(Math.max(...a2.resid.map(Math.abs)), 2), teeth: r(360 / a2.T, 2), ptp: r(pmax - pmin, 1) },
    h3: { T: r(a3.T, 3), r2: r(a3.r2, 4), rms: r(a3.rms, 2), A5: r(a3.harm[2].A, 2) },
    acfMax, acf, dmax: r(dmax, 2),
    resid: ANGLE.map((d, i) => ({ th: d[0], U: d[1], fit: r(a2.pred[i], 1), res: r(a2.resid[i], 1) })),
  },
  gmr: { X0, X0up, maxMR: r(maxMR, 2), halfMR: r(maxMR / 2, 2), maxHyst: { I: maxH.I, d: maxH.d, pct: maxH.pct }, maxSym: maxS, lowSlope, highSlope, satRatio: r(lowSlope / highSlope, 1) },
  current: {
    low: { ...fL, span: r(spanL, 1), nl: r(fL.maxdev / spanL * 100, 2), S_mVA: r(fL.slope * 1000, 2), res0: r(CURR.low[3] - 25, 1) },
    high: { ...fH, span: r(spanH, 1), nl: r(fH.maxdev / spanH * 100, 2), S_mVA: r(fH.slope * 1000, 2), res0: r(CURR.high[3] - 150, 1) },
    ratio: r(fH.slope / fL.slope, 3),
  },
  record: { vLmean: r(mean(vL), 4), vLmax: r(Math.max(...vL), 3), vHmean: r(mean(vH), 4), vHmin: r(Math.min(...vH), 3), Vth: r(Vth, 3), diff: r(Math.min(...vH) - Math.max(...vL), 3), mLow: r(Vth - Math.max(...vL), 3), mHigh: r(Math.min(...vH) - Vth, 3) },
};
fs.writeFileSync('analysis2.json', JSON.stringify(out, null, 1));
console.log(JSON.stringify(out, null, 1));
