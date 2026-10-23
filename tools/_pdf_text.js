// Minimal PDF text extractor: inflate FlateDecode streams, pull Tj/TJ strings.
const fs = require('fs');
const zlib = require('zlib');

const file = process.argv[2];
const out = process.argv[3] || null;
const buf = fs.readFileSync(file);

let chunks = [];
let idx = 0;
let nStream = 0, nOk = 0;
while (true) {
  const s = buf.indexOf('stream', idx);
  if (s < 0) break;
  // skip CR/LF after 'stream'
  let p = s + 6;
  if (buf[p] === 0x0d) p++;
  if (buf[p] === 0x0a) p++;
  const e = buf.indexOf('endstream', p);
  if (e < 0) break;
  const raw = buf.subarray(p, e);
  nStream++;
  let data = null;
  try { data = zlib.inflateSync(raw); } catch (err) {
    try { data = zlib.inflateRawSync(raw); } catch (err2) { data = null; }
  }
  if (data) { nOk++; chunks.push(data.toString('latin1')); }
  idx = e + 9;
}

// Extract text-show operators
function pdfUnescape(str) {
  let r = '';
  for (let i = 0; i < str.length; i++) {
    const c = str[i];
    if (c !== '\\') { r += c; continue; }
    const nx = str[++i];
    if (nx === 'n') r += '\n';
    else if (nx === 'r') r += '\r';
    else if (nx === 't') r += '\t';
    else if (nx === 'b') r += '\b';
    else if (nx === 'f') r += '\f';
    else if (nx === '(' || nx === ')' || nx === '\\') r += nx;
    else if (nx >= '0' && nx <= '7') {
      let oct = nx;
      while (oct.length < 3 && str[i + 1] >= '0' && str[i + 1] <= '7') oct += str[++i];
      r += String.fromCharCode(parseInt(oct, 8));
    } else if (nx === '\n') { /* line continuation */ }
    else r += nx;
  }
  return r;
}

function extractText(content) {
  const parts = [];
  // ( ... ) Tj    and  [ ... ] TJ
  const re = /\((?:\\.|[^\\()])*\)\s*Tj|\[(?:[^\[\]\\]|\\.)*\]\s*TJ|<([0-9A-Fa-f\s]+)>\s*Tj/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    const tok = m[0];
    if (tok.startsWith('[')) {
      const inner = tok.slice(0, tok.lastIndexOf(']'));
      const reS = /\((?:\\.|[^\\()])*\)/g;
      let ms, line = '';
      while ((ms = reS.exec(inner)) !== null) line += pdfUnescape(ms[0].slice(1, -1));
      if (line.trim()) parts.push(line);
    } else if (tok.startsWith('<')) {
      const hex = m[1].replace(/\s+/g, '');
      let line = '';
      for (let i = 0; i + 3 < hex.length + 1; i += 4) {
        const code = parseInt(hex.substr(i, 4), 16);
        if (!isNaN(code)) line += String.fromCharCode(code);
      }
      if (line.trim()) parts.push(line);
    } else {
      parts.push(pdfUnescape(tok.slice(1, tok.lastIndexOf(')'))));
    }
  }
  return parts.join('');
}

let text = '';
for (const c of chunks) {
  const t = extractText(c);
  if (t) text += t + '\n';
}
// collapse whitespace a bit
text = text.replace(/\u0000/g, '').replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n');

console.log('STREAMS=' + nStream + ' INFLATED=' + nOk + ' TEXTCHARS=' + text.length);
if (out) { fs.writeFileSync(out, text, 'utf8'); console.log('WROTE ' + out); }
else console.log(text.slice(0, 4000));
