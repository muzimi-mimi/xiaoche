const fs = require("fs");
const { TextDecoder } = require("util");

function stripComments(text) {
  let out = [];
  let i = 0, n = text.length;
  let state = "code";
  while (i < n) {
    const c = text[i];
    const nx = i + 1 < n ? text[i + 1] : "";
    if (state === "code") {
      if (c === "/" && nx === "/") { state = "line"; out.push("  "); i += 2; continue; }
      if (c === "/" && nx === "*") { state = "block"; out.push("  "); i += 2; continue; }
      if (c === '"') { state = "str"; out.push(c); i++; continue; }
      if (c === "'") { state = "chr"; out.push(c); i++; continue; }
      out.push(c); i++;
    } else if (state === "line") {
      if (c === "\n") { state = "code"; out.push("\n"); }
      i++;
    } else if (state === "block") {
      if (c === "*" && nx === "/") { state = "code"; out.push("  "); i += 2; continue; }
      if (c === "\n") out.push("\n");
      i++;
    } else if (state === "str") {
      if (c === "\\" && i + 1 < n) { out.push(c, text[i + 1]); i += 2; continue; }
      if (c === '"') state = "code";
      out.push(c); i++;
    } else if (state === "chr") {
      if (c === "\\" && i + 1 < n) { out.push(c, text[i + 1]); i += 2; continue; }
      if (c === "'") state = "code";
      out.push(c); i++;
    }
  }
  return out.join("");
}

function norm(code) {
  return code.split("\n").map(s => s.trim()).filter(s => s.length > 0);
}

const [pa, pb] = process.argv.slice(2);
const Atext = new TextDecoder("utf-8").decode(fs.readFileSync(pa));
const Btext = new TextDecoder("gbk").decode(fs.readFileSync(pb));
const la = norm(stripComments(Atext));
const lb = norm(stripComments(Btext));
console.log("CURRENT code lines =", la.length);
console.log("BACKUP  code lines =", lb.length);

// LCS-based diff
function diff(a, b) {
  const n = a.length, m = b.length;
  const dp = Array.from({length: n + 1}, () => new Int32Array(m + 1));
  for (let i = n - 1; i >= 0; i--)
    for (let j = m - 1; j >= 0; j--)
      dp[i][j] = a[i] === b[j] ? dp[i + 1][j + 1] + 1 : Math.max(dp[i + 1][j], dp[i][j + 1]);
  const res = [];
  let i = 0, j = 0;
  while (i < n && j < m) {
    if (a[i] === b[j]) { res.push([" ", a[i]]); i++; j++; }
    else if (dp[i + 1][j] >= dp[i][j + 1]) { res.push(["-", a[i]]); i++; }
    else { res.push(["+", b[j]]); j++; }
  }
  while (i < n) { res.push(["-", a[i]]); i++; }
  while (j < m) { res.push(["+", b[j]]); j++; }
  return res;
}
const d = diff(lb, la);
const onlyA = d.filter(x => x[0] === "+").length;
const onlyB = d.filter(x => x[0] === "-").length;
console.log(`\n--- lines only in CURRENT: ${onlyA}, only in BACKUP: ${onlyB}, common: ${d.filter(x=>x[0]===" ").length}`);
let c = 0;
for (const [k, s] of d) {
  if (k === " ") { c++; continue; }
  console.log((k === "+" ? "CUR  " : "BAK  ") + s.slice(0, 150));
  if (++c > 4000) { break; }
}

