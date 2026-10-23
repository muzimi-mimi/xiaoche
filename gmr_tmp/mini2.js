const fs = require('fs');
const P = require('./pptxlib.js');
const mode = process.argv[2] || 'a';      // a=无notes  b=加notesMaster  c=再加1个notesSlide
const { text } = P;

let body = text(600000, 600000, 8000000, 800000, [[{ t: '测试文本 Test ① ΔR/R₀', sz: 2400, b: 1, color: '1F4E79' }]]);
const imgs = [];
const hasMaster = mode !== 'a';
const hasSlides = mode === 'c';

const core = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>mini2</dc:title><dc:language>zh-CN</dc:language></cp:coreProperties>`;
const app = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"><Application>Qoder</Application></Properties>`;

const entries = [
  { name: '[Content_Types].xml', data: P.contentTypes(1, hasSlides ? 1 : 0, hasMaster) },
  { name: '_rels/.rels', data: P.ROOT_RELS },
  { name: 'docProps/core.xml', data: core },
  { name: 'docProps/app.xml', data: app },
  { name: 'ppt/presentation.xml', data: P.presentation(1, hasMaster) },
  { name: 'ppt/_rels/presentation.xml.rels', data: P.presRels(1, hasMaster) },
  { name: 'ppt/presProps.xml', data: P.PRES_PROPS },
  { name: 'ppt/theme/theme1.xml', data: P.THEME },
  { name: 'ppt/slideMasters/slideMaster1.xml', data: P.SLIDE_MASTER },
  { name: 'ppt/slideMasters/_rels/slideMaster1.xml.rels', data: P.masterRels },
  { name: 'ppt/slideLayouts/slideLayout1.xml', data: P.SLIDE_LAYOUT },
  { name: 'ppt/slideLayouts/_rels/slideLayout1.xml.rels', data: P.layoutRels },
  { name: 'ppt/slides/slide1.xml', data: P.slide(body) },
  { name: 'ppt/slides/_rels/slide1.xml.rels', data: P.slideRels(imgs, hasSlides ? 1 : 0) },
];
if (hasMaster) {
  entries.push({ name: 'ppt/notesMasters/notesMaster1.xml', data: P.NOTES_MASTER });
  entries.push({ name: 'ppt/notesMasters/_rels/notesMaster1.xml.rels', data: P.NOTES_MASTER_RELS });
}
if (hasSlides) {
  entries.push({ name: 'ppt/notesSlides/notesSlide1.xml', data: P.notesSlide([[{ t: '【数据】  ', b: 1 }, { t: '这是一条测试备注。' }]]) });
  entries.push({ name: 'ppt/notesSlides/_rels/notesSlide1.xml.rels', data: P.NOTES_SLIDE_RELS(1) });
}
fs.writeFileSync('mini2.pptx', P.zip(entries));
console.log(mode, '->', fs.statSync('mini2.pptx').size);
