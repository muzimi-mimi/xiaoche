/* 无依赖 PPTX 生成层：手写 PresentationML + 复用 docxlib 的 ZIP */
const fs = require('fs');
const { zip } = require('./docxlib.js');
const E = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

const SW = 12192000, SH = 6858000;            // 16:9 EMU
const CM = 360000;
const emu = cm => Math.round(cm * CM);

let idSeq = 1;
const nextId = () => ++idSeq;

/* ---------- 文本 ---------- */
function run(t, o = {}) {
  const clr = o.color ? `<a:solidFill><a:srgbClr val="${o.color}"/></a:solidFill>` : '<a:solidFill><a:srgbClr val="262626"/></a:solidFill>';
  const fonts = o.mono
    ? '<a:latin typeface="Consolas"/><a:ea typeface="Consolas"/><a:cs typeface="Consolas"/>'
    : `<a:latin typeface="${o.latin || 'Microsoft YaHei'}"/><a:ea typeface="${o.ea || '微软雅黑'}"/><a:cs typeface="${o.ea || '微软雅黑'}"/>`;
  return `<a:r><a:rPr lang="zh-CN" altLang="en-US" sz="${o.sz || 1800}"${o.b ? ' b="1"' : ''}${o.i ? ' i="1"' : ''}${o.sub ? ' baseline="-25000"' : o.sup ? ' baseline="30000"' : ''} dirty="0">${clr}${fonts}</a:rPr><a:t>${E(t)}</a:t></a:r>`;
}
function ap(runs, o = {}) {
  const open = `<a:pPr${o.align ? ` algn="${o.align}"` : ''} marL="0" indent="0"`;
  const ppr = o.spcBef ? `${open}><a:spcBef><a:spcPts val="${o.spcBef}"/></a:spcBef></a:pPr>` : `${open}/>`;
  return `<a:p>${ppr}` + (runs.length ? runs.map(r => r).join('') : '<a:endParaRPr lang="zh-CN"/>') + '</a:p>';
}
// 把 ΔR/R₀、p₉₅ 这类 Unicode 下标拆成 baseline 真下标（U+2080-2089 不在 CP936，易成方框）
const SUBMAP = { '₀': '0', '₁': '1', '₂': '2', '₃': '3', '₄': '4', '₅': '5', '₆': '6', '₇': '7', '₈': '8', '₉': '9' };
function expandSub(t) {
  const s = String(t);
  if (!/[₀₁₂₃₄₆₇₈₉]/.test(s)) return [{ t: s, sub: false }];
  const out = []; let buf = '';
  for (const ch of s) {
    if (SUBMAP[ch]) { if (buf) { out.push({ t: buf, sub: false }); buf = ''; } out.push({ t: SUBMAP[ch], sub: true }); }
    else buf += ch;
  }
  if (buf) out.push({ t: buf, sub: false });
  return out;
}
// 文本框；paras = [ [ {t,sz,b,color,mono,...}, ... ], ... ]
function text(x0, y0, w0, h0, paras, o = {}) {
  const [x, y, w, h] = [x0, y0, w0, h0].map(v => Math.round(v));
  const xml = paras.map(runs => {
    const out = [];
    for (const r of runs) for (const p of expandSub(r.t)) out.push(run(p.t, { ...o, ...r, sub: p.sub ? true : r.sub }));
    return ap(out, { spcBef: (runs[0] && runs[0]._p) ? 700 : 0 });
  }).join('');
  return `<p:sp><p:nvSpPr><p:cNvPr id="${nextId()}" name="tx${idSeq}"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>` +
    `<p:spPr><a:xfrm><a:off x="${x}" y="${y}"/><a:ext cx="${w}" cy="${h}"/></a:xfrm>` +
    `<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr>` +
    `<p:txBody><a:bodyPr wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="${o.anchor || 't'}"><a:normAutofit/></a:bodyPr><a:lstStyle></a:lstStyle>${xml}</p:txBody></p:sp>`;
}
// 色块（用于标题条 / 数字卡背景）
function rect(x0, y0, w0, h0, fill, o = {}) {
  const [x, y, w, h] = [x0, y0, w0, h0].map(v => Math.round(v));
  const line = o.line ? `<a:ln w="12700"><a:solidFill><a:srgbClr val="${o.line}"/></a:solidFill></a:ln>` : '<a:ln><a:noFill/></a:ln>';
  const sf = fill === 'none' ? '<a:noFill/>' : `<a:solidFill><a:srgbClr val="${fill}"/></a:solidFill>`;
  return `<p:sp><p:nvSpPr><p:cNvPr id="${nextId()}" name="rc${idSeq}"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>` +
    `<p:spPr><a:xfrm><a:off x="${x}" y="${y}"/><a:ext cx="${w}" cy="${h}"/></a:xfrm>` +
    `<a:prstGeom prst="${o.round ? 'roundRect' : 'rect'}"><a:avLst>${o.round ? '<a:gd name="adj" fmla="val 12000"/>' : ''}</a:avLst></a:prstGeom>` +
    `${sf}${line}</p:spPr><p:txBody><a:bodyPr/><a:lstStyle></a:lstStyle><a:p><a:endParaRPr lang="zh-CN"/></a:p></p:txBody></p:sp>`;
}
function pic(rid, x0, y0, w0, h0) {
  const [x, y, w, h] = [x0, y0, w0, h0].map(v => Math.round(v));
  return `<p:pic><p:nvPicPr><p:cNvPr id="${nextId()}" name="pg${idSeq}"/><p:cNvPicPr><a:picLocks noChangeAspect="1"/></p:cNvPicPr><p:nvPr/></p:nvPicPr>` +
    `<p:blipFill><a:blip r:embed="${rid}"/><a:stretch><a:fillRect/></a:stretch></p:blipFill>` +
    `<p:spPr><a:xfrm><a:off x="${x}" y="${y}"/><a:ext cx="${w}" cy="${h}"/></a:xfrm>` +
    `<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:ln w="9525"><a:solidFill><a:srgbClr val="D0D7DE"/></a:solidFill></a:ln></p:spPr></p:pic>`;
}

/* ---------- 静态部件 ---------- */
const THEME = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="GMR">
<a:themeElements>
<a:clrScheme name="GMR"><a:dk1><a:srgbClr val="262626"/></a:dk1><a:lt1><a:srgbClr val="FFFFFF"/></a:lt1>
<a:dk2><a:srgbClr val="1F4E79"/></a:dk2><a:lt2><a:srgbClr val="F2F5F8"/></a:lt2>
<a:accent1><a:srgbClr val="1F6FB2"/></a:accent1><a:accent2><a:srgbClr val="C8322B"/></a:accent2>
<a:accent3><a:srgbClr val="2E8B57"/></a:accent3><a:accent4><a:srgbClr val="7B4EA0"/></a:accent4>
<a:accent5><a:srgbClr val="D97706"/></a:accent5><a:accent6><a:srgbClr val="666666"/></a:accent6>
<a:hlink><a:srgbClr val="0563C1"/></a:hlink><a:folHlink><a:srgbClr val="954F72"/></a:folHlink></a:clrScheme>
<a:fontScheme name="GMR"><a:majorFont><a:latin typeface="Microsoft YaHei"/><a:ea typeface="微软雅黑"/><a:cs typeface=""/></a:majorFont>
<a:minorFont><a:latin typeface="Microsoft YaHei"/><a:ea typeface="微软雅黑"/><a:cs typeface=""/></a:minorFont></a:fontScheme>
<a:fmtScheme name="GMR">
<a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
<a:solidFill><a:schemeClr val="phClr"><a:tint val="75000"/></a:schemeClr></a:solidFill>
<a:solidFill><a:schemeClr val="phClr"><a:shade val="85000"/></a:schemeClr></a:solidFill></a:fillStyleLst>
<a:lnStyleLst>
<a:ln w="6350" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/><a:miter lim="800000"/></a:ln>
<a:ln w="12700" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/><a:miter lim="800000"/></a:ln>
<a:ln w="19050" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/><a:miter lim="800000"/></a:ln></a:lnStyleLst>
<a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>
<a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:solidFill><a:schemeClr val="phClr"><a:tint val="95000"/></a:schemeClr></a:solidFill><a:solidFill><a:schemeClr val="phClr"><a:shade val="95000"/></a:schemeClr></a:solidFill></a:bgFillStyleLst>
</a:fmtScheme></a:themeElements><a:objectDefaults/><a:extraClrSchemeLst/></a:theme>`;

const TXSTYLES = `<p:txStyles><p:titleStyle><a:lvl1pPr algn="l"><a:defRPr sz="3200" b="1"><a:solidFill><a:srgbClr val="1F4E79"/></a:solidFill><a:latin typeface="Microsoft YaHei"/><a:ea typeface="微软雅黑"/></a:defRPr></a:lvl1pPr></p:titleStyle>
<p:bodyStyle><a:lvl1pPr><a:defRPr sz="1800"><a:solidFill><a:srgbClr val="262626"/></a:solidFill><a:latin typeface="Microsoft YaHei"/><a:ea typeface="微软雅黑"/></a:defRPr></a:lvl1pPr></p:bodyStyle>
<p:otherStyle><a:lvl1pPr><a:defRPr sz="1800"><a:latin typeface="Microsoft YaHei"/><a:ea typeface="微软雅黑"/></a:defRPr></a:lvl1pPr></p:otherStyle></p:txStyles>`;

const CLRM = '<p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>';
const treeOpen = '<p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>';
const treeClose = '</p:spTree>';
const CS = '<p:cSld>' + treeOpen;      // 普通页面：cSld + spTree
const CE = treeClose + '</p:cSld>';

const SLIDE_LAYOUT = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldLayout xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" type="blank" preserve="1">
${CS}${CE}<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sldLayout>`;

const SLIDE_MASTER = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldMaster xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
<p:cSld><p:bg><p:bgPr><a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill><a:effectLst/></p:bgPr></p:bg>${treeOpen}${treeClose}</p:cSld>${CLRM}
<p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/></p:sldLayoutIdLst>${TXSTYLES}</p:sldMaster>`;

function slide(body) {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
${CS}${body}${CE}<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sld>`;
}

/* ---------- 备注页：直接采用 PowerPoint 自己生成的部件作模板，避免手写骨架踩坑 ---------- */
const NOTES_MASTER_RAW = fs.readFileSync(__dirname + '/ctrl/ppt/notesMasters/notesMaster1.xml', 'utf8');
const NOTES_SLIDE_TPL = fs.readFileSync(__dirname + '/ctrl/ppt/notesSlides/notesSlide1.xml', 'utf8');
const NOTES_MASTER = NOTES_MASTER_RAW;

const NOTES_MASTER_RELS = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
</Relationships>`;

// paras: [ [ {t, b, color, sz}, ... ], ... ]  —— 用 PowerPoint 原文模板，只注入段落
const NOTES_BODY_INJECT = '<a:bodyPr/><a:p><a:endParaRPr lang="zh-CN" altLang="en-US"/></a:p>';
function notesSlide(paras) {
  const xml = paras.map(runs => {
    const out = [];
    for (const r of runs) for (const p of expandSub(r.t)) out.push(run(p.t, { sz: 1100, ...r, sub: p.sub ? true : r.sub }));
    return ap(out, { spcBef: (runs[0] && runs[0]._p) ? 600 : 0 });
  }).join('');
  if (!NOTES_SLIDE_TPL.includes(NOTES_BODY_INJECT)) throw new Error('notesSlide 模板锚点未找到');
  return NOTES_SLIDE_TPL.replace(NOTES_BODY_INJECT, '<a:bodyPr/>' + xml);
}
const NOTES_SLIDE_RELS = slideIdx => `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="../slides/slide${slideIdx}.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesMaster" Target="../notesMasters/notesMaster1.xml"/>
</Relationships>`;

function presentation(slideCount, withNotes) {
  const nml = withNotes === false ? '' : `<p:notesMasterIdLst><p:notesMasterId r:id="rId${slideCount + 4}"/></p:notesMasterIdLst>`;
  const ids = Array.from({ length: slideCount }, (_, i) => `<p:sldId id="${256 + i}" r:id="rId${i + 2}"/>`).join('');
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" saveSubsetFonts="1">
<p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst>
${nml}
<p:sldIdLst>${ids}</p:sldIdLst>
<p:sldSz cx="${SW}" cy="${SH}"/><p:notesSz cx="6858000" cy="9144000"/></p:presentation>`;
}

const PRES_PROPS = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentationPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"/>`;

const ROOT_RELS = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>`;

function contentTypes(slideCount, notesSlides, notesMaster) {
  const NC = (notesSlides === undefined) ? slideCount : notesSlides;
  const NM = (notesMaster === undefined) ? NC > 0 : !!notesMaster;
  const ov = [
    '/ppt/presentation.xml|application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml',
    '/ppt/presProps.xml|application/vnd.openxmlformats-officedocument.presentationml.presProps+xml',
    '/ppt/slideMasters/slideMaster1.xml|application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml',
    '/ppt/slideLayouts/slideLayout1.xml|application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml',
    ...(NM ? ['/ppt/notesMasters/notesMaster1.xml|application/vnd.openxmlformats-officedocument.presentationml.notesMaster+xml'] : []),
    ...Array.from({ length: NC }, (_, i) => `/ppt/notesSlides/notesSlide${i + 1}.xml|application/vnd.openxmlformats-officedocument.presentationml.notesSlide+xml`),
    '/ppt/theme/theme1.xml|application/vnd.openxmlformats-officedocument.theme+xml',
    '/docProps/core.xml|application/vnd.openxmlformats-package.core-properties+xml',
    '/docProps/app.xml|application/vnd.openxmlformats-officedocument.extended-properties+xml',
    ...Array.from({ length: slideCount }, (_, i) => `/ppt/slides/slide${i + 1}.xml|application/vnd.openxmlformats-officedocument.presentationml.slide+xml`),
  ].map(p => { const [n, t] = p.split('|'); return `<Override PartName="${n}" ContentType="${t}"/>`; }).join('');
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Default Extension="png" ContentType="image/png"/>
<Default Extension="jpeg" ContentType="image/jpeg"/>${ov}</Types>`;
}

function presRels(slideCount, withNotes) {
  let r = `<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>`;
  for (let i = 0; i < slideCount; i++) r += `<Relationship Id="rId${i + 2}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide${i + 1}.xml"/>`;
  r += `<Relationship Id="rId${slideCount + 2}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>`;
  r += `<Relationship Id="rId${slideCount + 3}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/presProps" Target="presProps.xml"/>`;
  if (withNotes !== false) r += `<Relationship Id="rId${slideCount + 4}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesMaster" Target="notesMasters/notesMaster1.xml"/>`;
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">${r}</Relationships>`;
}

const MASTER_RELS = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
</Relationships>`;
const LAYOUT_RELS = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>
</Relationships>`;
function slideRels(images, notesIdx) {
  let r = `<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>`;
  images.forEach((f, i) => { r += `<Relationship Id="rId${i + 2}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/${f}"/>`; });
  if (notesIdx) r += `<Relationship Id="rId${images.length + 2}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesSlide" Target="../notesSlides/notesSlide${notesIdx}.xml"/>`;
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">${r}</Relationships>`;
}

module.exports = { zip, E, SW, SH, CM, emu, text, rect, pic, run, ap, slide, presentation, presRels, masterRels: MASTER_RELS, layoutRels: LAYOUT_RELS, slideRels, contentTypes, THEME, SLIDE_MASTER, SLIDE_LAYOUT, ROOT_RELS, PRES_PROPS, NOTES_MASTER, NOTES_MASTER_RELS, notesSlide, NOTES_SLIDE_RELS };
