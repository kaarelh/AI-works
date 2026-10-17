# Final check of the text: abstract, §1, §6, §10–§13, Appendices D, H, I, J

*Fresh final checker, 2026-10-17. Status: complete. Build checked: the full build of 17:20 (after this check's one edit).*

**Summary.** Every major issue of `DECISIONS.md` that touches the scope is fixed as decided (there are no fatal issues). Of 30 statements spot-checked against the thread records and `CLAIMS.md`, 29 match in hypotheses, constants and status; one, contribution (7) of the introduction, omitted the renaming condition (F1) of the theorem it cites, and is fixed. Every computed number in the scope (about 300) agrees with the saved script outputs. The greps are clean, every citation in the scope is in the citable lists of `bib-report.md`, and the full build has 0 errors, 0 undefined references or citations, 0 multiply defined labels and no overfull box above 10pt. The PDF has 223 pages and the main text is 50.38 pages, unchanged by the edit.

Scope: `sections/abstract.tex`, `intro.tex` (§1), `phil.tex` (§6), `kepler.tex` (§10), `limits.tex` (§11), `related.tex` (§12), `discussion.tex` (§13), `app-phil.tex` (App D), `app-kepler.tex` (App H), `app-notation.tex` (App I), `app-verification.tex` (App J; switched off in the arXiv build).

## 1. Fatal and major issues of DECISIONS.md in scope

DECISIONS.md has no fatal issue. The major issues touching the files in scope, with what the sources now say (checked in the sources and in `pdftotext main.pdf` of the build of 17:11):

| id | where | decided fix | status |
|---|---|---|---|
| FRO-01 (U1 short) | abstract, last sentence | short form of U1 | **in place**, verbatim; abstract 246 words (cap 250); FRO-02/03/04 also in place |
| FRO-05 (U4) | intro "What a theory is"; `sec:intro:notclaim` | U4 first sentence; "on data labelled true or false" twice more | **in place** (all three places) |
| FRO-06 (PHIL-04) | intro contribution item (9) (the decided "(10)" is (9) after the shortening) | "one aspect of what Lewis calls a kind nature" wording | **in place**, verbatim |
| FRO-13 (U1, U2, U3) | discussion "What the formalism shows" | U1 long form (first sentence shortened as allowed), U2 discussion version, U3 first sentence | **in place**; FRO-14, FRO-15 also in place |
| FRO-19 | Code and data | sentence kept; README is a publication-step item (§X9) | **as decided** (README still to be written before publishing to `main`) |
| PHI-01 (U1 long) | `phil.tex`, paragraph after U5 in `sec:phil:craig`; directionality paragraph | U1 long form; "In the model of \cref{sec:shape} … on what is written or on the time to write it" | **in place** (the directionality sentence says "directions matter" for "they matter", a copy-edit) |
| PHI-02 (U2) | same paragraph | U2 `phil.tex` version | **in place**, verbatim |
| PHI-03 | "Declarative is not sentential" | semantic-view sentence with Halvorson, Lutz and pointer to `sec:kepler:pool` | **in place** ("result" for "verdict", a copy-edit that avoids a process word); pointer still true (the answer is in §10.4) |
| PHI-04 (U6) | `sec:phil:differences` | confirmation-theory paragraph with `\status{assessment}` | **in place** |
| PHI-05 (U3) | "What rests on theorems", last "Proved" item | U3 clarification, kept under "Proved" | **in place** |
| PHI-06 (U5) | `sec:phil:craig`, caption of `tab:phil:differences` | partiality paragraph; scope "on data labelled true or false"; caption sentence | **in place** (all three) |
| KEP-01 | `sec:kepler:pool`, after "relative to the language of the law texts." | semanticist paragraph with `\status`/`\src` | **in place**, verbatim; numbers match App H ("The data without the text prior": ellipse at every δ≤60′, eccentricity-range halving moves the vicarious hypothesis by one bit) |
| LIM-01 (U1) | `sec:limits:textbook`, two occurrences | "in the model of \cref{sec:shape}, when what is written, or the time to write it, is charged" | **in place** (first occurrence inside a sentence that already opens "In the model of \cref{sec:shape}") |
| LIM-02 (U3) | `sec:limits:approx` | both U3 sentences | **in place** ("the open problem stated above" for "of \cref{sec:limits:stat}": the paragraph is now in the same section, and the reference is to the first paragraph of §11) |
| LIM-03 (U6) | `sec:limits:other`; `related.tex` | two limits changes, one related change | **in place** ("all our comparisons of theories" for "all our verdicts", avoiding a process word) |
| PHI-L1, KEP-L1, LIM-L1, LIM-L2, FRO-L1, FRO-L2 | lengths | targets +0.25 | **met**: §1 2.93 (≤3.25), §6 4.78 (≤5.00), §10 4.35 (≤4.50), §11 2.62 (≤2.75), §12 2.46 (≤2.50), §13 with ack. and code 1.64 (≤2.00). Moves of lists A (and B where applied) are in place: App D holds `def:phil:questions`, `prop:phil:answers`, `prop:phil:extractor`, `prop:phil:flagpole`; App H holds `prop:kepler:geo`, `ex:kepler:K3cost`, `ex:kepler:graded`, the distances paragraph and `tab:kepler:minimax`; §11 subsections are labelled paragraphs. Main text total 50.38 pages (accepted by the task). |
| FRO-F | final phase | build and greps | see §3 and §4 below |

Cross-group items touching the scope: X4 (semantic view: KEP-01 + PHI-03) consistent; X10 credit footnotes F3 (intro) and F7 (limits) present; X7: the intro and limits sentences that cite moved labels (`prop:kepler:geo`, `ex:kepler:K3cost`, `ex:kepler:graded`, `prop:phil:extractor`, `prop:phil:flagpole`, `def:laws:EP`, `rem:laws:typical`, `prop:shape:depth`) read correctly with appendix numbers. Floats: Table 2 (p. 24) and Table 3 (p. 28) lie in §6 (pp. 24–29; PHI-15), Table 5 and Figure 1 (p. 44) in §10, Table 6 (p. 47) in §11. PHI-14 (swallowed spaces after `\src`): no "word.Word" joins on the scope pages of the PDF text. All 22 `q:` labels are cited in §13.

The minor issues of the groups phil, kepler, limits and front were also looked at: all are in place as decided (PHI-07 to PHI-15, KEP-02 to KEP-11, LIM-04 to LIM-10, FRO-02 to FRO-04, FRO-07 to FRO-12, FRO-14 to FRO-18, FRO-20).

## 2. Spot-checks of statements and computed numbers

### 2.1 Statements (30 checked; sources: `research/tracks/philosophy/notes-final.md` unless named; the synthesis H-items and `final-check.md` §4 for the introduction; `CLAIMS.md` rows 248–262, 435–447 for statuses)

| # | place | statement | source | result |
|---|---|---|---|---|
| 1 | App D | `prop:phil:answers` (a)–(c), status proved; computed | Prop 2.1 | match |
| 2 | App D | `prop:phil:conservation` (a)–(d), the bound for $t\le Z/2$, share $O(\log m/m)$ | Prop 2.2 | match |
| 3 | §6, App D | `prop:phil:extractor`: hypothesis "consistent with $B$ $\mu$-a.s.", $c$ depends on the question family, status "given dominance and the sampling construction" | Prop 2.4 | match (the proof's $K(\nu_G)\le K(G)$ holds by the paper's definition of $K(\nu)$) |
| 4 | App D | `prop:phil:predicting` (a)–(d), status "(a)–(c) proved there; (d) proved; computed" | Prop 2.5 | match |
| 5 | §6, App D | `prop:phil:flagpole` (a)–(c), least costs 1,2,2,1 / 0,1,0,1 / 1,0,1,0 | Prop 3.1 | match |
| 6 | §6, App D | `prop:phil:flagpolesystem` (a)–(d), $O(1)$ independent of $k$, $N_{\rm p}$, $N_{\rm d}$ | Prop 3.2 | match |
| 7 | §6 | "at least five gaps" of explanation (asymmetry, approximate correction, irrelevance, conjunction, statistical) | §3.5 (four) + DECISIONS PHI-10 (fifth) | match as decided; `salmon1971statistical` cited only for the S-R model, as bib-report §5.3 item 5 requires; the irrelevance examples carry no citation |
| 8 | §6 | Hempel's inductive-systematisation reply fails in the idealised setting, by a constant number of bits | §1.6; `terms` Thm 2.1, Rem 2.2 | match |
| 9 | §6 | partiality paragraph (U5): unbounded gap on one datum; certainty of consequences in the semimeasure convention; no r.e. family | synthesis H7; `sfi` Props 6.1, 6.3–6.5 | match |
| 10 | §6 | directions: factor exactly $m$ for one parity law over the base variables or with one round; at most 9 with intermediate concepts and unbounded rounds; $O(m)$ operations for a program with internal variables | `shape` Prop 4.2, Thm 4.3 | match |
| 11 | §6, Table 3 | items 2, 4, 8, 10, 11 (closure in the semimeasure convention; observed independence with $\Q\subseteq\Cn(B)$; truth from unprovability; lottery and false theories as a possibility result; translations $2^{\pm(K(\tau)+c)}$) | §1.7 | match |
| 12 | App H | `prop:kepler:ramsey` (a), (b), second-order semantic consequence | Prop 4.1 | match |
| 13 | §10 | `prop:kepler:helio`, for every $B$ containing RCF | Prop 4.2 | match |
| 14 | §10, App H | `prop:kepler:geo`: (a) over $\mathbb R$, $\vdash$ for every $B\ni\zeta_{\rm K3},\zeta_{\rm pos}$; (b) every $B$ true in $\mathbb R$; status proved; computed | Prop 4.3 | match |
| 15 | §10 | `prop:kepler:K3worth` (a), (b), the arc of length $\alpha(t)$ and the bound $\delta<\alpha(t)/2$ | Prop 4.4 | match ("for every $B$ true in $\mathbb R$" in (b) is the record's "models over $\mathbb R$", not a strengthening) |
| 16 | App H | `ex:kepler:K3cost` status "conditional on the code; extrapolation and compact-code threshold estimates" | §4.4 Part B; `laws` Prop 5.5(b) | match |
| 17 | App H | `ex:kepler:graded` status "honest-band crossovers are estimates" | §4.4 Part A′ | match |
| 18 | §10 | semantic-view paragraph (KEP-01): presentation-free prior selects the ellipse at every $\delta\le60'$; enumeration and parametrisation relocate the relativity | §1.4 item 4 | match |
| 19 | §10 | Newton (3): about $531''$ of about $574''$ per century, GR the remaining $43''$ | §4.5 item 3 | match |
| 20 | §11 | `eq:limits:analogy`, status proved | §5.4 (analogy row) | match |
| 21 | §11 | computational gap a theorem only in the model of §7 when what is written, or the time to write it, is charged; charged deduction cannot express it | §5.1(b); `shape` Thm 5.2 | match |
| 22 | §11 | domains: honest models jointly consistent over a true background; Lanford "as described in expositions"; domain usually a tolerance with an error distribution | §5.3; `laws` Prop 4.3, Prop 6.1 | match |
| 23 | §11 | concepts table, 15 rows (agreement and capture columns) | §5.4 | match (row "reinforcement structures" omitted, as logged by the writer) |
| 24 | §12 | Sawin–Demski with coherence conditions; Krajíček's p-time axiomatisation; Gaifman condition iff the instances prove the universal; systems bound "short combination … probably known to specialists" | bib-report §4.1, refs.bib comments; `logic` Props 5.1–5.2 | match, at the verified content level |
| 25 | §1 (1) | coin-free and one-tape within constant factors, Kolmogorov within an additive constant; transfer of results that hold up to additive constants | H1; final-check §4 item 1 | match |
| 26 | §1 (2) | lottery; false theories over a decidable true background containing $\Q$ (adversarial); one random true theory on $\Pi_1$ data | H2, H5 | match |
| 27 | §1 (3) | factor $m$ for a parity law; "any law at most a factor 9" | `shape` Thm 4.3(2) ("for every law") | match |
| 28 | §1 (4), (5), (9) | dilemma with $B=\emptyset$ (FRO-10 wording); error-model rate attained by $\MA$ if the distribution is computable; kink iff robustness to the balance | H4; `laws` Prop 3.6a(c) (`prop:laws:errormodel`(c)); `prop:laws:kink` | match |
| 29 | §1 (6), (8); §13 | loss bound against $\Keq$; Solovay-complete random $\Inc_0$; $\Q$ certificate; coin-free soundness never learned over $\PA$; "identifies a complete r.e. theory that the data present" | H6, H9; `prop:basic:limits`(a) | match |
| 30 | §1 (7) | "with deduction charged, \SAIabbr is certificate \SOIabbr up to polynomial changes of the budgets" | `sfi` Thm 8.1 "[proved under (F1)]"; `thm:soi:sandwich` "Under (F1)" | **hypothesis dropped; fixed** (§5 below) |

Statuses rendered in prose in the scope agree with `CLAIMS.md` (e.g. `prop:phil:answers` PC, `prop:phil:flagpolesystem` P, `prop:kepler:geo` PC, `tab:kepler:minimax` C with "upper bounds witnessed by elements … global optimality not proved", `tab:kepler:distances` C with "minimality not proved"). No proof sketch is stated as a theorem in the scope. Every theorem-like environment in the scope has `\status` and `\src` (checked by script); the three tables that only collect other results (`tab:phil:map`, `tab:phil:differences`, `tab:limits:concepts`) have none, as App J records ("see the items it collects"), and their captions say which entries are arguments.

### 2.2 Computed numbers (every number in the scope, against the saved outputs)

* **§6 and App D, conservation world** against `philosophy/checks/c5_conservation.out` (A, B, C) and `c9_revision.out` (1): gains $1.871\dots10.292$, $\frac12\log\frac{\pi m}2$ values, shares $0.23\dots1.0\times10^{-5}$; $\kappa_{Z/2}$ $2.659\dots6.308$; uniform-baseline losses $3.170\dots10.001$; $m=12$: $2415.6$, $3004.9$, $0.196$, $2416.6$, $3.70$, $1113.8$, $0.997$, whole cycle $0.232$ and $2.75$; simulation within one standard error; identity to $1.8\times10^{-15}$. All match.
* **App D, flagpole** against `c6_flagpole.out`: 500 data sets, 2000/2000 identical statuses, the least-cost table, 20 tokens and 1 token per pole. All match.
* **§10, App H, residuals and the third law** against `scouts/philosophy/checks/c1_kepler_fit.out` and `c3_kepler_constant.out`: every cell of `tab:kepler:residuals` (Mercury, Mars, Jupiter, Saturn, Moon), the $q$ ranges and two-body values, the 12-year $q$ values, the ring estimate $1.00154$ and Jupiter's $1.25\times10^{-3}$, Mercury's $575.4''$, the great-inequality periods and amplitudes. All match. Exact $\mathrm{K3}$ errors $0.233'$, $0.193'$ (medians $0.150'$, $0.129'$) and relative changes $3.170\times10^{-4}$, $4.985\times10^{-4}$ match `c9_revision.out` (9).
* **§10, App H, Mars pool** against `c4_mars_pool.out` (A1–A5): the data plane ($1.8828^\circ$, $50.757^\circ$, $0.070'$); minimax errors and every witnessing element of `tab:kepler:minimax`; every Occam factor of `tab:kepler:map` and of the App H table; token counts, alphabet sizes and bit lengths of the law texts; faithfulness $\le1.4\times10^{-14}$; the MAP rows of the three syntaxes and Figure 1 (runner-up at most $2^{-12.4}$: S2 at $9'$, $0.00018$); the S2 equant/vicarious Occam differences $2.14$ and $5.56$ bits and the $12.4$-bit margin; text differences $100$–$835$ bits; the Elias-gamma figures. All match. Figure 1's TikZ coordinates ($x=4\log_{10}(720'/\delta)$ for the five minimax errors, the 13 sampled precisions and the axis ticks) were recomputed and match.
* **App H, intrinsic errors, Gaussian noise, honest bands, no-text prior, Polish codes** against `c9_revision.out` (2)–(8): RMS residuals, penalties and crossovers at $\sigma=1',2',4'$, the simulation counts and the median evidence ratios $2^{2.2}$ to $2^{276}$, the honest-band costs $4.43$, $2.93$, $0.40$ and crossovers $23$, $71$, $70$, about $470$, the no-text margins $0.69$, $0.46$, $0.20\dots14.61$, the exact-ellipse errors $22.34'$, $7.43'$, $0.62'$ ($e=0.0930$, $1.25'$), the Polish lengths and the body counts $33.2/25.5$, $14.6/11.2$, $10.2/7.8$. All match.
* **App H, what K3 is worth** against `c4_mars_pool.out` (B): fit $0.627'$ and $0.632'$, $\rho$ values, $s_{\rm K3}$ table, sd$(y)$, chains $492$–$583$, failures $38,5,1,0$, linear-to-exact shares; the halves agree to within $0.06$ bits except at $8'$ (at $4'$, $h=0.1$: $12.28$ against $12.34$), which confirms the KEP-05 correction. Arc percentiles, sensitivity (median $969'$, maximum $3555'$), the $9.8/10.8/11.8$-bit crude estimate and the opposition model figures match `c7_geocentric_arc.out`. The independent-implementation figures ($0.819\dots0.968$; $11.27$–$14.71$; $0.6266'$, $0.6318'$) are those the record quotes from the referee code.
* **App H, distances** against `c10_distances_research.out`, `c8_mars_distances.out` and `referee_code/rb3b_distances.out`: every cell of `tab:kepler:distances` (the vicarious $132.04'$ at $0.05\%$ is rb3b's, $132.35'$ is c10's, as the text says), the $1\%$ witness elements and $5.119'$, the rounded-element $6.217'$ (KEP-03 wording correct), $e=0.142$, $r^*$ values. All match. The c4b cross-check values ($22.73\dots43.02$) match `c4b_volume_crosscheck.out`.
* **App H, reproduction**: seeds 20261015/20261016 and versions (Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1, pyerfa 2.0.1.5) match the output headers; run times (about 80 min, 36 min, 2 min, under a minute) match the outputs' timing lines (4692 s, 2131 s, 1 min 51 s, 27 s). The §13 Code and data statement ("more than half an hour each") is consistent.
* **§1 Kepler preview and §6** quote only numbers listed above.

One small inconsistency in the source record, not in the paper: the record states the sensitivity maximum as $3556'$ in one place; the saved output `c7_geocentric_arc.out` has $3555$, which the paper uses.

## 3. arXiv-readiness greps

On the sources in scope (`abstract`, `intro`, `phil`, `kepler`, `limits`, `related`, `discussion`, `app-phil`, `app-kepler`, `app-notation`), outside `%` comments and the arguments of `\status`/`\src`, with the pattern of DECISIONS rule 0.8 plus model names, "SFI", "working notes", "the author" and Hänni's name:
* process vocabulary: one hit, "the revision of the base abstractions" (§11), allowed by rule 0.8; none else;
* "SFI": only inside the citation keys `claudeSFI2026…`, which do not print;
* Hänni's notes: only the credit footnote of §1 (F3), the footnote of §11 on the draft essay (F7) and the acknowledgements; no running-text citation, quotation of or reply to the notes. The quoted strings in the scope (checked one by one) are data sentences, questions and paraphrases, none from the notes;
* model names: none.

On `pdftotext main.pdf` (whole paper, build of 17:20):
* model names (`opus|sonnet|haiku|claude-[0-9]|gpt|gemini`): 0;
* process vocabulary: only "referees" in the title-page footnote (allowed), "the revision of the base abstractions", "Intelligent Agent Foundations Forum" (a venue in the bibliography) and "tracks of one tape" (multitape simulation, App B); thread, scout, workflow, synthesis, ledger, notes-final, verdict, snippet, unverified, AI-paper: 0;
* printed status tags: none (the one regex hit, "P[refuted]" in App G, is a probability);
* "SFI": 0; "Hänni" appears only as author, in the title-page footnote, the citations "Hänni and Claude (Anthropic)" of the companion works, the credit footnotes and the acknowledgements.

**Citations.** The 142 keys cited in the scope were extracted from the sources: the 5 internal keys are in `bib/core.bib`, and each of the other 137 is listed as citable in `bib-report.md` §5.1 or §5.2. None is in §5.3 ("not citable"). Spot-checked content levels: `sawin2013computable` (abstract), `krajicek2025proof` (quotation), `nauenberg2015reception`/`bodenmann2010battle` (Newton about half of the lunar apsides; Clairaut 1749), `salmon1971statistical` (S-R model only), `lanford1975time` (secondary; hedged "as described in expositions"), `bernardo1979expected` (secondary; hedged "a result attributed to"), `garrabrant2015modification` (attribution only; the description of the sampling stage rests on `garrabrant2016inductive`'s quoted text), `pitt1989probabilistic`, `ambainis1999probabilistic`, `shapiro1981algorithm`, `dorling1979bayesian`, `strevens2001bayesian`. Every claim made about these works in the scope stays at the recorded level.

## 4. Full build

`cd paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh`, run twice (17:11, before the edit; 17:20, after it):
* LaTeX errors 0; undefined references 0; undefined citations 0; multiply defined labels 0; "Float too large" 0; overfull hboxes above 10pt 0 (the five overfull boxes, all below 9pt, are in `shape.tex`, `app-terms.tex`, `app-laws.tex` and two unattributed places, none in the scope's sources); overfull vboxes 0; `merge_bib.py`: 299 entries, 219 cited keys, 0 missing, 0 from the fallback; BibTeX: one warning (empty publisher in `shapiro1991inductive`, a book entry; harmless).
* **Pages:** 223 in all. Title page, abstract and contents pp. 1–2; main text from the heading of §1 to the end of Code and data **50.38 pages** (pp. 2–52; the task accepts it); references pp. 52–64; Appendices A 65, B 88, C 110, D 130–137 (8 pages), E 138, F 159, G 182, H 208–218 (11 pages), I 219–223 (4.5 pages). Appendix J (`app-verification.tex`) is switched off (`\sairecordfalse`) and does not print; an isolated build of it (`./test-section.sh discussion app-verification`) has no LaTeX error, no undefined citation and no overfull box above 10pt (its cross-references are undefined there, as expected).
* **Sections in scope (pages, measured from `pdftotext -layout` as in DECISIONS §L1):** §1 2.93 (target 3.00), §6 4.78 (4.75), §10 4.35 (4.25), §11 2.62 (2.50), §12 2.46 (2.25), §13 with acknowledgements and code and data 1.64 (1.75); all within target +0.25. The other sections: §2 3.82, §3 4.55, §4 5.82, §5 5.16, §7 4.70, §8 3.89, §9 3.65.
* **Floats:** Table 2 (p. 24) and Table 3 (p. 28) in §6 (pp. 24–29); Table 5 and Figure 1 (p. 44) in §10 (pp. 41–46); Table 6 (p. 47) in §11.

## 5. Edits made by this check

1. `sections/intro.tex`, contribution (7): "with deduction charged, \SAIabbr is certificate \SOIabbr up to polynomial changes of the budgets" → "with deduction charged, **on hypotheses closed under renaming of parameters**, \SAIabbr is certificate \SOIabbr up to polynomial changes of the budgets". Reason: `thm:soi:sandwich` holds "Under (F1)" (`sfi` Thm 8.1 "[proved under (F1)]"; `soi.tex` §4.6 states it), and the contributions list must keep the hypotheses of what it summarises (final-check §4; DECISIONS rule 0.3). A comment in the file header records the change. Net addition: six words; the page count of §1 and of the main text is unchanged (2.93 and 50.38).

No other file was changed.

## 6. Remaining items (for the author or the publication step; none blocks the text)

* The project README promised by the Code and data statement (FRO-19, DECISIONS §X9) does not exist yet; it is a blocking item of the publication to `main`, not of this check.
* Verified references for the ERFA library and the plan94 theory (DECISIONS §R) are still to be added before submission; the text names the routines instead.
* Contribution (4) of §1 summarises `thm:terms:dilemma`(iii), whose fit-class part also uses (F1); the theorem itself lists that condition only in its proof ("with the conditions of the parts listed in the proof"), and the decided intro wording (FRO-10) follows the theorem's statement, so it was left as is. If the author wants (F1) in the statement of `thm:terms:dilemma`, the intro could follow.
