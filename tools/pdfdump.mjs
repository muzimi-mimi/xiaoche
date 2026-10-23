import { readFileSync, writeFileSync } from 'node:fs';
import zlib from 'node:zlib';

const buf = readFileSync(process.argv[2]);
const out = [];
// find all "stream ... endstream" regions
let idx = 0;
let n = 0;
while (true) {
  const s = buf.indexOf('stream', idx);
  if (s < 0) break;
  // must be preceded by dict with obj
  let e = buf.indexOf('endstream', s);
  if (e < 0) break;
  let start = s + 6;
  if (buf[start] === 0x0d) start++;
  if (buf[start] === 0x0a) start++;
  let end = e;
  while (end > start && (buf[end - 1] === 0x0a || buf[end - 1] === 0x0d)) end--;
  const raw = buf.subarray(start, end);
  const headerStart = Math.max(0, s - 400);
  const header = buf.subarray(headerStart, s).toString('latin1');
  let text = null;
  try {
    text = zlib.inflateSync(raw).toString('latin1');
  } catch (err) {
    try { text = zlib.inflateRawSync(raw).toString('latin1'); } catch (e2) { text = null; }
  }
  if (text !== null) {
    out.push({ index: n++, header: header.slice(-250), len: text.length, text });
  }
  idx = e + 9;
}
console.log(`streams inflated: ${out.length}`);
const contentStreams = out.filter(o => /(^|[\s>])BT[\s]/.test(o.text) || o.text.includes('Tj') || o.text.includes('TJ'));
const cmapStreams = out.filter(o => o.text.includes('beginbfchar') || o.text.includes('beginbfrange') || o.text.includes('begincmap'));
console.log(`content-ish: ${contentStreams.length}, cmap-ish: ${cmapStreams.length}`);
for (const c of contentStreams) {
  console.log(`\n===== STREAM ${c.index} len=${c.len} =====`);
  console.log('HEADER:', c.header.replace(/\s+/g, ' ').slice(-200));
  console.log(c.text.slice(0, 1500));
}
writeFileSync('D:\\codex\\pdf-streams.json', JSON.stringify(out.map(o => ({ index: o.index, len: o.len, header: o.header, text: o.text })), null, 0));
