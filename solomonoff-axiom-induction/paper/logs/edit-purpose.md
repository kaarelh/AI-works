# Edit log: approximate correctness and purpose (2026-10-18)

*Status: done. Final full build (under the lock): 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, no overfull box above 10pt (largest 8.37pt, unchanged), 230 pages; main text 50.86 pages (+0.48, within the +0.50 allowed).*

Editor applying the agreed approximate-correctness change. Sources: the brief, section "Approximate correctness: where the discussion stands (2026-10-17)" (`research/00-brief.md`); the purpose record `research/tracks/purpose/notes-final.md`, whose section "How to state it in the paper" is binding, with its two reports (`referee-A.md`, `referee-B.md`); writing rules `../solomonoff-operator-induction/research/paper-review/REFRAME.md` and `DECISIONS.md` §A.

## 0. Restart check

No `logs/edit-purpose.md` existed. All section files, `bib/refs.bib`, `bib/bib-report.md`, `CLAIMS.md` and the README had modification times of 2026-10-17, before the purpose record (2026-10-18 01:46), and `git diff` showed no uncommitted change under `paper/` or in the README. So this was a fresh start. The originals were backed up in the session scratchpad (`purpose-edit/orig/`). Baseline (the `main.pdf` of 2026-10-17 17:23, measured with the front group's script `front/measure.py`, copied to `purpose-edit/measure.py`): 223 pages, main text 50.38 pages.

## 1. A deviation from the computed task, and why

* **The scope of the limitation.** The task's item 2 asks to state that approximate correctness "remains a limitation, of SAI and of Bayesian cumulative log loss generally". The record judges the second half of the brief's wording ("of any Bayesian cumulative log loss") **probably wrong as stated** (section "Probably wrong"; P38; referee A, M1), because a decision layer (posterior plus purpose loss) ranks laws by purpose without changing credence. The task also says "at the strength of the record" and "never strengthen", and the record's "How to state it" (P29 / S-final) is binding. So the paper says: a limitation of SAI, "shared by any account that ranks approximate laws by cumulative log loss, that is by posterior weight or code length, but not by Bayesian inference as such". This keeps "Bayesian cumulative log loss generally" in the only sense the record supports (cumulative log loss used to rank approximate laws) and adds the record's qualification.
* **`phil.tex` was edited although it is not in this editor's file list.** Binding decision 1 says to remove the "not a limitation" claim *everywhere it occurs*, and the record's list of occurrences ("What this changes", item 1) includes `phil.tex` line 37, where the claim stood in the list headed "Proved, in the stated settings". Leaving it would have kept a retracted claim, labelled as proved, in the paper. The edit is minimal (one clause replaced, one clause added to the list of arguments; details in §2.7). No other content of §6 was touched.
* **One bibliography entry from `refs-revision.bib`.** The task says to add only entries from the track's `refs.bib`. The record's binding text (S-final, item 4 of "What this changes") cites Miller (1975) for "the choice of quantities is not neutral"; that entry was verified by search in the track's revision and is in `research/tracks/purpose/refs-revision.bib`, which the record describes as supplementing `refs.bib`. It is cited once, with "cf.", at its verified level ([B]/[S]). Every other new entry is from `refs.bib`. Two DOIs verified in the revision (Patton 2020; Vovk and Watkins 1998) were added to those entries.

## 2. Changes, file by file

### 2.1 `sections/laws.tex` (§9)

* **Opening (decision 1).** Deleted "The difficulty is a limitation of proof-requiring compatibility with deterministic theories, not of the axiom view as SAI formalises it: $\MA$ mixes randomised theories, and under SAI's pricing an approximately true law is a law with a calibrated error model (Prop. 9.2)." Replaced by "$\MA$ also mixes randomised theories, and under SAI's pricing an approximately true law is a law with a calibrated error model (Prop. 9.2); that pricing is not an account of approximate correctness (§9.3, `par:laws:purpose`)." Same length.
* **New paragraph `\paragraph{What the pricing does not see.}\label{par:laws:purpose}`** (decision 6), after the paragraph that follows Prop. 9.2 ("So under SAI's pricing …"); 9 printed lines. `\status{assessment, resting on prop:laws:partition, thm:laws:entropy, ex:laws:rival, ex:laws:misspecified, prop:laws:dominance (proved; computed)}`, `\src{purpose P29, S-final; P4--P7, P14, P16, P31, P34--P36}`. Content, each at the record's strength: Prop. 9.2 describes the credence- and compression-best forecast, not approximate correctness (record item 2 of "What this changes"; S-final); for questions about one quantity the loss is the log score of the cell the answers determine, a question family fixes a resolution, and the cost of a miss is set by each hypothesis's own error model, not by a purpose (P4–P5, P31); the pricing ranks rival laws by a dispersion of the error for coarse cells and, for fine ones, by the entropy of the error rather than its size (P14, S-final's wording); it can rank a law above one closer to the truth at every time (P16, P36); other proper scores rank rival laws differently, under misspecification and even without it (P11, P33); a tolerance on a domain is a sentence in which SAI holds a credence, a graded loss is not (P34). Pointers to App. G.9.
* **"Kepler's residuals" paragraph: one sentence (decision 6, T4(b)).** "Over the four fits, maximum, RMS and mean absolute error disagree on the best fit, the calibrated pricing agrees with none, and its ranking changes with cell width for 11–16 of 234 pairs, by up to 6.8% of the rate (App. G.9)." P18 at its "How to state" strength (ranges, not single counts; "by up to 7% of the rate" given as the record's 6.8%).
* Unchanged: Prop. 9.2 and its proof idea, the Kepler computations, the "So under SAI's pricing the preferred form is a law with a calibrated error model …" paragraph (the qualifier of record item 2 is carried by the first sentence of the new paragraph instead; a version that inserted it into this sentence was tried and removed for length).

### 2.2 `sections/app-laws.tex` (Appendix G): new subsection G.9, `app:laws:purpose`, "What log loss does and does not measure"

Placed at the end of Appendix G, so that no existing number changes (G.1–G.41 unchanged). Every item has `\status` and `\src{purpose …}`. Local symbols chosen to avoid clashes (comment at the head of the subsection): $\mathrm h$ for differential entropy ($h$ is a length in G.4), $\tilde u$ for the uniform variable ($V$ is the universal machine), $\mathrm{disp}$ for the dispersion ($D$ is a data set), $\mathrm{sep}$ for the separation probability, $\mathsf L$ and $\mathsf Y$ for the purpose loss and its range ($\lambda$ is the steepness).

| label | number | content | record | status rendered as |
|---|---|---|---|---|
| `prop:laws:partition` | Prop. G.42 | (a) machine-by-machine locality and the chain rule for questions about one quantity: loss $-\log\beta_G(C_D)+\log\nu_G(\emptyset)$, a sub-probability on cells; (b) the price of a miss is set by the forecast (Gaussian $d^2/(2\sigma^2\ln2)+O(\lvert d\rvert)$, Laplace $\lvert d\rvert/(b\ln2)+O(1)$, fixed and dithered cells); (c) one randomly offset question per value: exact expected loss of a near-point forecast with $\mathrm{sep}=\min(\lvert x-d\rvert/\Delta,1)$ | T1.1, T1.3, T1.4, T1.5(d), T1.6; P2, P4, P5, P7, P31 | Proposition with proof; the computed Gaussian check (25.95 against 25.97 bits) in the paragraph after it |
| `prop:laws:fitted` | Prop. G.43 | ML-fitted Gaussian, Laplace, uniform and generalised-Gaussian error models rank laws by RMS, mean absolute, maximum and $L^p$ error (closed forms) | T3.1; P12 | Proposition with proof |
| `lem:laws:dither` | Lemma G.44 | $H(C_u(e)\mid u)=\mathrm h(e+\Delta\tilde u)-\log\Delta$ | T3.2; P13 | Lemma with proof; "the known rate of entropy-coded subtractively dithered quantisation" in prose, without a citation (the record has the attribution only at [S] and says the statement in Zamir–Feder was not seen) |
| `thm:laws:entropy` | Thm. G.45 | $r_{\mathcal F}(\Delta)=\mathrm h(e+\Delta\tilde u)-\log\Delta$; (a) coarse: $\mathrm{disp}(e)/\Delta$, $\mathrm{disp}=2\varepsilon c_{\mathcal F}$; (b) fine limit $\mathrm h(e)\in[-\infty,\infty)$ for every error law with bounded support, rearrangement-invariant; (c) atoms, non-atomic part | T3.3; P14 | Theorem with full proof (the general fine-limit proof of the revision); the arcsine convergence numbers (0.8542, 0.1935, 0.0274, $8.66\times10^{-4}$; $0.866\sqrt\Delta$) as a computation after it; P28 (Prop. 9.2(b) holds for every proper score) as a sentence with its one-line argument |
| `prop:laws:rival` | Prop. G.46 | two laws can both have regime-R errors only if their errors differ by a constant (errors in arcs shorter than $\mathsf R/2$); then their prices agree | Remark T3.4; P32 | Proposition with proof (the rotation argument written out) |
| `ex:laws:rival` | Ex. G.47 | (a) toy 1 closed forms, $\Delta_c=1.558542$; (b) the dominance reversal A′/B′, $\Delta_c'=1.429612$; (c) the explicit non-nested-information model of Prop. T4.1 | T4(a), Prop. T4.1; P16, P33, P36 | Example; closed forms proved, roots and criteria values "a direct computation"; the sentence after it: neither pair of prices is SAI's rate for both laws (P32), rate 0 for a machine stating both laws (rb4 B(i)), Patton 2020 for non-nested information at abstract level |
| `ex:laws:misspecified` | Ex. G.48 | (a) the five nearby / five scattered forecasts: equal log scores, CRPS 0.4 and 4.0, and the 0.21 variant; (b) the bimodal truth and the Gaussian family: $s=1.004988$ against $1.202984$ | T2; P10, P11 | Example (computation); the sentence after it cites Kleijn–van der Vaart (and cf. Berk) for the KL projection, keys already in the paper's bibliography |
| `prop:laws:dominance` | Prop. G.49 | (a) threshold purposes are sentences; (b) dominance implies at least as good for every accuracy-monotone purpose; (c) invariance under monotone reparametrisation, not under a change of quantities | Props T6.A, T6.B; P34, P35 | Proposition with proof; after it: graded purposes are functionals, not sentences (P34), the purpose-neutral core (T6.3, assessment), Miller 1975 with "cf.", the calibrated pricing can reverse dominance (P36) |
| (paragraph) "Rival fits of Kepler's laws." | — | T4(b) robust findings with estimators and ranges | T4(b); P17, P18 | prose, "A computation (code in the accompanying repository) finds" |
| `def:laws:purposesai` | Def. G.50 | purpose-SAI: answer distributions, acts, the aggregating algorithm over theory machines with weights $\mm(i)$ | Def. T5.1, T5.0 | Definition |
| `prop:laws:purposeregret` | Prop. G.51 | regret $\le K(G)\ln2/\eta$; square loss on $[-\mathsf Y,\mathsf Y]$: $2\mathsf Y^2K(G)\ln2$ | T5.0, T5.2; P19–P21 | Proposition with proof; the AA bound credited to Vovk (2001) as known, square-loss mixability "cf. Haussler et al. 1998" with the rescaling; after it the scale remark ($1.6\times10^8$ arcmin² per bit), absolute loss not mixable (one-line proof), incomputability, general-Bayes form of the weights (Bissiri et al.), predictive complexity as prior art (cf. Vovk and Watkins 1998; "only the version over theory machines is new") |
| `rem:laws:decision` | Rem. G.52 | a decision layer; SAI has none and adding one is not immediate (belief functions); Hutter 2003 for Solomonoff's mixture | T6.1; P37 | Remark (assessment; open part pointed to the question) |
| `q:laws:purpose` | Q. G.53 | SAI with a purpose: (i) acts under belief functions, well-specified optimality; (ii) which properties survive in purpose-SAI, and an upper semicomputable universal element | Q1, Q2, Q3; P25, P26 | Question environment |

Not included (optional in the record): P15 (permuted histogram bins), P22–P23 (transfers to purpose-SAI; they would need their proofs written out), P24 (proof sketch, a third "best law"), P30 (Mars pool under the purpose view; it belongs to §10, which is not this editor's).

The word "agent" (twice, in Remark G.52, in the decision-theoretic sense) was replaced by "inducer" and "user" so that the process-vocabulary grep stays clean.

### 2.3 `sections/limits.tex` (§11)

* **"Approximate truth" rewritten (decisions 1, 2).** Deleted the claim "``Kepler's laws are only approximately true'' is a limitation of proof-requiring compatibility with deterministic theories, not of the axiom view as SAI formalises it: its mixture contains randomised theories, and under its pricing an approximately true law is a law with a calibrated error model". New text, from S-final at its strength: a limitation of SAI, not only of proof-requiring compatibility; the mixture prices an approximately true law as a law with a calibrated error model (Prop. 9.2); whether such a law is good enough depends on a purpose, which the pricing sees only through the questions asked (§9.3); adequacy for a purpose needs a loss on answers, either as a decision layer on the posterior, which ranks laws by purpose when the posterior predicts well, or inside learning when the pool of hypotheses is restricted (Rem. G.52, Q. G.53); the limitation is shared by any account that ranks approximate laws by cumulative log loss, that is by posterior weight or code length, but not by Bayesian inference as such; a law at least as close to the truth on every question is at least as good for every purpose that rewards closeness (Prop. G.49). The existing sentence on a canonical metric is kept as the record supports it, with "metric" replaced by "score" (T6.5: "no canonical score, and no canonical choice of quantities") and "the choice of quantities is not neutral (cf. Miller, 1975)" added; "our notion is local: a question family, a tolerance, a domain" kept.
* Dropped for length, both said elsewhere: "the error model is carried by the randomness of the theory machine, not stated as an axiom; a treatment … by sentences about probabilities belongs to the open problem stated above" (§6's summary and the "Statistical confrontation" paragraph keep the point); "whether a deterministic theory holds a law honestly or with exceptions is a modelling choice of pricing (Prop. G.18); humility is partiality … calibration …" (§9.3 says both).
* `\status` and `\src` of the paragraph updated.
* **"What the axiom view captures"** (record item 3): "approximate truth in honest or error-model form" became "approximate truth at a tolerance, priced with error models", and "and graded adequacy for a purpose" was added to what it misses.

### 2.4 `sections/related.tex` (§12) (decision 7)

Two sentences added to "Laws, approximation, explanation, and what a theory is", after the MDL/Akaike sentence: rankings of point forecasts can depend on the consistent loss under misspecification, estimation error or non-nested information (Patton 2020, [A]); for proper scoring rules Gneiting–Raftery 2007; for model assessment by adequacy for particular purposes Parker 2009, 2020 ([A]); a purpose loss can replace log loss in learning through generalised Bayesian updating (Bissiri et al. 2016, [A]) or the aggregating algorithm (Vovk 1990, 2001), which with universal weights gives predictive complexity (cf. Vovk and Watkins 1998, [S]); App. G.9 gives a form over theory machines. "What is new" is unchanged (the record's novelty searches for T1.4–T1.6, T3.3, T4.1, T6.A–B are limited, so no novelty claim was added; the predictive-complexity prior art is stated in the related-work sentence and after Prop. G.51).

### 2.5 `sections/discussion.tex` (§13) (decision 5)

* "Finally, …" sentence: now "Finally, ``Kepler's laws are only approximately true'' remains a limitation: SAI prices an approximately true law as a law with a calibrated error model (Prop. 9.2), but whether a law is good enough depends on a purpose, which its log loss sees only through the questions asked (§11)."
* "What it cannot show": "approximate truth" became "approximate truth at a tolerance", and "and graded adequacy for a purpose" was added to what the axiom view misses.
* Open problems: item (6) added, citing `q:laws:purpose`. Every `q:` label of the paper is still cited in §13 (checked by grep, §3).

### 2.6 `sections/abstract.tex` and `sections/intro.tex` (decisions 3, 4)

* Abstract: "Under SAI's pricing an approximately true law is a law with a calibrated error model; Kepler's laws are worked through." became "SAI prices approximately true laws by their calibrated error models, not by their adequacy for a purpose; Kepler's laws are worked through." Word count 248 (limit 250; counted with the macros expanded, comment lines excluded).
* Introduction, contribution (5): "…the best loss rate is that of the law with its error distribution (attained by $\MA$ if computable), which is no account of approximate correctness (Props 9.2, G.10, §9.3)." A longer version (with "a smoothed entropy of the error" and Thm G.45) added one line to §1 and, through page breaks, 0.10 page to §2; it was replaced by this one, which keeps item (5) at four lines.

### 2.7 `sections/phil.tex` (§6; outside the file list, see §1)

In the paragraph listing what is proved (before Table 2), the clause "``Kepler's laws are only approximately right'' is a limitation of proof-requiring compatibility with deterministic theories, not of the axiom view as SAI formalises it: its mixture contains randomised theories, and in it an approximately true law is a law with a calibrated error model, carried by the randomness of the theory machine rather than stated as an axiom (Prop. 9.2)" became "in SAI's mixture an approximately true law is priced as a law with a calibrated error model, carried by the randomness of the theory machine rather than stated as an axiom (Prop. 9.2), a pricing that sees a purpose only through the questions asked (Prop. G.42)". In the list "Arguments only" the item "that approximate correctness, which depends on a purpose, remains a limitation of SAI (§11)" was added. A `%` comment records the edit.

### 2.8 `sections/app-notation.tex`

One row added: $r_{\mathcal F}(\Delta)$; $\mathrm h$; CRPS (the best rate in regime R and price of a calibrated completion; differential entropy in bits; continuous ranked probability score), pointing to Prop. 9.2 and App. G.9.

### 2.9 `bib/refs.bib`

Eleven entries appended, in a block with a provenance comment: from `research/tracks/purpose/refs.bib`, with that file's verification comments, `gneiting2007strictly`, `patton2020comparing` (DOI added from the revision), `vovk1990aggregating`, `vovk2001competitive`, `vovk1998universal` (DOI added from the revision), `haussler1998sequential`, `bissiri2016general`, `parker2009confirmation`, `parker2020model`, `hutter2003optimality`; from `refs-revision.bib`, `miller1975accuracy` (its `note` field moved into the comment, so that nothing prints). Every new key is cited in the text; `bernardo1979expected`, `berk1966limiting`, `kleijn2006misspecification`, `pettigrew2016accuracy` were already in the bibliography. No `note` field prints.


## 3. Records

* **`bib/bib-report.md`:** new §7, "Addendum: entries added for the approximate-correctness change", one row per new key (data, level, what may be attributed, where cited), the list of track entries not added and why, the two keys already present that the new text cites, and the `merge_bib.py` check (310 entries, 232 cited keys, 0 missing, 0 from the fallback). No new search was made; the levels are the track's.
* **`CLAIMS.md`:**
  * a note under the header (what changed on 2026-10-18);
  * §8: thirteen rows added after `q:laws:domains` (`par:laws:purpose`, `prop:laws:partition`, `prop:laws:fitted`, `lem:laws:dither`, `thm:laws:entropy`, `prop:laws:rival`, `ex:laws:rival`, `ex:laws:misspecified`, `prop:laws:dominance`, `def:laws:purposesai`, `prop:laws:purposeregret`, `rem:laws:decision`, `q:laws:purpose`), each with source, status, place, how to state and dependencies;
  * rows changed: `prop:laws:strength` (its "how to state" was the retracted wording; now marked retracted), `prop:laws:errormodel` (the headline now carries the record's qualifier and "never 'not a limitation of the axiom view'"), `prop:laws:peaked` and `prop:laws:humility` (no longer cited in §11), the `limits` and `related` rows of §10 (pages; `sec:limits:approx` rewritten);
  * §12: `q:laws:purpose ★` added (it is problem (6) of §13);
  * the place column: every page number re-read from `main.aux` by a script (`purpose-edit/claims_pages.py` in the session scratchpad), 278 rows changed. The appendices moved by 1 to 8 pages and §10's items by one page; the script also checked that the printed number in each row is the number in `main.aux` (no mismatch, so no existing item was renumbered).
* **`README.md`** (decision 9), every statement checked against the PDF:
  * the PDF line: 230 pages, main text about 51 pages (pp. 2–53), appendices pp. 67–230;
  * "Answers in brief", Limitations: the approximate-correctness bullet rewritten (a limitation of SAI; the pricing describes the credence- and compression-best forecast; what the pricing does not see, with Prop. G.42, Thm G.45, Exs G.47–G.48 and the Kepler fits; scope: tolerances are sentences, the decision layer, not a limitation of Bayesian inference as such, the dominance order, no canonical score, the choice of quantities);
  * "Further results", §9: a bullet on scores and purposes (Thm G.45, purpose-SAI and Prop. G.51, Q. G.53);
  * "Where the paper departs from the brief": the Kepler item replaced. It says what the draft said, Hänni's objection (paraphrased), that the paper now agrees with Hänni's objection that log loss cannot be the account of approximate correctness and retracts the claim, that the paper is narrower than the brief's agreed wording in one respect (not a limitation of Bayesian inference as such), and what remains open (Q. G.53). The earlier text ("Hänni's wording is compatible with this; it is a refinement") is gone. Hänni is named, never referred to by a pronoun;
  * "How it was produced": a block "After the draft: approximate correctness" (the eighth track `purpose`, its two referees and final record, and this edit);
  * layout table: `research/tracks/` now "the eight track records";
  * building and reproducing: `research/tracks/purpose/referee_A_code/` added to the script folders, `purpose/checks/p4_allfits.py` to the pyerfa list, and a "needing care" item on `p4_allfits.npz` and `laws/checks/l4_residuals.npz`; a row "§9.3, App. G.9" in the table of where the computed numbers come from.
* **Not changed:** `OUTLINE.md`, `NOTATION.md` (the new local symbols are defined where used and listed in App. I), `app-verification.tex` (switched off), the track's files.

## 4. Checks

* **Isolated build** (`./test-section.sh laws app-laws`) after each change to §9 and App. G: OK, 0 undefined citations, 0 overfull boxes above 10pt; the undefined references were all to other sections and are defined in the full build.
* **Full builds** only under `flock /tmp/claude-0/paper-build-sai.lock ./build.sh` (eight builds while fitting the length). Final: 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt (largest 8.37pt, the existing table of App. G.4), no "Float too large", BibTeX: the one intentional warning (`shapiro1991inductive`; `build.sh` prints 2 because it also counts the summary line).
* **Greps on `pdftotext main.pdf`:** the process-vocabulary pattern of DECISIONS §A5 plus "track", "referee", "scout", "workflow", "agent", "record", "synthesis", "thread": only the hits already present before this edit (the title-page footnote's "referees", "a superseded theory" in §9.7 and Prop. G.40, "not written out" in Rem. G.38, "Intelligent Agent Foundations Forum" in the bibliography, "tracks of one tape", "the revision of the base abstractions"); two new hits of "agent" (Rem. G.52) were removed. Model names: none. Printed status tags: none (the one regex hit is "P[not proved]", a probability, as before). "not of the axiom view" / "not a limitation": no hit in the PDF or the sources (one `%` comment in `phil.tex` quotes the retracted clause).
* **Every `q:` label is cited in §13** (script over `sections/*.tex`; the new `q:laws:purpose` is problem (6)).
* **Every new result has `\status` and `\src{purpose …}`** (script over the new subsection; the two new paragraphs of §9 and §11 also).
* **Abstract:** 248 words (limit 250).
* **Mathematics against the record:** each statement of App. G.9 was compared with the record item named in its `\src` (hypotheses, quantifiers, constants); the computed numbers were compared with the saved outputs `checks/p2_scores.out` (Ex. G.48), `checks/p4_toy.out` (Ex. G.47(a), (b)), `checks/p6_revision.out` parts B and C (the Gaussian check after Prop. G.42; the arcsine numbers after Thm G.45), `checks/p4_kepler_allfits.out` and `checks/p7_kepler_effects.out` (the Kepler fits). The closed forms of Ex. G.47 ($r_A$, $H(0.1,0.8,0.1)$, the crossovers as roots of $r_A=H(B)$ and $\Delta=4\ln\Delta$) and the fitted-scale formulas of Prop. G.43 were re-derived by hand. Two places where the record's wording was sharpened by the referees are printed in the sharpened form: "rather than its size" (not "distance-blind") for the fine limit, and "price of the calibrated completion" (never "SAI's rate") for cross-law comparisons.

## 5. Pages

Measured as in `edit-front.md` §3 (each section from its heading to the next, word positions from `pdftotext -bbox`; §13 includes the acknowledgements and code and data, up to the heading of the references), with the front group's script.

| § | file | baseline (2026-10-17 17:23) | after this edit | change |
|---|---|---|---|---|
| 1 | `intro.tex` | 2.96 | 2.96 | 0 |
| 2 | `setting.tex` | 3.76 | 3.76 | 0 |
| 3 | `basic.tex` | 4.58 | 4.58 | 0 |
| 4 | `soi.tex` | 5.78 | 5.78 | 0 |
| 5 | `logic.tex` | 5.17 | 5.17 | 0 |
| 6 | `phil.tex` | 4.81 | 4.81 | 0 |
| 7 | `shape.tex` | 4.67 | 4.67 | 0 |
| 8 | `terms.tex` | 3.88 | 3.88 | 0 |
| 9 | `laws.tex` | 3.67 | 3.92 | +0.25 |
| 10 | `kepler.tex` | 4.33 | 4.39 | +0.06 (unchanged text; floats placed differently after §9 grew) |
| 11 | `limits.tex` | 2.65 | 2.75 | +0.10 |
| 12 | `related.tex` | 2.43 | 2.49 | +0.06 |
| 13 | `discussion.tex` (+ ack., code and data) | 1.70 | 1.72 | +0.02 |
| | **main text** | **50.38** | **50.86** | **+0.48** |

Whole PDF: 230 pages (was 223): title, abstract and contents pp. 1–2; main text pp. 2–53; references pp. 53–66; appendices A–I pp. 67–230 (App. G pp. 183–215, of which the new G.9 is pp. 209–215; App. H now starts on p. 216).

Tightening done to stay within the half page: the qualifier of Prop. 9.2 moved from the "So under SAI's pricing" sentence into the new paragraph; the T4(b) sentence shortened (so that no line holds only a reference); in §11 the clause on how the error model is carried and the sentences on honest laws against laws with exceptions and on humility were dropped (said in §6 and §9.3); the §12 sentences shortened; the introduction's item (5) kept at four lines, after a longer version had cost 0.12 page through page breaks in §1–§2. Further cuts in §9 did not change the measure (the page breaks of §9–§10 are set by floats), so they were not pursued at the cost of content.

## 3. Post-check wording fixes (2026-10-18, after review/final-check-purpose.md §6)

* §11 "Approximate truth" and README (two places): "ranks approximate laws by cumulative log loss, that is by posterior weight or code length" became "ranks approximate laws by posterior weight or code length", the record's exact scope (S-final); posterior weight and code length include the prior term, cumulative log loss does not (checker §6 item 1).
* §6 "Purpose and logarithmic loss": the uniqueness of the local proper score now says "under regularity conditions" (refs-report: the conditions are part of the cited theorem; checker §6 item 4).
