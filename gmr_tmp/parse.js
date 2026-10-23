const fs = require('fs');
const path = require('path');

function decode(s) {
  return s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'").replace(/&#(\d+);/g, (_, d) => String.fromCodePoint(+d))
    .replace(/&amp;/g, '&');
}

function colToIdx(ref) {
  const m = /^([A-Z]+)(\d+)$/.exec(ref);
  if (!m) return null;
  let c = 0;
  for (const ch of m[1]) c = c * 26 + (ch.charCodeAt(0) - 64);
  return { col: c - 1, row: +m[2] - 1 };
}

function parseShared(xml) {
  const out = [];
  const re = /<si>([\s\S]*?)<\/si>/g;
  let m;
  while ((m = re.exec(xml))) {
    const t = [...m[1].matchAll(/<t[^>]*>([\s\S]*?)<\/t>/g)].map(x => decode(x[1])).join('');
    out.push(t);
  }
  return out;
}

function parseSheet(xml, shared) {
  const grid = [];
  const rowRe = /<row[^>]*r="(\d+)"[^>]*>([\s\S]*?)<\/row>/g;
  let rm;
  while ((rm = rowRe.exec(xml))) {
    const rowIdx = +rm[1] - 1;
    const cellRe = /<c\s+([^>]*?)(?:\/>|>([\s\S]*?)<\/c>)/g;
    let cm;
    while ((cm = cellRe.exec(rm[2]))) {
      const attrs = cm[1];
      const body = cm[2] || '';
      const refM = /r="([A-Z]+\d+)"/.exec(attrs);
      const tM = /t="([^"]+)"/.exec(attrs);
      const type = tM ? tM[1] : 'n';
      const idx = refM ? colToIdx(refM[1]) : null;
      if (!idx) continue;
      let val = '';
      if (type === 'inlineStr') {
        val = [...body.matchAll(/<t[^>]*>([\s\S]*?)<\/t>/g)].map(x => decode(x[1])).join('');
      } else {
        const vM = /<v>([\s\S]*?)<\/v>/.exec(body);
        if (vM) {
          const raw = decode(vM[1]);
          val = type === 's' ? (shared[+raw] ?? '') : raw;
        }
      }
      if (val === '') continue;
      (grid[rowIdx] ||= []);
      grid[rowIdx][idx.col] = val;
    }
  }
  return grid;
}

const base = path.join(__dirname, 'out');
for (const dir of fs.readdirSync(base)) {
  const p = path.join(base, dir);
  if (!fs.statSync(p).isDirectory()) continue;
  const sharedPath = path.join(p, 'xl/sharedStrings.xml');
  const shared = fs.existsSync(sharedPath) ? parseShared(fs.readFileSync(sharedPath, 'utf8')) : [];
  const sheetPath = path.join(p, 'xl/worksheets/sheet1.xml');
  const grid = parseSheet(fs.readFileSync(sheetPath, 'utf8'), shared);
  console.log('\n==================== ' + dir + ' ====================');
  grid.forEach((row, i) => {
    if (!row) return;
    console.log('R' + (i + 1) + ' | ' + row.map(c => c === undefined ? '' : c).join(' | '));
  });
}
