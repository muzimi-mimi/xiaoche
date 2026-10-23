import { readFileSync, writeFileSync } from 'node:fs';
import zlib from 'node:zlib';

const path = process.argv[2];
const buf = readFileSync(path);
const S = buf.toString('latin1');

// ---- index all indirect objects ----
const objs = new Map(); // num -> {num, dict, raw}
const objRe = /(\d+)\s+0\s+obj\b/g;
const matches = [];
let m;
while ((m = objRe.exec(S)) !== null) matches.push({ num: +m[1], at: m.index, dictStart: m.index + m[0].length });
for (let i = 0; i < matches.length; i++) {
  const cur = matches[i];
  const end = S.indexOf('endobj', cur.dictStart);
  const stop = end > 0 ? end : (i + 1 < matches.length ? matches[i + 1].at : S.length);
  const body = S.slice(cur.dictStart, stop);
  const sIdx = body.indexOf('stream');
  let dict = body;
  let raw = null;
  if (sIdx >= 0) {
    dict = body.slice(0, sIdx);
    let st = cur.dictStart + sIdx + 6;
    if (buf[st] === 0x0d) st++;
    if (buf[st] === 0x0a) st++;
    let en = S.indexOf('endstream', st);
    if (en < 0) en = stop;
    let e2 = en;
    while (e2 > st && (buf[e2 - 1] === 0x0a || buf[e2 - 1] === 0x0d)) e2--;
    raw = buf.subarray(st, e2);
  }
  objs.set(cur.num, { num: cur.num, dict, raw });
}

function inflate(o) {
  if (!o || !o.raw) return null;
  const head = o.dict;
  if (!/FlateDecode/.test(head)) return o.raw.toString('latin1');
  for (const fn of [zlib.inflateSync, zlib.inflateRawSync]) {
    try { return fn(o.raw).toString('latin1'); } catch (e) { /* next */ }
  }
  return null;
}
function refNum(dict, key) {
  const r = new RegExp('/' + key + '\\s+(\\d+)\\s+0\\s+R').exec(dict);
  return r ? +r[1] : null;
}

// ---- parse ToUnicode CMaps ----
function parseCMap(txt) {
  const map = new Map();
  const hexToStr = (h) => {
    h = h.replace(/\s+/g, '');
    let out = '';
    for (let i = 0; i + 4 <= h.length; i += 4) out += String.fromCharCode(parseInt(h.substr(i, 4), 16));
    return out;
  };
  let re = /beginbfchar([\s\S]*?)endbfchar/g, mm;
  while ((mm = re.exec(txt)) !== null) {
    const body = mm[1];
    const pr = /<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]*)>/g;
    let p;
    while ((p = pr.exec(body)) !== null) map.set(parseInt(p[1], 16), hexToStr(p[2]));
  }
  re = /beginbfrange([\s\S]*?)endbfrange/g;
  while ((mm = re.exec(txt)) !== null) {
    const body = mm[1];
    const pr = /<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*(<([0-9A-Fa-f]*)>|\[([\s\S]*?)\])/g;
    let p;
    while ((p = pr.exec(body)) !== null) {
      const lo = parseInt(p[1], 16), hi = parseInt(p[2], 16);
      if (p[4] !== undefined) {
        const base = p[4].replace(/\s+/g, '');
        for (let c = lo; c <= hi; c++) {
          const off = (c - lo) * 4;
          map.set(c, hexToStr(base.substr(off, 4)));
        }
      } else if (p[5] !== undefined) {
        const items = p[5].match(/<([0-9A-Fa-f]*)>/g) || [];
        items.forEach((it, i) => { if (lo + i <= hi) map.set(lo + i, hexToStr(it.replace(/[<>]/g, ''))); });
      }
    }
  }
  return map;
}

// font object -> cmap
const fontCMap = new Map();
const fontInfo = new Map();
for (const [num, o] of objs) {
  if (!/\/Type\s*\/Font/.test(o.dict)) continue;
  let tu = refNum(o.dict, 'ToUnicode');
  let cmap = null;
  if (tu && objs.has(tu)) {
    const t = inflate(objs.get(tu));
    if (t) cmap = parseCMap(t);
  }
  let desc = null;
  // descend into Type0 descendant
  const dfs = /\/DescendantFonts\s*\[\s*(\d+)\s+0\s+R/.exec(o.dict);
  if (dfs && objs.has(+dfs[1])) {
    const d = objs.get(+dfs[1]);
    if (!cmap) {
      const tu2 = refNum(d.dict, 'ToUnicode');
      if (tu2 && objs.has(tu2)) { const t = inflate(objs.get(tu2)); if (t) cmap = parseCMap(t); }
    }
  }
  fontCMap.set(num, cmap);
  fontInfo.set(num, { dict: o.dict.slice(0, 300), hasCMap: !!cmap, size: cmap ? cmap.size : 0 });
}

// ---- pages ----
const pages = [];
for (const [num, o] of objs) {
  if (!/\/Type\s*\/Page[^s]/.test(o.dict)) continue;
  const cRef = refNum(o.dict, 'Contents');
  const resIdx = o.dict.indexOf('/Resources');
  let fontMap = new Map();
  // parse /Font <</F1 12 0 R ...>>  (may be inline dict or indirect)
  let resDict = o.dict;
  const resRef = /\/Resources\s+(\d+)\s+0\s+R/.exec(o.dict);
  if (resRef && objs.has(+resRef[1])) resDict = objs.get(+resRef[1]).dict;
  const fIdx = resDict.indexOf('/Font');
  if (fIdx >= 0) {
    let sub = resDict.slice(fIdx + 5, fIdx + 3000);
    const refForm = /^(\d+)\s+0\s+R\b/.exec(sub.trim().slice(0, 20));
    if (refForm && objs.has(+refForm[1])) sub = objs.get(+refForm[1]).dict;
    const fm = /<<([\s\S]*?)>>/.exec(sub);
    const body = fm ? fm[1] : sub;
    const pr = /\/([A-Za-z0-9_.]+)\s+(\d+)\s+0\s+R/g;
    let p;
    while ((p = pr.exec(body)) !== null) fontMap.set(p[1], +p[2]);
  }
  pages.push({ num, cRef, fontMap });
}

function decodeHex(hex, cmap) {
  hex = hex.replace(/\s+/g, '');
  let out = '';
  for (let i = 0; i + 4 <= hex.length; i += 4) {
    const code = parseInt(hex.substr(i, 4), 16);
    if (cmap && cmap.has(code)) out += cmap.get(code);
    else out += '\uFFFD{' + code.toString(16) + '}';
  }
  return out;
}

const result = [];
pages.forEach((page, pi) => {
  const stream = inflate(objs.get(page.cRef));
  if (!stream) return;
  const items = [];
  let tm = [1, 0, 0, 1, 0, 0];
  let tlm = [1, 0, 0, 1, 0, 0];
  let curFont = null, curSize = 0;
  const tokRe = /\/([A-Za-z0-9_.]+)\s+([\d.]+)\s+Tf|\[([^\]]*)\]\s*TJ|<([0-9A-Fa-f\s]*)>\s*Tj|\(((?:\\.|[^\\()])*)\)\s*Tj|([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+Tm|([-\d.]+)\s+([-\d.]+)\s+(TD|Td)|(T\*)|([-\d.]+)\s+TL/g;
  let t;
  while ((t = tokRe.exec(stream)) !== null) {
    if (t[1] !== undefined) { curFont = t[1]; curSize = parseFloat(t[2]); }
    else if (t[3] !== undefined) {
      const parts = t[3].match(/<([0-9A-Fa-f\s]*)>|\(((?:\\.|[^\\()])*)\)|([-\d.]+)/g) || [];
      let s = '';
      for (const p of parts) {
        if (p.startsWith('<')) s += decodeHex(p.slice(1, -1), fontCMap.get(page.fontMap.get(curFont)));
        else if (p.startsWith('(')) s += p.slice(1, -1);
      }
      if (s) items.push({ x: tm[4], y: tm[5], s, font: curFont, size: curSize });
    }
    else if (t[4] !== undefined) {
      const s = decodeHex(t[4], fontCMap.get(page.fontMap.get(curFont)));
      if (s) items.push({ x: tm[4], y: tm[5], s, font: curFont, size: curSize });
    }
    else if (t[5] !== undefined) {
      const s = t[5].replace(/\\([()\\])/g, '$1');
      if (s) items.push({ x: tm[4], y: tm[5], s, font: curFont, size: curSize });
    }
    else if (t[6] !== undefined) {
      const a = +t[6], b = +t[7], c = +t[8], d = +t[9], e = +t[10], f = +t[11];
      tm = [a, b, c, d, e, f]; tlm = [a, b, c, d, e, f];
    }
    else if (t[12] !== undefined) {
      const tx = +t[12], ty = +t[13];
      const ne = tx * tlm[0] + ty * tlm[2] + tlm[4];
      const nf = tx * tlm[1] + ty * tlm[3] + tlm[5];
      tlm = [tlm[0], tlm[1], tlm[2], tlm[3], ne, nf];
      tm = tlm.slice();
    } else if (t[15] !== undefined) {
      const ne = tlm[4] - 0 * 0;
      tlm = [tlm[0], tlm[1], tlm[2], tlm[3], tlm[4], tlm[5]];
      tm = tlm.slice();
    } else if (t[16] !== undefined) { /* TL */ }
  }
  // group into lines by y
  const rows = [];
  const sorted = items.slice().sort((a, b) => (a.y - b.y) || (a.x - b.x));
  for (const it of sorted) {
    let row = rows.find(r => Math.abs(r.y - it.y) < 1.5);
    if (!row) { row = { y: it.y, items: [] }; rows.push(row); }
    row.items.push(it);
  }
  rows.sort((a, b) => a.y - b.y);
  const lines = rows.map(r => {
    r.items.sort((a, b) => a.x - b.x);
    let out = '';
    let prevEnd = null;
    for (const it of r.items) {
      if (prevEnd !== null) {
        const gap = it.x - prevEnd;
        if (gap > 6) out += ' ';
      }
      out += it.s;
      prevEnd = it.x + it.s.length * 11;
    }
    return { y: Math.round(r.y * 100) / 100, text: out.trim(), fonts: [...new Set(r.items.map(i => i.font))].join(',') };
  }).filter(l => l.text);
  result.push({ page: pi + 1, objNum: page.num, lines });
});

let outTxt = '';
for (const p of result) {
  outTxt += `\n\n########## PAGE ${p.page} (obj ${p.objNum}) ##########\n`;
  for (const l of p.lines) outTxt += `[y=${l.y}] ${l.text}\n`;
}
writeFileSync('D:\\codex\\pdf-text.txt', outTxt, 'utf8');
console.log(outTxt.slice(0, 12000));
console.log('\n---- FONTS ----');
for (const [k, v] of fontInfo) console.log(k, JSON.stringify(v).slice(0, 200));
