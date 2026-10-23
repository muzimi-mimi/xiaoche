const fs = require('fs');
let s = fs.readFileSync('latex.js', 'utf8');
const re = new RegExp('(?<!\\\\)\\$\\{', 'g');
const c = (s.match(re) || []).length;
s = s.replace(re, () => '\\${');
fs.writeFileSync('latex.js', s);
console.log('escaped ${ count:', c);
