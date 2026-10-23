const fs = require('fs');
const F = require('./final.json');
const { GMR, ANGLE, RECORD, CURR, SW } = require('./analysis.json');

const W = 760, H = 492, M = { l: 78, r: 26, t: 44, b: 88 };
const C = { blue: '#1f6fb2', red: '#c8322b', green: '#2e8b57', purple: '#7b4ea0', orange: '#d97706', gray: '#666' };
const FONT = 'Microsoft YaHei,SimHei,PingFang SC,sans-serif';

function ticks(lo, hi, want = 6) {
  const span = hi - lo, raw = span / want, mag = 10 ** Math.floor(Math.log10(raw)), n = raw / mag;
  const step = (n >= 5 ? 10 : n >= 2 ? 5 : n >= 1 ? 2 : 1) * mag;
  const out = []; for (let v = Math.ceil(lo / step) * step; v <= hi + step * 1e-9; v += step) out.push(+v.toFixed(10));
  return out;
}
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const fmt = v => Math.abs(v) >= 1000 ? v.toExponential(1) : String(+v.toFixed(Math.abs(v) < 1 ? 3 : Math.abs(v) < 10 ? 2 : 1));

function chart(o) {
  const iw = W - M.l - M.r, ih = H - M.t - M.b;
  const xs = o.series.flatMap(s => s.pts.map(p => p[0])), ys = o.series.flatMap(s => s.pts.map(p => p[1]));
  const xlo = o.xmin ?? Math.min(...xs), xhi = o.xmax ?? Math.max(...xs);
  const ylo = o.ymin ?? Math.min(...ys), yhi = o.ymax ?? Math.max(...ys);
  const X = v => M.l + (v - xlo) / (xhi - xlo) * iw;
  const Y = v => M.t + ih - (v - ylo) / (yhi - ylo) * ih;
  const xt = o.xticks || ticks(xlo, xhi), yt = o.yticks || ticks(ylo, yhi);
  let g = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" font-family="${FONT}">`;
  g += `<rect width="${W}" height="${H}" fill="#fff"/>`;
  g += `<text x="${W / 2}" y="24" text-anchor="middle" font-size="16" font-weight="600" fill="#1a1a1a">${esc(o.title)}</text>`;
  // 网格 + 轴
  g += `<g stroke="#e6e6e6" stroke-width="1">`;
  for (const t of yt) g += `<line x1="${M.l}" y1="${Y(t).toFixed(1)}" x2="${M.l + iw}" y2="${Y(t).toFixed(1)}"/>`;
  for (const t of xt) g += `<line x1="${X(t).toFixed(1)}" y1="${M.t}" x2="${X(t).toFixed(1)}" y2="${M.t + ih}"/>`;
  g += `</g>`;
  g += `<rect x="${M.l}" y="${M.t}" width="${iw}" height="${ih}" fill="none" stroke="#333" stroke-width="1.4"/>`;
  for (const t of xt) g += `<line x1="${X(t).toFixed(1)}" y1="${M.t + ih}" x2="${X(t).toFixed(1)}" y2="${M.t + ih + 6}" stroke="#333"/><text x="${X(t).toFixed(1)}" y="${M.t + ih + 22}" text-anchor="middle" font-size="12" fill="#333">${fmt(t)}</text>`;
  for (const t of yt) g += `<line x1="${M.l - 6}" y1="${Y(t).toFixed(1)}" x2="${M.l}" y2="${Y(t).toFixed(1)}" stroke="#333"/><text x="${M.l - 10}" y="${(Y(t) + 4).toFixed(1)}" text-anchor="end" font-size="12" fill="#333">${fmt(t)}</text>`;
  g += `<text x="${M.l + iw / 2}" y="${M.t + ih + 44}" text-anchor="middle" font-size="13.5" fill="#1a1a1a">${esc(o.xlabel)}</text>`;
  g += `<text transform="translate(20,${M.t + ih / 2}) rotate(-90)" text-anchor="middle" font-size="13.5" fill="#1a1a1a">${esc(o.ylabel)}</text>`;
  // 参考线
  for (const h of o.hlines || []) g += `<line x1="${M.l}" y1="${Y(h.y).toFixed(1)}" x2="${M.l + iw}" y2="${Y(h.y).toFixed(1)}" stroke="${h.color || C.gray}" stroke-width="1.4" stroke-dasharray="7 4"/>${h.label ? `<text x="${h.align === 'left' ? M.l + 8 : M.l + iw - 6}" y="${(Y(h.y) - 7).toFixed(1)}" text-anchor="${h.align === 'left' ? 'start' : 'end'}" font-size="11.5" fill="${h.color || C.gray}" paint-order="stroke" stroke="#fff" stroke-width="3.5">${esc(h.label)}</text>` : ''}`;
  for (const v of o.vlines || []) g += `<line x1="${X(v.x).toFixed(1)}" y1="${M.t}" x2="${X(v.x).toFixed(1)}" y2="${M.t + ih}" stroke="${v.color || C.gray}" stroke-width="1.2" stroke-dasharray="4 4"/>`;
  // 数据
  for (const s of o.series) {
    if (s.type === 'bar') {
      const bw = s.bw ?? (iw / s.pts.length) * 0.55;
      for (const [x, y] of s.pts) g += `<rect x="${(X(x) - bw / 2).toFixed(1)}" y="${Math.min(Y(y), Y(s.zero ?? ylo)).toFixed(1)}" width="${bw.toFixed(1)}" height="${Math.abs(Y(y) - Y(s.zero ?? ylo)).toFixed(1)}" fill="${s.color}" fill-opacity="${s.fill ?? 0.75}" stroke="${s.color}"/>`;
    } else {
      if (s.type !== 'scatter' && s.pts.length > 1) {
        const d = s.pts.map((p, i) => `${i ? 'L' : 'M'}${X(p[0]).toFixed(1)} ${Y(p[1]).toFixed(1)}`).join(' ');
        g += `<path d="${d}" fill="none" stroke="${s.color}" stroke-width="${s.width ?? 2}"${s.dash ? ` stroke-dasharray="${s.dash}"` : ''}/>`;
      }
      for (const [x, y] of (s.marker === false ? [] : s.pts)) {
        const cx = X(x).toFixed(1), cy = Y(y).toFixed(1), r = s.size ?? 3.6;
        if (s.shape === 'square') g += `<rect x="${(X(x) - r).toFixed(1)}" y="${(Y(y) - r).toFixed(1)}" width="${(2 * r).toFixed(1)}" height="${(2 * r).toFixed(1)}" fill="${s.hollow ? '#fff' : s.color}" stroke="${s.color}" stroke-width="1.6"/>`;
        else if (s.shape === 'triangle') g += `<path d="M${cx} ${(Y(y) - r).toFixed(1)} L${(X(x) + r).toFixed(1)} ${(Y(y) + r).toFixed(1)} L${(X(x) - r).toFixed(1)} ${(Y(y) + r).toFixed(1)} Z" fill="${s.hollow ? '#fff' : s.color}" stroke="${s.color}" stroke-width="1.6"/>`;
        else g += `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${s.hollow ? '#fff' : s.color}" stroke="${s.color}" stroke-width="1.6"/>`;
      }
    }
  }
  for (const m of o.marks || []) g += `<text x="${(X(m.x) + (m.dx ?? 8)).toFixed(1)}" y="${(Y(m.y) + (m.dy ?? 0)).toFixed(1)}" font-size="11.5" fill="${m.color || C.red}" font-weight="600">${esc(m.text)}</text>`;
  if (o.legend !== false) {
    const items = o.series.filter(s => s.name);
    const wid = t => [...t].reduce((a, ch) => a + (ch.charCodeAt(0) > 0x2e80 ? 12.2 : 6.9), 0);
    const gap = 30, rows = [[]];
    let cur = 0;
    for (const it of items) {
      const wd = 42 + wid(it.name) + gap;
      if (cur + wd > iw && rows[rows.length - 1].length) { rows.push([]); cur = 0; }
      rows[rows.length - 1].push(it); cur += wd;
    }
    rows.forEach((row, ri) => {
      const rowW = row.reduce((a, it) => a + 42 + wid(it.name) + gap, 0) - gap;
      let cx = M.l + (iw - rowW) / 2;
      const ly = M.t + ih + 62 + ri * 21;
      for (const s of row) {
        if (s.type === 'bar') g += `<rect x="${cx}" y="${ly - 12}" width="24" height="15" fill="${s.color}" fill-opacity="${s.fill ?? 0.75}" stroke="${s.color}"/>`;
        else g += `<line x1="${cx}" y1="${ly - 4}" x2="${cx + 28}" y2="${ly - 4}" stroke="${s.color}" stroke-width="2.6"${s.dash ? ` stroke-dasharray="${s.dash}"` : ''}/>`;
        if (s.type !== 'bar' && s.marker !== false) g += `<rect x="${cx + 9}" y="${ly - 9}" width="11" height="11" fill="${s.hollow ? '#fff' : s.color}" stroke="${s.color}" stroke-width="1.6"/>`;
        g += `<text x="${cx + 34}" y="${ly}" font-size="12" fill="#333">${esc(s.name)}</text>`;
        cx += 42 + wid(s.name) + gap;
      }
    });
  }
  return g + '</svg>';
}
const curve = (fn, a, b, n = 300) => Array.from({ length: n + 1 }, (_, i) => [a + (b - a) * i / n, fn(a + (b - a) * i / n)]);
const dir = d => d === 'down' ? { shape: 'circle' } : { shape: 'square', hollow: true };

/* 图1 GMR 四段扫描 */
fs.writeFileSync('fig1.svg', chart({
  title: '图 1  GMR 响应量随励磁电流的四段扫描曲线',
  xlabel: '励磁电流 I / mA', ylabel: 'GMR 响应量读数 / (mA，表 E 列)',
  xmin: -110, xmax: 110, ymin: 1.55, ymax: 1.85,
  series: [
    { name: '下降段 ① +100→0', color: C.blue, ...dir('down'), pts: GMR.seg1.pts },
    { name: '下降段 ② 0→−100', color: C.red, ...dir('down'), pts: GMR.seg2.pts },
    { name: '上升段 ③ −100→0', color: C.red, ...dir('up'), dash: '6 4', pts: GMR.seg3.pts },
    { name: '上升段 ④ 0→+100', color: C.blue, ...dir('up'), dash: '6 4', pts: GMR.seg4.pts },
  ],
  hlines: [{ y: 1.594, label: '零磁场 X₀ = 1.594', color: C.green }],
}));

/* 图2 ΔR/R0 */
fs.writeFileSync('fig2.svg', chart({
  title: '图 2  相对磁阻变化率 ΔR/R₀ 随励磁电流的变化',
  xlabel: '励磁电流 I / mA', ylabel: 'ΔR/R₀ / %',
  xmin: -110, xmax: 110, ymin: -0.8, ymax: 15.5,
  series: [
    { name: '下降段', color: C.purple, ...dir('down'), pts: [...F.gmr.mrT.seg1, ...F.gmr.mrT.seg2] },
    { name: '上升段', color: C.orange, ...dir('up'), dash: '6 4', pts: [...F.gmr.mrT.seg3, ...F.gmr.mrT.seg4] },
  ],
  hlines: [{ y: F.gmr.maxMR, label: `饱和值 ${F.gmr.maxMR}%`, color: C.gray }, { y: F.gmr.maxMR / 2, label: `半饱和 ${+(F.gmr.maxMR / 2).toFixed(2)}%`, color: C.gray }],
  vlines: [{ x: -F.gmr.Ihalf, color: C.green }, { x: F.gmr.Ihalf, color: C.green }],
  marks: [{ x: F.gmr.Ihalf, y: F.gmr.maxMR / 2, text: `I½ ≈ ${F.gmr.Ihalf} mA`, color: C.green, dx: 6, dy: 16 }],
}));

/* 图3 角位移 */
const mk = F.angle.keep;
fs.writeFileSync('fig3.svg', chart({
  title: '图 3  GMR 梯度传感器输出电压—角位移特性（T = 24°）',
  xlabel: '角位移 θ / (°)', ylabel: '输出电压 U / mV',
  xmin: -2, xmax: 50, ymin: -75, ymax: 75,
  series: [
    { name: '实测数据', color: C.blue, shape: 'circle', size: 4.2, pts: ANGLE },
    { name: '基波拟合（A = 58.12 mV，T = 24°）', color: C.red, width: 2.6, marker: false, pts: curve(t => mk.off + mk.A * Math.sin(2 * Math.PI * t / 24 + mk.ph), -2, 50) },
    { name: '离群点（拟合时剔除）', color: C.orange, type: 'scatter', shape: 'square', hollow: true, size: 6.5, pts: [[27, 0], [45, -1.1]] },
  ],
  hlines: [{ y: 0, color: '#999' }],
  marks: [],
}));

/* 图4 磁记录 */
fs.writeFileSync('fig4.svg', chart({
  title: '图 4  磁卡 8 区域读出电平与判决阈值',
  xlabel: '磁卡区域号', ylabel: 'GMR 读出头输出电压 U / V',
  xmin: 0.35, xmax: 8.65, ymin: -0.05, ymax: 2.35, xticks: [1,2,3,4,5,6,7,8],
  series: [{ name: '读出电平', color: C.blue, type: 'bar', zero: 0, fill: 0.8, bw: 46, pts: RECORD.volts.map((v, i) => [i + 1, v]) }],
  hlines: [{ y: 0.965, label: '判决阈值 Vth = 0.965 V', color: C.red, align: 'left' }],
  legend: false,
  marks: RECORD.volts.map((v, i) => ({ x: i + 1, y: v + 0.06, text: (RECORD.bits[i]) + '', color: v > 0.965 ? C.green : C.gray, dx: -3, dy: 0 })),
}));

/* 图5 测量电流 */
fs.writeFileSync('fig5.svg', chart({
  title: '图 5  GMR 模拟传感器测电流：输出电压—待测电流',
  xlabel: '待测电流 I / mA', ylabel: '输出电压 U / mV',
  xmin: -340, xmax: 340, ymin: 15, ymax: 140,
  series: [
    { name: '低偏置（校准 25 mV）', color: C.blue, shape: 'circle', pts: CURR.I.map((x, i) => [x, CURR.low[i]]) },
    { name: '低偏置拟合 S=15.46 µV/mA', color: C.blue, width: 2, dash: '7 4', pts: curve(x => F.current.low.U0 + F.current.low.S * x, -320, 320) },
    { name: '适当偏置（校准 150 mV）', color: C.red, shape: 'triangle', pts: CURR.I.map((x, i) => [x, CURR.high[i]]) },
    { name: '适当偏置拟合 S=18.25 µV/mA', color: C.red, width: 2, dash: '7 4', pts: curve(x => F.current.high.U0 + F.current.high.S * x, -320, 320) },
  ],
}));

/* 图6 开关磁滞回线 */
const loopDown = [[50,1],[SW.release_pos,1],[SW.release_pos,0],[-SW.operate_neg,0],[-SW.operate_neg,1],[-50,1]];
const loopUp = [[-50,1],[-SW.release_neg,1],[-SW.release_neg,0],[SW.operate_pos,0],[SW.operate_pos,1],[50,1]];
fs.writeFileSync('fig6.svg', chart({
  title: '图 6  GMR 开关传感器的磁滞回线（开关特性）',
  xlabel: '励磁电流 I / mA', ylabel: '输出电平',
  xmin: -52, xmax: 52, ymin: -0.55, ymax: 1.62,
  series: [
    { name: '下降路径 +50→−50', color: C.blue, width: 2.8, marker: false, pts: loopDown },
    { name: '上升路径 −50→+50', color: C.red, width: 2.8, dash: '8 5', marker: false, pts: loopUp },
  ],
  yticks: [0, 1],
  vlines: [{ x: SW.release_pos, color: C.gray }, { x: SW.operate_pos, color: C.gray }, { x: -SW.operate_neg, color: C.gray }, { x: -SW.release_neg, color: C.gray }],
  marks: [
    { x: SW.operate_pos, y: 0, text: `正向动作 ${SW.operate_pos}`, color: C.red, dx: -18, dy: 16 },
    { x: SW.release_pos, y: 1, text: `正向释放 ${SW.release_pos}`, color: C.blue, dx: -34, dy: -8 },
    { x: -SW.operate_neg, y: 0, text: `负向动作 ${SW.operate_neg}`, color: C.red, dx: -80, dy: 16 },
    { x: -SW.release_neg, y: 1, text: `负向释放 ${SW.release_neg}`, color: C.blue, dx: -80, dy: -8 },
  ],
}));
console.log('charts written');
