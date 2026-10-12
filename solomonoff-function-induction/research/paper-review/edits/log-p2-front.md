# Edit log: group p2-front (Paper 2, phase 3)

Files edited: `paper-steeper/sections/abstract.tex`, `intro.tex`, `discussion.tex`, `paper-steeper/main.tex`, `paper-steeper/preamble.tex`, `paper-steeper/bib/core.bib`, `paper-steeper/bib/steep-b.bib`, `paper-steeper/CLAIMS.md` (optional P2F-25). Not edited: `app-verification.tex` (unchanged; switched off from `main.tex`), every body file, every Paper 1 file. No git command was run. No label was renamed or deleted.

Read before writing: DECISIONS.md (all sections), `status-rendering.md`, `p2-front.json`, `log-p2-body.md`, the edited body sections (`related`, `setup`, `absorb`, `teacher`, `limits`, `split`, `algstat`, `computable`, and the moved items in the appendices), the grokking note (`research/prior/hanni-grokking-a-notion.md`), steeper `notes-final.md` §0, §4.6, §5, and the P2 arXiv review §4.3 (replacement map).

Final full build (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, 20:24): **0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt** (one of 1.8pt, in the exact Code and data text of §A4); 57 pages. `pdfinfo`: Title and Author set.

---

## 1. Issues of `edits/p2-front.json`

### Fatal

* **P2F-01** (§F37). `discussion.tex`, ¶"The gap to realistic errors": the first two sentences replaced by the exact §F37 text (parity instance, two ways of failing, "Whether any window survives for structured errors in general is open."); the LessWrong quotation replaced by "We do not expect steeper penalisation alone to solve the general problem of learning a norm from imperfect imitation; it works in one toy case and fails in others."
* **P2F-02** (§F30). `tab:intro:claims`, the row on the vertex of the hull: exact §F30 row-3 text ("Yes for error rules incompressible relative to the model. Not for every rule with the same density and description length: … elsewhere only the weaker bounds of \cref{thm:teacher:main} with that rule's deficiency apply").
* **P2F-03** (§F29). Introduction, Limits bullet: "Plain Bayes, MDL and SI learn the errors, and so does every schedule with $(\lambda_n/n)(d+L_S)\to0$ along a sequence of instances, so steeper selection needs $\lambda=\Theta(n)$ (\cref{prop:limits:plain,rem:limits:schedule})." No "$\lambda_n/n\to0$" remains in my files.

### Major

* **P2F-04** (§F28). `abstract.tex` replaced by the exact §F28 text (1435 characters). As the issue allows, one sentence on the algorithmic-statistics result was added at the end, with its hypotheses ("For a random parity on $\{0,1\}^d$ whose labels are flipped on a random set of inputs of density below $1/4$, the sophistication defined with product models exceeds the set sophistication of algorithmic statistics by $d-O(\log d)$ bits, for a range of sufficiency slacks"; `prop:algstat:parity`(iii),(iv)). Total 1707 characters (≤ 1920).
* **P2F-05** (§F29, §F37). Intro Absorption bullet: "for every fixed $\lambda>1$ a computable deterministic teacher's labels, errors included, are eventually predicted"; Discussion ¶1: "it cannot for any model longer than $\ell^*_\lambda$, a bound that does not depend on the data, and for fixed $\lambda$ a computable teacher's labels, errors included, are eventually predicted".
* **P2F-06** (§F29, §F37). The §F29 teacher sentence ("If $S$ is incompressible relative to the parity, the inputs are uniform and $\lambda=cn$ with $c$ in an explicit window $(2^{-m},c_{\rm hi})$, every near-optimal product hypothesis of the population objective … $0.199$ ($\kappa=0$) or $0.274$ ($\kappa=30$) at $c=10^{-4}$ and the example's sizes, against $1$ for a memoriser") is the second half of the informal theorem (P2F-19), verbatim, so it is not repeated in the Contributions bullet, which points to it ("The theorem above holds over all product hypotheses (\cref{thm:teacher:main}) …"). The sentence after it states that the numbers assume $\delta_S=0$ (the table's rows). Discussion ¶2: "near-optimal product hypotheses are, up to explicit slack, the simple model with noise for $2^{-m}<c<c_{\rm hi}$".
* **P2F-07** (§F37, §F29). Discussion ¶"The model–randomness split": "indifferent, up to factors that grow at most triply logarithmically in the amount of data"; also "For fixed $\lambda>1$" added before the steeper tie-break (`thm:split:private` is for fixed $\lambda$). Intro Split bullet: "with $2\log(t_n+1)$ doubly logarithmic in the input length and at most triply logarithmic in $n$ and in the sampled randomness, and $\delta^*$ a Ville deficiency"; "no sampler longer than a data-independent bound $\ell^*_\lambda$ is selected (\cref{thm:split:shared})". "whatever the sampled randomness" no longer occurs in my files.
* **P2F-08** (§B, §A7). `hanni2026lesswrong` dropped from `core.bib` (with its comment). Its five citations in my files are gone: the proposal's wording "each input gets its own private randomness" and the questions of the example now cite `hanni2026grokking` (all occur in the grokking note, lines 61, 65–66); "somewhat cherry-picked" restated in the author's voice ("The example was chosen to favour the proposal"); the discussion's two LessWrong remarks restated without quotation (P2F-01); the table caption cites `hanni2026grokking` only.
* **P2F-09** (§A7). `hanni2026request` dropped from `core.bib` (with its comment). Intro: the exact sentence "A second question is whether a steeper prior prefers a simple sampler to programs in which the sampled bits are filled in; at $\lambda=1$, Solomonoff induction has no such preference."; Eisenstat: "the samplers of Sam Eisenstat's coin example (personal communication; see also \citet{claudeSFI2026fundamentals}) are covered by \cref{thm:split:lambda1}"; caption without the key. No request quotation remains.
* **P2F-10** (§G2). `hanni2026notes` and `hanni2026grokking` were already as decided (phase 0). Intro cites `hanni2026notes` for SFI and `hanni2026grokking` for the proposal and the example.
* **P2F-11** (§A8). The intro's "Prior work" paragraph is deleted (p2-body received its content in `related.tex`; no label was on it). In its place, in ¶"Relation to the author's notes and to other work", two sentences point to §2: the earlier report (\citet[Section~8]{claude2026whatfollows}, re-derived, \cref{rem:related:t5}) and "The closest prior work, $\lambda$-weighted two-part MDL in noisy classification, targets the data distribution, which ours deliberately does not; we do not claim as new that a bounded $\lambda$ fits the noise and that $\lambda$ must grow with $n$ (\cref{sec:related})" (P2M-20 wording; nothing attributed to Grünwald–Langford). Deleted: "as their abstracts describe them", "Our literature search went only as far as abstracts …", the weight-above-one clause, open problem (8), and the acknowledgements' literature clause.
* **P2F-12** (§A3). `main.tex`: `\sfirecordfalse   % internal verification record, not part of the arXiv version`; the switch `\ifsfirecord\input{sections/app-verification}\fi` kept; the six comment lines describing the conversion deleted. Before switching off: `grep -n 'app:verification\|app:verif' sections/*.tex` finds references only inside `app-verification.tex` itself. The file is unchanged.
* **P2F-13** (§A2). `\status`/`\src` redefined as the last step (see §3 below).
* **P2F-14** (§A6, §A11). Intro rewritten in the author's voice: no "H\"anni", "his", "he", "Verdict", "Confirmed", "refuted", "which are cited in the third person". Arrangement sentence (§A6, Paper 2 form): "The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}, and the proposal, its example and most of the questions studied here in the note \citep{hanni2026grokking}; we cite those notes where they arise and say where a claim made there needs correction (\cref{tab:intro:claims})." One verbatim quotation in the introduction (the proposal's wording); all other content of the notes paraphrased. `tab:intro:claims`: header "Question & Answer & Where", caption exactly as §A11, answers "Yes", "No", "In part", no quotations.
* **P2F-15** (§A4). Acknowledgements and Code and data replaced by the exact Paper 2 texts of §A4 (no `research/tracks`, no "research notes", responsibility sentence, Eisenstat "(personal communication)").
* **P2F-16** (§G2). `claude2026whatfollows` already as decided (phase 0). Cited once with the pinpoint, `\Citet[Section~8]{claude2026whatfollows}`, in the intro; the discussion has no citation of it; the acknowledgements cite it as decided ("The earlier report \citep{claude2026whatfollows}").
* **P2F-17** (phase 4). Not done in this phase: the informal names of companion results (marked `% P1: <label>` by p2-body) are replaced in phase 4, after Paper 1's final build. My files cite the companion paper only as a whole (no informal result names).
* **P2F-18** (§A10). Open problems: one numbered list that cites every `question` of Paper 2 (`q:limits:open` in (1), (2), (4); `q:teacher:open` in (2), (3); `q:absorb:shared` (5); `q:related:open` (6); `q:algstat:lsc` (7)); Paper 2 has no `conjecture`. (8) deleted; (2) "we expect that majority-like functions do not give a window" (no "presumably"). The question environment and its `\crefname`s were added in phase 0.
* **P2F-19** (§C, §D1, §D2). `main.tex` input order: intro, related, setup, absorb, teacher, limits, split, algstat, computable, discussion. Intro: "Theorem (informal)" for `thm:teacher:main` as a plain paragraph (no environment, no label) with its hypotheses: inputs in $\{0,1\}^d$, uniform; random parity; error set $S\times\{0,1\}^{d-m}$ of product form; density $p<0.056$; $S$ incompressible relative to the parity; population objective; $\lambda=cn$ with $c$ in an explicit window; plus part (iv) ("Below about $2^{-m}$ the memoriser beats every hypothesis that knows the parity and fits no better than noise"). Contributions list: 5 bullets naming the main results with `\cref`s.
* **P2F-26** (§F46). Discussion ¶"Relation to other work": "The $\lambda$-MAP is a two-part code with complexity weight $\lambda$, as in $\lambda$-weighted MDL in noisy classification, and maximises the tempered posterior, a generalised posterior with learning rate $1/\lambda$; the power-prior posterior has the same maximiser but is Bayes' rule with the prior $2^{-\lambda\ell}$." The intro no longer speaks of posteriors (the moved "Prior work" paragraph in §2 carries the §F46 text), so there is nothing to misstate there. Also "is the bridge question of the companion paper, which the slides of \citet{vaintrobhanni2026nnbayes} motivate" (§F37).

### Minor

* **P2F-20** (§A12). Deferred to the packaging step at submission (comments, `rem:absorb:wyeth` label stays as decided). I shortened the process-vocabulary comments of my own files (`main.tex`, `abstract.tex`, `intro.tex`, `discussion.tex`); the comment above the deleted bib entries is gone with them.
* **P2F-21** (§F29). "almost a third ($\kappa=0$; a quarter at $\kappa=30$)"; sophistication gap "for a range of sufficiency slacks"; computable bullet "(for the split, one that contains the sampler)", citing \cref{sec:computable} (not `sec:related`).
* **P2F-22** (§F30). Row on other pathologies: "possible confident wrong extrapolation off the training support".
* **P2F-23** (§G2–G3). See §4 (bibliography).
* **P2F-24**. `\hypersetup{pdftitle={Steeper Simplicity Priors in Solomonoff Function Induction: Absorption, the Teacher's Mistakes and the Model--Randomness Split},pdfauthor={Kaarel H\"anni}}` after `\title`; `\newpage` after the TOC deleted (TOC kept, `tocdepth` 1). `\usepackage{framed}` removed from Paper 2's preamble: no `framed`, `leftbar` or `shaded` environment occurs in either paper's sections (grep; the only hit is the word "framed blocks" in Paper 1's `app-hist.tex`). **For p1-front:** the same line can go from Paper 1's preamble.
* **P2F-25** (optional). `CLAIMS.md`: `rem:absorb:examples` "$\xi_1\le U$"; `cor:teacher:fulltable` with the §F44 hypotheses of (ii), the open windows of §F42 and "$\lambda\in(1,Nc_{\rm hi})$"; new row `rem:teacher:numbers`; one sentence pointing to `log-p2-body.md` §3 for the moved items.
* **P2F-27**. Intro ¶"Scope and reader's guide": "For sampled data, near-population constants need about $10^{11}$ samples; coarser guarantees hold from about $10^9$ (\cref{cor:teacher:sampled})". Open problem (3) the same, citing `cor:teacher:sampled` and `q:teacher:open`.
* **P2F-28**. Split bullet: "no $\lambda$-MAP is a fill-in once the sampled randomness $-\log\nu(D_n)$ exceeds $\lambda(k+\delta^*)/(\lambda-1)$ (\cref{thm:split:private})" (this is `rem:split:reading`'s statement).

### Items of `log-p2-body.md` §6 ("For p2-front"), all applied

* Input order with `computable` (done, P2F-19). The guide cites \cref{sec:computable} for computable classes and \cref{sec:related} for related work.
* "Full truth tables, sampled data, his other version of the example and the power posterior are treated too (\cref{sec:teacher:more})" removed; the bullet cites `cor:teacher:fulltable,cor:teacher:sampled`; Version 1 is cited as `ex:teacher:version1` (App C) in the table.
* Related-work labels on prose paragraphs: the discussion and the table cite \cref{sec:related} instead of `rem:related:mdl`, `rem:related:posteriors`, `rem:algstat:restricted`, `rem:related:new`. The intro keeps one `\cref{rem:related:t5}` (prints "Section 2", correct and single).
* "the trick" → "steeper selection" (discussion open problem (1) and ¶"The gap to realistic errors"); "H\"anni's sizes" → "the example's sizes".
* The intro's "Prior work" paragraph deleted and replaced by two sentences pointing to §2 (P2F-11).
* §A2.5: the five commented-out statuses of the related-work paragraphs are counted through p2-body's rows 24, 26–29 (see §3 below).
* Open problem (8) deleted (P2F-18).

### §F statements applied in my files

F28 (abstract), F29 (all five bullets; the teacher sentence inside the informal theorem, see P2F-06), F30 (rows 3 and 8, header, caption), F37 (all five items), F46 (discussion).

### Deviations from DECISIONS, with reasons

1. **The §F29 teacher sentence sits in the informal theorem, not in the Contributions bullet** (verbatim). Placing it in both would print the same 6 lines twice; §D1 asks for the informal theorem with its hypotheses, and the F29 sentence is exactly that theorem's conclusion with numbers.
2. **`tab:intro:claims` has 10 rows, not 12**: the two absorption questions (sequence case; private randomness) and the two sampler questions ($\lambda=1$; $\lambda>1$) are merged into one row each, to fit the introduction's length. The §F30 texts of the vertex row (old row 3) and the pathology row (old row 8) are unchanged.
3. **`claudeSFI2026steeper` title** now includes the subtitle, because §G2 requires "Titles as in the final `main.tex`" and Paper 2's title has the subtitle (Paper 1's entry likewise carries its full title).
4. **The abstract has one sentence beyond §F28** (algorithmic statistics), as P2F-04 allows within the character limit.

---

## 2. Bibliography (§G)

`core.bib` (Paper 2), exactly the decided edits:
* §G1 dropped: `hanni2026request`, `hanni2026lesswrong` (and their two comment lines).
* §G2: `hoeffding1963probability` `number = {301}`, `doi = {10.1080/01621459.1963.10500830}`; `barzdin1972prediction` `pages = {1224--1228}`; `ville1939etude` `series = {Monographies des Probabilit{\'e}s}`, `number = {3}` (publisher and address were already there); DOIs of P2X-36: `grunwald2012safe` 10.1007/978-3-642-34106-9_16, `grunwald2017inconsistency` 10.1214/17-BA1085, `zhang2006epsilon` 10.1214/009053606000000704, `bissiri2016general` 10.1111/rssb.12158, `bhattacharya2019fractional` 10.1214/18-AOS1712; `claudeSFI2026steeper` title with the subtitle (deviation 3). `hanni2026notes`, `hanni2026grokking`, `claudeSFI2026fundamentals`, `claude2026whatfollows` were already as decided in phase 0; `vaintrobhanni2026nnbayes` kept.
* `steep-b.bib`: `grunwald2007suboptimal` `number = {2--3}`, `doi = {10.1007/s10994-007-0716-7}`.
* §G3: all other entries kept; the nine writer-verified entries are unchanged (author's pre-submission list). Bib comments unchanged except the two deleted with their entries.
* plainnat prints the DOIs (checked in `main.bbl` and the PDF). 34 references are printed; `barron1991minimum` is no longer cited (it was cited only in the switched-off appendix).

**`diff paper/bib/core.bib paper-steeper/bib/core.bib` is not empty yet**: the differences are exactly the edits above, because Paper 1's `core.bib` (p1-front's file) has not been edited yet. **For p1-front:** the decided `core.bib` is `paper-steeper/bib/core.bib` (md5 `545de2f9f8241010c32d0029fc75246e`); making `paper/bib/core.bib` a byte-identical copy gives an empty diff. It contains no entry that only one paper needs removed.

---

## 3. Status and source notes (§A2)

* My files contain no `\status` or `\src` call, so I have no rendering of my own.
* **§A2.5 check** (the lead editor's `extract_status.py`, run unchanged except that it wrote its JSON to my scratchpad, so that Paper 1's in-progress `status_p1.json` was not overwritten): Paper 2 has 59 `\status` calls, 17 plain `proved`, 42 non-plain, **0 outside an environment, 0 inside a table float**. Every one of the 42 live non-plain labels has a "rendered as" row in `log-p2-body.md` §2 (checked by script), and so do the 5 statuses kept as comments in the header of `related.tex` (`rem:related:posteriors`, `rem:related:mdl`, `rem:related:cold`, `rem:related:t5`, `rem:related:new`: rows 24, 26–29). All 47 rows of `status-rendering.md` for Paper 2 are covered. Nothing had to be rendered by me.
* `grep -n 'src{[^}]*\(slides\|T5\|request\|draft\|known\)' sections/*.tex`: 16 notes, all of the form "(T5 …)"; every T5 result they name appears, by name, in the correspondence table `app:related:t5` (per-input pricing, sequence pathology, universal conditional semimeasure, per-block pricing, list-size and floor lemmas, error segment, shared-randomness kink, $2p$ slack, full-table identification, finite-sample lemma, hull, rate threshold and rate blindness, non-identifiability, guard erosion, envelopes, input law). No slides, request or draft note.
* **§A2.4 redefinition** appended at the end of the SFI macro block of `paper-steeper/preamble.tex`, exactly:
  ```
  % arXiv version: status tags and source notes are not printed (their content is rendered in the text).
  \renewcommand{\status}[1]{}
  \renewcommand{\src}[1]{}
  ```
  (immediately before `% ===== end of SFI macros`; **for p1-front:** the same three lines in the same place keep the block identical in both preambles).
* After the redefinition: `pdftotext main.pdf - | grep -n -E '\[(proved|computed|conjecture|known|proof sketch|refuted|remark)'` returns nothing.

## 4. Greps of §A5 and §B.6 (final PDF)

* §A5 grep on `pdftotext main.pdf`: hits are "independent AI referees" in the footnote (allowed), formula symbols ($s_0$, $e_1$, $S_1$, $S_2$, $B_2$, $c2^m$, parts (c1)–(c3) of `thm:absorb:absorption`, "(c1) in 300 cases" in App E) and the DOI "s10994-007-0716-7" of Grünwald–Langford. No other hit. "personal communication" occurs three times, each for Sam Eisenstat (introduction, §7, acknowledgements). No "H\"anni's", "his", "the trick", "presumably", "Verdict" in the PDF.
* §B.6: `pdftotext main.pdf - | grep -c -i wyeth` = **0**; the source grep (`grep -rn -i wyeth sections/*.tex bib/*.bib | grep -v '^[^:]*:[0-9]*:\s*%' | grep -v 'rem:absorb:wyeth' | grep -v app-verification`) returns nothing.
* Quotations in the PDF: the intro's "each input gets its own private randomness" (verbatim, grokking note l.61); the body's quotations are p2-body's.

## 5. Labels

Deleted: none. Renamed: none. New: none. Kept in my files: `sec:intro`, `tab:intro:claims`, `sec:discussion`, `sec:discussion:open`. The deleted "Prior work" paragraph had no label. `app:verification*` labels are no longer built (appendix switched off); nothing outside that file referred to them. `rem:split:reading` cites `sec:intro` ("the split asked for in Section 1"); the intro asks for it (the second question of ¶2).

## 6. Page counts (final build, 57 pages) against §C

Measured from the PDF (text block 76–720 pt; fractions of a page):

| part | pages | budget / cap |
|---|---|---|
| title, abstract, TOC (p. 1 to the heading of §1 on p. 2) | 1.40 | 1.5 |
| §1 Introduction (p. 2 to p. 5) | 2.89 | 2.5 (guide ±0.5) |
| §2–§9 body (p. 5 to p. 27) | 21.79 | 20.5 |
| §10 Discussion, open problems, acknowledgements, code and data (p. 27 to the end of p. 28) | 1.92 | 2.0 |
| **main text, title page through Code and data** | **28 pages (pp. 1–28)** | **cap 27: exceeded by 1 page** |
| references | pp. 29–31 | |
| **appendices A–G** (A starts a third down p. 31) | **pp. 31–57, about 26.6** | **cap 27: met** |
| **total** | **57** | **cap 57: met** |

Before this phase: 63 pages, main text 33.

**Cuts of §C for my files, all made:** Appendix H switched off (−5.5 pages); the introduction's "Prior work" paragraph moved to §2 (received by p2-body); `\newpage` after the TOC removed; the introduction and the discussion shortened against the final body (from 3.43 to 2.89 and from 2.07 to 1.92 pages between my first full build and the final one).

**What remains for the body:** the main text must lose about one more page (everything now on p. 28) to meet the cap of 27. The front matter is 6.21 pages against its summed budgets of 6.0; the body (§2–§9) is 21.79 pages against 20.5. If the body reaches its budget the main text is about 26.7 pages. The appendices are at their cap, so the page cannot be found by moving more material to the appendices without an equal cut there. The largest body overruns are §3 (2.80 against 2.5), §4 (3.51 against 3), §5 (5.22 against 5), §7 (2.71 against 2.5), §8 (2.20 against 2) and §9 (0.88 against 0.5), by p2-body's measurements. Further shortening of the introduction (the table of questions is about 0.55 page) would remove at most about 0.4 page and needs the lead editor's decision, since §A11 keeps the table.

## 7. For phase 4 and for p1-front

* Phase 4 (P2F-17): replace the informal companion-result names marked `% P1: <label>` by p2-body (setup, absorb, limits, split, computable, app-absorb, app-split, app-limits) with `\citet[Theorem~X.Y]{claudeSFI2026fundamentals}` from Paper 1's final `main.aux`; check Paper 1's `sec:steep` against Paper 2's final statements.
* p1-front: copy `paper-steeper/bib/core.bib` to `paper/bib/core.bib` (§2); same `\renewcommand` lines in the same place of the preamble (§3); `framed` can be removed from Paper 1's preamble (P2F-24).
