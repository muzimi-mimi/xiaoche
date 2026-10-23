import { readFileSync } from 'node:fs';
import zlib from 'node:zlib';
const buf = readFileSync(process.argv[2]);
const S = buf.toString('latin1');
const objs = new Map();
const objRe = /(\d+)\s+0\s+obj\b/g;
const matches = [];
let m;
while ((m = objRe.exec(S)) !== null) matches.push({ num: +m[1], at: m.index, ds: m.index + m[0].length });
for (let i = 0; i < matches.length; i++) {
  const cur = matches[i];
  const end = S.indexOf('endobj', cur.ds);
  const stop = end > 0 ? end : (i + 1 < matches.length ? matches[i + 1].at : S.length);
  const body = S.slice(cur.ds, stop);
  const sIdx = body.indexOf('stream');
  let dict = body, raw = null;
  if (sIdx >= 0) {
    dict = body.slice(0, sIdx);
    let st = cur.ds + sIdx + 6;
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
for (const n of [15, 20, 25, 30, 35, 49]) {
  const o = objs.get(n);
  let t = null;
  try { t = zlib.inflateSync(o.raw).toString('utf8'); } catch (e) { t = '(inflate fail)'; }
  console.log(`\n=========== Obj ${n} ToUnicode ===========`);
  console.log(t);
}
