const fs = require('fs');
const s = fs.readFileSync('doc.xml', 'utf8');
const txt = [...s.matchAll(/<w:t(?: [^>]*)?>([\s\S]*?)<\/w:t>/g)].map(m => m[1]).join('');
const flat = txt.replace(/\\/g, '');            // 去掉反斜杠后比对，避免 JS 字符串转义干扰
const cnt = re => (txt.match(re) || []).length;
console.log('字符数:', txt.length, ' 图:', (s.match(/<w:drawing>/g) || []).length, ' 表:', (s.match(/<w:tbl>/g) || []).length);
console.log('$ 个数:', cnt(/\$/g), '(应为偶数)  \\[ :', cnt(/\\\[/g), ' \\] :', cnt(/\\\]/g));
const need = [
  'frac{Delta R}{R_0}=frac{R(B)-R(0)}{R(0)}times 100%',
  'B = kI',
  'U(theta)=U_0+A sin(2pi theta/T+varphi)',
  'left.dfrac{mathrm{d}U}{mathrm{d}theta}right|_{max}',
  'Delta I_{mathrm{h}}=I_{mathrm{op}}-I_{mathrm{re}}',
  'V_{mathrm{th}}=0.965',
  'u=dfrac{5}{sqrt{3}}',
  'p_{95}approx 3/n=3/8',
  'N=dfrac{360^{circ}}{T}',
  'mumathrm{V/mA}',
  'dfrac{Delta R}{R_0}',
  'X_0^{prime}',
  'I_{1/2}',
  'R^2',
  'delta_{mathrm{NL}}',
  'mathrm{d}X/mathrm{d}I',
];
const miss = need.filter(t => !flat.replace(/\s+/g, '').includes(t.replace(/\s+/g, '')));
console.log('缺失 LaTeX 片段:', miss.length ? miss : '无');
const secs = ['一、实验目的', '二、实验仪器', '三、实验原理', '四、实验内容与步骤', '五、数据记录与处理', '六、误差分析与讨论', '七、实验总结与思考', '八、原始数据完整性说明', '附录 A'];
const sm = secs.filter(t => !txt.includes(t));
console.log('缺失章节:', sm.length ? sm : '无');
console.log('残留 Unicode 下标:', cnt(/[₀₁₂₃½]/g), ' 残留裸 ΔR/R0:', cnt(/ΔR\/R0/g));
for (const k of ['13.93', '31.4', '15.22', '0.965', '00110011', '15.46', '18.25', '2.75', '1.44', '0.9769'])
  if (!txt.includes(k)) console.log('!! 数值缺失', k);
console.log('数值抽查完成');
const unpaired = txt.split('$').length - 1;
console.log('美元分隔符总数:', unpaired, unpaired % 2 === 0 ? '(配对)' : '!! 有未闭合的 $');
