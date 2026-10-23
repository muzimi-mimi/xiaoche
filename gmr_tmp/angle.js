const fs = require('fs');
const ANGLE = [[0,0],[3,33],[6,57.3],[9,50.9],[12,1.5],[15,-46.8],[18,-56.5],[21,-33.7],[24,-4.9],[27,0],[30,57.2],[33,41.3],[36,-12.7],[39,-49.5],[42,-55.4],[45,-1.1],[48,-9.6]];
const r = (x, n = 4) => { const p = 10 ** n; return Math.round(x * p) / p; };
const mean = a => a.reduce((x, y) => x + y, 0) / a.length;

function solve(a) { const n = a.length; for (let c = 0; c < n; c++) { let p = c; for (let q = c + 1; q < n; q++) if (Math.abs(a[q][c]) > Math.abs(a[p][c])) p = q; const t = a[c]; a[c] = a[p]; a[p] = t; for (let q = 0; q < n; q++) { if (q === c) continue; const f = a[q][c] / a[c][c]; for (let k = c; k <= n; k++) a[q][k] -= f * a[c][k]; } } return a.map((x, i) => x[n] / x[i]); }

function fit(data, T, nh) {
  const w = 2 * Math.PI / T, ys = data.map(d => d[1]);
  const cols = [];
  for (let n = 1; n <= nh; n++) { cols.push(data.map(d => Math.sin(n * w * d[0]))); cols.push(data.map(d => Math.cos(n * w * d[0]))); }
  cols.push(data.map(() => 1));
  const k = cols.length, M = [], v = [];
  for (let i = 0; i < k; i++) { const row = []; for (let j = 0; j < k; j++) { let s = 0; for (let n = 0; n < ys.length; n++) s += cols[i][n] * cols[j][n]; row.push(s); } M.push(row); v[i] = cols[i].reduce((a, x, n) => a + x * ys[n], 0); }
  const s = solve(M.map((row, i) => [...row, v[i]]));
  const ev = t => { let y = s[2 * nh]; for (let n = 0; n < nh; n++) y += s[2 * n] * Math.sin((2 * n + 1) * w * t) + s[2 * n + 1] * Math.cos((2 * n + 1) * w * t); return y; };
  const derv = t => { let y = 0; for (let n = 0; n < nh; n++) y += (2 * n + 1) * w * (s[2 * n] * Math.cos((2 * n + 1) * w * t) - s[2 * n + 1] * Math.sin((2 * n + 1) * w * t)); return y; };
  const pred = data.map(d => ev(d[0])), resid = data.map((d, i) => d[1] - pred[i]);
  const ssr = resid.reduce((a, x) => a + x * x, 0), sst = ys.reduce((a, y) => a + (y - mean(ys)) ** 2, 0);
  const A = []; for (let n = 0; n < nh; n++) A.push(Math.hypot(s[2 * n], s[2 * n + 1]));
  let mx = 0, mxT = 0; for (let t = 0; t < T; t += 0.002) { const d = Math.abs(derv(t)); if (d > mx) { mx = d; mxT = t; } }
  let z0 = 0; for (let t = 0; t < T / 2; t += 0.002) { if (ev(t) * ev(t + 0.002) < 0) { z0 = t; break; } }
  return { s, pred, resid, ev, derv, r2: 1 - ssr / sst, rms: Math.sqrt(ssr / data.length), A, off: s[2 * nh], maxResid: Math.max(...resid.map(Math.abs)), maxSlope: mx, maxSlopeAt: mxT % (T / 2), zeroAt: z0 };
}

const T = 24;
console.log('=== 固定 T = 24° 拟合 ===');
for (const nh of [1, 2, 3]) { const f = fit(ANGLE, T, nh); console.log(`全17点 nh=${nh}: R²=${r(f.r2,4)} rms=${r(f.rms,2)} maxRes=${r(f.maxResid,2)} A1=${r(f.A[0],2)}${f.A[1]!==undefined?' A3='+r(f.A[1],2):''}${f.A[2]!==undefined?' A5='+r(f.A[2],2):''} off=${r(f.off,2)}`); }
const keep = ANGLE.filter(d => ![27, 45].includes(d[0]));
for (const nh of [1, 2, 3]) { const f = fit(keep, T, nh); console.log(`剔2点 nh=${nh}: R²=${r(f.r2,4)} rms=${r(f.rms,2)} maxRes=${r(f.maxResid,2)} A1=${r(f.A[0],2)}${f.A[1]!==undefined?' A3='+r(f.A[1],2):''}${f.A[2]!==undefined?' A5='+r(f.A[2],2):''} off=${r(f.off,2)}`); }

const f2 = fit(ANGLE, T, 2), f2k = fit(keep, T, 2);
console.log('\n逐点残差 (T=24, 基波+3次, 全17点):');
ANGLE.forEach((d, i) => console.log(`  ${String(d[0]).padStart(2)}°  U=${String(d[1]).padStart(6)}  fit=${r(f2.pred[i],1).toString().padStart(6)}  res=${r(f2.resid[i],1).toString().padStart(6)}${Math.abs(f2.resid[i]) > 20 ? '  <== 离群' : ''}`));

console.log('\n=== 由剔除后模型给出的特性量 ===');
console.log('最大斜率(灵敏度) =', r(f2k.maxSlope, 2), 'mV/°  @ θ =', r(f2k.maxSlopeAt, 2), '° (+k·12°)');
console.log('上升过零点 θ₀ =', r(f2k.zeroAt, 2), '°');
// 线性区：以过零点为中心，模型值与切线偏差 <= 5% 峰值的半宽
const t0 = f2k.zeroAt, k = f2k.maxSlope, A = f2k.A[0] * 1.0;
let hw = 0;
for (let d = 0; d < T / 4; d += 0.005) { const y = f2k.ev(t0 + d) - f2k.ev(t0); const lin = k * d; if (Math.abs(y - lin) / (A) > 0.05) { hw = d; break; } }
console.log('±5% 峰值线性半宽 =', r(hw, 2), '°  → 线性范围 ±', r(hw, 1), '° (占周期', r(hw / T * 100, 1), '%)');
console.log('若按峰峰值 113.8 mV、齿数 15：单齿角距 24°，一个齿距内可分辨（0.1 mV 表）≈', r(0.1 / f2k.maxSlope, 3), '°');

fs.writeFileSync('angle.json', JSON.stringify({
  T, teeth: 15, extMean: 56.6, ptp: 113.8,
  full_nh1: { r2: r(fit(ANGLE,T,1).r2,4), rms: r(fit(ANGLE,T,1).rms,2) },
  keep_nh1: { r2: r(fit(keep,T,1).r2,4), rms: r(fit(keep,T,1).rms,2), maxRes: r(fit(keep,T,1).maxResid,2), A1: r(fit(keep,T,1).A[0],2), off: r(fit(keep,T,1).off,2) },
  keep_nh2: { r2: r(f2k.r2,4), rms: r(f2k.rms,2), maxRes: r(f2k.maxResid,2), A1: r(f2k.A[0],2), A3: r(f2k.A[1],2), off: r(f2k.off,2), thd: r(f2k.A[1]/f2k.A[0]*100,1) },
  full_nh2: { r2: r(f2.r2,4), rms: r(f2.rms,2), maxRes: r(f2.maxResid,2) },
  maxSlope: r(f2k.maxSlope,2), maxSlopeAt: r(f2k.maxSlopeAt,2), zeroAt: r(f2k.zeroAt,2), linHalfWidth: r(hw,2),
  resid: ANGLE.map((d,i)=>({th:d[0],U:d[1],fit:r(f2.pred[i],1),res:r(f2.resid[i],1)})),
}, null, 1));
