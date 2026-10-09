# Final check of the revised paper

A fresh final check of `axiom-induction/paper` against `edits/DECISIONS.md` (read in full first), the four group issue files and logs, and the sources (track `notes-final.md`, check outputs, `code/results/`).

The changes this check made are listed with their reasons in `edits/final-log.md` (FC-1 … FC-7). In summary: six fixes of scope, status or wording, and one prose cut for length. No number, label, hypothesis or result statement was removed. No git command that changes repository state was run.

## Result in brief

* **1. Fatal and major issues (93):** the decided fix is in place for all 93 (10 fatal, 83 major).
  * One residual piece of process vocabulary (M-13) was fixed (FC-6).
  * Two length targets are still missed:
    * the intro is 4.00 pp against its cap of 3.75 (F-25, recorded as "partly done" by the front group);
    * the appendices are 81 pp against their cap of 66 (DECISIONS §2).
  * These need content decisions, not minimal fixes, and are left open (see 1.3).
* **2. Abstract, intro and discussion against the body:** five mismatches, all fixed:
  * a missing "in finite classes" in the §4 opening;
  * a quantifier order in intro A5;
  * an imprecise DT° gloss;
  * a conjecture stated as fact in §9.3;
  * an overstated verdict cell for H4(e) in App H.

  Everything else matches in scope and status.
* **3. Spot check:** 31 claims checked across §§2–8 and App A, F against sources. All agree, so no fix was needed.
* **4. Full build** (`flock /tmp/claude-0/paper-build-ai.lock ./build.sh`):
  * 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels;
  * 0 overfull boxes above 10 pt (one of 0.57 pt);
  * 127 pages; main text 41.39 pp (cap 41.5).

---

## 1. Fatal and major issues: is the decided fix in the .tex?

Method:
* For each fatal or major issue in `edits/*-issues.json`, the binding text or decided change was located in the current section files, by exact-string grep where DECISIONS gives binding text, and otherwise by reading the place.
* Label moves were checked with `grep 'label{…}'` over all section files: every moved label is in its decided file, and there are no duplicate labels.
* Lengths were measured from heading positions in `main.pdf`, with a text block of 645 pt from y = 76.2 pt.

### 1.1 front (32: F-01…F-04 fatal)

| id | decided fix | found in | status |
|---|---|---|---|
| F-01* | §8.3 abstract; canonical §9.1 in A2 | `abstract.tex` (verbatim binding text); intro A2 "In every comparison analysed … up to non-logical weight effects … (∧-rules: open)"; short answer items 3–4 | in place |
| F-02* | §10.F1 row H2 | `tab:intro:verdicts` (App H), H2 verdict and where cells verbatim | in place |
| F-03* | "only a logarithmic charge is proved; polynomial conjectured" | intro A5, short answer item 9, discussion "A time penalty"; the old phrase occurs only as a quotation in `tab:ver:writing` | in place |
| F-04* | §10.F3 | discussion `sec:disc:proposal` "Templates" (verbatim) | in place |
| F-05 | §8.3 abstract | `abstract.tex`, 248 words | in place |
| F-06 | §9.4 "in finite classes … full class can fail" | abstract, intro short answer item 7 and A6, discussion | in place (the §4 opening lacked it; fixed, FC-1) |
| F-07 | provenance §9.9 | abstract last sentence; short answer item 10; §1.4(vi); §1.5 | in place |
| F-08 | complete list of unrefereed results in `app:ver:process` | App H "What this means for the reader" (by track, with labels); app-ident, app-sound and app-pa point to it | in place |
| F-09 | "guaranteed sound only for well-specified data … waiting prover … merely incomplete" | intro A7 | in place |
| F-10 | §9.5 scoping; §10.F4 | intro A7; discussion "Output" (verbatim) | in place |
| F-11 | §10.F4 "What it can promise" | discussion `sec:disc:good` (verbatim) | in place |
| F-12 | §9.6 in A3, A5, item 9, discussion | "over PA", "Σ_n-sound … Σ_n sentences", "merely consistent … open", "fixed polynomial root"; "between … nondeterministic and deterministic" absent | in place (A5's quantifier order fixed, FC-2) |
| F-13 | MDL wording §9.3 in the templates answer | intro A3 | in place |
| F-14 | §10.F1 row H7 | `tab:intro:verdicts` H7 (verbatim) | in place |
| F-15 | §10.F5 | discussion "What it cannot promise" | in place, with the recorded deviation "when T* refutes σ". The deviation is correct: a false σ makes T* ∪ {σ} inconsistent only if T* refutes σ (`rem:ident:sparetotal`). |
| F-16 | missing rows in `tab:ver:corrections`; review rows in `tab:ver:writing` | App H (model m5, pa m10, m11, experiments m1–m14; second part of `tab:ver:writing`) | in place |
| F-16b | C-16 row in `tab:ver:conflicts` | App H, row "review C-16" | in place |
| F-17 | binding short answer in a box after the question; §1.1 ≤ ⅓ page | `framed` box, items 1–10; §1.1 one paragraph, no long quotes | in place, with the recorded deviation in item 9 ("the acceptance half of your schema"). The deviation is correct: `prop:time:notemplate` covers C_f only. |
| F-18 | answers reordered A1–A7 with the binding 3×2 table | intro §1.3 | in place |
| F-19 | 0.77 / 0.23 numbers | short answer item 4 (A2 points to `thm:univ:B`) | in place |
| F-20 | verdict table moved to `app:ver:process` with cell fixes | `app-verification.tex` | in place |
| F-21 | ≤ 2 `\cref` per answer, no undefined symbols, blanket sentence deleted | intro §1.3 | in place |
| F-22 | good version once, in `sec:disc:good`; A1 two lines | intro A1; discussion §9.2 | in place |
| F-23 | verifier answer opens with its definition | intro A7 | in place |
| F-24 | six-theorem stream, Q + theorems strictly weaker, within candidates scored | intro A4 (checked against pa notes §3.5) | in place |
| F-25 | intro 3.5 (cap 3.75), discussion 2.5 (cap 2.75), tocdepth 1 | tocdepth 1, main text from p. 3; discussion 2.74 (was 2.76; FC-7); **intro 4.00** | **partly done**: intro over its cap by 0.25 pp (see 1.3) |
| F-26 | no long quotes in intro and discussion | intro §1.1, discussion §9.3: short phrases only | in place |
| F-27 | discussion cut; §9.4 trimmed; §9.5 kept | `discussion.tex` | in place (2.74 pp) |
| F-28 | binding preamble code §7 | `preamble.tex` (`\emergencystretch`, `\status`, `\src`, no-op breaks, `\crefabbrev`, aliases); intro "small grey note" | in place |
| F-29 | `tab:ver:corrections` rows point to the new homes | App H (incl. `rem:pa:sdpcrefuted`, `rem:exp:refuted`, r6 qualifier) | in place |
| F-30 | no process vocabulary in intro and discussion running text | grep outside `\src`: only the decided §1.5 sentences and the binding item 10 remain | in place |
| F-31 | glosses at first use; Gold's languages as $\mathcal L$ | intro: generator class, ω-gap, root split, assigner, DTRC, instance union, parameters admissible | in place (DT° gloss made precise, FC-3) |

### 1.2 model-ident-sound (20: M-01, M-02 fatal)

| id | found in | status |
|---|---|---|
| M-01* | `def:model:scores`: §10.M1 verbatim; `tab:model:likelihoods` no longer equates L_ε and S_nc | in place |
| M-02* | `sound.tex` after `rem:sound:e4`: §10.M2 verbatim | in place |
| M-03 | `rem:model:graded`: §10.M8 verbatim; App A carries the r6 numbers with the 570-formula qualifier | in place |
| M-04 | `prop:ident:spare`(c) finite-χ² hypothesis; "span but outside the convex hull … not covered"; BF^σ_n; app-ident sketch names the quadratic expansion | in place |
| M-05 | `rem:sound:vacuous` (App D): L0 / affine-in-w, "under L1 … plausible but not proved"; proof points to the affine-slice argument of `rem:ident:exact`; §5.4 pointer keeps the qualifiers | in place |
| M-06 | `rem:sound:tight` (App D): "for d = ∞ only" with the {a, a→b} counterexample; §5.2 pointer | in place |
| M-07 | `rem:ident:x5` (App C): §10.M6 text and status; §4.3 pointer | in place |
| M-08 | `thm:sound:shrink` pool version; `rem:sound:lumps` "No contradiction with the pool version", `\Rreg(n,8)` | in place |
| M-09 | `tab:ident:c2`: −0.00, 41.0, 481.9, 4921.9, 49353.3; caption "(K−1)/2 … in both cases" | in place |
| M-10 | trichotomy is §2.7 in `model.tex` (all nine labels there); `app:sound:tri` in `app-model.tex`; F_{1/2}; questions answered next to their examples | in place |
| M-11 | `tab:model:calculi`, `lem:model:a4`, `prop:model:max` and the Elias-γ details in App A; α sentence after `def:model:lone`; pointer keeps "the maximum can break a tie inside the generator class" | in place |
| M-12 | `rem:model:subcrit` in App A; `rem:ident:exact` four lines with "(an earlier version claimed more; …)"; refuted parts of `rem:sound:hyp` in App D | in place |
| M-13 | process vocabulary removed from running text | in place after FC-6 ("the referee's runs" in `ex:sound:constant`). Kept as binding: "pre-referee sentence" in §10.M8. |
| M-14 | lengths: model 5.54 (cap 5.75), ident 5.16 (cap 5.25), sound 3.61 (cap 3.75) | in place |
| M-15 | canonical homes; app-ident "E8 windows" deleted; c4 run and spare costs cited, not repeated | in place |
| M-16 | spare template, ω-gap, KT, H_k/Acc_k, SeenQ, T_E/T_N glossed at first use | in place |
| M-17 | $\mathcal L_k$, BF^σ_n, F_{1/2}, W*_d, `\crefabbrev` (grep: no bare W^*, R_{1/2}, H(s)) | in place |
| M-18 | §2.6 keeps the variant and weighting quotations | in place |
| M-19 | `model.tex` §2.1: "Q has no axiom about <; it is Σ1-complete for <-free Σ1 sentences" | in place |
| M-20 | app-ident and app-sound openings point to `app:ver:process` | in place |

### 1.3 Issues not fully met (left open; need a content decision)

* **F-25 / DECISIONS §2, intro length.** The intro is 4.00 pp against a target of 3.5 and a cap of 3.75.
  * The question and the binding short-answer box take about 1.3 pp; the plan assumed +0.45 pp for the box.
  * The model heading sits at the top of p. 7 after about four blank lines on p. 6.
  * Getting under the cap would mean cutting about six lines of decided content: the 3×2 table, the answers, or §1.4–§1.5.
  * The main text as a whole is within its hard cap (41.39 against 41.5).
* **DECISIONS §2, appendices.** The appendices take pp. 47–127, 81 pp against a cap of 66:
  * A 8, B 12, C 11, D 6, E 7, F 13, G 12, H 12.
  * All four groups moved material into their appendices as decided, and most also moved more for length. No group deleted enough duplicates to offset this.
  * Meeting the cap needs a separate pass that deletes appendix text (duplicate computations, repeated tables). That is a content decision, so it is not made here.
* **C-18 (minor, F-32).** The optional "when the data are drawn from the model" was not added to the abstract, because it would exceed 250 words. The qualifier is in short-answer item 5 and A2.

### 1.4 univ-time (19: U-01, U-02 fatal)

| id | found in | status |
|---|---|---|
| U-01* | §3 opening (§10.U1); `sec:univ:never` and `thm:univ:B` retitled; "Not covered: L1^sel with a background …" paragraph with w_e = wc/(1−w+wc); proof-idea mechanism sentence; sentence after `prop:univ:B2`; §3.9 good-version text | in place |
| U-02* | `thm:univ:B` (B1), (B3) verbatim (equality conditions; Herbrand); App B proof uses Herbrand | in place |
| U-03 | `prop:univ:hanni` (App B) §10.U4 text; §3.5 pointer repeats the conclusion | in place |
| U-04 | `rem:time:summary`(1) | in place |
| U-05 | `rem:time:summary`(2): over PA, Σ_n-sound, open for merely consistent assigners | in place, with the recorded "acceptance part" deviation (correct; U-27) |
| U-06 | `rem:time:summary`(3); status string | in place, with the recorded added hypothesis "consistent with Γ_{f_X}". This is correct: it is a hypothesis of `thm:time:ntime` and `cor:time:hard`. |
| U-07 | `rem:time:upper` (App E) §10.U7; status | in place |
| U-08 | `prop:univ:open`(d) restricted to finite classes; "not proved" sentence for countable classes | in place |
| U-09 | `prop:time:lonesize`: 12.77 + 12.21k nats (12.206 per round) | in place |
| U-10 | §6.2 Acc_f and Rej_f without <; `prop:time:twosorted` status; App E proof | in place |
| U-11 | §3 opens with the verdict; `thm:univ:odds` displays the formulas plus the 0.77 / 0.23 sentence; `tab:univ:odds` in App B; `tab:univ:c2` in §3.2 | in place |
| U-12 | "faithful" defined before `thm:univ:omega`; head status; (d2) inline status; `prop:time:single` assumption moved into the statement | in place |
| U-13 | §6 opens with the collapse quotations, then `rem:time:summary`; the four L1 results in App E with the pointer | in place |
| U-14 | lengths: universal 6.46 (cap 6.5), time 4.57 (cap 4.75) | in place |
| U-15 | `rem:univ:detour`, `rem:univ:openrefuted`, `prop:time:lonesize` ≤ 4 lines; "(pre-referee … m1)" deleted | in place |
| U-16 | no "track", "brief" or "referee" in running text of `universal.tex` or `time.tex` | in place |
| U-17 | question not re-quoted in §3; collapse quotations only in the §6 opening | in place |
| U-18 | Mem(D_n) defined at first use; DirMult only in `prop:ident:splitlzero`; ω-gap and spare slot glossed | in place |
| U-19 | E1 paragraph canonical; E3(a) one clause; Bel ≈ 0.69 pointer; `rem:univ:mdl` ∀xφ-specific; `rem:time:e7` canonical | in place |

### 1.5 pa-exp (22: P-01, P-02 fatal)

| id | found in | status |
|---|---|---|
| P-01* | `prop:pa:must`(c) (App F) §10.P1 verbatim; the F_0 clause and "score 1 unless refuted" removed from the proof; (b) "associativity alone 76.9 > 72" | in place |
| P-02* | `prop:pa:wellspec` §10.P2 sentence and status | in place |
| P-03 | β_ax in `def:pa:lsch` and `prop:pa:memo`; `tab:pa:theorems` caption; Answer (3) "30–123 bits per symbol against β = 4.52" | in place |
| P-04 | `ex:pa:skel` (App F) §10.P4 text (42838.5, 43040, 164 templates, +2.0) | in place |
| P-05 | `rem:pa:e3b` "in this pool … about 590 bits behind … would lose only polynomially"; `tab:exp:e3b` caption note | in place |
| P-06 | `tab:pa:failures` F3 cell verbatim | in place |
| P-07 | `rem:pa:zf` (App F) last sentence; §7.2 pointer keeps the conjectured reverse overheads | in place |
| P-08 | §7.4 "Answer." §10.P8 | in place |
| P-09 | Kraft status "proved for β ≥ log₂(alphabet size)"; 4.8–7.3% and the 3% under-charge (App F); `prop:pa:gibbs` example | in place |
| P-10 | `rem:pa:pointwise` §10.P10 and status; §7.5 sentence; `rem:pa:shift` status | in place |
| P-11 | `sec:pa:answer` §10.P11; last sentence deleted | in place |
| P-12 | `prop:exp:exact`(d) §10.P12 and status | in place |
| P-13 | `prop:pa:occam` status | in place |
| P-14 | App F "3.4–7.5% higher" (recomputed from `c6_theorem_data.out`: min 4219.8/4081.9 = +3.4%, max +7.5%) | in place |
| P-15 | App F Euler paragraph "0.0049 … 0.0727 … false k < 200"; the reviewer's 0.0737 absent | in place |
| P-16 | `experiments.tex` §8.2 cites `rem:ident:x5`; "Every generator has one component, so …" absent | in place |
| P-17 | §8 restructured; `tab:exp:summary`; `app:exp:results` holds E1–E8 and four tables; `prop:exp:comm` in `pa.tex` only; `rem:exp:refuted` in App G | in place |
| P-18 | code names NAIVE, DPC, RDPC, CF, u7, G2, G3 absent from `pa.tex` running text (grep); SDPC defined in place | in place |
| P-19 | lengths: pa 6.66 (cap 6.75), experiments 2.65 (cap 3.0) | in place |
| P-20 | first-version sentences deleted; `rem:pa:sdpcrefuted` (App F); `rem:exp:refuted` (App G); `rem:pa:merge` cites `tab:pa:merge` | in place |
| P-21 | process vocabulary removed from running text | in place. Kept as binding: "the referee's 904 triples" in §10.P12. |
| P-22 | motive, DTRC, T_{𝓛∞}, Q⁻, Q_e, SeenQ and Trim glossed; pool names in the `tab:exp:summary` caption | in place |

---

## 2. Abstract, intro and discussion against the body

Each claim was read against the result it cites, for the same scope (hypotheses, calculus, weights, class) and the same status.

### 2.1 Checked and consistent

* **Abstract.** Each sentence was checked against its source:
  * size principle: `lem:model:size`;
  * the three odds regimes and the non-logical exception: `thm:univ:odds`, `thm:univ:B`, `prop:univ:B2`;
  * prediction confirmed, derivability tends to a prior share or 0: `thm:univ:confirm`, `thm:univ:omega`;
  * fixed weights identify theorems, not axioms: `thm:ident:doob`, `cor:ident:prior`, `cor:ident:deductive`;
  * finite classes go to the best-fitting generator: `thm:ident:kl`, `ex:ident:weaker`, `ex:ident:escape`;
  * time penalties and symbol size: `rem:time:summary`;
  * provenance: App H.
* **Short answer, items 1–10.**
  * Item 2: `prop:model:whichsize`(b) needs consistency with the data, and "a consistent strengthening" says so.
  * Items 4–5: 1/(1+c) = 0.769 and c/(1+c) = 0.231 at c = 0.3 (`thm:univ:odds`); shares 0.030–0.484 (`tab:univ:share`, universal notes).
  * Item 8: ratio column 5.8–24.2 of `tab:pa:theorems`, given as "about 6 to 24".
  * Item 9: matches `rem:time:summary`, including "acceptance half".
  * Item 10: matches App H.
* **Intro §1.1–§1.2.** Hänni's variants, trichotomy and collapse argument match §2.6, §2.7 and §6. The supports of L0 and L1 match `lem:model:lone`(c) and `prop:ident:splits`.
* **A1:** `prop:model:compute`.
* **A2:** `thm:univ:B`, `thm:univ:odds`, `prop:univ:B2`, `thm:univ:omega`, `prop:univ:noguard`.
* **A3:** `prop:time:notemplate` (acceptance part), `prop:time:collapse`, `rem:ident:mdl`.
* **A4:** `rem:pa:streams`. Six library theorems; Q + library is the MAP at u = 0 and is strictly weaker (pa notes §3.5).
* **A6 and the 3×2 table:** `cor:ident:prior`, `prop:ident:sep`, `cor:ident:deductive`, `thm:ident:limit`(b), `tab:ident:misspec`, `sec:pa:answer`.
* **A7:** `thm:sound:fixed`, `thm:sound:avg`, `thm:sound:shrink`, `prop:sound:misspec`, `ex:ident:weaker`, §2.7.
* **§1.4 (i)–(vi):** `rem:exp:limits`, `thm:ident:kl`, `prop:ident:splitlone`(d), `thm:ident:limit`(c), `conj:time:poly`, `prop:univ:noguard`(d), `prop:univ:memo`, and the `sec:pa` caveat (i).
* **Discussion §9.1.**
  * Templates: binding F3 text; `prop:time:notemplate`, `prop:pa:refl`, `prop:time:collapse`.
  * Derivation-length prior: `prop:time:lonesize`, `rem:model:graded`, `prop:pa:memo`, `prop:univ:quant`(c).
  * Time penalty: `prop:time:cheap`, `cor:time:log`, `conj:time:poly`.
* **Discussion §9.2:** binding F4 and F5 texts; each cited result says what is quoted.
* **Discussion §9.3:**
  * `prop:time:fiall` is Hänni's "easy" direction, checked against his notes;
  * `thm:time:equiv` holds only in the semimeasure convention, which the text says;
  * `prop:time:single`;
  * `rem:sound:e4`(C1).
* **Discussion §9.5 and closing:** match `app:ver:sketches` and the body.

### 2.2 Mismatches found and fixed

| # | where | mismatch | fix |
|---|---|---|---|
| 1 | `ident.tex`, opening of §4 (a section summary) | "Misspecified, the posterior goes to the best-fitting generator" drops "in finite classes" (`thm:ident:kl`; DECISIONS §9.4). The full class is open (`rem:ident:fullclass`). | added "in finite classes" (FC-1) |
| 2 | intro A5 | "a decidable hard assigner forces every theory with membership time within a polynomial bound …" reads as one assigner for all bounds. `cor:time:hard`(b) gives one X per exponent e; a single X for all e only as a proof sketch under a growth condition. | "for each polynomial bound on membership time, a decidable hard assigner forces every theory within that bound …" (FC-2) |
| 3 | intro §1.2 | DT° glossed as "formulas whose metavariables take metavariable-free arguments", which is only the general template condition. DT° also needs a pattern occurrence of each metavariable (`sec:model:syntax`). | "(formulas with metavariables, in AS's class DT°)" (FC-3) |
| 4 | discussion §9.3 | "his time-bounded note has an analogue for derivation-bounded inducers" states as fact what `conj:time:polytime` gives as a conjecture, not written out | "plausibly has an analogue … (\cref{conj:time:polytime})" (FC-4) |
| 5 | `tab:intro:verdicts` (the intro's verdict table, now App H), H4(e) | "without a guard the ω-step is not taken under L1". The body (`rem:univ:openrefuted`, `prop:univ:noguard`) says it *need not* be taken: it depends on the class, and over Q with deep splits the computed value is 1.000. | "need not be taken" (FC-5) |

---

## 3. Spot check of 31 claims against the sources

Every number was compared with the source output named. Where the paper gives a derived value (a ratio, slope or range), it was recomputed from the source columns.

| # | section | claim in the paper | source | result |
|---|---|---|---|---|
| 1 | §3.2 | `tab:univ:c2`: all 30 cells (L_cl, μ_T, L1 rows; root split; over-general .926/.307/.022, over-specific .011/.110/.067; F_0 0.674) | `universal/checks/c2_odds.out` (L0-closure, L1 = μ_T, L1-norm = L1) | agrees |
| 2 | §3.5; intro | share of H_∀: 0.333 (symbol count, π₁), 0.200 (π₂), 0.484 (experiments), 0.030–0.042 (pa codes); intro "3–48%" | universal notes, table l.899–904 | agrees |
| 3 | §3.4 | 1 − π_n(G) = 0.37 at n = 10⁵⁰, dyadic family with prior ∝ 1/(j(j+1)), π₀ = 0.01 | universal notes l.657–660 (c4) | agrees |
| 4 | §3.6 | `rem:univ:openrefuted`: 0.697 at n = 100, 0.000 from n = 1000 | universal notes l.968, l.1092 (c8) | agrees |
| 5 | §3.2 | `rem:univ:detour`: 0.15553; 9139-point grid ≤ 0.925, normalised ≤ 0.48 | universal notes l.373–375, l.1496 | agrees |
| 6 | §3.2 | `prop:univ:B2`: h(v) = c/(c+v(1−c))², threshold √c/(1+√c); computed to 4·10⁻⁴ at n = 10⁵ | universal notes Prop B2 (l.547–568), l.1586 (c10 (b)) | agrees |
| 7 | §3.6, §3.8 | W_o = 0.1252 nats at (c, g, ρ, q) = (.3, .2, .1, ½); ln((1+c)/c) = 1.466 | universal notes l.1032 (κ_o); arithmetic | agrees |
| 8 | §4.4 | `rem:ident:e8`: split loses 1.43 (L1) and 1.51 (L0) bits per doubling, n = 256…4096; skewed usage wins 0.202 against 0.074 bits per datum, n = 1024…4096 | recomputed from the tables of `code/results/e8_split_l1.md`: (−12.98+7.27)/4 = −1.43, (−12.86+6.82)/4 = −1.51, 620.52/3072 = 0.202, 227.54/3072 = 0.074 | agrees |
| 9 | §4.5 | nested spare exponent −0.251 ± 0.002 on n = 10²…10⁸; 14 stages of Gold's text | `code/results/e5_gold.md` (−0.2508, s.e. 0.0017; stage table) | agrees |
| 10 | §4.6 | `ex:ident:escape`: 2000/2000 runs, median 17 data | model notes l.465 (`c4_ville.out` Part 2) | agrees |
| 11 | §5.2 | waiting prover 400/400, every-round prover 11/400 | model notes l.546 | agrees |
| 12 | §5.4 | `ex:sound:constant`: 0.977–0.997 (ε = 10⁻⁵), 1.000 (10⁻⁶), 0.003–0.010 from the prior, 0/300 with the shrinking threshold | model notes Ex 4.9 table; `experiments/checks/check_fixed_weight.out`; `tab:sound:constant` | agrees |
| 13 | §5.5 | `rem:sound:e4`: (A) 9–46 times below δ′ (recomputed 8.9–46.3), 20/20 on selected data; (B) 0/100, peaks 0.45 and 0.53; (C1) 100/100, first acceptance at the first mistake in 90/100; (C2), (C3) 0/100 | `code/results/e4_ville.md`; experiments notes l.1018, l.1497 | agrees |
| 14 | §5.5 | `rem:sound:lumps`: 5 of 25 seeds at n = 8 or 16, never from n = 32; T* costs 226.2 bits | `code/results/e2_pa.md` (accepting-seeds table; pool table) | agrees |
| 15 | §7.6 | `rem:pa:e2`: median datum 55; ≥ 0.95 from n = 32, 64, 128 in 5, 15, 5 seeds; mean 0.751 (n = 64), 0.996 (n = 512); false spare 0.004 | `e2_pa.md`; experiments notes l.803–807 | agrees |
| 16 | App C; §8.3 | unsound MAP at n = 8 in 7/25 seeds; acceptances fell from 19 to 5 of 25 seeds | `e2_pa.md` (legacy vs causal table) | agrees |
| 17 | §6.5 | `prop:time:lonesize`: −ln Pr(tree) = 12.77 + 12.21k nats, 12.206 per round; size 2^{k+3} − 1 | `model/referee_code/r2_l1_size.out`; `model/checks/c12_l1_size.out` | agrees |
| 18 | §6.6 | `rem:time:e7`: τ = 1 unsound MAP in 9 vs 7 seeds; τ = 4: 0.372 vs 0.256, 5 vs 2 seeds; λ = 2: 22 seeds, 2·10⁻⁴ vs 0.004 at n = 512; log₂(78/2) ≈ 5.3 | `code/results/e7_prior.md` (T* size 77, bare ?P size 1) | agrees |
| 19 | §7.4; intro | `tab:pa:theorems`: all 42 cells; ratio 5.8–24.2; β* 30.5–122.9 | `pa/checks/c6_theorem_data.out`, T_Ind rows | agrees |
| 20 | App F; §7.4 | decodable code +3.4–7.5% (recomputed from the D, D(dec) columns); associativity 17·log₂23 = 76.9 > 72 | `c6_theorem_data.out`; arithmetic | agrees |
| 21 | §7.5 | `ex:pa:narrow`: +230.8 (n = 100), +174.6 (n = 3000), −11.5 bits per doubling, crossover 2^26.7; identity = code | `pa/checks/c8_narrow.out` | agrees |
| 22 | §7.5; App F | `ex:pa:skel`: 112 skeletons by n = 3000, 119 templates, +42838.5 bits, prior part 43040; 157 skeletons, 164 templates, +2.0 per doubling | `c8_narrow.out`; pa notes l.863–870 | agrees |
| 23 | §7.2 | `rem:pa:usage`: 0.600, 0.757; 81 + 86 bits; 0.29 bits per citation; 1–12 uses; 5·10⁻⁴ | pa notes l.280–290 | agrees |
| 24 | §7.5 | `rem:pa:e3b`: 0.998–1.000; T* 0.988 in 4 of 5 seeds at n = 64 (mean 0.790); frag-atoms 1.000 from n = 1024; 2·10⁻¹⁷⁸; about 590 bits (recomputed 590.6) | `code/results/e3_misspec.md` (E3(b) tables) | agrees |
| 25 | §7.6 | DTRC: ≥ 1 − 6·10⁻⁶ from n = 100; ≥ 1 − 1.6·10⁻⁵ from n = 10 with negatives; ≥ 1 − 10⁻⁹⁶; δ ≥ 3·10⁻¹³ | pa notes l.936–962 | agrees |
| 26 | §7.3; §4.4 | `prop:pa:detour` 369.2–488.9 bits; G1 split margins 17242–274656 bits (NAIVE, PC, DPC, CF); SDPC +762 at n = 256000 | `pa/checks/c2_detour.out`; pa notes table l.398–404 | agrees |
| 27 | App F; intro A4 | `rem:pa:streams`: six library theorems; Q + library MAP at u = 0; Q + T_Ind + library at u = 0.1, 0.5 from n = 10 | pa notes §3.5 (l.602–620) | agrees |
| 28 | §8.1 | code lengths 17.1, 17.2, 226.2 bits; largest bounded mass 8·10⁻¹⁴ | experiments notes l.215, l.673 | agrees |
| 29 | §8.1 | `prop:exp:exact` checks: 500 sums and 400 marginals to 1.4·10⁻¹⁴; 904 coefficients to 2.1·10⁻¹⁴; 21 unit tests; 65 and 43 theories excluded | experiments notes l.359–362, l.419, l.669; `code/results/pytest.txt` (21 passed) | agrees |
| 30 | §3.2; §7.2 | E1: chain factor exact to 1.1·10⁻¹¹ bits; L1^sel_cit limits 0.484 and 0.269. E6: provers' prior share 0.088 | experiments notes l.699–701; `e1_universal.md`; `e6_equivalent.md` | agrees |
| 31 | App A | `lem:model:size` computed: KL 2.618 on the truncated grammar; simulated 3.81, 4.19, 3.94 nats against 3.894 | `model/checks/c1_size_principle.out` | agrees |

Statuses checked along the way all match the cited items, including:
* `thm:univ:omega` with (d2) inline;
* `prop:univ:noguard` with (c) a proof sketch and (d) computed with a limit conjecture;
* `prop:ident:spare` with (b), (c), (d2) proof sketches;
* `rem:sound:vacuous`, `prop:pa:wellspec`, `prop:exp:exact`, `rem:time:summary`, `cor:time:hard`.

No error was found, so no fix was needed in this step.

---

## 4. Full build

`cd paper && flock /tmp/claude-0/paper-build-ai.lock ./build.sh`, after all changes:

```
LaTeX errors: 0
Undefined references: 0
Undefined citations: 0
Multiply defined labels: 0
Overfull hboxes >10pt: 0
Pages: 127
```

* Overfull boxes: one of 0.57 pt, in App H (`app-verification.tex` l.153, the "universal" row of `tab:ver:writing`). None above 10 pt.
* Other warnings: one font-shape substitution (T1/lmr/bx/sc, from `\DTRC` in a bold context).
* A baseline build before any change gave the same counts.

**Pages** (127 in all):
* Front matter: pp. 1–2 (title, abstract, contents); the main text starts on p. 3.
* Main text: pp. 3.00–44.39, **41.39 pp**, against a target of 40 and a hard cap of 41.5.
* References: pp. 44.39–47.
* Appendices: pp. 47–127, **81 pp**, against a cap of 66.

| section | span (pp.) | target | cap | |
|---|---|---|---|---|
| 1 intro | 4.00 (3.00–7.00) | 3.5 | 3.75 | **over cap by 0.25** |
| 2 model | 5.54 (7.00–12.54) | 5.5 | 5.75 | |
| 3 universal | 6.46 (12.54–19.00) | 6.25 | 6.5 | |
| 4 ident | 5.16 (19.00–24.16) | 5.0 | 5.25 | |
| 5 sound | 3.61 (24.16–27.77) | 3.5 | 3.75 | |
| 6 time | 4.57 (27.77–32.34) | 4.5 | 4.75 | |
| 7 pa | 6.66 (32.34–39.00) | 6.5 | 6.75 | |
| 8 experiments | 2.65 (39.00–41.65) | 2.75 | 3.0 | |
| 9 discussion | 2.74 (41.65–44.39) | 2.5 | 2.75 | (2.76 before FC-7) |
| **main text** | **41.39** | 40.0 | 41.5 | |

| appendix | pages |
|---|---|
| A model | 47–54 (8) |
| B universal | 55–66 (12) |
| C ident | 67–77 (11) |
| D sound | 78–83 (6) |
| E time | 84–90 (7) |
| F pa | 91–103 (13) |
| G experiments | 104–115 (12) |
| H verification | 116–127 (12) |
| **all** | **81 (cap 66)** |
