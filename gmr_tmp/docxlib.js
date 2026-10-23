/* 无依赖 DOCX 生成器：手写 OOXML + ZIP */
const fs = require('fs'), zlib = require('zlib');

/* ---------- ZIP ---------- */
const CRC = (() => { const t = []; for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; t[n] = c >>> 0; } return t; })();
const crc32 = buf => { let c = 0xffffffff; for (const b of buf) c = CRC[(c ^ b) & 0xff] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; };
function zip(entries) {
  const enc = s => Buffer.from(s, 'utf8');
  const now = new Date();
  const dosTime = ((now.getHours() << 11) | (now.getMinutes() << 5) | (now.getSeconds() / 2)) & 0xffff;
  const dosDate = (((now.getFullYear() - 1980) << 9) | ((now.getMonth() + 1) << 5) | now.getDate()) & 0xffff;
  const locals = [], centrals = []; let off = 0;
  for (const e of entries) {
    const name = enc(e.name), data = Buffer.isBuffer(e.data) ? e.data : enc(e.data);
    const comp = zlib.deflateRawSync(data, { level: 9 });
    const crc = crc32(data);
    const lh = Buffer.alloc(30);
    lh.writeUInt32LE(0x04034b50, 0); lh.writeUInt16LE(20, 4); lh.writeUInt16LE(0x0800, 6); lh.writeUInt16LE(8, 8);
    lh.writeUInt16LE(dosTime, 10); lh.writeUInt16LE(dosDate, 12); lh.writeUInt32LE(crc, 14);
    lh.writeUInt32LE(comp.length, 18); lh.writeUInt32LE(data.length, 22); lh.writeUInt16LE(name.length, 26);
    locals.push(lh, name, comp);
    const ch = Buffer.alloc(46);
    ch.writeUInt32LE(0x02014b50, 0); ch.writeUInt16LE(20, 4); ch.writeUInt16LE(20, 6); ch.writeUInt16LE(0x0800, 8); ch.writeUInt16LE(8, 10);
    ch.writeUInt16LE(dosTime, 12); ch.writeUInt16LE(dosDate, 14); ch.writeUInt32LE(crc, 16);
    ch.writeUInt32LE(comp.length, 20); ch.writeUInt32LE(data.length, 24); ch.writeUInt16LE(name.length, 28);
    ch.writeUInt32LE(0, 38); ch.writeUInt32LE(off, 42);
    centrals.push(ch, name);
    off += 30 + name.length + comp.length;
  }
  const cd = Buffer.concat(centrals), body = Buffer.concat(locals);
  const eo = Buffer.alloc(22);
  eo.writeUInt32LE(0x06054b50, 0); eo.writeUInt16LE(entries.length, 8); eo.writeUInt16LE(entries.length, 10);
  eo.writeUInt32LE(cd.length, 12); eo.writeUInt32LE(body.length, 16);
  return Buffer.concat([body, cd, eo]);
}

/* ---------- OOXML 片段 ---------- */
const { toOmml } = require('./omml.js');
const X = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const CM = 360000;
let ridSeq = 0; const rels = [];

const SUB = { '₀': '0', '₁': '1', '₂': '2', '₃': '3', '½': '1/2' };
const hasSub = t => /[₀₁₂₃½]/.test(t);
// 把含 Unicode 下标的文本拆成多个 run，下标改用 Word 原生 vertAlign（U+2080 不在 CP936 内，易成方框）
function subRuns(t, o) {
  const s = String(t);
  if (!hasSub(s)) return [{ t: s, sub: false }];
  const parts = []; let buf = '';
  for (const ch of s) { if (SUB[ch]) { parts.push({ t: buf, sub: false }); parts.push({ t: SUB[ch], sub: true }); buf = ''; } else buf += ch; }
  parts.push({ t: buf, sub: false });
  return parts;
}
const run = (t, o = {}) => {
  const lines = String(t).split('\n');
  const body = lines.map((line, i) => (i ? '<w:br/>' : '') + `<w:t xml:space="preserve">${X(line)}</w:t>`).join('');
  return `<w:r><w:rPr>${rPr(o)}</w:rPr>${body}</w:r>`;
};
const rPr = o =>
  `<w:rFonts w:ascii="${o.lat || 'Times New Roman'}" w:hAnsi="${o.lat || 'Times New Roman'}" w:eastAsia="${o.cn || '宋体'}"/>` +
  `${o.b ? '<w:b/><w:bCs/>' : ''}${o.i ? '<w:i/><w:iCs/>' : ''}` +
  `${o.color ? `<w:color w:val="${o.color}"/>` : ''}<w:sz w:val="${o.sz || 24}"/><w:szCs w:val="${o.sz || 24}"/>` +
  `${o.sub ? '<w:vertAlign w:val="subscript"/>' : ''}`;
const smart = s => s.replace(/"([^"\n]*)"/g, '“$1”');
// 把正文按 $...$ 切成普通文本段与 LaTeX 源码段；LaTeX 段用等宽字体，便于复制回 LaTeX 管线
function splitMath(s) {
  const out = []; const re = /\$([^$]+)\$/g; let last = 0, m;
  while ((m = re.exec(s))) {
    if (m.index > last) out.push({ t: s.slice(last, m.index), math: false });
    out.push({ t: m[1], math: true });
    last = m.index + m[0].length;
  }
  if (last < s.length) out.push({ t: s.slice(last), math: false });
  return out;
}
const mathOpt = o => ({ ...o, lat: 'Consolas', cn: 'Consolas', sz: o.sz ? Math.max(o.sz - 2, 16) : 22 });
// 组装一个段落内的全部 run；$..$ 段转成 Word 原生公式 (OMML)
const runsOf = (t, o) => {
  const out = [];
  const lines = String(t).split('\n');
  lines.forEach((line, li) => {
    if (li) out.push(`<w:r><w:rPr>${rPr(o)}</w:rPr><w:br/></w:r>`);
    for (const seg of splitMath(smart(line))) {
      if (seg.math) { out.push(toOmml(seg.t, mathOpt(o).sz)); continue; }
      for (const p of subRuns(seg.t, o)) {
        if (!p.t) continue;
        const oo = p.sub ? { ...o, sub: true } : o;
        out.push(`<w:r><w:rPr>${rPr(oo)}</w:rPr><w:t xml:space="preserve">${X(p.t)}</w:t></w:r>`);
      }
    }
  });
  return out.join('');
};
// 独立成行的显示公式：m:oMathPara，居中
const dm = tex => `<w:p><w:pPr><w:spacing w:before="120" w:after="120"/><w:jc w:val="center"/>` +
  `<w:rPr><w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math" w:eastAsia="宋体"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:pPr>` +
  `<m:oMathPara><m:oMathParaPr><m:jc m:val="center"/></m:oMathParaPr>${toOmml(tex, 24)}</m:oMathPara></w:p>`;

function para(t, o = {}) {
  const ind = o.noind ? '' : `<w:ind w:firstLine="${o.firstLine ?? 480}"/>`;
  return `<w:p><w:pPr>${o.style ? `<w:pStyle w:val="${o.style}"/>` : ''}` +
    `<w:spacing w:before="${o.before ?? 0}" w:after="${o.after ?? 60}" w:line="${o.line ?? 300}" w:lineRule="auto"/>${ind}` +
    (o.align ? `<w:jc w:val="${o.align}"/>` : '') +
    `<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="${o.cn || '宋体'}"/>` +
    `<w:sz w:val="${o.sz || 24}"/><w:szCs w:val="${o.sz || 24}"/></w:rPr></w:pPr>` +
    (Array.isArray(t) ? t.map(r => runsOf(r.t, r)).join('') : runsOf(t, o)) + '</w:p>';
}
const h1 = t => para([{ t, b: 1, sz: 30, cn: '黑体' }], { noind: true, before: 320, after: 140, line: 340 });
const h2 = t => para([{ t, b: 1, sz: 26, cn: '黑体' }], { noind: true, before: 220, after: 100 });
const h3 = t => para([{ t, b: 1, sz: 24, cn: '楷体' }], { noind: true, before: 140, after: 70 });
const body = (t, o = {}) => para(Array.isArray(t) ? t : [{ t, ...o }], { sz: 24, ...o });
const cap = t => para([{ t, sz: 21, b: 1 }], { align: 'center', noind: true, before: 60, after: 160 });

function table(rows, o = {}) {
  const cols = Math.max(...rows.map(r => r.length));
  const widths = o.w || new Array(cols).fill(Math.floor(9000 / cols));
  const tw = widths.map(w => `<w:gridCol w:w="${w}"/>`).join('');
  const bd = c => `<w:${c} w:val="single" w:sz="6" w:space="0" w:color="595959"/>`;
  const sum = widths.reduce((a, b) => a + b, 0);
  if (sum > 9306) console.warn(`!! 表宽溢出: ${sum} > 9306 twips (${rows[0] && rows[0][0]})`);
  let x = `<w:tbl><w:tblPr><w:tblW w:w="${sum}" w:type="dxa"/><w:jc w:val="center"/><w:tblBorders>${bd('top')}${bd('left')}${bd('bottom')}${bd('right')}${bd('insideH')}${bd('insideV')}</w:tblBorders>` +
    `<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="60" w:type="dxa"/><w:right w:w="60" w:type="dxa"/></w:tblCellMar></w:tblPr>` +
    `<w:tblGrid>${tw}</w:tblGrid>`;
  rows.forEach((row, ri) => {
    const hdr = ri === 0 && o.header !== false;
    x += `<w:tr>${hdr ? '<w:trPr><w:tblHeader/></w:trPr>' : ''}`;
    for (let c = 0; c < cols; c++) {
      const cell = row[c] ?? '';
      const span = (o.spans || {})[`${ri},${c}`];
      x += `<w:tc><w:tcPr><w:tcW w:w="${widths[c]}" w:type="dxa"/>` +
        (span ? `<w:gridSpan w:val="${span}"/>` : '') +
        (hdr ? '<w:shd w:val="clear" w:color="auto" w:fill="EDEFF3"/>' : '') +
        '<w:vAlign w:val="center"/></w:tcPr>' +
        para([{ t: cell, sz: o.sz || 20, b: hdr || (o.bold && o.bold.includes(ri)) }], { align: o.left && o.left.includes(c) && !hdr ? 'left' : 'center', noind: true, after: 20, before: 20, line: 240 }) +
        '</w:tc>';
    }
    x += '</w:tr>';
  });
  return x + '</w:tbl>' + '<w:p><w:pPr><w:spacing w:after="60"/></w:pPr></w:p>';
}

function image(file, wcm) {
  const b = fs.readFileSync(file);
  const w = b.readUInt32BE(16), h = b.readUInt32BE(20);
  const id = 'rId' + (++ridSeq + 100);
  rels.push({ id, target: 'media/' + file });
  const cx = Math.round(wcm * CM), cy = Math.round(wcm * h / w * CM);
  return `<w:p><w:pPr><w:spacing w:before="60" w:after="60"/><w:jc w:val="center"/></w:pPr>` +
    `<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="${cx}" cy="${cy}"/>` +
    `<wp:docPr id="${ridSeq}" name="${X(file)}"/><a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">` +
    `<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">` +
    `<pic:nvPicPr><pic:cNvPr id="${ridSeq}" name="${X(file)}"/><pic:cNvPicPr/></pic:nvPicPr>` +
    `<pic:blipFill><a:blip r:embed="${id}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>` +
    `<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${cx}" cy="${cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>` +
    `</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>`;
}

module.exports = { zip, para, run, h1, h2, h3, body, cap, table, image, rels, X, CM, dm };
