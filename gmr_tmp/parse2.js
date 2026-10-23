const fs = require('fs');
const path = require('path');

function decode(s) {
  return s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'").replace(/&#(\d+);/g, (_, d) => String.fromCodePoint(+d))
    .replace(/&amp;/g, '&');
}
function parseShared(xml) {
  const out = []; const re = /<si>([\s\S]*?)<\/si>/g; let m;
  while ((m = re.exec(xml))) {
    out.push([...m[1].matchAll(/<t[^>]*>([\s\S]*?)<\/t>/g)].map(x => decode(x[1])).join(''));
  }
  return out;
}
function parseCells(xml, shared) {
  const rows = [];
  const rowRe = /<row[^>]*r="(\d+)"[^>]*>([\s\S]*?)<\/row>/g; let rm;
  while ((rm = rowRe.exec(xml))) {
    const cells = [];
    const cellRe = /<c\s+([^>]*?)(?:\/>|>([\s\S]*?)<\/c>)/g; let cm;
    while ((cm = cellRe.exec(rm[2]))) {
      const attrs = cm[1], body = cm[2] || '';
      const refM = /r="([A-Z]+\d+)"/.exec(attrs); if (!refM) continue;
      const tM = /t="([^"]+)"/.exec(attrs); const type = tM ? tM[1] : 'n';
      let val = '';
      if (type === 'inlineStr') val = [...body.matchAll(/<t[^>]*>([\s\S]*?)<\/t>/g)].map(x => decode(x[1])).join('');
      else { const vM = /<v>([\s\S]*?)<\/v>/.exec(body); if (vM) { const raw = decode(vM[1]); val = type === 's' ? (shared[+raw] ?? '') : raw; } }
      if (val === '') continue;
      cells.push(refM[1] + '=' + val.replace(/\n/g, '\\n'));
    }
    if (cells.length) rows.push('R' + rm[1] + ': ' + cells.join('   '));
  }
  return rows;
}
const base = path.join(__dirname, 'out');
for (const dir of fs.readdirSync(base)) {
  const p = path.join(base, dir);
  if (!fs.statSync(p).isDirectory()) continue;
  const sp = path.join(p, 'xl/sharedStrings.xml');
  const shared = fs.existsSync(sp) ? parseShared(fs.readFileSync(sp, 'utf8')) : [];
  console.log('\n======== ' + dir + ' ========');
  const wb = fs.readFileSync(path.join(p, 'xl/workbook.xml'), 'utf8');
  console.log('SHEETS: ' + [...wb.matchAll(/<sheet[^>]*name="([^"]*)"/g)].map(m => m[1]).join(', '));
  for (const f of fs.readdirSync(path.join(p, 'xl/worksheets')).filter(f => /^sheet\d+\.xml$/.test(f))) {
    console.log('-- ' + f);
    for (const line of parseCells(fs.readFileSync(path.join(p, 'xl/worksheets', f), 'utf8'), shared)) console.log(line);
  }
}
