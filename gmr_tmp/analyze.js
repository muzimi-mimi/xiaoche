const fs = require('fs');

/* ---------- 原始数据（严格取自表格已填写单元格） ---------- */
const GMR = {
  seg1: { name: '正向测量 100→0（下降段）', dir: 'down', pts: [[100,1.816],[90,1.815],[80,1.815],[70,1.813],[60,1.807],[50,1.781],[40,1.741],[30,1.699],[20,1.659],[10,1.625],[0,1.594]] },
  seg2: { name: '反向测量 0→-100（下降段）', dir: 'down', pts: [[0,1.594],[-10,1.613],[-20,1.646],[-30,1.682],[-40,1.726],[-50,1.764],[-60,1.793],[-70,1.804],[-80,1.809],[-90,1.811],[-100,1.813]] },
  seg3: { name: '回程 -100→0（上升段）', dir: 'up', pts: [[-100,1.813],[-90,1.812],[-80,1.811],[-70,1.809],[-60,1.807],[-50,1.777],[-40,1.737],[-30,1.700],[-20,1.660],[-10,1.627],[0,1.596]] },
  seg4: { name: '回程 0→100（上升段）', dir: 'up', pts: [[10,1.616],[20,1.648],[30,1.682],[40,1.722],[50,1.758],[60,1.789],[70,1.803],[80,1.809],[90,1.812],[100,1.814]] },
};
const ANGLE = [[0,0],[3,33],[6,57.3],[9,50.9],[12,1.5],[15,-46.8],[18,-56.5],[21,-33.7],[24,-4.9],[27,0],[30,57.2],[33,41.3],[36,-12.7],[39,-49.5],[42,-55.4],[45,-1.1],[48,-9.6]];
const RECORD = { bits: [0,0,1,1,0,0,1,1], volts: [0.003,0.002,1.928,1.928,0.003,0.003,1.928,1.928] };
const CURR = {
  I: [300,200,100,0,-100,-200,-300],
  low: [30.4,29,27.5,26.1,24.5,22.8,21.1],
  high: [134.7,132.9,131.2,129.7,127.7,125.6,123.7],
};
const SW = { release_pos: 15.4, operate_neg: 18.5, release_neg: 16.7, operate_pos: 19.1 };

/* ---------- 拟合工具 ---------- */
function linfit(xs, ys) {
  const n = xs.length;
  const sx = xs.reduce((a, b) => a + b, 0), sy = ys.reduce((a, b) => a + b, 0);
  const sxx = xs.reduce((a, x) => a + x * x, 0), sxy = xs.reduce((a, x, i) => a + x * ys[i], 0);
  const k = (n * sxx - sx * sx);
  const slope = (n * sxy - sx * sy) / k, inter = (sy - slope * sx) / n;
  const pred = xs.map(x => slope * x + inter);
  const ssr = ys.reduce((a, y, i) => a + (y - pred[i]) ** 2, 0);
  const sst = ys.reduce((a, y) => a + (y - sy / n) ** 2, 0);
  const resid = ys.map((y, i) => y - pred[i]);
  return { slope, inter, r2: 1 - ssr / sst, rms: Math.sqrt(ssr / n), maxdev: Math.max(...resid.map(Math.abs)), resid, pred };
}
function sineFit(data) { // 扫描周期，每个周期用线性最小二乘求 A,B,C
  let best = null;
  for (let T = 10; T <= 60; T += 0.02) {
    const w = 2 * Math.PI / T;
    const xs = data.map(d => d[0]), ys = data.map(d => d[1]);
    const cols = [xs.map(x => Math.sin(w * x)), xs.map(x => Math.cos(w * x)), xs.map(() => 1)];
    // 正规方程 3x3
    const M = [[0,0,0],[0,0,0],[0,0,0]], v = [0,0,0];
    for (let i = 0; i < 3; i++) { for (let j = 0; j < 3; j++) M[i][j] = cols[i].reduce((a, c, k) => a + c * cols[j][k], 0); v[i] = cols[i].reduce((a, c, k) => a + c * ys[k], 0); }
    const s = solve(M, v); if (!s) continue;
    const ssr = ys.reduce((a, y, k) => a + (y - (s[0] * cols[0][k] + s[1] * cols[1][k] + s[2])) ** 2, 0);
    if (!best || ssr < best.ssr) best = { T, A: Math.hypot(s[0], s[1]), ph: Math.atan2(s[1], s[0]), off: s[2], ssr };
  }
  const sst = data.reduce((a, d) => a + (d[1] - data.reduce((b, e) => b + e[1], 0) / data.length) ** 2, 0);
  best.r2 = 1 - best.ssr / sst;
  best.rms = Math.sqrt(best.ssr / data.length);
  return best;
}
function solve(M, v) {
  const a = M.map((r, i) => [...r, v[i]]), n = a.length;
  for (let c = 0; c < n; c++) {
    let p = c; for (let r = c + 1; r < n; r++) if (Math.abs(a[r][c]) > Math.abs(a[p][c])) p = r;
    if (Math.abs(a[p][c]) < 1e-12) return null;
    [a[c], a[p]] = [a[p], a[c]];
    for (let r = 0; r < n; r++) { if (r === c) continue; const f = a[r][c] / a[c][c]; for (let k = c; k <= n; k++) a[r][k] -= f * a[c][k]; }
  }
  return a.map((r, i) => r[n] / r[i]);
}
const mean = a => a.reduce((x, y) => x + y, 0) / a.length;
const r3 = x => Math.round(x * 1000) / 1000;

/* ---------- A. 巨磁阻特性 ---------- */
const X0 = 1.594; // 零磁场读数（正向/反向段 I=0）
const mr = {};
for (const k of ['seg1', 'seg2', 'seg3', 'seg4']) {
  mr[k] = GMR[k].pts.map(([I, x]) => [I, (x - X0) / X0 * 100]);
}
const allPts = [...GMR.seg1.pts, ...GMR.seg2.pts, ...GMR.seg3.pts, ...GMR.seg4.pts];
const maxMR = Math.max(...allPts.map(p => (p[1] - X0) / X0 * 100));
const minMR = Math.min(...allPts.map(p => (p[1] - X0) / X0 * 100));
// 磁滞：同 I 处 下降段 vs 上升段
function at(k, I) { const p = GMR[k].pts.find(q => q[0] === I); return p ? p[1] : null; }
const hystPos = [], hystNeg = [];
for (let I = 10; I <= 100; I += 10) hystPos.push([I, at('seg1', I), at('seg4', I)]);
for (let I = -10; I >= -100; I -= 10) hystNeg.push([I, at('seg2', I), at('seg3', I)]);
const hystDev = [...hystPos, ...hystNeg].map(r => [r[0], Math.abs(r[1] - r[2])]);
const maxHyst = Math.max(...hystDev.map(r => r[1]));
const maxHystI = hystDev.find(r => r[1] === maxHyst)[0];
// 对称性
const sym = []; for (let I = 10; I <= 100; I += 10) sym.push([I, Math.abs(at('seg1', I) - at('seg2', -I))]);
const maxSym = Math.max(...sym.map(s => s[1]));
// 半饱和
const half = maxMR / 2;
let Ihalf = null;
for (let i = 1; i < GMR.seg1.pts.length; i++) {
  const [I1, x1] = GMR.seg1.pts[i - 1], [I2, x2] = GMR.seg1.pts[i];
  const m1 = (x1 - X0) / X0 * 100, m2 = (x2 - X0) / X0 * 100;
  if ((m1 - half) * (m2 - half) <= 0 && m1 !== m2) { Ihalf = I2 + (half - m2) * (I1 - I2) / (m1 - m2); break; }
}

/* ---------- B. 角位移 ---------- */
const fit = sineFit(ANGLE);
const w = 2 * Math.PI / fit.T;
const model = t => fit.off + fit.A * Math.sin(w * t + fit.ph);
const angResid = ANGLE.map(([t, u]) => u - model(t));
const teeth = 360 / fit.T;
// 线性段（峰附近 ±1/8 周期）与过零段斜率
const zeroSlope = (2 * Math.PI * fit.A / fit.T);

/* ---------- C. 磁记录 ---------- */
const vLow = RECORD.volts.filter((_, i) => RECORD.bits[i] === 0);
const vHigh = RECORD.volts.filter((_, i) => RECORD.bits[i] === 1);
const Vth = (Math.max(...vLow) + Math.min(...vHigh)) / 2;
const decoded = RECORD.volts.map(v => v > Vth ? 1 : 0);
const bitErr = decoded.filter((b, i) => b !== RECORD.bits[i]).length;
const marginLow = Vth - Math.max(...vLow), marginHigh = Math.min(...vHigh) - Vth;
const levelDiff = Math.min(...vHigh) - Math.max(...vLow);

/* ---------- D. 测量电流 ---------- */
const fLow = linfit(CURR.I, CURR.low);
const fHigh = linfit(CURR.I, CURR.high);
const spanLow = Math.max(...CURR.low) - Math.min(...CURR.low);
const spanHigh = Math.max(...CURR.high) - Math.min(...CURR.high);

/* ---------- E. 开关 ---------- */
const hystPos2 = SW.operate_pos - SW.release_pos;
const hystNeg2 = SW.operate_neg - SW.release_neg;
const hystMean = (hystPos2 + hystNeg2) / 2;
const opMean = (SW.operate_pos + SW.operate_neg) / 2;
const relMean = (SW.release_pos + SW.release_neg) / 2;
const centre = (opMean + relMean) / 2;

const out = {
  gmr: { X0, maxMR: r3(maxMR), minMR: r3(minMR), maxHyst: r3(maxHyst), maxHystI, maxSym: r3(maxSym), Ihalf: Ihalf && r3(Ihalf), half: r3(half), mrTable: mr },
  angle: { T: r3(fit.T), A: r3(fit.A), phase_deg: r3(fit.ph * 180 / Math.PI), off: r3(fit.off), r2: r3(fit.r2), rms: r3(fit.rms), teeth: r3(teeth), zeroSlope: r3(zeroSlope), maxResid: r3(Math.max(...angResid.map(Math.abs))) },
  record: { vLowMean: r3(mean(vLow)), vHighMean: r3(mean(vHigh)), Vth: r3(Vth), marginLow: r3(marginLow), marginHigh: r3(marginHigh), levelDiff: r3(levelDiff), decoded: decoded.join(''), written: RECORD.bits.join(''), bitErr, dec: parseInt(RECORD.bits.join(''), 2) },
  current: {
    low: { S: r3(fLow.slope), S_mVmA: r3(fLow.slope), off: r3(fLow.inter), r2: r3(fLow.r2), maxdev: r3(fLow.maxdev), nl: r3(fLow.maxdev / spanLow * 100), span: r3(spanLow), meas0: CURR.low[3] },
    high: { S: r3(fHigh.slope), off: r3(fHigh.inter), r2: r3(fHigh.r2), maxdev: r3(fHigh.maxdev), nl: r3(fHigh.maxdev / spanHigh * 100), span: r3(spanHigh), meas0: CURR.high[3] },
  },
  sw: { hystPos: r3(hystPos2), hystNeg: r3(hystNeg2), hystMean: r3(hystMean), opMean: r3(opMean), relMean: r3(relMean), centre: r3(centre), asym: r3(Math.abs(hystPos2 - hystNeg2)) },
};
fs.writeFileSync('analysis.json', JSON.stringify({ out, GMR, ANGLE, RECORD, CURR, SW }, null, 1));
console.log(JSON.stringify(out, null, 1));
