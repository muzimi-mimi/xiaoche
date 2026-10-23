const fs = require('fs');
let s = fs.readFileSync('build_ppt.js', 'utf8');
const pairs = [
  ['曲线低场陡峭、70 mA 后斜率降约 35 倍进入饱和——工作点必须选在陡峭区。',
   '曲线低场陡峭、70 mA 后斜率降约 35 倍进入饱和，灵敏区集中在低场陡峭段。'],
  ['→ 判为齿数错一格，建议复测。', '→ 判为齿数计数错位，而非传感器异常。'],
  ["[{ t: '两点保留意见：', sz: 1250, b: 1, color: C.red }]",
   "[{ t: '数据边界：', sz: 1250, b: 1, color: C.red }]"],
  ["[{ t: '下一步：记录 B—I 标定曲线；角位移加密到 1° 并双向复测；磁记录扩到 32 位以上。', sz: 1200, b: 1, color: C.red }]",
   "[{ t: '本次数据的边界：缺 B—I 标定曲线，故 13.93 % 是归一化相对量而非绝对电阻；开关阈值受 10 mA 步长限制，不确定度 ±5 mA 大于两侧回差之差 1.90 mA。', sz: 1200, b: 1, color: C.red }]"],
];
let n = 0;
for (const [a, b] of pairs) {
  if (!s.includes(a)) { console.log('未命中:', a.slice(0, 30)); continue; }
  s = s.split(a).join(b); n++;
}
fs.writeFileSync('build_ppt.js', s);
console.log('应用', n, '/', pairs.length);
