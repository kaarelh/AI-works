// Assemble shell.html + fragments/*.html (+ chart.html) into the-christiano-point.html, rendering math.
// Placeholders: in shell.html  <!-- SECTION:<name> -->  is replaced by fragments/<name>.html
//               in any fragment <!-- CHART -->           is replaced by chart.html
const fs = require('fs');
const path = require('path');
const {renderMath} = require('./render_math.js');
const dir = __dirname;
let shell = fs.readFileSync(path.join(dir, 'shell.html'), 'utf8');
const chart = fs.existsSync(path.join(dir, 'chart.html')) ? fs.readFileSync(path.join(dir, 'chart.html'), 'utf8') : null;
const missing = [];
const used = [];
shell = shell.replace(/<!--\s*SECTION:([\w-]+)\s*-->/g, (m, name) => {
  const f = path.join(dir, 'fragments', name + '.html');
  if (!fs.existsSync(f)) { missing.push(name); return m; }
  used.push(name);
  return fs.readFileSync(f, 'utf8');
});
let chartInserted = 0;
shell = shell.replace(/<!--\s*CHART\s*-->/g, m => { if (!chart) { missing.push('chart.html'); return m; } chartInserted++; return chart; });
const r = renderMath(shell);
const out = path.join(dir, 'the-christiano-point.html');
fs.writeFileSync(out, r.html);
const leftovers = (r.html.match(/\\\(|\\\)|\\\[|\\\]/g) || []).length;
const titleIdx = r.html.indexOf('<title>');
console.log(JSON.stringify({
  out, bytes: Buffer.byteLength(r.html), fragments_used: used, missing,
  chart_inserted: chartInserted, math_rendered: r.count, math_errors: r.errors,
  leftover_tex_delimiters: leftovers, title_offset_bytes: titleIdx,
  forbidden_tags: (r.html.match(/<\/?(html|head|body)[\s>]|<!doctype/gi) || []),
}, null, 1));
process.exit(missing.length || r.errors.length ? 1 : 0);
