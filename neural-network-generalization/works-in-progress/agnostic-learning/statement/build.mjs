// Build the statement PDFs from their HTML sources:
//   source.html -> tempered-learner.pdf        (full statement)
//   short.html  -> tempered-learner-short.pdf  (one-page main result)
// Math between \( \) (inline) and \[ \] (display) is rendered with KaTeX;
// each page is printed to PDF with the Chromium that Playwright provides.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const katex = require('katex');
const { chromium } = require('playwright');

const here = dirname(fileURLToPath(import.meta.url));
// `node build.mjs` builds both; `node build.mjs short.html` builds only the named sources.
const all = [
  ['source.html', 'tempered-learner.pdf'],
  ['short.html', 'tempered-learner-short.pdf'],
];
const wanted = process.argv.slice(2);
const targets = wanted.length ? all.filter(([source]) => wanted.includes(source)) : all;
if (!targets.length) throw new Error(`unknown source; expected one of: ${all.map(([s]) => s).join(', ')}`);

const render = (tex, displayMode) =>
  katex.renderToString(tex, { displayMode, throwOnError: true, strict: 'error', output: 'html' });
const css = pathToFileURL(join(here, 'node_modules/katex/dist/katex.min.css')).href;

mkdirSync(join(here, 'build'), { recursive: true });
const browser = await chromium.launch();
for (const [source, pdf] of targets) {
  const src = readFileSync(join(here, source), 'utf8');
  let html = src.replace(/\\\[([\s\S]+?)\\\]/g, (_, tex) => render(tex.trim(), true));
  html = html.replace(/\\\(([\s\S]+?)\\\)/g, (_, tex) => `<span class="nw">${render(tex.trim(), false)}</span>`);
  html = html.replace('<!--KATEX-CSS-->', `<link rel="stylesheet" href="${css}">`);
  const page = join(here, 'build', pdf.replace(/\.pdf$/, '.html'));
  writeFileSync(page, html);
  const tab = await browser.newPage();
  await tab.goto(pathToFileURL(page).href, { waitUntil: 'networkidle' });
  await tab.evaluate(() => document.fonts.ready);
  await tab.pdf({
    path: join(here, pdf),
    format: 'A4',
    margin: { top: '18mm', bottom: '18mm', left: '19mm', right: '19mm' },
    printBackground: true,
  });
  await tab.close();
  console.log(`wrote ${pdf}`);
}
await browser.close();
