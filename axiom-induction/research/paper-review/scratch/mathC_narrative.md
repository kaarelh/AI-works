# Review C: mathematics and experiments in Sections 7 (PA and ZF) and 8 (experiments)

**Scope.** This review covers `paper/sections/pa.tex`, `app-pa.tex`, `experiments.tex` and `app-experiments.tex`. I
checked every statement and proof against the final track records (`research/tracks/pa/notes-final.md`,
`research/tracks/experiments/notes-final.md`, their referee reports and `checks/*.out`) and on its own terms. I checked
the equivalence claims against the literature, every quoted number against `code/results/*.md` and `*.json` and the pa
`.out` files, and the conclusions against the evidence behind them (seeds, pools, hand-picked candidate sets).
I did not edit the paper, and I ran no git command that changes repository state. My scripts and their outputs are in
`research/paper-review/scratch/` under the prefix `mathC_`.

**Verdict.** The numbers are in very good shape. Every table entry I compared, several hundred numbers across all the tables in the four files, agrees with the
results files and check outputs, apart from two small range or truncation slips (C14, C15), one bound violated by rounding (C34), and one place
where the paper quotes a rate other than the one in the results file without saying which (C17). Everything I re-ran
reproduces exactly. Most of the mathematics checks out by hand: the three forms of induction, the recursion
conventions, the lower bound, the reflection argument, the read-once dichotomy, the atomic-fragment counter-model, the
redundant-Q models, the commutativity counter-model, the Occam identity and its expansion, the spare-slot formula, and
all the slopes and crossovers.

The problems are of three kinds.

* **Two false mathematical statements**, both in parts the appendix lists as added after refereeing:
  * the F_0 example in `prop:pa:must`(c) (C1);
  * the "polynomial decay" of PA ∪ S under the fixed-weight setting W in `prop:pa:wellspec` (C2).
* **One vacuous threshold.** `prop:pa:memo` uses one β for the prior and for the proof text. With a single β,
  memorising wins at every β, so the threshold β < β\*(s), and item (3) of the Answer paragraph that relies on it,
  only make sense with a separate axiom-prior rate (C3).
* **Framing that outruns the evidence:**
  * the summary row F3 of `tab:pa:failures` (C6);
  * the ZF "exactly when" (C7);
  * the headline "direct uses of axioms" answer (C11);
  * the mixing of the full-sum L1 with the two-part code L_sch in the Answer paragraph (C8);
  * the E3(b) mass "2·10⁻¹⁷⁸ on T\*-equivalents" (C5). One natural PA-equivalent theory missing from the pool changes
    this mass to 2.2·10⁻¹⁴ in all five seeds. It is verified by re-running the experiment with that theory added.

The issue count is 2 fatal, 13 major and 22 minor. Four of the majors are one-line fixes: C13 is a status-line
hypothesis, C14 and C15 are wrong numbers that change no conclusion, and C9 is a stated-but-unmet Kraft condition.

## 1. Method and reproduction log

| what | how | result |
|---|---|---|
| unit tests | `cd code && python3 -m pytest -q -p no:cacheprovider tests` (no cache or bytecode written) | 21 passed (28.7 s) |
| pa checks | copied `research/tracks/pa/checks/*.py` to `scratch/mathC_pa_checks_copy/` and ran them there (they write `name.out` into the working directory) | `test_nd`, `c1_costs`, `c2_detour`, `c3_tower`, `c4_bdtrc`, `c5_euler`, `c2b_cf`, `c6_theorem_data`, `c7_rulecode`, `c8_narrow`, `c9_shift`, `c2_mdl` (about 25 min): all twelve **byte-identical** to the saved `.out` |
| E6, E8 | `scratch/mathC_checks/rerun_e6_e8.py` calls `run()` in memory for all seeds and compares with the saved JSON | E6: 2970 numbers, largest difference 0.0; E8: 20 runs, largest difference 0.0 |
| E1 per-seed claims | `scratch/mathC_e1_json.py`, `mathC_e1_table.py` | worst-run "first n" is 16/16/16/16/8/16 as in `tab:exp:e1`; held-out mass ≥ 0.99901 from n = 8 except open/L0; Mem@8 ≤ 2.419·10⁻¹²; over-general@8 ≤ 6.99·10⁻⁵; all caption claims about the L0 rows hold |
| E2 per-seed claims | `scratch/mathC_e2_json.py` | last needed axiom at datum 20–97, median 55; equivalence onset at n = 32/64/128 in 5/15/5 seeds; slopes 4.24, 0.49, 0.25; accepting seeds 1, 4, 11 (n = 16) and 14, 17 (n = 8) |
| E3(b) per-seed claims | `scratch/mathC_e3b_json.py` | T\* has 0.988 at n = 64 in 4/5 atomic seeds; frag-atoms has 1.0 from n = 1024; root-skew frag-observed −1387…−1509 bits, all as stated |
| E3(b) pool dependence | `scratch/mathC_checks/e3b_pool_extension.py` adds Q + {T_=, T_<, T_Ind} to the pool and re-runs atomic, seeds 0–4 | T\*-equivalent mass 2.2·10⁻¹⁴ at n = 2048 (paper: 2·10⁻¹⁷⁸), see C5 |
| theorem data with one β | `scratch/mathC_checks/memo_single_beta.py` uses the track's library through the copy | memorising wins at every β for all 18 pairs (C3); decodable overhead 3.4–7.5% (C14) |
| arithmetic | `scratch/mathC_checks/arith_checks.py` | lower bound 53.08/44.03; break-even 0.600/0.757 (0.609/0.765); spare 19.03/19.82; slopes −11.5, +2.0 (−20.5 for the 119-template theory), −5, −1; crossovers 2^26.7, 1.2·10⁸; E4 exact (1−u)^t\* and ratios 8.9–46.3; E6 prior share 0.0883; E8 rates 0.202/0.074 (marginal) against 0.1995/0.0731 (mean); Euler false-k mass 0.0049 and **0.0737** (C15) |
| counter-models | `scratch/mathC_checks/models_check.py`, written independently of `check_models.py` | all six X11 models falsify exactly their Q_i; the X12 model satisfies the closed instances of S_ab, M_x and M_y and 14400 one-parameter S_ab^open instances, and refutes A_xy |

## 2. Section 7 (pa.tex, app-pa.tex)

**Setting and caveats (§7.1).** Caveats (i)–(iii) are the right ones and are honoured almost everywhere. Two
qualifications are missing:

* Def `pa:lsch` uses one β for the prior and for proof text. This matters for the theorem-data threshold (C3).
* The "prefix code, so Kraft holds (proved)" claim needs β ≥ log₂|alphabet|. The track notes admit that β = log₂ 23
  is below this (about log₂ 25) (C9).

**Equivalent axiomatisations (§7.2).** I re-derived (A), (B), (C1) and (C2) of `prop:pa:equiv` by hand, and they are
correct:

* (A) uses Q3, Q4, Q5 and Dlt to get w < Sw.
* (B) uses Q1 for the base and Q2, Q3, Q4, Q5 for the step.
* (C1) and (C2) are classical contrapositions.

So PA_Ind, PA_CVI and PA_LNP have the same theorems over B = Q1–Q5 + Dlt, as the literature says for the full schemas.
The appendix's remark on fragments is accurate in substance but worded misleadingly: the proofs use BΣ_n, which IΣ_n
proves (C22). The parameter-free failures cite Kaye–Paris–Dimitracopoulos (1988) correctly.

`prop:pa:lower` checks out:

* The symbol counts are right: |CVI(P)| = 18 with a 13-symbol antecedent, and |Ind(P)| = 16 with an 11-symbol
  antecedent.
* So is the arithmetic: log₂10 + 11β = 53.08 and log₂10 + 9β = 44.03.
* The chain argument is sound. The side remark "no instance has a ∀-prefix" is unnecessary and inaccurate with
  closures (C33).

The break-even ratios and "ahead after 1–12 uses" match `c1_costs.out`. The 5·10⁻⁴ threshold in `rem:pa:usage`(iii)
is library-specific; the proved lower bounds allow up to about 7·10⁻³ (C36).

`prop:pa:recursion`: I re-derived all four inductions by hand, and they are correct.

ZF (`rem:pa:zf`, `tab:pa:zf`):

* Separation from the image form of Replacement in pure logic, Replacement from Collection, and Foundation from
  ∈-induction are standard, and the checked derivations confirm them.
* The citations are correctly reported: Zarach (1996) and Gitman–Hamkins–Johnstone (2016) for Collection failing
  without Power Set, and Kaye–Wong (2007) for ∈-induction needing transitive containment.
* "Open to us without Foundation" is an honest hedge.
* The closing "exactly when they are used directly" depends on conjectured reverse overheads and drops the notes'
  qualifier (C7).

**MDL in PA (§7.3).** `prop:pa:chain` is correct. `prop:pa:occam`(a) is correct, and I re-derived the Stirling
expansion in (b) term by term. Part (c) follows from (b), so it inherits (b)'s growth condition, which its status line
omits (C13). The slopes are −1, −2.5 and −3 bits per doubling. The crossover 2^780 is right. Every number in
`tab:pa:mdl` matches `c2_mdl.out` and `c2b_cf.out` as quoted in the notes.

`prop:pa:detour` is right:

* (a) Each wrapper is equivalent to P and has the required root; `c2_detour.out` reproduces the costs.
* (b) Q + T_= ⊆ IOpen, and Shepherdson's model of IOpen has x² = 2y² with y ≠ 0.

**Theorem data (§7.4).** The table numbers match `c6_theorem_data.out`. `prop:pa:gibbs` is correct, but its
"e.g. ℓ = β|s|" needs the alphabet condition (C37). `prop:pa:wellspec`:

* The Q ∪ S part is correct: PA is not finitely axiomatisable (Ryll-Nardzewski 1952).
* The last sentence is false in setting W (C2).

`prop:pa:must`:

* (a) and (b) are correct, though one library theorem already suffices in (b) (C24).
* The F_0 example in (c) is wrong (C1).

The Answer paragraph:

* Item (1) cites full-sum L1 results inside an L_sch discussion (C8).
* Item (3) is vacuous under the paper's single β (C3).

`rem:pa:streams`: the MAP claims hold from n = 10 for u > 0 (C23).

**Th(ℕ), the IΣ_n chain, narrow practice (§7.5).** The following are correct:

* `prop:pa:thn`, `prop:pa:refute`, `prop:pa:regret`;
* `prop:pa:refl`: the two-case argument is complete;
* `lem:pa:motive`;
* `prop:pa:isigma`(a): it uses IΣ_{n+1} ⊢ Con(IΣ_n), or equivalently the reflexivity of PA for finitely axiomatised
  subtheories, plus Gödel II and Doob;
* `prop:pa:readonce`. Part (a) needs one sentence of induction to justify forcing the sibling subtrees (C32). Part (b)
  is correct; take k ≥ 1.

`rem:pa:pointwise` claims more than it proves for the posterior when inconsistent theories are present (C10).

`ex:pa:narrow` is fully reproduced: the slope is −11.5 and the crossover 2^26.7. `ex:pa:skel` attaches the slope of
the 164-template covering theory to the computed lag of the 119-template theory (C4).

`prop:pa:atomic` is correct:

* The parameter-elimination trick for T\* ⊇ PA works.
* Shepherdson's model with < read as the empty relation satisfies Q + {T_=, T_<} and refutes σ.

`prop:pa:redundant`: the models are verified (§1).

`prop:pa:fragments` is correct.

**Bayesian DTRC (§7.6).** `prop:pa:spare` is exact: 19.03 and 19.82. Every entry of `tab:pa:dtrc`, the masses
(2.607·10⁻⁵³, 2.204·10⁻¹³, 5.808·10⁻⁶, 1.595·10⁻⁵ and 7.679·10⁻⁹⁷) and the threshold δ ≥ 3·10⁻¹³ match `c4_bdtrc.out`.

`rem:pa:merge` and `tab:pa:rulecode` match `c7_rulecode.out` and `c4_bdtrc.out`, including the shared-code
mixed-practice values (1+f)·h(f/(1+f)). I checked the closed forms. `prop:pa:nc` and `prop:pa:incons` are correct.

**Failures and answer (§7.7).** `ex:pa:euler` is reproduced (`c5_euler.out` is byte-identical). The sizes are right
(27-symbol frame, template of 171 symbols), and so is the first composite k = 40. The ρ = 0.97 false-k mass is
truncated at k < 200 (C15). The "beyond 10⁶" estimate is consistent with a crossover near 10⁸. F3 in
`tab:pa:failures` is mislabelled "harmless for theorems" (C6). The headline answer needs scoping to broad usage laws
(C11).

## 3. Section 8 (experiments.tex, app-experiments.tex)

**Implementation and exactness (§8.1).** The Dirichlet-moment formula, the concavity upper bound and the properness of
the chain are correct. The predecessor enumeration (d1)–(d5) is plausible. The appendix honestly says that the code
does not check the hypothesis of (d3); `prop:exp:exact`(d) in the main text should say so too (C12).

The other facts here are confirmed:

* The grammar's mean offspring counts are 0.75 and 0.72.
* Kraft holds for the template prior.
* The bounded cases: E1 at most 8.43·10⁻¹⁴, and E2–E4 0 in every run (but see C27 for E6).

**E1.** Every entry of `tab:exp:e1` matches the results. The averaging over φ in the L_sel row conflicts with the
caption (C19). The exact one-bit factor (n + 0.090 and n + 1.440) and the L_sel tie match `check_x6.out`. Two small
points: the pool-size range should say "at n = 256" (C20), and the Doob citation should be to the (T, w) form, because
the pools contain Dirichlet-integrated members (C21).

**E2.** Every number in `tab:exp:e2` and `tab:exp:e2seen` matches `e2_pa.md`, and the per-seed claims match the JSON.
Item (2) attributes all five acceptances to Q-lumped or its trim; in seed 1 the accepting MAP is `skel4@16` (C16).
Item (3)'s "loses the prior difference" is accurate only from about n = 32 (C35).

**E3.** Every number in `tab:exp:e3a`, `tab:exp:e3afam` and `tab:exp:e3b` matches. Two pieces of wording overreach:

* E3(a) heavy: "deepest nesting wins" and "keeps changing" (C31).
* E3(b) atomic: the equivalents' mass 2·10⁻¹⁷⁸ is a pool artefact (C5).

The qualitative conclusion is robust: the MAP is the strictly weaker Q + {T_=, T_<} from n = 1024 in every seed.

**E4.** The exact win probability is (1−u)^{t\*} (re-derived), and the "9–46 times below" ratios are 8.9–46.3. The
(B, C) numbers and the caption's statements match `check_e4_where.out`.

**E5.** All numbers match. The quadrature slope is −0.251 ± 0.002. The 3 − log₂5 gain assumes uniform L₅ weights,
which the text does not state (C25).

**E6.** `prop:exp:comm` is correct: the model is verified independently, and (a) is right because one bound variable
plus the parameter suffice. The numbers re-run exactly. The prior share is 0.0883. One cross-reference is wrong (C26).

**E7.** All numbers match. "Slightly" fits τ = 1 but not τ = 4 (C30).

**E8.** The numbers re-run exactly. The slopes are −1.43 and −1.51. The quoted 0.202 and 0.074 are marginal rates and
should be labelled as such (C17).

**Limitations and refuted claims.** `rem:exp:limits` and `rem:exp:refuted` are accurate, apart from the seed counts
and status label in (v) (C18).

## 4. Numbered issue list

Severity: **fatal** means a false or unsupported mathematical claim, or a claim stronger than the sources. **Major**
means a missing hypothesis, wrong number, inconsistency or misleading framing. **Minor** means local wording. The same
list is in `issues-math-C.json`.

