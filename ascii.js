const fs = require('fs');
const zlib = require('zlib');
const src = process.argv[2];
const buf = fs.readFileSync(src);
let pos = 8, width, height, colorType, bitDepth;
const idat = [];
while (pos < buf.length) {
  const len = buf.readUInt32BE(pos);
  const type = buf.toString('ascii', pos + 4, pos + 8);
  const data = buf.slice(pos + 8, pos + 8 + len);
  if (type === 'IHDR') { width = data.readUInt32BE(0); height = data.readUInt32BE(4); bitDepth = data[8]; colorType = data[9]; }
  else if (type === 'IDAT') idat.push(data);
  pos += 12 + len;
}
if (bitDepth !== 8) throw new Error('bitdepth ' + bitDepth);
const bpp = colorType === 6 ? 4 : colorType === 2 ? 3 : 1;
const raw = zlib.inflateSync(Buffer.concat(idat));
const stride = width * bpp;
const px = Buffer.alloc(height * stride);
let rp = 0;
for (let y = 0; y < height; y++) {
  const f = raw[rp++];
  const line = raw.slice(rp, rp + stride); rp += stride;
  const cur = px.slice(y * stride, (y + 1) * stride);
  const prev = y > 0 ? px.slice((y - 1) * stride, y * stride) : Buffer.alloc(stride);
  for (let x = 0; x < stride; x++) {
    const a = x >= bpp ? cur[x - bpp] : 0, b = prev[x], c = x >= bpp ? prev[x - bpp] : 0;
    let v = line[x];
    if (f === 1) v += a; else if (f === 2) v += b;
    else if (f === 3) v += (a + b) >> 1;
    else if (f === 4) { const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c); v += (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c); }
    cur[x] = v & 255;
  }
}
const lum = (x, y) => { const i = (y * width + x) * bpp; return (px[i] + px[i + 1] + px[i + 2]) / 3; };
const [x0, y0, w, h] = process.argv.slice(3, 7).map(Number);
let head = '     ';
for (let x = x0; x < x0 + w; x++) head += (x % 10 === 0 ? String(Math.floor(x / 10) % 10) : (x % 5 === 0 ? ' ' : ' '));
console.log(head);
for (let y = y0; y < y0 + h; y++) {
  let row = String(y).padStart(5, ' ');
  for (let x = x0; x < x0 + w; x++) {
    const v = lum(x, y);
    row += v < 100 ? '#' : v < 150 ? '+' : v < 200 ? ':' : v < 235 ? '.' : ' ';
  }
  console.log(row);
}
