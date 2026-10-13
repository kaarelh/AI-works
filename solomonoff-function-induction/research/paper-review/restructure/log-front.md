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
