import { DatabaseSync } from 'node:sqlite';

const db = new DatabaseSync(process.argv[2], { readOnly: true });

console.log('== message extraction state ==');
for (const r of db.prepare("select extraction_state s, count(*) n from gm_messages group by s order by n desc").all()) {
  console.log(`  ${r.s}: ${r.n}`);
}

console.log('\n== extraction errors (newest 6) ==');
for (const r of db.prepare("select created_at, extraction_attempts a, substr(coalesce(extraction_error,''),1,160) e from gm_messages where extraction_error is not null order by created_at desc limit 6").all()) {
  console.log(`  ${new Date(Number(r.created_at)).toISOString()} attempts=${r.a} :: ${r.e.replace(/\s+/g, ' ')}`);
}

console.log('\n== pending backlog ==');
const p = db.prepare("select count(*) n from gm_messages where extraction_state='pending'").get();
console.log(`  pending: ${p.n}`);

console.log('\n== per-session memory coverage ==');
for (const r of db.prepare("select session_id, count(*) n from gm_turn_memories group by session_id order by n desc").all()) {
  console.log(`  n=${String(r.n).padStart(3)}  ${r.session_id}`);
}

console.log('\n== outcomes ==');
for (const r of db.prepare("select outcome o, count(*) n from gm_turn_memories group by o order by n desc").all()) {
  console.log(`  ${r.o}: ${r.n}`);
}

console.log('\n== migrations ==');
for (const r of db.prepare("select v, at from _migrations order by v").all()) {
  console.log(`  v${r.v}  ${new Date(Number(r.at)).toISOString()}`);
}

db.close();
