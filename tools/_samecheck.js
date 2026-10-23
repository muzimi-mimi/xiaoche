const fs = require("fs");
const { TextDecoder } = require("util");
function stripComments(text){let out=[],i=0,n=text.length,state="code";
 while(i<n){const c=text[i],nx=i+1<n?text[i+1]:"";
  if(state==="code"){if(c==="/"&&nx==="/"){state="line";out.push("  ");i+=2;continue;}
   if(c==="/"&&nx==="*"){state="block";out.push("  ");i+=2;continue;}
   if(c==='"'){state="str";out.push(c);i++;continue;}
   if(c==="'"){state="chr";out.push(c);i++;continue;} out.push(c);i++;}
  else if(state==="line"){if(c==="\n"){state="code";out.push("\n");}i++;}
  else if(state==="block"){if(c==="*"&&nx==="/"){state="code";out.push("  ");i+=2;continue;} if(c==="\n")out.push("\n");i++;}
  else if(state==="str"){if(c==="\\"&&i+1<n){out.push(c,text[i+1]);i+=2;continue;} if(c==='"')state="code"; out.push(c);i++;}
  else if(state==="chr"){if(c==="\\"&&i+1<n){out.push(c,text[i+1]);i+=2;continue;} if(c==="'")state="code"; out.push(c);i++;}}
 return out.join("");}
const norm=c=>c.split("\n").map(s=>s.trim()).filter(s=>s.length>0);
const dec=new TextDecoder("utf-8");
const [pa,pb]=process.argv.slice(2);
const la=norm(stripComments(dec.decode(fs.readFileSync(pa))));
const lb=norm(stripComments(dec.decode(fs.readFileSync(pb))));
console.log("NEW lines =",la.length,"  CURRENT lines =",lb.length);
let same=la.length===lb.length, first=null;
for(let i=0;i<Math.max(la.length,lb.length);i++){
  if(la[i]!==lb[i]){same=false; if(!first&&first!==0)first=i;
    if(i<first+40)console.log(`  [${i}] NEW: ${(la[i]||"<none>").slice(0,120)}\n  [${i}] CUR: ${(lb[i]||"<none>").slice(0,120)}`);}}
console.log(same?"CODE IDENTICAL ✓":"CODE DIFFERS ✗");
