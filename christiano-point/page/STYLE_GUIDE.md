# Style guide for section fragments

You are converting part of `/home/user/AI-works/christiano-point/report.md` into an HTML fragment for the published page "The Christiano Point". The page shell (`shell.html`) already holds the title, subtitle, byline, the report's line 5 note (models, §14, "Read §13 before quoting any number"), the table of contents, every style and the footer. Your fragment only replaces one placeholder in `<main>`.

**Hard rules**

- Write plain semantic HTML. No `<style>`, no `<script>`, no `style=""` attributes, no classes or ids other than the ones listed in this guide. If you need a style that does not exist, do not invent one: put a request in your notes back to the orchestrator.
- No `<!doctype>`, `<html>`, `<head>`, `<body>`, `<h1>`, `<h4>`–`<h6>`, `<hr>`, `<br>` for spacing, `<img>`, `<iframe>`, `<font>`, `<center>`, wrapper `<div>`s or nested `<section>`s.
- Double-quote every attribute. Close every non-void element.
- Keep the report's wording. Do not paraphrase, summarise, add commentary or drop content. Only the markup and the typography (quotes, escapes) change.
- Drop the Markdown `---` rules (sections already have rules), the report title, subtitle, line 5 and the Contents list (all in the shell).

## 1. Which fragment holds what

Write to `fragments/NAME.html (in this directory)`, overwriting the stub that is there.

| Fragment file | Contains, in this order |
|---|---|
| `s00.html` | §0 Summary (includes the figure, see §9 below) |
| `s01.html` | §1 |
| `s02.html` | §2 |
| `s03-04.html` | §3, then §4 |
| `s05.html` | §5 |
| `s06.html` | §6 |
| `s07.html` | §7 |
| `s08-09.html` | §8, then §9 |
| `s10.html` | §10 |
| `s11-12.html` | §11, then §12 |
| `s13-14.html` | §13, then §14 |
| `appendices.html` | Appendix A, then Appendix B |

A fragment is one or two `<section>` elements and nothing else at top level.

## 2. Sections and headings (exact)

```html
<section id="s5" aria-labelledby="s5-h">
<h2 id="s5-h"><span class="secnum">5</span> Software engineering</h2>
...
</section>
```

- Section ids: `s0` … `s14`, `appA`, `appB`. Heading ids: the section id plus `-h`.
- `<span class="secnum">` holds only the number, then one space, then the title.
- Appendices:
  - `<section id="appA" aria-labelledby="appA-h">` with `<h2 id="appA-h"><span class="secnum">Appendix A</span> Proofs for §2</h2>`
  - `<section id="appB" aria-labelledby="appB-h">` with `<h2 id="appB-h"><span class="secnum">Appendix B</span> The AI R&amp;D multiplier model</h2>`
- Section titles (use exactly, with curly quotes):
  0 Summary · 1 The concept and where it comes from · 2 What “contribution” can mean · 3 Questions worth asking · 4 Domains that crossed long ago, and what happened next · 5 Software engineering · 6 Frontier AI development and frontier algorithmic progress · 7 Mathematics · 8 Physics, biology, chemistry and materials · 9 ML research outside the labs, and alignment research · 10 All economic activity · 11 Synthesis · 12 Forecasts and what to watch · 13 Caveats · 14 Sources

**Numbered subsections** (`### 6.2 …` in the report) become `h3` with id `sN-M`:

```html
<h3 id="s6-2"><span class="secnum">6.2</span> Progress: the uplift crossover has not happened, by the labs’ own accounts</h3>
```

All subsection ids in the report: `s2-1`, `s2-2`; `s6-1` … `s6-5`; `s7-1`, `s7-2`, `s7-3`; `s8-1` … `s8-4`; `s9-1`, `s9-2`; `s11-1` … `s11-5`.

**Unnumbered h3** (no `secnum` span):
- §0: the findings heading inside the callout, `<h3 id="s0-findings">The six findings I’m most confident of</h3>` (drop the trailing colon).
- §14 source groups: `<h3 id="s14-1">Concept and theory</h3>`, `s14-2` Frontier AI R&amp;D, `s14-3` Software engineering, `s14-4` Mathematics, `s14-5` Sciences, `s14-6` Economy and analogies.

No other headings. Bold run-in labels stay in their paragraph: `<p><strong>Assessment.</strong> Problem-solving has crossed…</p>`. A bold label that stands alone in the report stays a paragraph: `<p><strong>Where things stand.</strong></p>`.

## 3. Running text

- Paragraphs: `<p>`. Bold: `<strong>`. Italic: `<em>` for emphasis, `<i>` for book titles (*Superintelligence*).
- Lists: `<ul>` / `<ol>`, nested freely. If a list item holds more than one block (text, then a list, then more text), wrap each run of text in `<p>` inside the `<li>`:

```html
<li><p><strong>The narrower the slice …</strong> In order:</p>
<ul><li>implementation and coding: probably past;</li></ul>
<p>Christiano’s own operationalisation (…) points to the broad one.</p></li>
```

- `.lede`: only the first paragraph of §0 gets `<p class="lede">`.
- `.small`: only the §14 legend paragraph (see §10 below). Do not use `<sub>` or `<small>` for notes.
- Inline code: `<code>` for file and folder names (`<code>models/rd_multiplier.py</code>`, `<code>paulsen/</code>`).

## 4. Links

**Cross-references to sections** use `a.xref`, link text exactly as the report writes it:

```html
(<a class="xref" href="#s6-2">§6.2</a>)
<a class="xref" href="#s4">§§4–10</a>          <!-- a range links to its first section -->
<a class="xref" href="#appA">Appendix A</a>
<a class="xref" href="#figure">the figure</a>   <!-- only where the report says "the figure" -->
```

`§2.1` → `#s2-1`, `§11.4` → `#s11-4`, `§2` → `#s2`. Two refs in one parenthesis: `(<a class="xref" href="#s6-5">§6.5</a>, <a class="xref" href="#s11-3">§11.3</a>)`. A list like `(§§2, 5, 6, 11.2)` becomes `(<a class="xref" href="#s2">§§2</a>, <a class="xref" href="#s5">5</a>, <a class="xref" href="#s6">6</a>, <a class="xref" href="#s11-2">11.2</a>)`.

**Citations** use `a.cite`, one link per source number, brackets inside the link, a non-breaking space (`&nbsp;`) before the first one so a marker never starts a line, and a word joiner (`&#8288;`) between consecutive ones:

```html
… not yet by a factor of 2”&nbsp;<a class="cite" href="#src-14">[14]</a>.
… unreliable lower bounds&nbsp;<a class="cite" href="#src-23">[23]</a>&#8288;<a class="cite" href="#src-25">[25]</a>.
```

(`[23, 25]` and `[12, 17, 18]` are split this way.) Keep each citation where the report puts it, before the punctuation it precedes there.

**Repository files** become absolute links under the branch URL; put the path in `<code>`:

- folders use `/tree/`: `https://github.com/kaarelh/AI-works/tree/claude/vibrant-wright-pdohvb/christiano-point`, and `models/` → `…/tree/claude/vibrant-wright-pdohvb/christiano-point/models`
- files use `/blob/`: `models/rd_multiplier.py` → `<a href="https://github.com/kaarelh/AI-works/blob/claude/vibrant-wright-pdohvb/christiano-point/models/rd_multiplier.py"><code>models/rd_multiplier.py</code></a>`; `models/crossover_definitions_output.txt`, `models/rd_multiplier_output.txt`, `models/crossover_definitions.py`, `models/make_figure.py` likewise.
- The repository is private: the shell's header note and footer say so; fragments need not repeat it.
- `paulsen/` (§7.3) lives at the repository root, outside `christiano-point`: `https://github.com/kaarelh/AI-works/tree/claude/vibrant-wright-pdohvb/paulsen`.
- `figures/domains-*.png` are replaced by the interactive chart; do not link them.

**External links** are plain `<a href="https://…">…</a>`; no `target`, no `rel`, no `download`. Text that the report prints without a scheme (`github.com/malob/ai-system-cards`, `arXiv:2507.23181`) stays plain text.

## 5. Tables

Every table sits in a `div.table-wrap` that is a named, focusable scroll region (keyboard users can scroll it), and every table has a visually hidden caption that names it. Use `thead`/`tbody`, `th scope="col"` for headers, and `th scope="row"` for the first cell when it is a short label naming the row (a domain, process, level, quantity). Long cells (the §11.4 claims) stay `td`, so they are not set as bold row headers:

```html
<div class="table-wrap wide" role="region" tabindex="0" aria-labelledby="tc-s6-nesting">
<table>
<caption class="sr-only" id="tc-s6-nesting">Nesting: uplift and status at each level</caption>
<thead>
<tr><th scope="col">Level</th><th scope="col">Uplift</th><th scope="col" class="num">AI share</th><th scope="col">Status</th></tr>
</thead>
<tbody>
<tr><th scope="row">Implementation and coding at labs</th><td>≈2–3.5×</td><td class="num">50–70%</td><td><span class="status-at">probably past</span></td></tr>
<tr class="highlight"><th scope="row">Frontier algorithmic progress</th><td>≈1.35–1.5×</td><td class="num">25–35%</td><td><span class="status-before">before</span></td></tr>
</tbody>
</table>
</div>
```

- `class="num"` (on the `th` and every `td` of that column): right-aligned, no wrapping. Use it for columns whose cells are short numbers, percentages or numeric ranges (the §2.1 worked example, the §6.3 tables, Appendix B, the §0 "AI share" column). Do not use it on columns with prose or dates in words.
- `class="tight"`: a cell that should take no minimum width, for single-letter key columns (the V / T / U / E / A / F column in §2).
- `div.table-wrap.wide`: prose-heavy tables (§0 summary, §2 readings, §4, §5, §6.5, §7.2, §10, §11.2, §11.4, the chart data). On phones they keep a minimum width (34rem; 42rem from 5 columns, 46rem from 6), scroll sideways, and pin their row-header column. Small numeric tables are not `wide` and fit the phone column.
- `table.compact`: small numeric tables (§6.3's two tables, Appendix B's projection) size to their content instead of spanning the column; their `.num` cells may wrap.
- Two-column tables (§12) are capped at the text measure automatically.
- `tr class="highlight"`: rows that are bold throughout in the report (e.g. **Frontier algorithmic progress** and **World economy** in §0, the bold rows of §6.5, §10 and §12). Drop the `<strong>` tags inside a highlighted row; the row style is bold.
- Single bold words inside an ordinary cell stay `<strong>`, except status words (next point).
- Empty header cell: `<th scope="col"><span class="sr-only">Quantity</span></th>` (name what the column holds). Empty-value cells (`—` in the report): write `–` (en dash).
- Math in cells works as in text (the shell lifts the inline-math width cap inside cells so headers like “AI share \(1-1/m\)” size correctly).
- Captions are `sr-only` (the report's tables have no visible captions); ids are `tc-…`.
- Do not split or reshape tables.

### Status chips

Use a chip only in columns headed **Status** in §0, §6.5 and §7.2. The chip holds the status word(s) only; any qualifier follows as plain text. One class, no `status` base class:

| Report text | Markup |
|---|---|
| past | `<span class="status-past">past</span>` |
| **past** (H1 2026) | `<span class="status-past">past</span> (H1 2026)` |
| past on V and roughly at T | `<span class="status-past">past</span> on V and roughly at T` |
| at or past | `<span class="status-at">at or past</span>` |
| probably past | `<span class="status-at">probably past</span>` |
| at; past by 2027 | `<span class="status-at">at</span>; past by 2027` |
| before | `<span class="status-before">before</span>` |
| before; past on headline open problems in Q3 2026 | `<span class="status-before">before</span>; past on headline open problems in Q3 2026` |
| before by count, at for flagship bounds | `<span class="status-before">before</span> by count, at for flagship bounds` |
| well before | `<span class="status-well">well before</span>` |
| far | `<span class="status-far">far</span>` |

Chips are filled (past), half-filled (at), outlined with a ring (before), dashed (well before) and dotted (far), so the state reads without colour. Do not use chips in §11.4's "Status, Oct 2026" column (those are verdicts: keep `<strong>Confirmed.</strong>` etc.) or in §12's "Estimate" column.

## 6. Quotations

- Inline quotations stay in running text with curly quotes, exactly as in the report, however long.
- No blockquotes. The report's one Markdown `>` (the order-of-crossing chain in §11.1) is a result, not a quotation: it is set as `<ol class="stages">`, one stage per `<li>`, wording unchanged, the → arrows dropped (the list order carries them).

## 7. Callout

Exactly one, in §0, around the six findings:

```html
<div class="callout">
<h3 id="s0-findings">The six findings I’m most confident of</h3>
<ol>
<li><strong>AI R&amp;D is approaching its Christiano point, but has not passed it.</strong>
<ul>
<li>Anthropic, August 2026: …</li>
</ul>
</li>
…
</ol>
</div>
```

No other callouts anywhere.

## 8. Math

- Inline: `\( … \)`. Display: `\[ … \]` on its own line, directly inside the `<section>` (or inside an `<li>`), never inside `<p>`.
- Convert every TeX `$…$` in the report to `\(…\)` and keep the TeX unchanged (`\tfrac12`, `\text{system}`, `\varepsilon_A`, `\dot C`). Do not turn a `$…$` into display math unless the report sets it apart.
- **Dollar signs that mean money are not math** (`$730B`, `$6 per developer-day`, `$10–1000`, `$126T`, `>$600 per day`). Write them as plain text.
- Inside `\( \)` and `\[ \]` write `<` `>` `&` as `&lt;` `&gt;` `&amp;` (e.g. `\(r&gt;1\)`, `\(\rho = 1-1/\sigma&lt;0\)`).
- A range with math on both ends stays two inline formulas joined by an en dash: `\(m \approx 1.35\)–\(1.5\)`.
- Check your fragment before handing it back:
  `node render_math.js fragments/NAME.html out/NAME.mathcheck.html`
  Exit code 1 and a JSON error list mean some TeX failed; fix it.

## 9. The §0 figure (s00 only)

Replace the Markdown image and its `<sub>` note with the figure below, followed directly (outside the figure, since a `figcaption` must be its first or last child) by the `<details class="chart-data">` disclosure holding the chart's data table:

```html
<figure id="figure">
<!-- CHART -->
<figcaption><p>Where domains stand relative to their Christiano point, October 2026. Blue dots and whiskers are judgement estimates with ranges, from <a class="xref" href="#s4">§§4–10</a>. Orange diamonds are measured volume shares; their definitions differ by row. Hover or focus a row for its numbers; the full data are under “Chart data”. Source: <a href="https://github.com/kaarelh/AI-works/tree/claude/vibrant-wright-pdohvb/christiano-point/models/make_figure.py"><code>models/make_figure.py</code></a>.</p></figcaption>
</figure>
```

`<!-- CHART -->` must appear exactly once, on its own line; the build replaces it with the interactive chart (legend, SVG, tooltip). The “Chart data” disclosure lives in `s00.html` right after `</figure>`; its rows must match `models/make_figure.py` ROWS (as does `CP_ROWS` in `chart.html`). Do not mention a dark-mode PNG: the chart follows the theme. Place the figure where the image is in the report, after `<p><strong>Where things stand.</strong></p>` and before the summary table.

## 10. Sources (§14)

The legend paragraph comes first and uses the tags themselves:

```html
<p class="small"><span class="vtag v1">✓</span> means read by me or a research agent this session, in the primary text, a verbatim mirror, or primary data (I re-ran or re-computed items marked <span class="nowrap"><span class="vtag v2">✓✓</span>).</span> <span class="vtag v0">○</span> means seen only in a search snippet or secondary coverage.</p>
```

Then, per group, an `h3` (ids in §2 above) and an ordered list whose `start` is the group's first number:

```html
<h3 id="s14-2">Frontier AI R&amp;D</h3>
<ol class="sources" start="12">
<li id="src-12"><span class="vtag v2">✓✓</span>Anthropic Institute (Favaro &amp; Clark), “When AI builds itself”, May 2026, updated 18 Sep 2026. <a href="https://www.anthropic.com/institute/recursive-self-improvement">https://www.anthropic.com/institute/recursive-self-improvement</a></li>
…
</ol>
```

- Groups and starts: Concept and theory 1; Frontier AI R&amp;D 12; Software engineering 22; Mathematics 32; Sciences 44; Economy and analogies 55. Every item `<li id="src-N">`, all 66 present, numbers consecutive within a group.
- Each item starts with its tag, with no space between `<li …>` and the `<span>`: `v2` for ✓✓, `v1` for ✓, `v0` for ○, and `<span class="vtag vmix">✓/○</span>` for item 42.
- URLs: the link text is the URL as printed; put trailing notes such as "(mirror; quotes checked)" after the link as plain text.

## 11. Typography

- Curly quotes: “double” and ‘single’; apostrophes ’ (Christiano’s, labs’, don’t). The report source often has straight quotes; convert them all, including inside table cells.
- En dash – for ranges (2027–29, 30–75%) and for pairs of names (Christiano–Yudkowsky, Davidson–Houlden), as in the report.
- True minus − for negative numbers in prose (−19%, −0.10); multiplication ×; ≈, ≥, ≫, …, as in the report. Write → in prose as `<span class="arr">→</span>`: the web fonts' latin subsets lack the arrow, and the class picks a symbol-capable face.
- Keep short units that must not break apart in `<span class="nowrap">…</span>` (e.g. an inline formula with its parentheses and closing punctuation, or “(pre-2023)”). Keep the report's em dashes where it has them; do not add new ones.
- Escape `&` as `&amp;` (R&amp;D, Davidson &amp; Houlden) and `<` `>` in text as `&lt;` `&gt;` (`&gt;80%`, `&lt;$10M/year`).
- Keep numbers, units and spellings exactly as in the report (British spelling, "labour", "formalisation").

## 12. Ids you may create

Only: section ids (`s0`–`s14`, `appA`, `appB`), heading ids (`sN-h`, `appA-h`, `appB-h`), subsection ids (`sN-M`), `s0-findings`, `s14-1`–`s14-6`, `figure`, `src-1`–`src-66`, and table-caption ids `tc-…`. The shell already uses `main`, `cp-chart` and `xd-title`. Every `href="#…"` you write must point at one of these ids.

## 13. Classes you may use (complete list)

`secnum`, `lede`, `small`, `callout`, `table-wrap`, `wide`, `compact`, `num`, `tight`, `highlight`, `sr-only`, `status-past`, `status-at`, `status-before`, `status-well`, `status-far`, `cite`, `xref`, `sources`, `vtag`, `v2`, `v1`, `v0`, `vmix`, `stages`, `arr`, `nowrap`, `chart-data`.

## 14. Checking your work

```sh
cd christiano-point/page
node render_math.js fragments/NAME.html out/NAME.mathcheck.html   # TeX errors
node assemble.js                                                    # whole page; missing fragments, leftover delimiters
node check.js > out/check.json                                      # overflow at 400px, missing #anchors, console errors
```

In `check.js` output, failed requests to `fonts.googleapis.com` / `fonts.gstatic.com` (certificate errors) come from the sandbox proxy and can be ignored. Missing anchors that point at other agents' sections are expected until every fragment is in. Never edit `shell.html`, `chart.html` or another agent's fragment.

## 15. Minimal complete example

```html
<section id="s9" aria-labelledby="s9-h">
<h2 id="s9-h"><span class="secnum">9</span> ML research outside the labs, and alignment research</h2>
<h3 id="s9-1"><span class="secnum">9.1</span> Academic ML</h3>
<p>Empirical ML research is code-heavy, so its <em>labour</em> uplift should track software engineering, roughly 1.3–2× for active users.</p>
<h3 id="s9-2"><span class="secnum">9.2</span> Alignment and safety research</h3>
<ul>
<li><strong>Anthropic’s compute split</strong>&nbsp;<a class="cite" href="#src-13">[13]</a>: “About 6% of compute that went to AI R&amp;D was allocated toward safety”; …</li>
<li><strong>A clean demonstration.</strong> The 97%-versus-23% weak-to-strong supervision comparison (<a class="xref" href="#s6-2">§6.2</a>)&nbsp;<a class="cite" href="#src-12">[12]</a> was on an alignment problem …</li>
</ul>
<p><strong>Net:</strong> empirical alignment research crosses roughly when capabilities research does.</p>
</section>
```
