const fs = require('fs');
const P = require('./pptxlib.js');
const F = require('./final.json');
const { SW, SH, emu, text, rect, pic } = P;

const ML = 600000, CW = SW - 2 * ML;
const C = { blue: '1F6FB2', navy: '1F4E79', red: 'C8322B', green: '2E8B57', purple: '7B4EA0', orange: 'D97706', gray: '666666', lite: 'F2F5F8', card: 'F7F9FB' };
const AR = 984 / 1520;

const slides = [];
function begin() { return { body: '', imgs: [] }; }
function add(s, x) { s.body += x; }
function img(s, file, x, y, w) {
  const rid = 'rId' + (s.imgs.length + 2);
  s.imgs.push(file);
  add(s, pic(rid, x, y, w, Math.round(w * AR)));
  return Math.round(w * AR);
}
function header(s, title, tag) {
  add(s, rect(ML, 330000, 90000, 500000, C.blue));
  add(s, text(ML + 200000, 330000, CW - 1400000, 500000, [[{ t: title, sz: 2500, b: 1, color: C.navy }]]));
  if (tag) add(s, text(SW - ML - 1300000, 360000, 1300000, 400000, [[{ t: tag, sz: 1300, color: C.gray }]], { align: 'r' }));
}
function takeaway(s, txt, y) {
  const yy = y || 900000;
  add(s, rect(ML, yy, CW, 560000, C.lite, { round: true }));
  add(s, text(ML + 260000, yy + 130000, CW - 520000, 320000, [[{ t: '一句话结论  ', sz: 1400, b: 1, color: C.red }, { t: txt, sz: 1500, b: 1, color: '262626' }]]));
  return yy + 560000;
}
function card(s, x, y, w, h, big, label, color) {
  add(s, rect(x, y, w, h, C.card, { round: true, line: 'DCE3EA' }));
  add(s, text(x + 150000, y + 110000, w - 300000, 400000, [[{ t: big, sz: 2100, b: 1, color: color || C.blue }]]));
  add(s, text(x + 150000, y + h - 330000, w - 300000, 260000, [[{ t: label, sz: 1150, color: C.gray }]]));
}
function bullets(s, x, y, w, items, o = {}) {
  add(s, text(x, y, w, o.h || 3600000, items.map(it => (Array.isArray(it) ? it : [{ t: it }])).map(r => ({ ...r, _p: 1 })), o));
}

/* ================= S1 封面 ================= */
{
  const s = begin();
  add(s, rect(0, 0, SW, SH, 'FFFFFF'));
  add(s, rect(0, 0, SW, 120000, C.blue));
  add(s, rect(0, SH - 120000, SW, 120000, C.blue));
  add(s, text(ML, 1250000, CW, 900000, [[{ t: '巨磁阻效应及应用', sz: 5200, b: 1, color: C.navy }]], { align: 'ctr' }));
  add(s, text(ML, 2180000, CW, 500000, [[{ t: 'GMR 磁阻特性 · 齿轮角位移 · 磁记录与读出 · 两项拓展', sz: 1900, color: C.gray }]], { align: 'ctr' }));
  const chips = [['① 磁阻特性', 'ΔR/R₀ = 13.93 %'], ['② 角位移', 'T = 24° → 15 齿'], ['③ 磁记录', '8 位全对'], ['④ 拓展（三选二）', '测电流 + 开关']];
  const cw = 2500000, gap = (CW - 4 * cw) / 3;
  chips.forEach((c, i) => {
    const x = ML + i * (cw + gap);
    add(s, rect(x, 3050000, cw, 1000000, C.card, { round: true, line: 'DCE3EA' }));
    add(s, text(x + 150000, 3170000, cw - 300000, 350000, [[{ t: c[0], sz: 1400, b: 1, color: C.blue }]], { align: 'ctr' }));
    add(s, text(x + 120000, 3560000, cw - 240000, 350000, [[{ t: c[1], sz: 1300, color: '262626' }]], { align: 'ctr' }));
  });
  add(s, text(ML, 4500000, CW, 900000, [
    [{ t: '姓名：              学号：              同组人：', sz: 1500, color: '262626' }],
    [{ t: '实验日期：2026 年    月    日          指导教师：', sz: 1500, color: '262626' }],
  ], { align: 'ctr', h: 900000 }));
  add(s, text(ML, 5850000, CW, 400000, [[{ t: '汇报时长 2 分钟 · 共 7 页 · 成员互评', sz: 1250, color: C.gray }]], { align: 'ctr' }));
  slides.push(s);
}

/* ================= S2 原理 ================= */
{
  const s = begin();
  header(s, '原理：自旋相关散射 → 电阻随磁化取向改变', '2 / 7');
  const y0 = takeaway(s, 'GMR 把“磁化相对取向”转成“电阻变化”，因此既能测弱磁场，也能测位置与电流。');
  const colW = (CW - 400000) / 2;
  add(s, text(ML, y0 + 280000, colW, 400000, [[{ t: '机理', sz: 1700, b: 1, color: C.navy }]]));
  add(s, text(ML, y0 + 780000, colW, 2600000, [
    [{ t: '· ', sz: 1450, color: C.blue }, { t: '1988 年 Baibich 在 Fe/Cr 多层膜中发现', sz: 1450 }],
    [{ t: '· ', sz: 1450, color: C.blue }, { t: '铁磁层中 3d 电子被自旋极化', sz: 1450 }],
    [{ t: '· ', sz: 1450, color: C.blue }, { t: '自旋 ∥ 磁化 → 散射弱、自由程长（低阻通道）', sz: 1450 }],
    [{ t: '· ', sz: 1450, color: C.blue }, { t: '自旋 ⊥ 磁化 → 散射强（高阻通道）', sz: 1450 }],
    [{ t: '· ', sz: 1450, color: C.blue }, { t: '磁化平行＝低阻，反平行＝高阻；外场驱动转向', sz: 1450 }],
    [{ t: '· ', sz: 1450, color: C.red }, { t: '对比：AMR 仅 2~5 %，GMR 达百分之几十', sz: 1450 }],
  ]));
  add(s, rect(ML, y0 + 3450000, colW, 620000, 'FFF6F5', { round: true, line: 'E8C4C1' }));
  add(s, text(ML + 200000, y0 + 3620000, colW - 400000, 350000, [[{ t: 'ΔR/R₀ = [R(B) − R(0)] / R(0) × 100 %', sz: 1500, b: 1, mono: true, color: C.red }]], { align: 'ctr' }));
  const x2 = ML + colW + 400000;
  add(s, text(x2, y0 + 280000, colW, 400000, [[{ t: '应用方式与本次任务对应', sz: 1700, b: 1, color: C.navy }]]));
  const rows = [
    ['梯度（差分）模式', '两元件电阻反向变化，抑制均匀杂散场', '任务② 齿轮角位移', C.blue],
    ['开关模式', '内置迟滞，输出仅高/低电平，抗抖动', '拓展② 磁电转换特性', C.purple],
    ['磁记录与读出', '读头感应磁卡局部杂散场 → 电平', '任务③ 8 位写入读出', C.green],
    ['模拟线性输出', '偏置磁场决定灵敏度与线性度', '拓展① 测量电流', C.orange],
  ];
  rows.forEach((r, i) => {
    const yy = y0 + 780000 + i * 800000;
    add(s, rect(x2, yy, colW, 700000, C.card, { round: true, line: 'DCE3EA' }));
    add(s, rect(x2, yy, 70000, 700000, r[3]));
    add(s, text(x2 + 200000, yy + 90000, colW - 300000, 300000, [[{ t: r[0], sz: 1400, b: 1, color: r[3] }]]));
    add(s, text(x2 + 200000, yy + 390000, colW - 300000, 280000, [[{ t: r[1] + '   →   ' + r[2], sz: 1150, color: C.gray }]]));
  });
  slides.push(s);
}

/* ================= S3 磁阻特性 ================= */
{
  const s = begin();
  header(s, '任务① GMR 磁阻特性：13.93 % 饱和，31 mA 半饱和', '3 / 7');
  const y0 = takeaway(s, '曲线低场陡峭、70 mA 后斜率降约 35 倍进入饱和，灵敏区集中在低场陡峭段。');
  const iw = 6500000;
  img(s, 'fig2.png', ML, y0 + 250000, iw);
  const x2 = ML + iw + 250000, cw2 = SW - ML - x2;
  card(s, x2, y0 + 300000, cw2, 800000, 'ΔR/R₀ = 13.93 %', '最大相对磁阻变化率（+100 mA）', C.blue);
  card(s, x2, y0 + 1200000, cw2, 800000, 'I½ ≈ 31.4 mA', '半饱和励磁电流', C.green);
  card(s, x2, y0 + 2100000, cw2, 800000, '1.44 % FS', '下降/上升段最大偏差（@50 mA）', C.red);
  add(s, text(x2, y0 + 3050000, cw2, 900000, [
    [{ t: '数据处理：', sz: 1250, b: 1, color: C.navy }],
    [{ t: '表中 B、U、R 三列未填，仅 E 列有值；该读数随 |I| 单调增大，与 R 同向，故按 ΔX/X₀ 归一化求 ΔR/R₀，横标用 I 而非 mT。', sz: 1150, color: '262626' }],
  ]));
  slides.push(s);
}

/* ================= S4 角位移 ================= */
{
  const s = begin();
  header(s, '任务② 齿轮角位移：周期 24° ⇒ 15 齿', '4 / 7');
  const y0 = takeaway(s, '周期由四个极值位置定出，不依赖拟合；剔掉 2 个坏点后 R² = 0.977。');
  const iw = 6500000;
  img(s, 'fig3.png', ML, y0 + 250000, iw);
  const x2 = ML + iw + 250000, cw2 = SW - ML - x2;
  card(s, x2, y0 + 300000, cw2, 800000, 'T = 24° → N = 15', '极值 6/18/30/42°，间隔恒 12°', C.blue);
  card(s, x2, y0 + 1200000, cw2, 800000, '15.22 mV/°', '过零灵敏度，线性区 ±2.58°', C.green);
  card(s, x2, y0 + 2100000, cw2, 800000, '0.40°', '实际角分辨率（受残差限制）', C.orange);
  add(s, text(x2, y0 + 3050000, cw2, 900000, [
    [{ t: '两个坏点：', sz: 1250, b: 1, color: C.red }],
    [{ t: 'θ = 27°、45° 实测均≈0，模型预测 +39.1 / −43.1 mV；实测值恰落在模型过零差 3° 处 → 判为齿数计数错位，而非传感器异常。', sz: 1150, color: '262626' }],
  ]));
  slides.push(s);
}

/* ================= S5 磁记录 ================= */
{
  const s = begin();
  header(s, '任务③ 磁记录与读出：8 位全对', '5 / 7');
  const y0 = takeaway(s, '写入 00110011（= 0x33 = 51），译码结果与写入逐位一致，误码 0/8。');
  const iw = 6500000;
  img(s, 'fig4.png', ML, y0 + 250000, iw);
  const x2 = ML + iw + 250000, cw2 = SW - ML - x2;
  card(s, x2, y0 + 300000, cw2, 800000, 'V_th = 0.965 V', '判决阈值（高低组中点）', C.blue);
  card(s, x2, y0 + 1200000, cw2, 800000, '±0.96 V', '两侧噪声容限，各约 50 % 电平差', C.green);
  card(s, x2, y0 + 2100000, cw2, 800000, '1.925 V', '高 1.928 V / 低 0.003 V 电平差', C.purple);
  add(s, text(x2, y0 + 3050000, cw2, 900000, [
    [{ t: '数据边界：', sz: 1250, b: 1, color: C.red }],
    [{ t: '高电平 1.928 V 已接近输出级上限，可能饱和钳位；0/8 误码按三法则只能给 p₉₅ ≈ 37.5 % 上限，样本太少。', sz: 1150, color: '262626' }],
  ]));
  slides.push(s);
}

/* ================= S6 拓展两项 ================= */
{
  const s = begin();
  header(s, '拓展（三选二）：测电流 · 开关特性', '6 / 7');
  const y0 = takeaway(s, '偏置磁场用 18 % 的灵敏度换取约 1 个百分点的线性度；开关回差 2.75 mA 提供抗抖动死区。');
  const iw = 5300000, gap = CW - 2 * iw;
  const ih = img(s, 'fig5.png', ML, y0 + 250000, iw);
  img(s, 'fig6.png', ML + iw + gap, y0 + 250000, iw);
  const yy = y0 + 250000 + ih + 200000;
  add(s, text(ML, yy, iw, 900000, [
    [{ t: '拓展① 模拟传感器测电流', sz: 1400, b: 1, color: C.navy }],
    [{ t: 'S：15.46 → 18.25 µV/mA（+18.0 %）', sz: 1250 }],
    [{ t: '非线性度：2.00 → 3.12 % FS，R² > 0.997', sz: 1250 }],
    [{ t: '注：适当偏置校准未到位，实测零点 129.36 mV（目标 150）', sz: 1150, color: C.red }],
  ]));
  add(s, text(ML + iw + gap, yy, iw, 900000, [
    [{ t: '拓展② 开关传感器磁电转换', sz: 1400, b: 1, color: C.navy }],
    [{ t: '动作 ±18.8 mA，释放 ±16.05 mA', sz: 1250 }],
    [{ t: '回差：正 3.70 / 负 1.80 / 平均 2.75 mA', sz: 1250 }],
    [{ t: '注：逐格步长 10 mA → 阈值不确定度 ±5 mA，两侧回差之差（1.90 mA）不作物理结论', sz: 1150, color: C.red }],
  ]));
  slides.push(s);
}

/* ================= S7 误差与结论 ================= */
{
  const s = begin();
  header(s, '误差主线与结论', '7 / 7');
  const y0 = takeaway(s, '定性结论与参量测定都成立；涉及绝对磁场与回差细微不对称的量，本次数据不支持下定量结论。');
  const colW = (CW - 400000) / 2;
  add(s, text(ML, y0 + 280000, colW, 400000, [[{ t: '三条误差主线', sz: 1700, b: 1, color: C.red }]]));
  add(s, text(ML, y0 + 780000, colW, 3200000, [
    [{ t: '1  磁场标定缺失（最主要）', sz: 1400, b: 1, color: C.navy }],
    [{ t: '    B、U、R 三列未填 → 只能以 I 为磁标度，ΔR/R₀ 是归一化相对量，无绝对电阻。', sz: 1200 }],
    [{ t: '2  扫描路径依赖', sz: 1400, b: 1, color: C.navy, _p: 1 }],
    [{ t: '    同 |I| 处最大偏差 1.44 % FS，且集中在 dX/dI 最大的中场区 → 标定不重复被陡峭响应放大，故要求恒流源单向调节、不得回调。', sz: 1200 }],
    [{ t: '3  离散采样的分辨上限', sz: 1400, b: 1, color: C.navy, _p: 1 }],
    [{ t: '    角位移 3° 一格 → 3° 错位即 45 mV；开关 10 mA 一格 → 阈值 ±5 mA。', sz: 1200 }],
  ]));
  const x2 = ML + colW + 400000;
  add(s, text(x2, y0 + 280000, colW, 400000, [[{ t: '四条结论', sz: 1700, b: 1, color: C.green }]]));
  add(s, text(x2, y0 + 780000, colW, 3200000, [
    [{ t: '① ', sz: 1350, b: 1, color: C.green }, { t: 'GMR 磁阻曲线呈饱和形，ΔR/R₀ = 13.93 %，I½ = 31.4 mA；工作点应取低场陡峭区。', sz: 1350 }],
    [{ t: '② ', sz: 1350, b: 1, color: C.green }, { t: '梯度模式输出周期信号，可直接反推机械参数：T = 24° ⇒ 15 齿，15.22 mV/°。', sz: 1350 }],
    [{ t: '③ ', sz: 1350, b: 1, color: C.green }, { t: '开关与线性是两种取舍：要“有无”用开关（带回差），要“多少”用线性（需比较器与校正）。', sz: 1350 }],
    [{ t: '④ ', sz: 1350, b: 1, color: C.green }, { t: '偏置决定灵敏度：+18 % 灵敏度换 −1 个百分点线性度；全桥差分可同时改善两者。', sz: 1350 }],
  ]));
  add(s, rect(x2, y0 + 2950000, colW, 620000, 'FFF6F5', { round: true, line: 'E8C4C1' }));
  add(s, text(x2 + 200000, y0 + 3120000, colW - 400000, 420000, [[{ t: '本次数据的边界：缺 B—I 标定曲线，故 13.93 % 是归一化相对量而非绝对电阻；开关阈值受 10 mA 步长限制，不确定度 ±5 mA 大于两侧回差之差 1.90 mA。', sz: 1200, b: 1, color: C.red }]]));
  slides.push(s);
}

/* ================= 备注：数据 / 现象 / 结论 ================= */
const D = { t: '【数据】  ', b: 1, color: '1F6FB2' };
const X = { t: '【现象】  ', b: 1, color: 'D97706' };
const J = { t: '【结论】  ', b: 1, color: '2E8B57' };
const N = (data, phen, concl) => {
  const mk = (lab, runs, sp) => [{ t: lab.t, b: 1, color: lab.color, sz: 1150, _p: sp ? 1 : undefined }, ...runs];
  return [mk(D, data, 0), mk(X, phen, 1), mk(J, concl, 1)];
};

slides[0].notes = N(
  [{ t: '完成 4 项测量：磁阻特性（±100 mA 四段扫描 43 点）、角位移（0~48° 共 17 点）、磁记录（8 区域）、拓展两项（测电流 ±300 mA 两行 7 点、开关四段 4 个阈值）。', sz: 1100 }],
  [{ t: '全部数值取自实验记录表已填写的单元格；表中 B、U、R 三列空白，未作推算。', sz: 1100 }],
  [{ t: '四项任务均取得可用数据，下面逐项报告。', sz: 1100 }]);

slides[1].notes = N(
  [{ t: '理论预期：磁化由反平行转为平行时电阻下降，ΔR/R₀ 可达百分之几十；坡莫合金 AMR 仅 2~5 %。', sz: 1100 }],
  [{ t: '由此应能观测到三件事：① 电阻随磁场单调上升后趋于饱和；② 梯度结构在齿轮上输出周期信号；③ 开关结构输出带回差的方波。', sz: 1100 }],
  [{ t: '本次三件事全部被数据证实（见后四页），且实测 ΔR/R₀ = 13.93 % 落在 GMR 量级、明显高于 AMR。', sz: 1100 }]);

slides[2].notes = N(
  [{ t: '零磁场读数 X₀ = 1.594（下降段）/ 1.596（上升段）；+100 mA 处 1.816，−100 mA 处 1.813。', sz: 1100 },
   { t: '0→30 mA 平均变化率 3.50×10⁻³/mA，70→100 mA 仅 1.0×10⁻⁴/mA。同 |I| 处下降段与上升段最大偏差 0.023（在 50 mA）。', sz: 1100 }],
  [{ t: '① 响应量随 |I| 单调增大，低场陡、高场平；② 高场斜率比低场小约 35 倍；③ 磁滞偏差集中在曲线最陡的中场区（30~60 mA），在低场与饱和区都明显变小；④ 正负两侧最大值仅差 0.003。', sz: 1100 }],
  [{ t: 'ΔR/R₀ = 13.93 %，半饱和 I½ = 31.4 mA，|I| > 70 mA 进入饱和。偏差的分布特征说明它主要来自励磁电流—磁场标定的路径不重复被陡峭的 dX/dI 放大，而不是 GMR 材料本身的大磁滞；左右磁路对称性良好（0.13 %）。', sz: 1100 }]);

slides[3].notes = N(
  [{ t: 'θ = 0~48°、步长 3°、共 17 点。四个极值：6°→57.3、18°→−56.5、30°→57.2、42°→−55.4 mV。', sz: 1100 },
   { t: '固定 T = 24° 作基波最小二乘：17 点 R² = 0.858、最大残差 36.6 mV；剔除 2 点后 A = 58.12 mV、R² = 0.977、残差 rms 6.10 mV。', sz: 1100 }],
  [{ t: '① 相邻极值间隔恒为 12°，两次正峰与两次负峰重复性很好；② θ = 27° 读到 0、θ = 45° 读到 −1.1 mV，模型预测 +39.1 与 −43.1 mV，偏离约 0.7 倍幅值，而其余各点均不超过 11.5 mV。', sz: 1100 }],
  [{ t: '周期 T = 24°（由极值位置直接定出，不依赖拟合），齿数 N = 360/24 = 15；峰峰值 113.8 mV；过零灵敏度 15.22 mV/°，线性区 ±2.58°，实际角分辨率 0.40°。两个坏点的实测值都落在模型过零位置差约 3°（恰一个采样步长）处，故判为转齿时计数错位，不是传感器异常。', sz: 1100 }]);

slides[4].notes = N(
  [{ t: '写入 00110011；读出 0.003 / 0.002 / 1.928 / 1.928 / 0.003 / 0.003 / 1.928 / 1.928 V。', sz: 1100 },
   { t: '低电平组最大 0.003 V，高电平组最小 1.928 V，电平差 1.925 V；取中点 0.965 V 作判决。', sz: 1100 }],
  [{ t: '两组电平之间没有任何重叠，两侧噪声容限各约 0.96 V，即电平差的一半；输出是干净的高/低二值量而非模拟量。', sz: 1100 }],
  [{ t: '译码结果 00110011（= 0x33 = 51）与写入逐位一致，误码 0/8，GMR 读出头可正确还原磁卡信息。同时观察到高电平 1.928 V 已接近输出级上限，"高电平一致"部分反映的是钳位而非磁阻线性响应；且 0/8 按三法则只能给出误码率 95 % 上限约 37.5 %，故"无误码"仅在该置信水平内成立。', sz: 1100 }]);

slides[5].notes = N(
  [{ t: '测电流：±300 mA 两行各 7 点。低偏置拟合 U = 25.914 + 0.015464·I，R² = 0.99839；适当偏置 U = 129.357 + 0.018250·I，R² = 0.99765。开关：四个阈值 15.4 / 18.5 / 16.7 / 19.1 mA。', sz: 1100 }],
  [{ t: '① 灵敏度由 15.46 升到 18.25 µV/mA，最大残差由 0.186 升到 0.343 mV，非线性度由 2.00 % 升到 3.12 % FS；两组残差符号都是"负—正—负"的系统性弯曲，不是随机散布。② 开关动作点两侧（19.1 与 18.5 mA）接近，释放点两侧（15.4 与 16.7 mA）差得多；逐格记录区仅有的两个电平格（+10 mA→低、−20 mA→高）与四个阈值自洽。', sz: 1100 }],
  [{ t: '偏置磁场使灵敏度提高 18.0 %，代价是非线性度增加约 1.1 个百分点——两者是工作点移动的一体两面；残差的系统形状说明它来自 GMR 磁阻曲线本身的非线性，可用分段拟合或查表校正消除。开关构成带回差的施密特特性，平均回差 2.75 mA；但逐格步长 10 mA 决定阈值不确定度约 ±5 mA，大于两侧回差之差 1.90 mA，因此本次数据不支持"回差存在物理不对称"这一结论。', sz: 1100 }]);

slides[6].notes = N(
  [{ t: '零点一致性：I = 0 处下降段 1.594、上升段 1.596，差 0.002（0.13 %）。扫描回线最大偏差 1.44 % FS。B、U、R 三列未填，仪器 B—I 标定曲线未记录。', sz: 1100 }],
  [{ t: '电流归零后读数未回到同一值，说明磁路存在剩磁，"零磁场"并非真正的 B = 0；磁滞偏差与不对称量都在 1~1.5 % 量级，远大于电表量化误差（约 0.03 %）。', sz: 1100 }],
  [{ t: '四条结论：① 磁阻曲线呈饱和形，ΔR/R₀ = 13.93 %、I½ = 31.4 mA，灵敏区在低场陡峭段；② 梯度模式输出周期 24° 的唯一对应 15 齿，灵敏度 15.22 mV/°；③ 开关给"有无"、线性给"多少"，平均回差 2.75 mA 是这一取舍的量化体现；④ 偏置换来 18.0 % 灵敏度、损失约 1.1 个百分点线性度。数据边界：因缺 B—I 标定，13.93 % 是归一化相对量而非绝对电阻；受 10 mA 步长限制，回差的细微不对称不能下定量结论。', sz: 1100 }]);

/* ================= 打包 ================= */
if (process.env.ONLY) slides.length = parseInt(process.env.ONLY, 10);
// 诊断用：只保留每页前 CAP 个顶层形状
if (process.env.CAP) {
  const cap = parseInt(process.env.CAP, 10);
  for (const s of slides) {
    let depth = 0, count = 0, cut = -1, i = 0;
    const re = /<p:(sp|pic)[ >]|<\/p:(sp|pic)>/g;
    let m;
    while ((m = re.exec(s.body))) {
      if (m[2]) { if (depth === 0) continue; depth--; if (depth === 0) { count++; if (count === cap) { cut = m.index + m[0].length; break; } } }
      else { if (depth === 0 && count >= cap) { cut = m.index; break; } depth++; }
    }
    if (cut >= 0 && cut < s.body.length) s.body = s.body.slice(0, cut);
    const kept = [...s.body.matchAll(/r:embed="(rId\d+)"/g)].map(x => x[1]);
    s.imgs = s.imgs.filter((_, idx) => kept.includes('rId' + (idx + 2)));
  }
}
const core = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<dc:title>巨磁阻效应及应用 答辩汇报</dc:title><dc:subject>2 分钟汇报</dc:subject><dc:language>zh-CN</dc:language>
<dcterms:created xsi:type="dcterms:W3CDTF">2026-10-23T00:00:00Z</dcterms:created></cp:coreProperties>`;
const app = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
<Application>Qoder</Application><Slides>${slides.length}</Slides><Company></Company></Properties>`;

const WITH_NOTES = !!process.env.EMBED_NOTES;   // 默认关闭：备注由 PowerPoint 自己写入
fs.writeFileSync(__dirname + '/notes.json', JSON.stringify(slides.map(s =>
  (s.notes || []).map(par => par.map(r => r.t).join('')).join('\n')
)), 'utf8');
const entries = [
  { name: '[Content_Types].xml', data: P.contentTypes(slides.length, WITH_NOTES ? slides.length : 0) },
  { name: '_rels/.rels', data: P.ROOT_RELS },
  { name: 'docProps/core.xml', data: core },
  { name: 'docProps/app.xml', data: app },
  { name: 'ppt/presentation.xml', data: P.presentation(slides.length, WITH_NOTES) },
  { name: 'ppt/_rels/presentation.xml.rels', data: P.presRels(slides.length, WITH_NOTES) },
  { name: 'ppt/presProps.xml', data: P.PRES_PROPS },
  { name: 'ppt/theme/theme1.xml', data: P.THEME },
  { name: 'ppt/slideMasters/slideMaster1.xml', data: P.SLIDE_MASTER },
  { name: 'ppt/slideMasters/_rels/slideMaster1.xml.rels', data: P.masterRels },
  { name: 'ppt/slideLayouts/slideLayout1.xml', data: P.SLIDE_LAYOUT },
  { name: 'ppt/slideLayouts/_rels/slideLayout1.xml.rels', data: P.layoutRels },
  ...slides.map((s, i) => ({ name: `ppt/slides/slide${i + 1}.xml`, data: P.slide(s.body) })),
  ...slides.map((s, i) => ({ name: `ppt/slides/_rels/slide${i + 1}.xml.rels`, data: P.slideRels(s.imgs, WITH_NOTES ? i + 1 : 0) })),
  ...(WITH_NOTES ? [
    { name: 'ppt/notesMasters/notesMaster1.xml', data: P.NOTES_MASTER },
    { name: 'ppt/notesMasters/_rels/notesMaster1.xml.rels', data: P.NOTES_MASTER_RELS },
    ...slides.map((s, i) => ({ name: `ppt/notesSlides/notesSlide${i + 1}.xml`, data: P.notesSlide(s.notes || [[{ t: '' }]]) })),
    ...slides.map((_, i) => ({ name: `ppt/notesSlides/_rels/notesSlide${i + 1}.xml.rels`, data: P.NOTES_SLIDE_RELS(i + 1) })),
  ] : []),
];
const used = [...new Set(slides.flatMap(s => s.imgs))];
for (const f of used) entries.push({ name: 'ppt/media/' + f, data: fs.readFileSync(f) });

const out = process.env.OUT || 'D:/qq下载文件/GMR巨磁阻效应及应用答辩.pptx';
fs.writeFileSync(out, P.zip(entries));
console.log('written', out, fs.statSync(out).size, 'bytes;', slides.length, 'slides;', used.length, 'images');
