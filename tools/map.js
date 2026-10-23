const fs = require('fs');
const zlib = require('zlib');
function load(src) {
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
  return { width, height, bpp, px, lum: (x, y) => { const i = (y * width + x) * bpp; return (px[i] + px[i + 1] + px[i + 2]) / 3; } };
}
module.exports = { load };

if (require.main === module) {
  const img = load(process.argv[2]);
  const step = Number(process.argv[3] || 4);
  let head = '      ';
  for (let x = 0; x < img.width; x += step) head += (x % 100 < step ? String(Math.floor(x / 100) % 10) : x % 50 < step ? String(Math.floor(x / 10) % 10) : ' ');
  console.log(head);
  for (let y = 0; y < img.height; y += step) {
    let row = String(y).padStart(6, ' ');
    for (let x = 0; x < img.width; x += step) {
      let min = 999;
      for (let dy = 0; dy < step; dy++) for (let dx = 0; dx < step; dx++) {
        const xx = Math.min(img.width - 1, x + dx), yy = Math.min(img.height - 1, y + dy);
        min = Math.min(min, img.lum(xx, yy));
      }
      row += min < 110 ? '#' : min < 160 ? '+' : min < 210 ? ':' : ' ';
    }
    console.log(row);
  }
}
