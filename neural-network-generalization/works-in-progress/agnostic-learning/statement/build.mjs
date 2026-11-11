// Build tempered-learner.pdf from source.html.
// Math between \( \) (inline) and \[ \] (display) is rendered with KaTeX;
// the page is printed to PDF with the Chromium that Playwright provides.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const katex = require('katex');
const { chromium } = require('playwright');

const here = dirname(fileURLToPath(import.meta.url));
const src = readFileSync(join(here, 'source.html'), 'utf8');

const render = (tex, displayMode) =>
  katex.renderToString(tex, { displayMode, throwOnError: true, strict: 'error', output: 'html' });

let html = src.replace(/\\\[([\s\S]+?)\\\]/g, (_, tex) => render(tex.trim(), true));
html = html.replace(/\\\(([\s\S]+?)\\\)/g, (_, tex) => render(tex.trim(), false));

const css = pathToFileURL(join(here, 'node_modules/katex/dist/katex.min.css')).href;
html = html.replace('<!--KATEX-CSS-->', `<link rel="stylesheet" href="${css}">`);

mkdirSync(join(here, 'build'), { recursive: true });
const page = join(here, 'build', 'tempered-learner.html');
writeFileSync(page, html);

const browser = await chromium.launch();
const tab = await browser.newPage();
await tab.goto(pathToFileURL(page).href, { waitUntil: 'networkidle' });
await tab.evaluate(() => document.fonts.ready);
await tab.pdf({
  path: join(here, 'tempered-learner.pdf'),
  format: 'A4',
  margin: { top: '22mm', bottom: '22mm', left: '22mm', right: '22mm' },
  printBackground: true,
});
await browser.close();
console.log('wrote tempered-learner.pdf');
