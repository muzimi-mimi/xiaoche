/* LaTeX 子集 → OMML(Office Math Markup Language)，供 Word 原生公式使用 */
const X = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const SYM = {
  Delta: 'Δ', Sigma: 'Σ', Omega: 'Ω', Alpha: 'Α', theta: 'θ', phi: 'φ', varphi: 'φ', pi: 'π', mu: 'μ',
  alpha: 'α', beta: 'β', gamma: 'γ', delta: 'δ', epsilon: 'ε', lambda: 'λ', rho: 'ρ', sigma: 'σ', tau: 'τ', omega: 'ω',
  approx: '≈', times: '×', cdot: '·', div: '÷', le: '≤', leq: '≤', ge: '≥', geq: '≥', pm: '±', mp: '∓',
  ne: '≠', neq: '≠', sim: '∼', propto: '∝', infty: '∞', partial: '∂', nabla: '∇', prime: '′', circ: '∘',
  rightarrow: '→', to: '→', leftarrow: '←', Rightarrow: '⇒', Leftrightarrow: '⇔', ldots: '…', cdots: '…',
  in: '∈', notin: '∉', subset: '⊂', cup: '∪', cap: '∩', forall: '∀', exists: '∃',
  '%': '%', '&': '&', '#': '#', '_': '_', '$': '$', '{': '{', '}': '}', '|': '‖',
};
const FUNCS = new Set(['sin', 'cos', 'tan', 'log', 'ln', 'exp', 'max', 'min', 'lim', 'arctan', 'sinh', 'cosh', 'tanh', 'det', 'gcd']);
const STYCMD = new Set(['mathrm', 'text', 'textrm', 'mathbf', 'mathit', 'mathsf', 'operatorname', 'bm']);
const SPACE = new Set(['quad', 'qquad', ',', ';', ':', '!']);

function tokenize(src) {
  const t = []; let i = 0;
  while (i < src.length) {
    const c = src[i];
    if (c === '\\') {
      const nx = src[i + 1] || '';
      if (/[a-zA-Z]/.test(nx)) {
        let j = i + 1; while (j < src.length && /[a-zA-Z]/.test(src[j])) j++;
        t.push({ k: 'cmd', v: src.slice(i + 1, j) }); i = j;
        if (src[i] === ' ') i++;            // LaTeX 语义：命令后的单个空格被吞掉
        continue;
      }
      else { t.push({ k: 'cmd', v: nx }); i += 2; }
      continue;
    }
    if ('{}_^'.includes(c)) { t.push({ k: c }); i++; continue; }
    if (c === ' ') { t.push({ k: 'sp' }); i++; continue; }
    t.push({ k: 'ch', v: c }); i++;
  }
  return t;
}

function parse(tex) {
  const tk = tokenize(tex);
  let i = 0;
  const peek = () => tk[i];
  const arg = () => {
    const t0 = peek();
    if (!t0) return { t: 'row', items: [] };
    if (t0.k === '{') { i++; return row(true); }
    i++;
    if (t0.k === 'ch') return { t: 'row', items: [{ t: 'sym', v: t0.v }] };
    if (t0.k === 'sp') return { t: 'row', items: [] };
    return { t: 'row', items: [cmdNode(t0.v)] };
  };
  function cmdNode(name) {
    if (name === 'frac' || name === 'dfrac' || name === 'tfrac' || name === 'cfrac') { const n = arg(), d = arg(); return { t: 'frac', num: n, den: d }; }
    if (name === 'sqrt') return { t: 'rad', e: arg() };
    if (name === 'overline') return { t: 'bar', e: arg(), pos: 'top' };
    if (name === 'underline') return { t: 'bar', e: arg(), pos: 'bot' };
    if (STYCMD.has(name)) { const a = arg(); return { t: 'sty', sty: (name === 'mathbf' ? 'b' : name === 'mathit' ? 'i' : 'p'), items: a.items }; }
    if (SPACE.has(name)) return { t: 'sp', v: name === 'quad' || name === 'qquad' ? '  ' : '' };
    if (name === 'left' || name === 'right') return { t: 'raw', v: '\\' + name };
    if (FUNCS.has(name)) return { t: 'sym', v: name, sty: 'p' };
    if (SYM[name] !== undefined) return { t: 'sym', v: SYM[name] };
    return { t: 'sym', v: name };            // 未知命令：去掉反斜杠原样输出，绝不丢内容
  }
  function row(stopAtBrace) {
    const items = [];
    while (i < tk.length) {
      const t0 = tk[i];
      if (t0.k === '}') { i++; if (stopAtBrace) return { t: 'row', items }; break; }
      if (t0.k === '{') { i++; items.push(row(true)); continue; }
      if (t0.k === 'sp') { i++; items.push({ t: 'sp', v: ' ' }); continue; }
      if (t0.k === '_' || t0.k === '^') {
        i++;
        const s = arg();
        const base = items.pop() || { t: 'row', items: [] };
        if (base.t === 'sSub' && t0.k === '^') items.push({ t: 'sSubSup', e: base.e, sub: base.sub, sup: s });
        else if (base.t === 'sSup' && t0.k === '_') items.push({ t: 'sSubSup', e: base.e, sub: s, sup: base.sup });
        else items.push(t0.k === '_' ? { t: 'sSub', e: base, sub: s } : { t: 'sSup', e: base, sup: s });
        continue;
      }
      if (t0.k === 'cmd') {
        const name = t0.v;
        if (name === 'left') {
          i++;
          let beg = tk[i] ? tk[i].v : '';
          if (tk[i] && tk[i].k === 'cmd' && tk[i].v === '.') beg = '';
          i++;
          const inner = [];
          while (i < tk.length && !(tk[i].k === 'cmd' && tk[i].v === 'right')) {
            const save = { i }; const n = single(); if (n) inner.push(n); else i = save.i + 1;
          }
          i++;                                   // 吃掉 \right
          let end = tk[i] ? tk[i].v : '';
          if (tk[i] && tk[i].k === 'cmd' && tk[i].v === '.') end = '';
          i++;
          items.push({ t: 'd', beg, end, e: { t: 'row', items: inner } });
          continue;
        }
        i++; items.push(cmdNode(name)); continue;
      }
      i++; items.push({ t: 'sym', v: t0.v });
    }
    return { t: 'row', items };
  }
  function single() {
    const t0 = peek(); if (!t0) return null;
    if (t0.k === 'ch') { i++; return { t: 'sym', v: t0.v }; }
    if (t0.k === 'sp') { i++; return { t: 'sp', v: ' ' }; }
    if (t0.k === '{') { i++; return row(true); }
    if (t0.k === 'cmd') { const nm = t0.v; i++; return cmdNode(nm); }
    return null;
  }
  const out = row(false);
  return out.items;
}

/* ---- 发射 OMML ---- */
let SZ = 22;
const rPr = sty => (sty ? `<m:rPr><m:sty m:val="${sty}"/></m:rPr>` : '') +
  `<w:rPr><w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math" w:eastAsia="宋体"/><w:sz w:val="${SZ}"/><w:szCs w:val="${SZ}"/></w:rPr>`;
const run = (txt, sty) => `<m:r>${rPr(sty)}<m:t xml:space="preserve">${X(txt)}</m:t></m:r>`;
const rowOf = items => items.map(o).join('');

function collapseDeg(items) {
  // 360^\circ 这类上标度数直接落成 ° ，避免公式里出现孤立的 ∘
  return items.map(it => {
    if (it.t === 'sSup') {
      const supTxt = txtOf(it.sup.items);
      if (/^[∘°]$/.test(supTxt)) return { t: 'row', items: [it.e, { t: 'sym', v: '°' }] };
    }
    return it;
  });
}
function txtOf(items) { return items.map(it => it.t === 'sym' ? it.v : it.t === 'sp' ? (it.v || '') : it.t === 'row' ? txtOf(it.items) : '').join(''); }

function o(it) {
  if (it.t === 'sym') return run(it.v, it.sty);
  if (it.t === 'sp') return it.v ? run(it.v) : '';
  if (it.t === 'raw') return run(it.v);
  if (it.t === 'row') return rowOf(collapseDeg(it.items));
  if (it.t === 'grp') return rowOf(collapseDeg(it.items));
  if (it.t === 'sty') return it.items.length === 1 && it.items[0].t === 'row'
    ? run(txtOf(it.items[0].items), it.sty) : run(txtOf(it.items), it.sty);
  if (it.t === 'frac') return `<m:f><m:fPr><m:type m:val="bar"/></m:fPr><m:num>${rowOf(it.num.items)}</m:num><m:den>${rowOf(it.den.items)}</m:den></m:f>`;
  if (it.t === 'rad') return `<m:rad><m:radPr><m:degHide m:val="1"/></m:radPr><m:deg/><m:e>${rowOf(it.e.items)}</m:e></m:rad>`;
  if (it.t === 'bar') return `<m:bar><m:barPr><m:pos m:val="${it.pos}"/></m:barPr><m:e>${rowOf(it.e.items)}</m:e></m:bar>`;
  if (it.t === 'd') {
    const pr = (it.beg === '(' && it.end === ')' || it.beg === '' && it.end === ')' || it.beg === '(' && it.end === '') ? '' :
      `<m:dPr>${it.beg !== '(' ? `<m:begChr m:val="${X(it.beg)}"/>` : ''}${it.end !== ')' ? `<m:endChr m:val="${X(it.end)}"/>` : ''}</m:dPr>`;
    return `<m:d>${pr}<m:e>${rowOf(it.e.items)}</m:e></m:d>`;
  }
  if (it.t === 'sSub') return `<m:sSub><m:e>${rowOf(it.e.items || [it.e].filter(Boolean))}</m:e><m:sub>${rowOf(it.sub.items)}</m:sub></m:sSub>`;
  if (it.t === 'sSup') return `<m:sSup><m:e>${rowOf(it.e.items || [it.e].filter(Boolean))}</m:e><m:sup>${rowOf(it.sup.items)}</m:sup></m:sSup>`;
  if (it.t === 'sSubSup') return `<m:sSubSup><m:e>${rowOf(it.e.items || [it.e].filter(Boolean))}</m:e><m:sub>${rowOf(it.sub.items)}</m:sub><m:sup>${rowOf(it.sup.items)}</m:sup></m:sSubSup>`;
  return run(JSON.stringify(it));
}
// 基元可能是单个 sym 节点（如 X_0 里的 X），统一包成 row
function norm(it) { return it.t === 'row' || it.t === 'grp' ? it : { t: 'row', items: [it] }; }

function toOmml(tex, size) {
  SZ = size || 22;
  let items;
  try { items = parse(tex); } catch (e) { return run('$' + tex + '$', 'p'); }
  items = items.map(x => (x && x.t === 'sSub') ? { ...x, e: norm(x.e) } : (x && x.t === 'sSup') ? { ...x, e: norm(x.e) } : (x && x.t === 'sSubSup') ? { ...x, e: norm(x.e) } : x);
  return `<m:oMath>${rowOf(collapseDeg(items))}</m:oMath>`;
}
module.exports = { toOmml, parse };
