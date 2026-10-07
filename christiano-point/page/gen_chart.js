// Generates chart.html: a dot-and-whisker chart of AI share by domain.
// The same render() source is used twice: run here in Node to produce the static
// fallback SVG, and shipped in an inline <script> that re-renders at the exact
// container width (wide layout >= 540px, stacked layout below).
// Data: ROWS from christiano-point/models/make_figure.py (same numbers, same order).
const fs = require('fs');
const path = require('path');

const ROWS = [
  ["Lean formalisation", 85, 65, 97, 95, "AI share of new Lean"],
  ["De novo protein design", 70, 35, 90, 95, "DL-generated designs"],
  ["Erdős-type problems", 65, 45, 85, 45, "AI-primary new solutions"],
  ["Software eng., frontier labs", 60, 33, 75, 85, "merged code"],
  ["Software eng., industry", 30, 10, 50, 50, "new code"],
  ["Frontier algorithmic progress", 28, 13, 45, 76, "research labour-time"],
  ["Mathematics, overall", 25, 10, 50, 3, "papers / theorems"],
  ["Frontier AI dev., overall", 18, 9, 30, null, ""],
  ["Theoretical physics", 17, 5, 38, null, ""],
  ["Biology, overall", 13, 5, 29, null, ""],
  ["Experimental physics", 9, 2, 23, null, ""],
  ["Materials science", 9, 0, 23, null, ""],
  ["Drug discovery", 5, 0, 15, 1.5, "clinical-stage assets"],
  ["World economy", 2, 1, 4, null, ""],
];

// ---- shared source (no backslashes allowed: the math renderer scans the whole page) ----
const SHARED = String.raw`
function cpEsc(s) {
  return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}
function cpPct(v) { return (Math.round(v * 10) / 10) + "%"; }
function cpDesc(r) {
  var s = r[0] + ". Uplift share " + r[1] + "% (range " + r[2] + "–" + r[3] + "%).";
  s += r[4] == null ? " Volume share not measured." : " Volume share " + cpPct(r[4]) + " (" + r[5] + ").";
  return s;
}
function cpRender(ROWS, W) {
  var narrow = W < 540;
  var padR = 18;
  var x0 = narrow ? 14 : 226;
  var x1 = W - padR;
  function X(v) { return x0 + (x1 - x0) * v / 100; }
  function f(n) { return Math.round(n * 10) / 10; }
  var top = 34, y = top, rows = [], i;
  for (i = 0; i < ROWS.length; i++) {
    var hasVol = ROWS[i][4] != null;
    var h = narrow ? (hasVol ? 58 : 44) : 38;
    var markY = narrow ? y + 32 : y + 22;
    rows.push({ r: ROWS[i], y: y, h: h, markY: markY });
    y += h;
  }
  var bottom = y + 6;
  var H = bottom + 48;
  var o = [];
  o.push('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + W + ' ' + H + '" width="' + W + '" height="' + H + '" role="group" aria-label="Dot-and-whisker chart: AI share of each domain’s output, uplift estimate with range and measured volume share. Use Tab to step through the domains.">');
  [0, 25, 75, 100].forEach(function (v) {
    o.push('<line class="cp-grid" x1="' + f(X(v)) + '" y1="' + (top - 6) + '" x2="' + f(X(v)) + '" y2="' + bottom + '"></line>');
  });
  o.push('<line class="cp-ref" x1="' + f(X(50)) + '" y1="' + (top - 6) + '" x2="' + f(X(50)) + '" y2="' + bottom + '"></line>');
  o.push('<text class="cp-ref-label" x="' + f(X(50)) + '" y="' + (top - 13) + '" text-anchor="middle">Christiano point (50%)</text>');
  [0, 25, 50, 75, 100].forEach(function (v) {
    o.push('<text class="cp-tick" x="' + f(X(v)) + '" y="' + (bottom + 17) + '" text-anchor="middle">' + v + '%</text>');
  });
  o.push('<text class="cp-axis-title" x="' + f((x0 + x1) / 2) + '" y="' + (bottom + 39) + '" text-anchor="middle">AI share of the domain’s output</text>');
  rows.forEach(function (row, k) {
    var r = row.r, my = row.markY;
    o.push('<g class="cp-row" tabindex="0" role="img" data-i="' + k + '" aria-label="' + cpEsc(cpDesc(r)) + '">');
    o.push('<rect class="cp-hit" x="0" y="' + f(row.y + 1) + '" width="' + W + '" height="' + (row.h - 2) + '" rx="3"></rect>');
    if (narrow) o.push('<text class="cp-label" x="' + x0 + '" y="' + (row.y + 17) + '">' + cpEsc(r[0]) + '</text>');
    else o.push('<text class="cp-label" x="4" y="' + (my + 4.5) + '">' + cpEsc(r[0]) + '</text>');
    o.push('<line class="cp-whisker" x1="' + f(X(r[2])) + '" y1="' + my + '" x2="' + f(X(r[3])) + '" y2="' + my + '"></line>');
    if (r[4] != null) {
      var vx = X(r[4]), d = 6.5;
      o.push('<path class="cp-vol" d="M' + f(vx) + ' ' + (my - d) + 'L' + f(vx + d) + ' ' + my + 'L' + f(vx) + ' ' + (my + d) + 'L' + f(vx - d) + ' ' + my + 'Z"></path>');
    }
    o.push('<circle class="cp-dot" cx="' + f(X(r[1])) + '" cy="' + my + '" r="5"></circle>');
    if (r[4] != null && r[5]) {
      var anchor = "middle", tx = vx;
      if (r[4] > 80) { anchor = "end"; tx = vx + 6; }
      else if (r[4] < 8) { anchor = "start"; tx = vx - 6; }
      if (Math.abs(r[4] - 50) < 3) { anchor = "start"; tx = vx + 5; }
      var tw = r[5].length * 6.0;
      var left = anchor === "start" ? tx : anchor === "end" ? tx - tw : tx - tw / 2;
      if (left < x0 - 6) tx += (x0 - 6 - left);
      if (left + tw > W - 4) tx -= (left + tw - (W - 4));
      var ty = narrow ? my + 19 : my - 11;
      o.push('<text class="cp-note" x="' + f(tx) + '" y="' + ty + '" text-anchor="' + anchor + '">' + cpEsc(r[5]) + '</text>');
    }
    o.push('</g>');
  });
  o.push('</svg>');
  return o.join("");
}
`;

// Browser-side behaviour: re-render at container width, tooltip on hover and focus.
const CLIENT = String.raw`
(function () {
  var root = document.getElementById("cp-chart");
  if (!root) return;
  var plot = root.querySelector(".chart-plot");
  var tip = root.querySelector(".chart-tip");
  var lastW = 0;
  function draw() {
    var W = Math.floor(plot.clientWidth);
    if (!W || W === lastW) return;
    lastW = W;
    plot.innerHTML = cpRender(CP_ROWS, W);
  }
  draw();
  if ("ResizeObserver" in window) {
    var pending = false;
    new ResizeObserver(function () {
      if (pending) return;
      pending = true;
      requestAnimationFrame(function () { pending = false; draw(); });
    }).observe(plot);
  }
  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }
  function line(key, val, lab) {
    var d = el("div", "tip-row");
    var k = el("span", "tip-key " + key);
    d.appendChild(k);
    d.appendChild(el("span", "tip-val", val));
    d.appendChild(el("span", "tip-lab", lab));
    return d;
  }
  function show(g) {
    var r = CP_ROWS[+g.getAttribute("data-i")];
    tip.textContent = "";
    tip.appendChild(el("div", "tip-title", r[0]));
    tip.appendChild(line("u", r[1] + "%", "uplift share, range " + r[2] + "–" + r[3] + "%"));
    if (r[4] != null) tip.appendChild(line("v", cpPct(r[4]), "volume share: " + r[5]));
    else tip.appendChild(line("none", "–", "volume share not measured"));
    tip.hidden = false;
    var cr = root.getBoundingClientRect();
    var dot = g.querySelector(".cp-dot").getBoundingClientRect();
    var cx = dot.left + dot.width / 2 - cr.left;
    var tw = tip.offsetWidth, th = tip.offsetHeight;
    var x = Math.max(0, Math.min(cx - tw / 2, root.clientWidth - tw));
    var y = dot.top - cr.top - th - 10;
    if (y < 0) y = dot.bottom - cr.top + 10;
    tip.style.left = Math.round(x) + "px";
    tip.style.top = Math.round(y) + "px";
  }
  function hide() { tip.hidden = true; }
  plot.addEventListener("pointerover", function (e) {
    var g = e.target.closest && e.target.closest(".cp-row");
    if (g) show(g);
  });
  plot.addEventListener("pointerleave", function () {
    var f = document.activeElement;
    if (f && f.classList && f.classList.contains("cp-row") && plot.contains(f)) show(f); else hide();
  });
  plot.addEventListener("focusin", function (e) {
    var g = e.target.closest && e.target.closest(".cp-row");
    if (g) show(g);
  });
  plot.addEventListener("focusout", function (e) {
    var n = e.relatedTarget;
    if (!n || !plot.contains(n)) hide();
  });
  plot.addEventListener("keydown", function (e) { if (e.key === "Escape") hide(); });
})();
`;

// Evaluate shared source in Node to build the static fallback.
const ctx = {};
new Function('ctx', SHARED + '\nctx.cpRender = cpRender; ctx.cpPct = cpPct;')(ctx);
const fallback = ctx.cpRender(ROWS, 720);

const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const pct = v => (Math.round(v * 10) / 10) + '%';
const tableRows = ROWS.map(r => `      <tr><th scope="row">${esc(r[0])}</th><td class="num">${r[1]}%</td><td class="num">${r[2]}–${r[3]}%</td><td class="num">${r[4] == null ? '–' : pct(r[4])}</td><td>${r[4] == null ? 'not measured' : esc(r[5])}</td></tr>`).join('\n');

const html = `<div class="chart" id="cp-chart">
<ul class="chart-legend" aria-label="Legend">
<li><svg width="34" height="14" viewBox="0 0 34 14" aria-hidden="true"><line class="cp-whisker" x1="3" y1="7" x2="31" y2="7"></line><circle class="cp-dot" cx="17" cy="7" r="5"></circle></svg><span>Uplift share 1 − 1/<i>m</i> (with range)</span></li>
<li><svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true"><path class="cp-vol" d="M8 1.5L14.5 8L8 14.5L1.5 8Z"></path></svg><span>Volume share, where measured</span></li>
</ul>
<div class="chart-plot">${fallback}</div>
<div class="chart-tip" hidden="hidden"></div>
</div>
<details class="chart-data">
<summary>Chart data</summary>
<div class="table-wrap">
<table>
  <thead>
    <tr><th scope="col">Domain</th><th scope="col" class="num">Uplift share 1 − 1/<i>m</i></th><th scope="col" class="num">Range</th><th scope="col" class="num">Volume share</th><th scope="col">Volume measure</th></tr>
  </thead>
  <tbody>
${tableRows}
  </tbody>
</table>
</div>
<p class="small">Uplift shares are judgement estimates from §§4–10; volume shares are measured, and each row defines volume differently.</p>
</details>
<script>
var CP_ROWS = ${JSON.stringify(ROWS)};
${SHARED.trim()}
${CLIENT.trim()}
</script>
`;
if (/\\[\(\)\[\]]/.test(html)) throw new Error('chart.html contains a TeX delimiter sequence');
fs.writeFileSync(path.join(__dirname, 'chart.html'), html);
console.log('wrote chart.html', Buffer.byteLength(html), 'bytes');
