// Render the-christiano-point.html inside the artifact-style skeleton and check it.
// Usage: node check.js  -> prints JSON report; writes screenshots to out/shots/
const fs = require('fs');
const path = require('path');
const {chromium} = require('playwright-core');
const CHROME = process.env.CHROME_PATH || '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';
const dir = __dirname;
const page_src = fs.readFileSync(path.join(dir, 'the-christiano-point.html'), 'utf8');
// Mimic the publish skeleton (charset + viewport-fit=cover + small reset)
const skeleton = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"><style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0;font:14px system-ui,sans-serif;background:#fafaf8}img{max-width:100%}[hidden]{display:none!important}</style></head><body>${page_src}</body></html>`;
fs.mkdirSync(path.join(dir, 'out', 'shots'), {recursive: true});
const wrapper = path.join(dir, 'out', 'preview.html');
fs.writeFileSync(wrapper, skeleton);
const ALLOWED = ['cdnjs.cloudflare.com', 'cdn.jsdelivr.net', 'unpkg.com', 'cdn.tailwindcss.com', 'code.jquery.com', 'fonts.googleapis.com', 'fonts.gstatic.com'];

(async () => {
  const browser = await chromium.launch({executablePath: CHROME});
  const report = {bytes: Buffer.byteLength(page_src), title_offset: page_src.indexOf('<title>'), runs: [], shots: []};
  const configs = [
    {name: 'desktop-light', width: 1280, scheme: 'light', theme: null},
    {name: 'desktop-dark', width: 1280, scheme: 'dark', theme: null},
    {name: 'mobile-light', width: 400, scheme: 'light', theme: null},
    {name: 'mobile-dark', width: 400, scheme: 'dark', theme: null},
    {name: 'toggle-dark-on-light-os', width: 1280, scheme: 'light', theme: 'dark'},
    {name: 'toggle-light-on-dark-os', width: 1280, scheme: 'dark', theme: 'light'},
  ];
  for (const c of configs) {
    const ctx = await browser.newContext({viewport: {width: c.width, height: 900}, colorScheme: c.scheme, deviceScaleFactor: 1});
    const page = await ctx.newPage();
    const consoleErrors = [], pageErrors = [], badRequests = [];
    page.on('console', m => { if (m.type() === 'error') consoleErrors.push(m.text()); });
    page.on('pageerror', e => pageErrors.push(String(e)));
    page.on('request', r => {
      const u = r.url();
      if (u.startsWith('file:') || u.startsWith('data:') || u.startsWith('blob:')) return;
      const host = new URL(u).host;
      if (!ALLOWED.includes(host)) badRequests.push(u);
    });
    page.on('requestfailed', r => { if (!r.url().startsWith('data:')) badRequests.push('FAILED ' + r.url()); });
    await page.goto('file://' + wrapper, {waitUntil: 'networkidle'});
    if (c.theme) await page.evaluate(t => document.documentElement.setAttribute('data-theme', t), c.theme);
    await page.waitForTimeout(400);
    const m = await page.evaluate(() => {
      const de = document.documentElement;
      const vw = de.clientWidth;
      const overflowing = [];
      const inScroller = el => { for (let p = el.parentElement; p; p = p.parentElement) { const s = getComputedStyle(p); if (/(auto|scroll|hidden)/.test(s.overflowX) && p.scrollWidth > p.clientWidth - 1) return true; if (/(auto|scroll)/.test(s.overflowX)) return true; } return false; };
      for (const el of document.body.querySelectorAll('*')) {
        const r = el.getBoundingClientRect();
        if (r.width && (r.right > vw + 1 || r.left < -1) && !inScroller(el)) {
          overflowing.push((el.tagName + (el.id ? '#' + el.id : '') + (el.className && typeof el.className === 'string' ? '.' + el.className.split(' ').join('.') : '')).slice(0, 80) + ` right=${Math.round(r.right)}`);
          if (overflowing.length > 15) break;
        }
      }
      const anchors = [...document.querySelectorAll('a[href^="#"]')].map(a => a.getAttribute('href')).filter(h => h.length > 1);
      const missingAnchors = [...new Set(anchors.filter(h => !document.getElementById(decodeURIComponent(h.slice(1)))))];
      const bs = getComputedStyle(document.body);
      const fontsLoaded = [...document.fonts].filter(f => f.status === 'loaded').map(f => f.family + ' ' + f.weight);
      return {
        horizontal_page_overflow: de.scrollWidth > vw + 1, scrollWidth: de.scrollWidth, viewport: vw,
        overflowing_elements: overflowing, page_height: de.scrollHeight,
        anchors_checked: anchors.length, missing_anchors: missingAnchors,
        body_bg: bs.backgroundColor, body_fg: bs.color,
        h1: document.querySelector('h1') && document.querySelector('h1').textContent.trim().slice(0, 80),
        h2_count: document.querySelectorAll('h2').length, table_count: document.querySelectorAll('table').length,
        math_inline: document.querySelectorAll('.math').length, math_display: document.querySelectorAll('.math-display').length,
        svg_count: document.querySelectorAll('svg').length, fonts_loaded: [...new Set(fontsLoaded)].slice(0, 12),
        leftover_placeholders: (document.body.innerHTML.match(/<!--\s*(SECTION|CHART)/g) || []).length,
      };
    });
    report.runs.push({config: c.name, ...m, console_errors: consoleErrors, page_errors: pageErrors, bad_requests: [...new Set(badRequests)]});
    // screenshots at a few anchors
    const targets = c.theme ? ['top'] : (c.width > 600 ? ['top', '#s0', 'figure', '#s2', '#s6', '#s14'] : ['top', 'figure', '#s0 table', '#s10']);
    for (const t of targets) {
      try {
        if (t === 'top') await page.evaluate(() => window.scrollTo(0, 0));
        else await page.evaluate(sel => { const el = document.querySelector(sel); if (el) el.scrollIntoView({block: 'start'}); }, t);
        await page.waitForTimeout(150);
        const f = path.join(dir, 'out', 'shots', `${c.name}_${t.replace(/[^a-z0-9]+/gi, '_')}.png`);
        await page.screenshot({path: f});
        report.shots.push(f);
      } catch (e) { report.shots.push('ERR ' + t + ' ' + e.message); }
    }
    await ctx.close();
  }
  await browser.close();
  console.log(JSON.stringify(report, null, 1));
})();
