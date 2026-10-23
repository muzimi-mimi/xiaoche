// Add the exact git-prepare allowlist key pnpm printed, as a YAML *mapping*
// (DSH's readPolicy() rejects a sequence: "allowBuilds must be a YAML mapping").
import { readFileSync, writeFileSync, existsSync } from 'node:fs'

const KEY = 'dsh-ops@https://codeload.github.com/T-Auto/dsh-ops/tar.gz/b963fb29e03ad21ebe76d6f552c70f0544ca92b9'
const file = process.argv[2]
if (!file) throw new Error('usage: node allow-git-build.mjs <pnpm-workspace.yaml>')
if (!existsSync(file)) throw new Error(`missing: ${file}`)

let text = readFileSync(file, 'utf8')
if (text.charCodeAt(0) === 0xfeff) throw new Error('file starts with a BOM; refusing to proceed')

const already = new RegExp('^\\s*' + KEY.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\s*:', 'm')
if (already.test(text)) {
  console.log('already-present')
} else if (/^\s*allowBuilds\s*:/m.test(text)) {
  throw new Error('an allowBuilds block already exists in a different shape; inspect it by hand')
} else {
  if (!text.endsWith('\n')) text += '\n'
  text += '\nallowBuilds:\n  ' + KEY + ': true\n'
  writeFileSync(file, text, 'utf8')
  console.log('appended')
}

// Verify with the same YAML library DSH's plugin manager uses.
const YAML = await import('file:///D:/Deepseek-Harness-EAC-6.0.0-portable/dsh-desktop/node_modules/yaml/dist/index.js')
const doc = YAML.parseDocument(readFileSync(file, 'utf8'))
if (doc.errors.length) throw new Error('YAML parse error: ' + doc.errors[0].message)
const builds = doc.get('allowBuilds')
const plain = builds && typeof builds.toJSON === 'function' ? builds.toJSON() : builds
console.log(JSON.stringify({
  packages: doc.get('packages'),
  allowBuilds: plain,
  allowBuildsIsMapping: YAML.isMap(builds),
  keyMatches: Object.prototype.hasOwnProperty.call(plain ?? {}, KEY),
}, null, 2))
