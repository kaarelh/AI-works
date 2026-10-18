# Final check: the approximate-correctness edit (2026-10-18)

*Status: complete. A fresh checker looked at the edit recorded in `paper/logs/edit-purpose.md`. The sources were `research/tracks/purpose/notes-final.md`, especially "How to state it in the paper", and the brief's section "Approximate correctness: where the discussion stands (2026-10-17)", including its correction of 2026-10-18.*

**Verdict.** The edit does what the brief and the record ask, and it states every result at the record's strength or weaker.
* Two hypotheses were missing from Proposition G.42. They are fixed below (§2.3).
* The full build after the fixes is clean: 0 errors, 0 undefined references or citations, 0 multiply defined labels, no overfull box above 10pt. The PDF has 230 pages, of which 50.86 are main text.

## 0. Restart check

When this run started there was no `review/final-check-purpose.md`, so this is a fresh start. A skeleton was written first and progress was saved during the run. `git status` showed the editor's uncommitted changes under `paper/` and in the README; nothing else was pending.

## 1. The retracted claim is gone

* **Sources.** I grepped `paper/sections/*.tex`, `README.md` and `CLAIMS.md` for "not a limitation", "not of the axiom view" and "limitation of proof-requiring".
  * No hit in printed text.
  * Hits that remain:
    * one `%` comment in `phil.tex:12` that records the retracted clause;
    * `CLAIMS.md` rows `prop:laws:strength` and `prop:laws:errormodel`, which mark the wording as retracted;
    * README §5 and "How it was produced", which describe the retraction as history.
* **PDF.** `pdftotext main.pdf`, after the final build: 0 hits.
* **Every passage on approximate truth** was read: abstract; §1 item (5); §6 (the "Proved" list, the "Arguments only" list, the paragraph on statistical explanation); §9 opening and §9.3; §11 "Approximate truth" and the closing paragraph; §13 "What the formalism shows" and "What it cannot show"; App. H ("conservative estimate", which the record says is fine as it stands); README "Answers in brief", "Further results" and §5.
  * None of them presents log-loss pricing as the account of approximate correctness.
  * Each one that states Prop. 9.2 also says, or points to a sentence saying, that the pricing is not such an account. This is the record's item 2 qualifier: "describes the credence- and compression-best forecast, not approximate correctness" (§9.3; App. G.9; abstract "not by their adequacy for a purpose"; intro "no account of approximate correctness").
* **The limitation statement (§11, §13, README).**
  * §11 says the limitation "is shared by any account that ranks approximate laws by cumulative log loss, that is by posterior weight or code length, but not by Bayesian inference as such".
  * This follows the record's corrected scope (S-final, P38, brief correction of 2026-10-18), not the brief's withdrawn wording "of any Bayesian cumulative log loss". `edit-purpose.md` §1 records the deviation from the computed task. I agree with it: the record wins where it and the brief differ.
  * "A limitation of SAI" (not only of its pricing) is supported by the record. SAI as defined has no act layer, and adding one is open (T6.1, P37, the response to referee A M1). §11 points to Rem. G.52 and Q. G.53 for this.
* **The out-of-list edit to `phil.tex`.**
  * It was needed: the record's item 1 lists `phil.tex` line 37, where the retracted clause stood under "Proved".
  * The replacement clause is the content of Prop. 9.2 plus a pointer to Prop. G.42. Approximate correctness as a limitation appears under "Arguments only".

## 2. Statements, proofs and numbers against the record

### 2.1 Main text

| place | record line ("How to state") | checked |
|---|---|---|
| §9 opening | P29 / S-final; item 2 | "that pricing is not an account of approximate correctness": matches |
| §9.3 `par:laws:purpose` | S-final; P4–P5, P31, P14, P16/P36, P11/P33, P34 | each clause at the record's strength. "for fine ones, by the entropy of the error rather than its size" is S-final's wording, and referee A's m2 refinement replaces "distance-blind" |
| §9 "Kepler's residuals", last sentence | P18 | ranges, not single counts. "11–16 of 234" covers every estimator. "by up to 6.8%" is the largest relative difference among the 14 exact-rate reversals in `p7_kepler_effects.out` §2; the record allows "up to 7%" |
| §11 "Approximate truth" | S-final, P34–P37, T6.5, item 4 | matches; "no canonical score, and the choice of quantities is not neutral (cf. Miller 1975)"; the local notion kept |
| §11 closing, §13 "What it cannot show" | item 3 | "approximate truth at a tolerance … misses … graded adequacy for a purpose": matches |
| §13 "What the formalism shows" | items 1, 5 | matches |
| §13 open problem (6) | Q3, P25–P26 | matches `q:laws:purpose` |
| §1 item (5), abstract | item 2 | matches; abstract 248 words |
| §12 | P11, P33, T5 prior art, T6.2 | Patton for point forecasts, Parker for adequacy for purpose, Bissiri and the AA for learning with a purpose loss, Vovk–Watkins with "cf."; no novelty claim added |

### 2.2 Appendix G.9: statements and proofs

Every item was compared with its `\src` item in the record. I checked the hypotheses, the quantifiers and the constants, and re-derived the proofs.

| item | record | result |
|---|---|---|
| Prop. G.42 (a) | T1.1, T1.3, T1.4 | proof correct (telescoping, B-incompatible cells). **Fixed: loss convention** (§2.3) |
| Prop. G.42 (b) | T1.6 | Mills-ratio and Laplace computations re-derived, including the Laplace cell mass |
| Prop. G.42 (c) | T1.5(d) | exact decomposition correct. **Fixed: circle of one cell** (§2.3) |
| Prop. G.43 | T3.1 | the closed forms re-derived, including the minimiser $s^p=pM_p^p$ of the generalised Gaussian |
| Lemma G.44 | T3.2 | density of $e+\Delta\tilde u$ and the change of variables correct. "Known" is rendered without a citation, as the record has only [S] for it |
| Thm. G.45 | T3.3, P14 | (a) the three-piece density and $\mathrm{disp}=2\varepsilon c_{\mathcal F}$ re-derived. (b) lower bound by conditioning; upper bound by Donsker–Varadhan lower semicontinuity (bits form correct). (c) atoms and the concentration-function bound. The reduction $\mathrm h(-e+\Delta\tilde u)=\mathrm h(e+\Delta\tilde u)$ is correct |
| P28 sentence after Thm. G.45 | P28 | matches ("what is specific to log loss is the ranking across laws") |
| Prop. G.46 | Remark T3.4, P32 | rotation argument correct (irrational rotations give full support; $k$ equally spaced points lie in no arc shorter than $\mathsf R-\mathsf R/k\ge\mathsf R/2$) |
| Ex. G.47 (a), (b) | T4(a), P16, P36 | $r_A$ re-derived from the trapezoidal density ($1+\Delta/(4\ln2)-\log\Delta$) and in the coarse regime ($(\log\mathrm e)/\Delta$); $r_B$ from Thm. G.45(a), (c). For (b), "the smaller root of $\Delta=4\ln\Delta$" is the right root: the other is about 8.6, outside $\Delta\le2$ |
| Ex. G.47 (c) | Prop. T4.1, P33 | matches, including $\mathsf R\ge4M$ and the decoding of $e_B$ |
| Ex. G.48 | T2, P10, P11 | matches; CRPS 3.9006 of the 0.21 forecast recomputed by hand |
| Prop. G.49 | T6.A, T6.B, P34–P36 | matches; the example for (c) checked |
| "Rival fits" paragraph | T4(b), P17–P18 | matches, including "close to, but not the same as, a ranking by the standard deviation" and the near-tie qualifier |
| Def. G.50, Prop. G.51 | T5.0, T5.1, T5.2, P19–P21 | matches; rescaling $\eta=2/(4\mathsf Y^2)$ checked; after the proposition, absolute loss is not mixable (AM–GM) |
| Rem. G.52 | T6.1, P37 | matches; Hutter (2003) cited at its abstract level |
| Q. G.53 | Q1–Q3 | matches |

Excluded optional items, all permitted by the record: P15, P22–P23, P24 (a proof sketch, so correctly not stated as a theorem), P30.

### 2.3 Fixes made (both in `sections/app-laws.tex`, Prop. G.42)

1. **(a): loss convention.** The statement said "define the cumulative loss … as in \cref{def:setting:conventions}". Definition 2.5 defines four loss conventions, and part (a) is false for the normalised one (record T1.2, P3). It now says "as in the semimeasure convention of \cref{def:setting:conventions}", matching record T1.1 ("by analogy with the paper's Def. 2.5 (the semimeasure conditional …)") and the `CLAIMS.md` row ("cumulative semimeasure loss").
2. **(c): a circle of one cell.** The statement said "a circle of circumference $\mathsf R$ (an integer multiple of $\Delta$)". For $\mathsf R=\Delta$ the grid has one cell, so the true value and the prediction always share it and the loss is $0$, while the formula gives $\mathrm{sep}\log(1/s)>0$. The proof's step "different cells iff a grid point falls on the shorter arc" needs the longer arc to contain a grid point, that is $\mathsf R\ge2\Delta$. It now says "(an integer multiple of $\Delta$, at least $2\Delta$)". This adds a hypothesis, so it weakens the statement and does not strengthen it. The record's T1.5(d) leaves $\mathsf R_c$ unconstrained, and its check uses a large circle.

After the fixes: the isolated build (`./test-section.sh laws app-laws`) was OK, and the full build is in §5. All label numbers and pages are unchanged; the `CLAIMS.md` place column still matches `main.aux` for the 14 new and changed labels.

### 2.4 Computed numbers against saved outputs (`research/tracks/purpose/`)

| printed | saved output | match |
|---|---|---|
| after Prop. G.42: 25.95 against 25.97 bits ($\sigma=1$, $\Delta=0.1$, $d=6$, fixed and dithered grids) | `checks/p6_revision.out` B: 25.947 / 25.947 [25.969] | yes |
| after Thm. G.45: 0.8542, 0.1935, 0.0274, $8.66\times10^{-4}$; $0.866\sqrt\Delta$ | `p6_revision.out` C: 8.542e-01, 1.935e-01, 2.738e-02, 8.659e-04; 8.659e-03 at $\Delta=10^{-4}$ | yes |
| Ex. G.47: 0.92193, $\Delta_c=1.558542$, $\Delta_c'=1.429612$; 1/0.577/0.5 and 1000/447.2/200; CRPS 0.333, 180, 1/3, 1/2 | `checks/p4_toy.out` | yes |
| Ex. G.48: $\log5$; 0.4, 4.0; 2.2515, 3.9006; 1.004988, 1.202984; 2.05427, 2.09580; 0.60447, 0.59725 | `checks/p2_scores.out` A–C | yes |
| "Rival fits": 204, 121, 101 of 234 | `checks/p4_kepler_allfits.out` (disagreement matrix) | yes |
| 67, 85, 14, 13 of 165 | `checks/p7_kepler_effects.out` §4 | yes |
| 11–16 reversals; 13 of 14 at 0.7%–6.8%; near-ties 0.01%–0.1%; SH and the exact rate agree | `p7_kepler_effects.out` §2–3; record T4(b) for the SH and referee counts (`ra1_fine_rates.out`, `rb5_kepler.out`) | yes |
| after Prop. G.51: $1.6\times10^8$ arcmin² per bit | `referee_code/rb6_aggregating.out` D: 1.62e+08 | yes |

## 3. References

The eleven new keys were checked against `research/tracks/purpose/refs-report.md` (and `refs-revision.bib`) and against where the text cites them.

| key | level in the track | cited for | within its level? |
|---|---|---|---|
| `gneiting2007strictly` | [A], [Q], [S] | CRPS as a proper score ("cf."); proper scoring rules (§12) | yes |
| `patton2020comparing` | [A] | loss-dependence of rankings of point forecasts under misspecification, estimation error, non-nested information | yes ("for point forecasts" in App. G.9) |
| `vovk1990aggregating`, `vovk2001competitive` | [A], [A]/[S] | the aggregating algorithm; the bound with prior weights (Lemma 1 at [S]) | yes |
| `vovk1998universal` | [A], [S] | predictive complexity through the AA, "cf.", not its origin | yes |
| `haussler1998sequential` | [A], [S] | square loss on [0,1] is 2-mixable, "cf." | yes |
| `bissiri2016general` | [A], [S] | generalised Bayesian updating; the exponential-weights form | yes |
| `parker2009confirmation`, `parker2020model` | [A] | adequacy for particular purposes (no formal notion attributed) | yes |
| `hutter2003optimality` | [A] | Bayes-optimal acting under bounded loss for Solomonoff's mixture, well-specified | yes (Rem. G.52 paraphrases the abstract) |
| `miller1975accuracy` | [B]/[S] in `refs-revision.bib` (verified in the track's revision, notes-final verification log), not in `refs-report.md` | closeness rankings reverse under a change of quantities, "cf." only | yes. The record's binding S-final cites it; the editor documents the source (`edit-purpose.md` §1; `bib-report.md` §7) |

* The printed bibliography entries have no `note` fields.
* `merge_bib.py` reports 310 entries, 232 cited keys and 0 missing.
* Two keys already in the bibliography are reused after Ex. G.48: `kleijn2006misspecification` and `berk1966limiting` ("cf.").

## 4. arXiv-readiness

* **Process vocabulary.** I ran the DECISIONS §A5 pattern, plus thread|scout|workflow|agent|record|synthesis, on `pdftotext main.pdf` and compared the hit counts with the committed PDF of 2026-10-17.
  * The only differences are formula fragments: e1, e2, s2 and h2, which come from $e_1$, $e_2$, $s^2$ and $H_2$ in the new text; r1 has one fewer hit.
  * No new word hit. The remaining hits are those present before ("referees" in the title footnote, "Intelligent Agent Foundations Forum", "tracks of one tape", "superseded", "not written out", "revision").
* **Model names.** No hit in the PDF, the sections or the README.
* **Quotations.** The new text has no quotations or paraphrased replies to the author's comments or notes. The five-values example appears only as mathematics (Ex. G.48(a)). There are no new mentions of Hänni.
* **Statuses rendered in prose.**
  * Every new item carries `\status{…}` and `\src{purpose …}`.
  * Computed numbers appear only after statements or in Examples, each introduced with "a direct computation (code in the accompanying repository)".
  * "Known" for Lemma G.44 is rendered in prose.
  * The proof sketch P24 was not included.
* **Abstract.** 248 words, counted from the source with macros expanded and from the PDF text; the limit is 250.
* **Open questions.** The sections have 23 `q:` labels, and every one is cited in §13. The new `q:laws:purpose` is problem (6).

## 5. Full build

`cd paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh`, after the two fixes:

* LaTeX errors: 0
* undefined references: 0
* undefined citations: 0
* multiply defined labels: 0
* overfull boxes above 10pt: 0 (largest 8.37pt, the existing table of App. G.4)
* "Float too large": 0
* BibTeX: the one intentional warning (`shapiro1991inductive`; `build.sh` prints 2 because it also counts the summary line)

**Pages.**

| part | pages |
|---|---|
| whole PDF | 230 |
| title, abstract and contents | 1–2 |
| main text | 2–53 |
| references | 53–66 |
| appendices A–I | 67–230 |
| App. G | 183–215 (G.9 from p. 209) |
| App. H | from 216 |

**Main text by section** (front group's measure script): **50.86 pages**.

| section | pages |
|---|---|
| §9 | 3.92 |
| §10 | 4.39 |
| §11 | 2.75 |
| §12 | 2.49 |
| §13 | 1.72 |

These are the editor's figures: the fixes are in the appendix and changed no page. The main text was 50.38 pages before this edit, so the edit added 0.48 pages, within the +0.50 the editor was allowed.

## 6. Observations not changed (judgement calls)

1. **The §11 and README gloss** "ranks approximate laws by cumulative log loss, that is by posterior weight or code length". Strictly, posterior weight and code length also carry the prior term. The gloss keeps the record's scope (posterior weight, code length; not Bayesian inference as such), so I left it. The record's exact wording would be "a limitation of SAI's posterior pricing read as an account of approximate correctness, as of any account that ranks approximate laws by posterior weight or code length".
2. **"Significant by the estimator's rule"** in the "Rival fits" paragraph. The record calls the SH rule a stability heuristic, not a test (referee A m18). The paper states the rule explicitly, and the record itself uses "significantly" for these counts, so I left the wording.
3. **`phil.tex`'s "Proved" list** ends the Prop. 9.2 clause with "a pricing that sees a purpose only through the questions asked (Prop. G.42)". This is a one-line reading of a proved proposition. The judgement that approximate correctness is a limitation is correctly listed under "Arguments only".
4. **The new paragraph's pointer `rem:phil:purpose`.**
   * The pointer comes after Prop. G.42 and leads to the existing §6 paragraph on the uniqueness of the local proper score. That paragraph, which this edit did not change, does not say "under regularity conditions".
   * The record's Summary 3 has the uniqueness as known in general, so I left it.

## 7. Files

* Changed: `paper/sections/app-laws.tex` (Prop. G.42, two hypotheses).
* Rebuilt: `paper/main.pdf` and the build outputs.
* Written: this report.
* No git command that changes repository state was run. I used only `git status`, `git diff`, `git log` and `git show` to a scratch file.
