const fs = require('fs');
const P = require('./pptxlib.js');
const lvl = parseInt(process.argv[2] || '0', 10);
const { text, rect, pic } = P;

let body = '';
if (lvl >= 1) body += text(600000, 600000, 8000000, 800000, [[{ t: '测试文本 Test ① ΔR/R₀', sz: 2400, b: 1, color: '1F4E79' }]]);
if (lvl >= 2) body += rect(600000, 1600000, 4000000, 800000, 'F2F5F8', { round: true, line: 'DCE3EA' });
if (lvl >= 3) body += pic('rId2', 600000, 2800000, 4000000, 2590000);
const imgs = lvl >= 3 ? ['fig2.png'] : [];

const core = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<dc:title>mini</dc:title><dc:language>zh-CN</dc:language></cp:coreProperties>`;
const app = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"><Application>Qoder</Application></Properties>`;

const entries = [
  { name: '[Content_Types].xml', data: P.contentTypes(1) },
  { name: '_rels/.rels', data: P.ROOT_RELS },
  { name: 'docProps/core.xml', data: core },
  { name: 'docProps/app.xml', data: app },
  { name: 'ppt/presentation.xml', data: P.presentation(1) },
  { name: 'ppt/_rels/presentation.xml.rels', data: P.presRels(1) },
  { name: 'ppt/presProps.xml', data: P.PRES_PROPS },
  { name: 'ppt/theme/theme1.xml', data: P.THEME },
  { name: 'ppt/slideMasters/slideMaster1.xml', data: P.SLIDE_MASTER },
  { name: 'ppt/slideMasters/_rels/slideMaster1.xml.rels', data: P.masterRels },
  { name: 'ppt/slideLayouts/slideLayout1.xml', data: P.SLIDE_LAYOUT },
  { name: 'ppt/slideLayouts/_rels/slideLayout1.xml.rels', data: P.layoutRels },
  { name: 'ppt/slides/slide1.xml', data: P.slide(body) },
  { name: 'ppt/slides/_rels/slide1.xml.rels', data: P.slideRels(imgs) },
  ...imgs.map(f => ({ name: 'ppt/media/' + f, data: fs.readFileSync(f) })),
];
const out = 'mini.pptx';
fs.writeFileSync(out, P.zip(entries));
console.log('lvl', lvl, '->', out, fs.statSync(out).size);
