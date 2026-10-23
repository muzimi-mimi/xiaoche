import { readFileSync } from 'node:fs';
import zlib from 'node:zlib';
const buf = readFileSync(process.argv[2]);
const S = buf.toString('latin1');
const objRe = /(\d+)\s+0\s+obj\b/g;
const matches = [];
let m;
while ((m = objRe.exec(S)) !== null) matches.push({ num: +m[1], at: m.index, ds: m.index + m[0].length });
console.log('objects found:', matches.length, matches.map(x => x.num).join(','));
for (const cur of matches) {
  const end = S.indexOf('endobj', cur.ds);
  const head = S.slice(cur.ds, cur.ds + 160).replace(/\s+/g, ' ');
  console.log(cur.num, '=>', head.slice(0, 150));
}
console.log('\n--- raw top-level keywords ---');
for (const kw of ['/ObjStm', '/XRef', '/Type /Font', '/ToUnicode', '/FontFile']) {
  console.log(kw, S.split(kw).length - 1);
}
