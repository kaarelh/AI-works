// Render TeX in an HTML string to self-contained SVG (MathJax 3, no font cache).
// Inline math: \( ... \)   Display math: \[ ... \]  (put display math in its own block, not inside <p>)
// TeX inside the HTML may use &lt; &gt; &amp; entities; they are unescaped before rendering.
const {mathjax} = require('mathjax-full/js/mathjax.js');
const {TeX} = require('mathjax-full/js/input/tex.js');
const {SVG} = require('mathjax-full/js/output/svg.js');
const {liteAdaptor} = require('mathjax-full/js/adaptors/liteAdaptor.js');
const {RegisterHTMLHandler} = require('mathjax-full/js/handlers/html.js');
const {AllPackages} = require('mathjax-full/js/input/tex/AllPackages.js');

const adaptor = liteAdaptor();
RegisterHTMLHandler(adaptor);
const doc = mathjax.document('', {
  InputJax: new TeX({packages: AllPackages, formatError: (jax, err) => { throw err; }}),
  OutputJax: new SVG({fontCache: 'none'}),
});

const unescape = s => s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, '&');
const attr = s => s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function tex2svg(tex, display) {
  const node = doc.convert(tex, {display});
  const svg = adaptor.innerHTML(node).replace(' role="img"', '').replace('<svg ', '<svg aria-hidden="true" ');
  return svg;
}

function renderMath(html) {
  const errors = [];
  let count = 0;
  const out = html.replace(/\\\[([\s\S]+?)\\\]|\\\(([\s\S]+?)\\\)/g, (m, disp, inl) => {
    const display = disp !== undefined;
    const tex = unescape((display ? disp : inl).trim());
    try {
      const svg = tex2svg(tex, display);
      count++;
      return display
        ? `<div class="math-display" role="img" aria-label="${attr(tex)}">${svg}</div>`
        : `<span class="math" role="img" aria-label="${attr(tex)}">${svg}</span>`;
    } catch (e) {
      errors.push({tex, error: String(e.message || e)});
      return m;
    }
  });
  return {html: out, count, errors};
}

module.exports = {renderMath, tex2svg};

if (require.main === module) {
  const fs = require('fs');
  const [inp, outp] = process.argv.slice(2);
  const r = renderMath(fs.readFileSync(inp, 'utf8'));
  if (outp) fs.writeFileSync(outp, r.html);
  console.log(JSON.stringify({rendered: r.count, errors: r.errors}, null, 1));
  process.exit(r.errors.length ? 1 : 0);
}
