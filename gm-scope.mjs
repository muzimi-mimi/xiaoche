import { DatabaseSync } from 'node:sqlite';

const db = new DatabaseSync(process.argv[2], { readOnly: true });

console.log('== gm_turn_memories schema ==');
console.log(db.prepare("select sql from sqlite_master where name='gm_turn_memories'").get().sql);

const cols = db.prepare("select name from pragma_table_info('gm_turn_memories')").all().map(r => r.name);
console.log('\ncolumns:', cols.join(', '));

if (cols.includes('created_at')) {
  const r = db.prepare("select count(*) n, min(created_at) a, max(created_at) b from gm_turn_memories").get();
  console.log(`\nmemories: ${r.n}  first: ${new Date(Number(r.a)).toISOString()}  last: ${new Date(Number(r.b)).toISOString()}`);
}

const scols = db.prepare("select name from pragma_table_info('gm_messages')").all().map(r => r.name);
console.log('gm_messages columns:', scols.join(', '));

console.log('\n== sessions seen ==');
for (const r of db.prepare("select session_id, count(*) n, min(created_at) a, max(created_at) b from gm_messages group by session_id order by b").all()) {
  console.log(`n=${String(r.n).padStart(4)}  ${new Date(Number(r.a)).toISOString()} .. ${new Date(Number(r.b)).toISOString()}  ${r.session_id}`);
}

console.log('\n== newest 8 turn memories ==');
const sel = cols.includes('outcome')
  ? "select id, outcome, created_at, substr(coalesce(summary,''),1,90) s from gm_turn_memories order by created_at desc limit 8"
  : "select id, created_at from gm_turn_memories order by created_at desc limit 8";
for (const r of db.prepare(sel).all()) {
  console.log(`- ${new Date(Number(r.created_at)).toISOString()} [${r.outcome ?? ''}] ${String(r.s ?? '').replace(/\s+/g, ' ')}`);
}

db.close();
