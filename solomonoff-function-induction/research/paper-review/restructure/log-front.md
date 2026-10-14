# Log of FRONT (Paper 2 restructure, 2026-10-13)

Inputs read: `PLAN.md` (in full), the six writer logs `log-W1.md` … `log-W6.md`, every body section and appendix of Paper 2 as rewritten (`setup`, `absorb`, `kinks`, `recovery`, `parity`, `teacher`, `limits`, `computable` and their appendices; the statements of `app-recovery`, `app-teacher`, `app-related`, `app-limits`, `app-parity`, `app-setup` that the front files cite), the synthesis `research/tracks/split/notes-final.md` (§0–§2, §3.3, §4, §6, §8), `REFRAME.md`, `DECISIONS.md` (§0, §A, §B, §C, §D, §F28–§F46, §G, §H), the base front files (`git show dcb3a3a3:…`), Paper 1's `steeper.tex`, `intro.tex`, `discussion.tex` and `main.aux`.

No git command that changes repository state was run. No body file was edited (none needed fixing for the build).

## 1. Files written

### Paper 2
* **`main.tex`.** Title "Steeper Simplicity Priors in Solomonoff Function Induction: The Model–Randomness Split and the Teacher's Mistakes" with the matching `\hypersetup{pdftitle=…}`; input order of PLAN §1.7 (intro, related, setup, absorb, kinks, recovery, parity, teacher, limits, computable, discussion; appendices setup, absorb, kinks, recovery, split (continuation), parity, teacher, limits, related); `split.tex`, `algstat.tex`, `app-algstat.tex` no longer input; `\sfirecordfalse` kept. `tocdepth` stays 1 (sections only; a trial with 0 emptied the contents list and was reverted).
* **`sections/abstract.tex`.** Rewritten per PLAN §1.2: SFI and the proposal, the two reasons; absorption; the first reason (Theorem A with its rate and the λ = 1 contrast; Theorem B; samples and the noisy parity have kinks, set models no steep one); the second reason (reuse factor, the teacher theorem with all its hypotheses, "for large error rules" (F35), windows below 0.1233 asymptotically). **1913 characters** of source between the environment lines (limit 1920).
* **`sections/intro.tex`.** The proposal with its footnote (unchanged credit list); one paragraph with the two reasons (split first; the three-hypothesis calculation; one geometry, reuse factor, `\cref{tab:discussion:reasons}`); the absorption objection (three sentences); conventions (with DS/FR/PQ); informal Theorems A (exact recovery), B (a kink implies the split, with where kinks occur and the flattening by a universal member) and C (the teacher's mistakes: base text, hypotheses and numbers, phrased about near-optimal hypotheses; the reuse-factor sentence; windows for $p\le0.1233$); six contribution bullets; `tab:intro:claims` with 8 rows; scope and reader's guide with the new section map.
* **`sections/related.tex`.** Paragraphs "Generalised posteriors and two-part codes" (`rem:related:posteriors`, with the cold-posterior sentence carrying `rem:related:cold`, and the new Barron–Cover paragraph content: "studied by", supervised analogue, standard method, no novelty claimed for Theorem A(a),(b)), "λ-weighted two-part MDL" (`rem:related:mdl`, kept; ends with the one-sentence pointer to the earlier report and `app:related:t5`), "Algorithmic statistics", "Novelty" (`rem:related:new`, updated list, with "the hull–penalty relation itself is elementary convex geometry; the method of Theorem A(a),(b) is standard"). The paragraph "An earlier report" (`rem:related:t5`) is gone from this file; W6 holds it in `app-related.tex`.
* **`sections/discussion.tex`.** "Two reasons, one geometry" with **`tab:discussion:reasons`** (new label; seven rows of PLAN §1.5: what is discarded, reuse factor, left steepness, the λ that works, what λ = 1 does, what defeats it, what the learner is; no numbers); "What counts as one hypothesis" (shortened, now with the kink reading); "The window and its price" (reuse factor; the deliberate inconsistency kept); "The gap to realistic errors" (F37 text verbatim); "Neural networks" (the old "Relation to other work" without its literature half, which §2 carries); open problems (6 items citing all seven questions: `q:recovery:open`, `q:parity:open`, `q:algstat:lsc`, `q:teacher:open`, `q:limits:open`, `q:absorb:shared`, `q:related:open`); acknowledgements and code and data unchanged (`\cref{sec:split:lambda1}` resolves; `rem:related:nn` resolves).
* **`bib/core.bib`.** Title of `claudeSFI2026steeper` changed to the new title; the same one-line change in `paper/bib/core.bib`; `diff paper/bib/core.bib paper-steeper/bib/core.bib` is empty. No other bibliography change (Barron–Cover was already `barron1991minimum`).
* **`preamble.tex`.** Not changed (no new macro needed).
* **`CLAIMS.md`.** Rewritten: binding notes, the claims of the two reasons, the flip-rate decimals, a ledger generated from the sources in input order (number, label, kind and title, status, source; 2026-10-13 build), the updated answers to the author's questions.
* **`OUTLINE.md`.** Rewritten to the new structure: binding notes, the story, the section/file/page table with budgets and measured pages, labels, builds.

### Paper 1 (text only)
* **`sections/steeper.tex`.** Reordered as the two reasons, the split first, with the exact-recovery sentence of PLAN §1.6; footnote kept; one comment line block added.
* **`sections/intro.tex`** (bullet on `sec:steep`) and **`sections/discussion.tex`** (paragraph "The companion paper"): the two reasons, one sentence each.
* No numbered environment, section, footnote or label added or removed: a regex comparison of `\begin{…}`, `\section`, `\subsection`, `\label`, `\footnote` against the base finds the same lists in all three files.

## 2. Deviations from the plan, with reasons

1. **0.056 → 0.05596** in the abstract, Theorem C, the scope paragraph and Paper 1 (`steeper.tex`, intro bullet, discussion). PLAN §1.2/§1.3/§1.6 say 0.056, but `verify-teacher.md` §9 (reported in log-W4 §7 and log-W5 §10) shows that "$G_1>H(p)$ iff $p<0.0560$" is false for some dyadic rule sizes now that $s_0$ is arbitrary (e.g. $p=3669/2^{16}$); the exact root is $p_0=0.0559643\ldots$, and the body (`sec:parity:full`, `teacher.tex`) prints the sufficient decimal $p<0.05596$. The rules require the verified form.
2. **Asymptotic threshold printed as $p\le0.1233$** (and "below 0.1233" in the abstract and section titles), matching `prop:teacher:rates` and the rounding of V-T §9.
3. **Related work.** The cold-posterior paragraph is one sentence inside the first paragraph; its label `rem:related:cold` sits on that sentence (no file cites it). The Barron–Cover content is in the same paragraph, not a separate one, for the page budget. The pointer to the earlier report is one sentence at the end of the MDL paragraph.
4. **`tab:intro:claims`.** 8 rows: absorption (kept); the two new rows (sampler/fill-ins; what λ = 1 does); the slope row rewritten; the "vertex" row merged with "does another hypothesis do better" and rewritten per synthesis §3.3 item 5 (with `rem:teacher:selected`); the length-coefficient row (errors yes, noise no); the absolute-bound row; the pathology row. Dropped: the three-hypothesis-realisation row (optional) and "Has a steeper penalty been studied…" (now in §2). The absolute-bound answer is restated as "every penalised minimiser solves a length-bounded problem, but a length bound can also select points that no penalty selects" (`lem:setup:hull`(iv), `rem:setup:hullconverse`), because the base answer "at vertices of the hull only" did not match (iv).
5. **Contributions.** The hull characterisation is cited in Theorem B, not in the kinks bullet; the parity bullet says "for large $d$" only through Theorem B's paragraph.
6. **Discussion.** "Relation to other work" is reduced to its neural-network sentence (now titled "Neural networks"); the literature comparison is in §2.

No [V-T] label had to be removed: `lem:teacher:reuse`, `prop:teacher:schedules`, `prop:teacher:frozen`, `lem:kink:secant` exist (verified per log-W2 §5 and log-W5 §4), and `lem:kink:main` is in its final form.

## 3. Integration checks

* **Full build of Paper 2** (`flock … ./build.sh`, last run after all edits): LaTeX errors 0; undefined references 0; undefined citations 0; multiply defined labels 0; overfull boxes above 10 pt 0 (one of 1.8 pt in the bibliography); **75 pages**. The first build with the new input order and the old front files showed only `rem:related:t5` multiply defined (removed from `related.tex` as planned).
* **Manifest.** All 203 labels named in PLAN §3.1–§3.3 (cut items excepted) are defined exactly once in `main.aux`; the cut labels `lem:split:hash`, `app:split:hash`, `tab:algstat:numbers`, `app:algstat:numbers`, `rem:limits:method`, `app:limits:method` are defined nowhere and occur only in `%` comments. Every move of PLAN §3.5 is confirmed by both logs and by the absence of duplicates.
* **DECISIONS §A2.5.** A copy of `extract_status.py` writing to the scratchpad: 98 `\status` calls in Paper 2's sources, none in a table float; the 7 calls it reports "outside an environment" are the `\status{open}` of the seven `question` environments (its environment list lacks `question`); every new non-plain status is rendered per the writer logs. `\status`/`\src` are redefined to print nothing (preamble lines 121–123); `pdftotext main.pdf | grep '\[(proved|computed|conjecture|known|proof sketch|refuted|remark)'` finds nothing.
* **DECISIONS §A5** grep on `pdftotext main.pdf`: only "independent AI referees" in the title footnote and formula renderings ($c_1$, $c_2$, $s_0$, $\mathcal E_0$, $e_1$, $S_1$, $S_2$, $\mathbb R^2$). The extra restructure vocabulary (synthesis, sub-track, verified, refereed, post-referee, withdrawn, corrected, iid, T1–T5, script ids) has no hit.
* **DECISIONS §B.6.** `grep -c -i wyeth` on the PDF: 0; in the sources only the label `rem:absorb:wyeth` and comments.
* **REFRAME.** `hanni2026notes`/`hanni2026grokking` are cited only in the two footnotes (`intro.tex`, `kinks.tex`) and the acknowledgements; "the author" appears only in the title footnote, the two footnotes and the acknowledgements; no visible text frames a result as a reply.
* **`T5` credit notes** (`\src{… T5 …}`): the 15 items that credit a result of the earlier report all appear in the correspondence table of `app:related:t5`; the sixteenth (`rem:teacher:hanni`, "T5 re-run") names only a computation.
* **Full build of Paper 1:** 0 errors, 0 undefined references and citations, 0 multiply defined labels, 0 overfull boxes above 10 pt; 91 pages.
* **`check_companion_numbers.py`** after the Paper 1 build: last line `ALL OK`. "Used not in intended: Theorem~5.1" (`absorb.tex`, `rem:absorb:wyeth`): checked by hand, `thm:learn:dominance` is `{5.1}` in `paper/main.aux`. "Intended not used: Remark~B.3" is informational (the hashing comparison was cut, log-W3 D-W3-4). The front files cite Paper 1 only as Question 10.9 (`q:nn:bridges`, in the known list).

## 4. Pages (full build of 2026-10-13; positions of the headings from `pdftotext -bbox`)

| part | plan budget | measured | over |
|---|---|---|---|
| title, abstract, contents | 1.25 | 1.51 | +0.26 |
| §1 Introduction (with `tab:intro:claims`, about 0.55) | 2.25 | 3.38 | +1.13 |
| §2 Related work | 0.75 | 0.97 | +0.22 |
| §3 Setting (W1) | 2.25 | 3.49 | +1.24 |
| §4 Absorption (W1) | 2.25 | 3.40 | +1.15 |
| §5 Kinks (W2) | 2.25 | 2.57 | +0.32 |
| §6 Exact recovery (W3) | 4.75 | 5.80 | +1.05 |
| §7 The noisy parity (W4) | 2.5 | 4.31 | +1.81 |
| §8 The teacher (W5) | 4.75 | 6.12 | +1.37 |
| §9 Structured errors (W6) | 1.75 | 2.43 | +0.68 |
| §10 Computable classes (W6) | 0.5 | 1.12 | +0.62 |
| §11 Discussion, acknowledgements, code and data (with `tab:discussion:reasons`, about 0.4) | 1.5 | 2.30 | +0.80 |
| **main text** (title to the end of Code and data) | **26.75** (cap 27) | **37.40** | **+10.65** |
| references | about 2 | 2.38 | |
| App A (W1) | 2.5 | 2.09 | −0.41 |
| App B (W1) | 3.5 | 3.85 | +0.35 |
| App C (W2) | 1.75 | 2.10 | +0.35 |
| App D (W3, with `app-split.tex`) | 7.0 | 8.27 | +1.27 |
| App E (W4) | 3.75 | 6.46 | +2.71 |
| App F (W5) | 4.5 | 6.38 | +1.88 |
| App G (W6) | 2.75 | 4.05 | +1.30 |
| App H (W6) | 1.25 | 1.99 | +0.74 |
| **appendices** | **27.0** (cap 27) | **35.19** | **+8.19** |
| **total** | cap 57 | **75** | **+18** |

**The DECISIONS §C caps are not met** (main ≤ 27, appendices ≤ 27, total ≤ 57). FRONT trimmed its own files twice (the introduction from 3.8 to 3.4 pages including the table, the discussion from 2.55 to 2.3, the related work from 1.3 to 1.0); the introduction cannot reach 2.25 pages with the three informal theorems, six bullets and the 8-row table that the plan requires. The body sections were declared final for now and were not cut. The writers' own lists of further placement changes (log-W1 D-W1-2 (a)–(d), log-W2 §7.8, log-W3 D-W3-10, log-W4 §8, log-W5 §7, log-W6 §9) add up to roughly 3 pp of main text and 3 pp of appendix, which would still leave the main text near 34 pages and the appendices near 32. Meeting the caps needs a decision on content (for example: state `prop:recovery:lambda1`, `thm:recovery:kink`, `prop:teacher:sharp`/`prop:teacher:rates` and `prop:algstat:parity` in the appendices with one-paragraph summaries, cut the computed tables `tab:parity:ranges` and `tab:teacher:rates`, drop `prop:teacher:concentration`, `ex:teacher:version1`, `prop:algstat:coarse` and `q:algstat:lsc`), or a decision to relax the caps for the restructured paper.

## Fixes (fix round, DECISIONS-restructure; `fix-FRONT.json`, 17 entries)

Files edited: `paper-steeper/sections/abstract.tex`, `intro.tex`, `discussion.tex`, `related.tex` (front files), and `paper-steeper/CLAIMS.md`, `OUTLINE.md`. No body file, no Paper 1 file and no bibliography was edited. No label was added, renamed or removed. No git command that changes repository state was run. Scratch scripts (page measurement, ledger generation, a copy of `extract_status.py` with `question` added to its environment list, and a check of the decided exact texts) are in the session scratchpad, not in the repository.

### id → change

| id | change |
|---|---|
| RF-01 | `abstract.tex`: body replaced by the D9 text, verbatim (extracted from DECISIONS-restructure by script; 1920 characters of stripped source between the environment lines). Comment lines updated: D9 as source, with the body labels each claim traces to. |
| RF-02 | `intro.tex`: last sentence of Theorem A and the answer of the `tab:intro:claims` row "Does a steeper prior separate a sampler from its fill-ins?" replaced by the D1 texts, verbatim. |
| RF-03 | `intro.tex`: Theorem A's margin is "a lower bound on the average squared Hellinger distance to $\nu$ (the Hellinger gap of \cref{def:split:setting}) of the inequivalent programs …" (D8, verbatim). |
| RF-04 | `intro.tex`: Theorem C "at most $0.200$ $(\kappa=0)$ or $0.274$ $(\kappa=30)$ at $c=10^{-4}$ and the sizes given below"; the next paragraph "$(9.54\cdot10^{-7},3.65\cdot10^{-3}]$ at $\kappa=30$" (D10). The numbers stay in the informal theorem (REJ-09). |
| RF-05 | (1) The `tab:intro:claims` row "What does $\lambda=1$ do?" is deleted (`tab:discussion:reasons` carries it). (2) The Kinks bullet is two lines: "One kink lemma for both reasons (\cref{lem:kink:main}) and Theorem B; a universal member flattens every kink far beyond its own length (\cref{prop:kink:universal})." The Exact-recovery bullet is two lines: the head and the RF-10 text only. (3) Discussion: "What counts as one hypothesis" is three sentences, in kink terms (which kinks exist depends on the class: `prop:kink:universal` with the RF-08 wording, `prop:parity:kink`, `prop:parity:sets`; the private-randomness class is the choice, with a pointer to `rem:absorb:wyeth` for its price and boundary); it no longer restates `rem:absorb:wyeth`(i)–(iv). "The window and its price" is three sentences: the reuse factor explains $\lambda\propto n$; the deliberate inconsistency, with a pointer to `rem:limits:schedule` for the batch excess; imitation data cannot justify the price (`prop:limits:noident`). (4) Conventions shortened (see deviations). |
| RF-06 | Integration: see "Integration checks" below. |
| RF-07 | `intro.tex`: the sentences after Theorem B replaced by the decided text, verbatim (sample kink "of the same kind", Ville deficiency in place of the sufficiency slack; "for large $d$ and typical error sets ($\delta_E=O(d)$)"; "dyadic"; "far beyond its own length"). |
| RF-08 | "a universal member flattens every kink far beyond its own length" in the Kinks bullet, after Theorem B (RF-07) and in the discussion paragraph "What counts as one hypothesis". |
| RF-09 | `tab:intro:claims` slope row: decided answer verbatim; Where: `cor:kink:split,thm:recovery:kink,prop:parity:range,prop:parity:sets`. |
| RF-10 | Exact-recovery bullet: "Theorem A, with each ingredient of its rate necessary separately, up to logarithms (\cref{thm:recovery:main,prop:recovery:lambda1,prop:recovery:necessity})." |
| RF-11 | `related.tex`: "every schedule $1\le\lambda_n=o(n)$". The Barron–Cover sentence and "we claim no novelty" stay; `rem:recovery:method` (W3, D11(e)) points here. |
| RF-12 | `tab:discussion:reasons`, row "What defeats it", first column: decided text verbatim. |
| RF-13 | Discussion "Neural networks": "… apply to countable discretisations with integer code lengths and Kraft weights whose noise model contains the sampler". |
| RF-14 | Discussion "The gap to realistic errors": "on about a third (with the machine constant set to $0$, an illustration) to a quarter ($\kappa=30$) of the window's logarithmic width". The rest of the F37 text is unchanged. |
| RF-15 | Open problems (3): "for $p_1\le p<\frac14$"; (2): the decided first question verbatim. |
| RF-16 | `tab:intro:claims` row 1: "… and randomness shared by several inputs costs about a factor $\min(\lambda,2)$ more than in a shared class". |
| RF-17 | Not applied: it is optional and only allowed if §1 stays within 3.2 pp; §1 measures 3.28 pp. |

**Deviations from the decided texts (layout, length or coherence; no mathematics):**
* **Kinks bullet (RF-05(2)).** To reach two lines, "read on data or in population" and the citation "(Corollary 5.5 and Theorem 5.6)" were dropped. "Theorem B" is named instead; its paragraph cites `cor:kink:split` and `thm:kink:converse`, and the converse is part of it.
* **Exact-recovery bullet (RF-05(2), RF-10).** The RF-10 text fills two lines, so the bullet's other items were dropped. All but one are cited elsewhere in §1:
  * the sample kink, after Theorem B;
  * frozen labels and `thm:split:private`, in Theorem A;
  * `thm:split:lambda1`, in the second paragraph.

  The exception is `cor:recovery:noisy`, which would otherwise not be cited in §1. One sentence in the scope paragraph now cites it: "from labels of a computable function flipped at a computable rate below $\frac12$ it recovers the function ($\mu$-a.e.) and the rate". This is `cor:recovery:noisy`(i), per query, as the preceding "Exact recovery holds per query" says.
* **Conventions (RF-05(4), optional).**
  * "not results about a reference machine" was dropped; the caption of `tab:intro:claims` still says that κ = 0 numbers are illustrations.
  * "that depends only on" became "depending only on".
  * "labels drawn afresh at every query" became "fresh labels at every query".
  * The semimeasure-convention sentence is kept (REJ-11).
* **Discussion layout and wording.**
  * In `tab:discussion:reasons` the two text columns have `\hsize` 1.18 and 0.82 instead of equal widths (layout only).
  * In the same table, the cell "structured rules, with a second kink" is now "structured rules (a second kink)".
  * "The window and its price" no longer has the clause "for noise there is no such price". The table and "Two reasons, one geometry" carry that contrast.
  * In open problem (2), the second question reads "lower-semicomputable products" instead of "lower-semicomputable product models".
* **Reader's guide.** "the instance shared by both" became "the shared instance", and "collects the open problems" became "lists open problems". Each change removes a line that held a single word.
* **Comments.** One fix-round comment line block was added at the top of `intro.tex`, `discussion.tex` and `related.tex` (comments only).

The intro and discussion were checked against the fixed body, sentence by sentence where a body item changed in this round:
* the frozen-label claims (D1–D3);
* the margin (D8);
* the numbers (D10);
* `prop:recovery:lambda1`(a) (D11(b)): "no recovery time depends only on $(\ell_0,\gamma,\varepsilon)$" still holds;
* `rem:teacher:hypotheses`, which still carries the δ_S/Ville-deficiency parallel that "Two reasons, one geometry" cites;
* `rem:limits:schedule`, which still carries the batch excess that "The window and its price" points to;
* `q:recovery:open`, `q:parity:open` and `q:teacher:open`, against open problems (1)–(3);
* `prop:teacher:sharp`, which is now App F and is still cited correctly from the teacher bullet.

### Integration checks (DECISIONS-restructure §4 item 7)

* **Full build of Paper 2** (`flock … ./build.sh`, last run after all edits):
  * 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels;
  * no overfull box above 10 pt (one of 1.8 pt, in the bibliography, as before);
  * **74 pages**.
* **Moved labels.** Each of these is defined exactly once in the sources and once in `main.aux`: `lem:setup:basic`, `app:setup:basic`, `prop:absorb:pricing`, `rem:recovery:window`, `rem:recovery:frozentable`, `prop:teacher:sharp`, `sec:limits:ood` (alias on `app:limits:ood`), `prop:related:computability`.
* **Decided texts.** A script compares the sources with 50 decided strings and 13 removed strings:
  * the 50 decided strings are D1–D8, D10, D11(a)–(x) (sample) and RF-07 to RF-16;
  * the 13 removed strings include `start=0`, `\Gamma_g`, the deleted table row and the D11(y) sentence.

  It ends ALL OK.
* **Removed phrases (§4 item 7).** In the sources (without `app-verification.tex`) and in `pdftotext main.pdf`, none of these occurs:
  * "identifies it on the queried inputs" and "identifies $\nu$/ν on the queried";
  * "average Hellinger distance";
  * "0.199", "3.66", "0.545", "0.955";
  * "useless over set models in this example (";
  * "() Level";
  * `0.1233\le p`.

  "(o) Level bounds" occurs once in the PDF. The only source hit of "0.545" is in `app-verification.tex`, which is switched off and not edited (PLAN §2): a historical script value in its table.
* **DECISIONS §A2.5.**
  * The scratch copy of `extract_status.py` (with `question` among the environments) counts 98 `\status` calls in Paper 2, 0 outside an environment and 0 in a table float.
  * `\status`/`\src` print nothing.
  * The status-string grep on the PDF text returns nothing.
* **DECISIONS §A5.** The grep on the PDF text hits only two kinds of text:
  * "independent AI referees" in the title footnote;
  * formula renderings: the items (c1)–(c3) of `thm:absorb:absorption`, $c_1,c_2$, $s_0$, $\mathcal E_0$, $r_0,r_1$, $S_1,S_2$, $e_1$, $\mathbb R^2$, $\mathsf C_{1/2}$, and a DOI.

  The extra restructure vocabulary (synthesis, sub-track, verified, refereed, withdrawn, corrected, iid, T1–T5, V-I/V-K/V-T, verify-) has no hit.
* **DECISIONS §B.6.**
  * `grep -c -i wyeth` on the PDF text: 0.
  * In the sources: only the label `rem:absorb:wyeth` and comments.
* **REFRAME.**
  * `hanni2026notes` and `hanni2026grokking` are cited only in the two footnotes (`intro.tex`, `kinks.tex`) and the acknowledgements.
  * "the author" appears only in the title footnote, those two footnotes and the acknowledgements.
  * There are two `\footnote`s besides the title `\thanks`.
* **Paper 1.**
  * Not edited.
  * Full build (`flock … ./build.sh`): 0 errors, 0 undefined references and citations, 0 multiply defined labels, 0 overfull boxes above 10 pt; 91 pages.
  * None of the changed Paper 2 phrases or numbers occurs in its PDF text. Its summary of Paper 2 (`steeper.tex`) still matches the fixed body: 0.05596, and "for fixed λ > 1 at a rate that depends only on λ, the program's length, a margin and the confidence".
  * `paper/bib/core.bib` and `paper-steeper/bib/core.bib` are identical.
* **Companion check.** `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py`, after the Paper 1 build: last line **ALL OK**.
  * "Used not in intended: Theorem~5.1" (`absorb.tex`). Checked by hand: `thm:learn:dominance` is `{5.1}` in `paper/main.aux`.
  * "Intended not used: Section~7.3" is the `\citealp[Section~7.3]` of `recovery.tex`, which the script does not parse. Checked by hand: `sec:ex:eisenstat` is `{7.3}`.
  * "Intended not used: Remark~B.3" is informational: the hashing comparison was cut.
  * Every other Paper 2 citation of Paper 1 (23 distinct locators, listed by a grep of `\cite…[…]{claudeSFI2026fundamentals}`) is in the script's known list.
* **`CLAIMS.md`.**
  * Ledger regenerated from the sources in input order, with numbers from the final `main.aux`. It records the moved items and the retitled ones (`prop:kink:universal`, `prop:teacher:rates`, `rem:setup:objects`, `q:recovery:open`).
  * The summary paragraphs now carry the fixed claims: equivalence on the run; the fill-in threshold; "far beyond its own length"; dyadic flip rates and typical error sets; $p_1$; the safely rounded numbers; the price factor min(λ, 2).
* **`OUTLINE.md`.** The page table now has the targets and caps of DECISIONS-restructure §3 and the final measurements. It also records the overrun with the REJ candidates, the moved items, the abstract (D9) and the story (per-query samples, dyadic flip rates).

### Pages (full build after the fix round; text-block pages between heading positions from `pdftotext -bbox`, the method of §4; target ± 0.15 from DECISIONS-restructure §3)

| part | before the fix round | target | after | |
|---|---|---|---|---|
| title, abstract, contents | 1.51 | 1.5 | 1.51 | ok |
| §1 Introduction | 3.38 | 3.2 | 3.28 | ok |
| §2 Related work | 0.97 | 0.95 | 0.97 | ok |
| §3 Setting (W1) | 3.49 | 3.0 | 3.24 | +0.24 (0.10 of it white space at the bottom of p. 9; §4 starts at the top of p. 10) |
| §4 Absorption (W1) | 3.40 | 2.9 | 3.00 | ok |
| §5 Kinks (W2) | 2.57 | 2.5 | 2.55 | ok |
| §6 Exact recovery (W3) | 5.80 | 5.1 | 5.33 | +0.23 |
| §7 Noisy parity (W4) | 4.31 | 3.8 | 3.84 | ok |
| §8 Teacher (W5) | 6.12 | 5.3 | 5.42 | ok |
| §9 Structured errors (W6) | 2.43 | 2.1 | 2.32 | +0.22 |
| §10 Computable classes (W6) | 1.12 | 0.8 | 0.95 | +0.15 (edge) |
| §11 Discussion etc. | 2.30 | 2.0 | 2.10 | ok |
| **main text** | **37.40** | **33.15, cap 33.5** | **34.50** | **cap exceeded by 1.00** |
| references | 2.38 | – | 2.33 | |
| App A (W1) | 2.09 | 2.4 | 2.33 | ok |
| App B (W1) | 3.85 | 4.4 | 4.30 | ok |
| App C (W2) | 2.10 | 2.1 | 2.07 | ok |
| App D (W3) | 8.27 | 8.7 | 8.80 | ok |
| App E (W4) | 6.46 | 6.3 | 6.37 | ok |
| App F (W5) | 6.38 | 7.0 | 7.30 | +0.30 |
| App G (W6) | 4.05 | 4.0 | 3.80 | ok |
| App H (W6) | 1.99 | 2.2 | 1.99 | ok |
| **appendices** | **35.19** | **37.1, cap 37.5** | **36.96** | ok |
| **total** | **75** | **cap 73.5** | **73.79 (74 pages)** | **cap exceeded by 0.29** |

**Overrun.** The appendix cap holds. The main-text cap (33.5) and the total cap (73.5) do not: the main text is 1.00 pp over its cap and the total 0.29 pp over.
* Even with every section exactly at its target, the main text would be 33.15 pp, which leaves 0.35 pp for page breaks and floats.
* The measured excess is spread over §3, §6, §9 and §10. The page-bottom white space of pp. 2–34 (the main-text pages before the last one) adds up to about 0.42 pp, 0.10 of it before §4.

As DECISIONS-restructure §3 requires, nothing further was moved or cut. The next candidates, which need the author's decision, are:
* main text: REJ-01 (the statements of `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart`, `lem:teacher:sharpfloor` and the $F^\sharp_t$ display to App E, with one summary paragraph), REJ-04 (`cor:recovery:noisy` and its paragraph to App D) and REJ-05 (§6.7, `thm:split:lambda1`, to App D);
* appendices: REJ-08 (the correspondence table of App H to the README; `prop:algstat:coarse`, `rem:algstat:near1`, `q:algstat:lsc`, `ex:teacher:version1`, `prop:teacher:concentration`).

### Outcome of every writer fix entry, as reported in the logs (checked by the source grep above where a decided text exists)

| id | outcome |
|---|---|
| RW1-01 | Applied, with these changes:<br>• `lem:setup:basic` and its proof moved to App A.2 (new structural label `app:setup:basic`), with one sentence in §3.<br>• The generalised-posterior sentence is now a pointer to `rem:related:posteriors`.<br>• `rem:setup:objects` is 4 lines, retitled "Repeated inputs".<br>• Prose trims, no statement changed. |
| RW1-02 | Applied, with these changes:<br>• `prop:absorb:pricing`, with the definition of $Q_x$, moved to App B.4 (retitled "Per-input pricing"). §4 keeps the two decided sentences, plus "with $Q_x$ the law of $f(x)$".<br>• The prediction sentence after `thm:split:shared` moved to App B.3.<br>• `rem:absorb:wyeth`(iii),(iv) are one clause each. |
| RW1-03 | Applied: D11(g) verbatim. |
| RW1-04 | Applied: D11(k) verbatim. |
| RW1-05 | Applied: the fit of `lem:setup:hull`, its proof and `rem:setup:hullconverse` is written $L$ (D11(z)). |
| RW2-01 | Applied: trims of `rem:kink:reading`, of the paragraph after `def:kink:kinks` and of the proof ideas; no statement changed. |
| RW2-02 | Applied: D11(i) verbatim. |
| RW2-03 | Applied: D11(j), the new title of `prop:kink:universal`. |
| RW3-01 | Applied: D1 in `recovery.tex`. |
| RW3-02 | Applied: D2 in three places. One clarifying clause was added in the "(iv), MAPs" step of `app:split:private` (indexing by distinct inputs); no mathematical change. |
| RW3-03 | Applied: D3 in `rem:split:reading`. |
| RW3-04 | Applied: D4. The computed values are in App D after `rem:recovery:frozentable`, checked against verify-iid §1.10. |
| RW3-05 | Applied, with these changes:<br>• `rem:recovery:window` moved to App D.4, with a pointer sentence in §6.4.<br>• The paragraph after `thm:split:lambda1` is one sentence; the $i_n$ bound moved to `app:split:si`.<br>• `rem:recovery:posterior` is 3 lines.<br>• The paragraph after `prop:recovery:frozen` is 4 lines.<br>• Prose trims. |
| RW3-06 | Applied: D11(e). |
| RW3-07 | Applied: D11(a). |
| RW3-08 | Applied: D11(b). |
| RW3-09 | Applied: the D11(h) renaming in §6.3, `rem:recovery:window`, `prop:recovery:necessity` and App D.3–D.4. |
| RW3-10 | Applied: D11(c). |
| RW3-11 | Applied: D11(d). The `\src` of `q:recovery:open` was updated to match. |
| RW3-12 | Applied: D11(f). |
| RW4-01 | Applied: D6 (W4 part). No result of §7 or App E uses (D2). |
| RW4-02 | Applied: D7 verbatim. |
| RW4-03 | Applied: prose trims only; nothing moved. |
| RW4-04 | Applied: D11(l) verbatim. Checked against the proof of `prop:parity:sets`: the printed cap is valid. |
| RW4-05 | Applied: D11(m), in both files. |
| RW4-06 | Applied: D11(n). |
| RW5-01 | Applied: D5. "(o) Level bounds." prints, and the five "(o)" citations match. |
| RW5-02 | Applied: D6 (W5 part). "(with $B$ as in \cref{thm:teacher:main})" was added in `prop:teacher:sharp`(iii) and `prop:teacher:concentration`. |
| RW5-03 | Applied: D10 in `tab:teacher:numbers` (rows, caption) and `rem:teacher:numbers`. |
| RW5-04 | Applied, with these changes:<br>• `prop:teacher:sharp`, with the $\mathrm{Floor}_t/\Psi_t/LB_t/\Phi_2^\sharp$ display, moved to App F.7. Its proof idea was dropped, because the proof follows.<br>• §8.4 keeps the decided paragraph.<br>• `rem:limits:schedule` lost its literature sentences; "literature: \cref{rem:related:mdl}" is merged into its parenthesis.<br>• The FQ paragraph is 6 lines and the samples paragraph 4 lines. |
| RW5-05 | Applied: the App F.2 numbers (D10). |
| RW5-06 | Applied: D11(o). |
| RW5-07 | Applied: D11(p). |
| RW5-08 | Applied: D11(q). |
| RW5-09 | Applied: D11(r). |
| RW5-10 | Applied: D11(s), in three places. |
| RW5-11 | Applied: D11(t). |
| RW5-12 | Applied: D11(u), $T_g$ and $t_c$. |
| RW5-13 | Applied: D11(v). |
| RW5-14 | Applied: `tab:teacher:rates` is `[!ht]` before its paragraph in App F.7; caption sentence D11(w). |
| RW5-15 | Applied: covered by RW5-04(2). |
| RW6-01 | Applied, with these changes:<br>• §9.3 moved to App G.4 (`sec:limits:ood` an alias on `app:limits:ood`), with one sentence at the end of §9.2; `q:limits:open` now closes §9.2.<br>• `prop:related:computability` moved to App H, with one sentence in §10.<br>• `rem:computable:examples` is 3 lines.<br>• The $d_0$ table is one sentence.<br>• Trims. |
| RW6-02 | Applied: the D10 envelope numbers. |
| RW6-03 | Applied: D11(x). |
| RW6-04 | Applied: D11(y). |

All 62 entries of the fix round are applied, except RF-17 (optional, not applied, §1 > 3.2 pp). RF-06 is complete, except that the main-text and total caps are not met (above).
