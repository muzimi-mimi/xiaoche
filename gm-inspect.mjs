import { DatabaseSync } from 'node:sqlite';

const path = process.argv[2];
const db = new DatabaseSync(path, { readOnly: true });

const objs = db
  .prepare("select type, name from sqlite_master where type in ('table','view') and name not like 'sqlite_%' order by type, name")
  .all();

console.log('== objects ==');
for (const o of objs) console.log(`${o.type}\t${o.name}`);

console.log('\n== row counts ==');
for (const o of objs) {
  try {
    const r = db.prepare(`select count(*) as n from "${o.name}"`).get();
    console.log(`${o.name}\t${r.n}`);
  } catch (e) {
    console.log(`${o.name}\tERR ${e.message}`);
  }
}

console.log('\n== schema ==');
for (const r of db.prepare("select sql from sqlite_master where sql is not null and name not like 'sqlite_%' order by name").all()) {
  console.log(r.sql + ';\n');
}

db.close();
