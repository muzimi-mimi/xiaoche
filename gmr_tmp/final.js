const fs = require('fs');
const r = (x, n = 4) => { const p = 10 ** n; return Math.round(x * p) / p; };
const mean = a => a.reduce((x, y) => x + y, 0) / a.length;

/* ---- 角位移：T=24° 固定，基波最小二乘（迭代求相位） ---- */
const ANGLE = [[0,0],[3,33],[6,57.3],[9,50.9],[12,1.5],[15,-46.8],[18,-56.5],[21,-33.7],[24,-4.9],[27,0],[30,57.2],[33,41.3],[36,-12.7],[39,-49.5],[42,-55.4],[45,-1.1],[48,-9.6]];
const T = 24, w = 2 * Math.PI / T;
function sineFixed(data) {
  const ys = data.map(d => d[1]);
  const S = data.map(d => Math.sin(w * d[0])), C = data.map(d => Math.cos(w * d[0])), O = data.map(() => 1);
  const k = [S, C, O], M = [], v = [];
  for (let i = 0; i < 3; i++) { M.push(k.map(cj => cj.reduce((a, x, n) => a + x * k[i][n], 0))); v[i] = k[i].reduce((a, x, n) => a + x * ys[n], 0); }
  const a = M.map((row, i) => [...row, v[i]]);
  for (let c = 0; c < 3; c++) { let p = c; for (let q = c + 1; q < 3; q++) if (Math.abs(a[q][c]) > Math.abs(a[p][c])) p = q; const t = a[c]; a[c] = a[p]; a[p] = t; for (let q = 0; q < 3; q++) { if (q === c) continue; const f = a[q][c] / a[c][c]; for (let x = c; x <= 3; x++) a[q][x] -= f * a[c][x]; } }
  const [bs, bc, c0] = a.map((x, i) => x[3] / x[i]);
  const A = Math.hypot(bs, bc), ph = Math.atan2(bc, bs), off = c0;
  const ev = t => off + A * Math.sin(w * t + ph);
  const resid = data.map(d => d[1] - ev(d[0]));
  const ssr = resid.reduce((x, y) => x + y * y, 0), sst = ys.reduce((x, y) => x + (y - mean(ys)) ** 2, 0);
  return { A: r(A, 2), ph: r(ph, 4), phDeg: r(ph * 180 / Math.PI, 2), off: r(off, 2), r2: r(1 - ssr / sst, 4), rms: r(Math.sqrt(ssr / data.length), 2), maxRes: r(Math.max(...resid.map(Math.abs)), 2), resid: resid.map(x => r(x, 1)), ev, evA: A, evPh: ph, evOff: off };
}
const all = sineFixed(ANGLE);
const OUT = [27, 45];
const keep = ANGLE.filter(d => !OUT.includes(d[0]));
const kp = sineFixed(keep);
const S_max = kp.evA * w;                        // 过零最大斜率 mV/°
const linHalf = Math.asin(Math.min(1, 0.05 + 0)) ; // placeholder
// 线性半宽：|sin x - x| = 0.05 数值解
let x5 = 0.6; for (let i = 0; i < 200; i++) x5 = x5 - (Math.sin(x5) - x5 + 0.05) / (Math.cos(x5) - 1);
const linHalfDeg = r(x5 / w, 2);
const resPractical = r(kp.rms / S_max, 2);
const resIdeal = r(0.1 / S_max, 4);

console.log('角位移 T=24° 固定基波拟合');
console.log('  全17点   :', JSON.stringify({ A: all.A, off: all.off, r2: all.r2, rms: all.rms, maxRes: all.maxRes }));
console.log('  剔除27/45:', JSON.stringify({ A: kp.A, off: kp.off, r2: kp.r2, rms: kp.rms, maxRes: kp.maxRes }));
console.log('  模型 U =', kp.off, '+', kp.A, '·sin( 2πθ/24 +', kp.ph, 'rad )  =', kp.off, '+', kp.A, '·sin[ 15θ', kp.phDeg, '° ]');
console.log('  最大灵敏度 =', r(S_max, 2), 'mV/°;  ±5%满幅线性半宽 =', linHalfDeg, '°;  实际分辨率(rms) =', resPractical, '°;  0.1mV 表理论 =', resIdeal, '°');
console.log('  离群点模型预测: θ=27° →', r(kp.ev(27), 1), 'mV (实测 0);  θ=45° →', r(kp.ev(45), 1), 'mV (实测 -1.1)');
const zc = []; for (let t = 0; t < 48; t += 0.001) if (Math.abs(kp.ev(t)) < 0.005) { zc.push(r(t, 2)); t += 5; }
console.log('  模型过零点:', zc.join(', '));

/* ---- 巨磁阻 ---- */
const G = require('./analysis.json').GMR;
const X0 = 1.594;
const at = (k, I) => G[k].pts.find(q => q[0] === I)[1];
const pairs = [];
for (let I = 10; I <= 100; I += 10) pairs.push({ I, down: at('seg1', I), up: at('seg4', I) });
for (let I = -10; I >= -100; I -= 10) pairs.push({ I, down: at('seg2', I), up: at('seg3', I) });
pairs.forEach(p => { p.d = r(p.down - p.up, 4); p.pct = r(Math.abs(p.d) / X0 * 100, 3); });
const maxH = pairs.reduce((b, p) => Math.abs(p.d) > Math.abs(b.d) ? p : b);
const sym = []; for (let I = 10; I <= 100; I += 10) sym.push({ I, d: r(at('seg1', I) - at('seg2', -I), 4) });
const maxS = sym.reduce((b, p) => Math.abs(p.d) > Math.abs(b.d) ? p : b);
const pct = x => (x - X0) / X0 * 100;
const maxMR = Math.max(...[].concat(...Object.values(G).map(s => s.pts.map(p => pct(p[1])))));
const seg = k => G[k].pts.map(([I, x]) => [I, r(pct(x), 2)]);
const mrT = { seg1: seg('seg1'), seg2: seg('seg2'), seg3: seg('seg3'), seg4: seg('seg4') };
let Ihalf = null;
for (let i = 1; i < G.seg1.pts.length; i++) { const [I1, x1] = G.seg1.pts[i - 1], [I2, x2] = G.seg1.pts[i]; const m1 = pct(x1), m2 = pct(x2); if ((m1 - maxMR / 2) * (m2 - maxMR / 2) <= 0) { Ihalf = r(I2 + (maxMR / 2 - m2) * (I1 - I2) / (m1 - m2), 1); break; } }
const s30 = r((at('seg1', 30) - at('seg1', 0)) / 30, 5), s100 = r((at('seg1', 100) - at('seg1', 70)) / 30, 5);
console.log('\n巨磁阻: maxΔR/R0 =', r(maxMR, 2), '%  半饱和 I =', Ihalf, 'mA  最大磁滞 =', maxH.d, '(', maxH.pct, '%FS ) @ I =', maxH.I, '  最大不对称 =', maxS.d, '@', maxS.I);
console.log('  低场斜率', s30, ' 高场斜率', s100, ' 比值', r(s30 / s100, 1));

/* ---- 测量电流 ---- */
const CURR = { I: [300,200,100,0,-100,-200,-300], low: [30.4,29,27.5,26.1,24.5,22.8,21.1], high: [134.7,132.9,131.2,129.7,127.7,125.6,123.7] };
function linfit(xs, ys) { const n = xs.length, sx = mean(xs), sy = mean(ys); let sxy = 0, sxx = 0; for (let i = 0; i < n; i++) { sxy += (xs[i] - sx) * (ys[i] - sy); sxx += (xs[i] - sx) ** 2; } const b = sxy / sxx, a0 = sy - b * sx; const res = ys.map((y, i) => y - (b * xs[i] + a0)); const ssr = res.reduce((x, y) => x + y * y, 0), sst = ys.reduce((x, y) => x + (y - sy) ** 2, 0); return { S: r(b, 6), U0: r(a0, 3), r2: r(1 - ssr / sst, 6), rms: r(Math.sqrt(ssr / n), 4), maxdev: r(Math.max(...res.map(Math.abs)), 4), res: res.map(x => r(x, 3)) }; }
const fL = linfit(CURR.I, CURR.low), fH = linfit(CURR.I, CURR.high);
const spL = Math.max(...CURR.low) - Math.min(...CURR.low), spH = Math.max(...CURR.high) - Math.min(...CURR.high);
console.log('\n测量电流 低偏置:', JSON.stringify(fL), '非线性度', r(fL.maxdev / spL * 100, 2), '%FS');
console.log('测量电流 适当偏置:', JSON.stringify(fH), '非线性度', r(fH.maxdev / spH * 100, 2), '%FS');
console.log('灵敏度比 =', r(fH.S / fL.S, 3), ' S低=', r(fL.S * 1000, 2), 'uV/mA  S高=', r(fH.S * 1000, 2), 'uV/mA');

const out = {
  angle: { T, teeth: 15, extMean: 56.6, ptp: 113.8, all, keep: { A: kp.A, off: kp.off, ph: kp.ph, phDeg: kp.phDeg, r2: kp.r2, rms: kp.rms, maxRes: kp.maxRes }, S_max: r(S_max, 2), linHalfDeg, resPractical, resIdeal, pred27: r(kp.ev(27), 1), pred45: r(kp.ev(45), 1), zc, residAll: all.resid },
  gmr: { X0, maxMR: r(maxMR, 2), Ihalf, maxH, maxS, s30, s100, mrT, pairs },
  current: { low: { ...fL, span: r(spL, 1), nl: r(fL.maxdev / spL * 100, 2) }, high: { ...fH, span: r(spH, 1), nl: r(fH.maxdev / spH * 100, 2) } },
};
fs.writeFileSync('final.json', JSON.stringify(out, null, 1));
