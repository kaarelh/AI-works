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

1. **C1 [fatal]** `paper/sections/pa.tex`, prop:pa:must (line 156); proof in app-pa.tex line 97.
   * *Problem.* Part (c) gives the bare formula metavariable F_0 as an example of an "unrefuted theory with smaller prior deriving all data within d". Under the rule R_d of def:pa:refute, F_0 is refuted by the first datum: for any datum s' the sentence -s' is itself an instance of F_0, so F_0 derives -s' by a one-line citation. Whenever d covers the 11-55-line derivations required in part (b), it covers that citation. The example is false (the track notes, Prop 3.4(c), make the same mistake). The appendix proof says "either has score 1 unless refuted within d", but does not notice that F_0 always is.
   * *Evidence.* def:pa:refute (pa.tex l.29): likelihood 0 if T |-_{<=d} -s' for a datum s'; under L0, derives = has as an instance. F_0 has every sentence, including -s', as an instance. Part (b) requires d to cover derivations of 11-55 lines (c6_theorem_data.out), so d is larger than the size of a one-line citation of -s'.
   * *Fix.* Delete "the bare formula metavariable F_0" from (c), or restrict it explicitly to d smaller than the size of a citation of a negated datum. In that regime (b) fails, so say so. Keep the inconsistent-theory example, and state that its shortest derivation of a negated datum or of a negative datum must exceed d. Correct CLAIMS.md (prop:pa:must) the same way.

2. **C2 [fatal]** `paper/sections/pa.tex`, prop:pa:wellspec (line 152), last sentence; proof in app-pa.tex line 95.
   * *Problem.* "Theories PA u S (generic weights) decay polynomially, like spare slots" is false in the stated setting. The proposition is posed in setting W (def:ident:W: every theory carries one FIXED law). For generic fixed weights P_{PA u S} != P_PA, so KL(P_PA || P_{PA u S}) > 0. By the strong law the log posterior odds of PA u S against PA then fall linearly in n: the decay is exponential, at the KL rate. Polynomial (spare-slot) decay belongs to Dirichlet-integrated weights (prop:ident:spare is stated "with Dir(alpha) priors"), which setting W excludes. The appendix calls the polynomial rate "a proof sketch", but the rate is wrong in this setting, not just unproved.
   * *Evidence.* def:ident:W (ident.tex l.23) "each T carries a fixed law P_T (fixed weights)"; prop:ident:spare (ident.tex l.137) is under Dir(alpha) priors; pa notes-final §3.6 say "Their decay should be polynomial, like a spare slot (model Prop 5.5)", which mixes the two settings in the same way.
   * *Fix.* Replace with: "Under W, theories PA u S with generic fixed weights have a different law and lose exponentially, at rate KL(P_PA || P_{PA u S}). With Dirichlet weights (outside W) they behave like spare slots and decay only polynomially (proof sketch, prop:ident:spare)." Update the appendix proof and CLAIMS.md (prop:pa:wellspec).

3. **C3 [major]** `paper/sections/pa.tex`, prop:pa:memo (line 124); Answer item (3) (line 159); tab:pa:theorems caption (line 140); def:pa:lsch (line 23).
   * *Problem.* Def pa:lsch uses ONE beta both for the prior (pi(T) ~ 2^{-beta sum|tau|}) and per written proof symbol. Prop pa:memo then says memorising at the first occurrence is cheaper "iff beta < beta*(s) := (D_T(s) - l_cite)/|s|". D_T(s) and l_cite are themselves computed at that beta. With a single beta, D_T(s) = A + beta*W with W >= |s| (every derivation writes s or its matrix), so beta*(s) > beta for EVERY beta. The "iff" is then vacuous: memorising always wins, and Answer (3) ("when the axiom prior is much steeper than the proof code (beta >= beta*)") cannot happen. The threshold only makes sense with a separate axiom-prior rate beta_ax, as check c6 ("the axiom prior per symbol is below beta*") and the referee's M3 ("the axiom prior about 7-10 times steeper than the track's beta") intend.
   * *Evidence.* Independent check scratch/mathC_checks/memo_single_beta.py, using the track's own derivation library: for all 18 (theory, theorem) pairs, W ranges from 33 to 1518 written symbols against |s| = 7-17, and the non-symbol cost A exceeds l_cite. So memorising is cheaper for every single beta. Output in memo_single_beta.out.
   * *Fix.* Introduce beta_ax (prior bits per axiom symbol) in Def pa:lsch, distinct from the proof-text beta = log2 23. Restate Prop pa:memo as CL(T u {s}) - CL(T) = beta_ax|s| + Delta I - r(D_T(s) - l_cite), with D_T and l_cite at the proof-text beta. Add: "with beta_ax = beta (the default), memorising wins for every beta". Rephrase Answer (3) and the tab:pa:theorems caption accordingly.

4. **C4 [major]** `paper/sections/pa.tex`, ex:pa:skel (lines 200-202); details app-pa.tex line 141.
   * *Problem.* The example describes two different theories as if they were one ("it"). The computed lag (42838.5 bits at n = 3000, prior part 43040) belongs to the theory of the 112 skeletons seen in 3000 data (119 templates). That theory does not cover G1: 45 of the 157 skeletons are unseen, and it gets likelihood 0 under L0 when one of them appears. While it covers the data, its asymptotic slope is (119-8)/2 - 19*4 = -20.5 bits per doubling: it CLOSES IN on T*. The +2.0 bits per doubling belongs to the 164-template theory that covers G1, whose code length was never computed. The main-text sentence thus pairs a computed lag with the slope of a different, uncomputed theory.
   * *Evidence.* c8_narrow.out (B): "n= 3000 H_skel (119 templates) ... +42838.5 ... asymptotic slope -20.5 bits per doubling"; "with all of them, H_skel has 164 templates; the asymptotic slope is ... +2.0". Recomputed in scratch/mathC_checks/arith_checks.out.
   * *Fix.* Rewrite as: "The theory of the 112 skeletons seen by n = 3000 (119 templates) is 42838.5 bits behind (prior part 43040). It covers only the data seen, and it dies at the first unseen skeleton. The covering theory of all 157 skeletons (164 templates) has a larger prior, and its asymptotic slope is +2.0 bits per doubling (Wilks; proof sketch). Its code length was not computed." Make the same change in CLAIMS.md (ex:pa:skel).

5. **C5 [major]** `paper/sections/pa.tex; paper/sections/experiments.tex`, rem:pa:e3b (pa.tex line 217); tab:exp:e3b (experiments.tex line 131); CLAIMS rem:pa:e3b.
   * *Problem.* The paper reports the mass of T*-equivalents under atomic motives as "2*10^-178 at n = 2048". That figure is an artefact of the pool. The only T*-equivalent left is frag-complete, which carries seven never-used fragments and is a constant 590.6 bits behind frag-atoms in every seed. The natural PA-equivalent competitor frag-atoms + T_Ind = Q + {T_=, T_<, T_Ind} is not in the pool. Its extra template is a spare slot, so it trails frag-atoms by only about 45 bits, and that gap grows by about 0.5 bit per doubling. The qualitative conclusion stands: the MAP is the strictly weaker frag-atoms, with mass about 1 - 2e-14. But the PA-equivalent mass is about 1e-14 and falls only polynomially; the paper overstates it by about 164 orders of magnitude.
   * *Evidence.* scratch/mathC_checks/e3b_pool_extension.py re-runs E3(b) "atomic" with that one theory added to the pool. Its mass relative to frag-atoms is 6.2e-14, 3.1e-14 and 2.2e-14 at n = 256, 1024 and 2048, and the T*-equivalent mass becomes 3.1e-14 (n = 1024) and 2.2e-14 (n = 2048) instead of 1e-112 and 2e-178. Bits behind frag-atoms: 43.87, 44.86, 45.36 (+0.5 per doubling, the n^{-1/2} rate of prop:ident:spare(b)). The same in all five seeds, with frag-atoms still the MAP (mass 1 - 2e-14) from n = 1024 (e3b_pool_extension.out). In the saved JSON, frag-complete minus frag-atoms is 590.6 bits in all five seeds.
   * *Fix.* Report the equivalent mass with this pool caveat. Either add Q + {T_=, T_<, T_Ind} to the pool and quote its mass (about 1e-14, decaying like n^{-1/2}), or write "PA-equivalents in this pool: 2e-178 (frag-complete only). A spare PA-equivalent such as Q + {T_=, T_<, T_Ind} would keep about 1e-14 and decay polynomially."

6. **C6 [major]** `paper/sections/pa.tex`, tab:pa:failures, row F3 (line 279).
   * *Problem.* The "fixable?" column calls never-used parts split off (the omega-gap) "harmless for theorems (prop:pa:detour)". prop:pa:detour(a) shows harmlessness only for splits of T_Ind that contain a NON-ATOMIC connective root, and (b) shows the atomic split is strictly weaker. The table also cites rem:pa:merge as evidence for F3. There the sound split by head symbol "does not entail forall x(x+0=x)" and eventually wins (crossover about 1e8): theorems ARE lost. The track notes (F3) carry the qualifier "harmless under L1 if a non-atomic connective is covered", which the table drops.
   * *Evidence.* pa.tex l.113 (prop:pa:detour (a), (b)); l.256 (rem:pa:merge: "covers every closed instance but does not entail forall x(x+0=x) ... crossover near n = 10^8"); pa notes-final §6 F3.
   * *Fix.* Change the F3 cell to: "harmless for theorems only for splits with a non-atomic formula root (prop:pa:detour(a)); term-root splits lose forall x phi (rem:pa:merge), and atomic-root splits are weaker (prop:pa:detour(b))".

7. **C7 [major]** `paper/sections/pa.tex`, rem:pa:zf (line 81), last sentence.
   * *Problem.* "So the textbook ZF axioms win exactly when they are used directly" is stronger than the evidence. Three parts are unsupported. (1) The "only if" direction for Replacement against Collection and for Foundation against in-induction needs the reverse overheads, which the same remark labels "not formalised (conjecture: much larger)". (2) Collection from Replacement without Foundation is "open to us". (3) The notes' qualifier "and of nothing else that they derive only at a cost" (pa §1.5) is dropped. Without it, data that use Collection or in-induction alongside the textbook forms make the textbook set lose.
   * *Evidence.* Same remark: "The reverse overheads were not formalised (conjecture: much larger)"; pa notes-final §1.5 states the qualifier. Literature: Collection from Replacement needs Foundation and Power Set in the standard proofs; it fails without Power Set (Zarach 1996; Gitman-Hamkins-Johnstone 2016). in-induction from Foundation needs transitive closures (Kaye-Wong 2007). These citations are correctly reported.
   * *Fix.* Write: "So, given the conjectured reverse overheads, the textbook ZF axioms win when the data are direct uses of them and of nothing they derive only at a cost." Or drop "exactly".

8. **C8 [major]** `paper/sections/pa.tex`, paragraph "Answer." (line 159), item (1).
   * *Problem.* The paragraph opens "A derivation-length likelihood finds Q+T_Ind from theorem data (1) when the data come from its own derivation process (prop:pa:gibbs, prop:pa:wellspec)". Both cited results concern the generative, full-sum L1 (Gibbs bounds -log2 P_{T*}; wellspec is Doob under L1 in setting W). Neither concerns the two-part code L_sch, which the rest of §7.4 and the sentence "Otherwise L_sch memorises" are about. A reader will take items (1)-(4) as statements about L_sch. Under L_sch no result is given for well-specified theorem data.
   * *Evidence.* prop:pa:gibbs (l.148) uses -log2 P under P_{T*}; prop:pa:wellspec (l.152) is "PA's L1 generator in setting W". The paragraph itself says "Not computed: theorem data under plain L1 or the full sum". CLAIMS C12 resolves that pa's numbers are never "L1 results".
   * *Fix.* Split the answer: "(1) under the full-sum generative L1, when the data come from its own derivation process (proved); under the two-part L_sch this case was not studied. (2)-(4) refer to L_sch."

9. **C9 [major]** `paper/sections/pa.tex`, paragraph after def:pa:lsch (line 26): "is a prefix code, so Kraft holds (proved)".
   * *Problem.* Kraft for a symbol-by-symbol code needs at least log2|alphabet| bits per written symbol. The track notes (pa §0) concede that "strictly, beta should be log2 of the alphabet size, about log2 25 with the variable names used". At beta = log2 23 the per-symbol charge is below that, so "Kraft holds (proved)" is not proved for the code as used. Consequently "L_sch is the two-part form of a sub-probability likelihood" is not established at the reported beta. The same gap affects prop:pa:gibbs's example l(s) = beta|s| (C37).
   * *Evidence.* pa notes-final §0, L1-sch decodable variant: "(Strictly, beta should be log2 of the alphabet size, about log2 25 with the variable names used; this changes symbol costs by about 3% and no conclusion.)" CLAIMS.md def:pa:lsch also says "Kraft proved".
   * *Fix.* Either state that Kraft holds with beta >= log2|alphabet| (about log2 25) and that beta = log2 23 under-charges by about 3% (no conclusion changes), or recompute at beta = log2 25. Change the status to "proved for beta >= log2|alphabet|".

10. **C10 [major]** `paper/sections/app-pa.tex; paper/sections/pa.tex`, rem:pa:pointwise (app-pa.tex lines 112-113; cited pa.tex line 182).
   * *Problem.* The remark (status "proved") says that under 0/1 support "every sentence is eventually decided correctly by memorisation alone (with inconsistent theories present, given R_{d_n})". Its next sentence calls it open whether the mass of not-yet-refuted inconsistent theories deriving a sentence tends to 0. With infinitely many inconsistent theories, R_{d_n} removes each one eventually but never all of them at once. So "decided correctly" holds theory by theory (every surviving CONSISTENT theory), not for the posterior. The parenthetical claims more than is proved.
   * *Evidence.* Proof (app-pa l.116): "with inconsistent theories present this needs R_{d_n} ... Their remaining mass can be large (prop:pa:incons); whether it tends to 0 is open". pa notes Remark 4.5 has the same tension.
   * *Fix.* Restate: "Every surviving consistent theory eventually decides each sentence correctly. With inconsistent theories in the class, each is eventually refuted under R_{d_n}, but whether the posterior mass deriving a false sentence tends to 0 is open."

11. **C11 [major]** `paper/sections/pa.tex`, sec:pa:answer (line 298).
   * *Problem.* The headline answer says that within the hand-picked candidate sets "and for data that are direct uses of axioms" the inducer puts nearly all mass on PA-equivalents. Direct-use data also include narrow and atomic practice. On such data the paper's own runs and examples end on a strictly weaker theory: E3(b) atomic motives give mass 1.000 on Q + {T_=, T_<} from n = 1024 (rem:pa:e3b), and ex:pa:narrow overtakes T* near n = 2^26.7. The next sentence lists "narrow practice" as a failure, which contradicts the scope as worded. The positive cases are the broad usage laws scored: G1, connective-rich motives, and the E2 weights at n >= 128.
   * *Evidence.* rem:pa:e3b (l.217); ex:pa:narrow (l.197); tab:exp:e3b atomic row; E2 at n <= 32, where the weaker SeenQ leads (tab:exp:e2).
   * *Fix.* Scope the claim: "for direct-use data under the broad usage laws scored (G1-type practice, connective-rich motives), and once every needed axiom has been cited". Name narrow/atomic direct-use practice as the exception in the same sentence.

12. **C12 [major]** `paper/sections/experiments.tex; paper/sections/app-experiments.tex`, prop:exp:exact(d) (experiments.tex line 35) vs remark after (d5) (app-experiments.tex line 53).
   * *Problem.* Part (d), status "proved; computed", says that the predecessor sets "are complete for the component shapes of app:exp:exact, and the code admits into L1 pools only theories of the shapes it checks". The appendix says the support check does NOT test the hypothesis of (d3) (no rigid p inside a metavariable argument). For data-derived theories at J = 2 (E1 allq2), exactness "rests on the computed checks". The proposition omits this hypothesis and thereby overstates what is proved.
   * *Evidence.* app-experiments.tex l.53: "The support check does not test the hypothesis of (d3) ... for data-derived theories at J=2 (E1 allq2) exactness rests on the computed checks: ... (same class, so not independent)".
   * *Fix.* Add to (d): "...except that the hypothesis of (d3) is not checked by the code. For data-derived theories at J = 2 (E1 allq2) exactness is computed (brute force to 1e-9 on 10 theories; the referee's 904 triples), not proved."

13. **C13 [major]** `paper/sections/pa.tex`, prop:pa:occam status line (line 97).
   * *Problem.* The status says "(a), (c) proved; (b) proved under its growth condition". Part (c) is derived from the expansion (b): the log2 n coefficients come from (b) applied to the index, to H, and to the context counts m_c. So (c) needs the same hypothesis, that every nonzero count grows linearly. For random data it holds almost surely, with the O(1) holding a.s.
   * *Evidence.* app-pa.tex l.65: "(c) ... The log2 terms give ... since m_c is linear in n" (uses (b)).
   * *Fix.* Change the status to "(a) proved; (b), (c) proved under the growth condition of (b) (a.s. for i.i.d. data); computed".

14. **C14 [major]** `paper/sections/app-pa.tex`, "The theorems in other axiomatisations" (line 99): "Decodable-code costs are 3.6-7.5% higher".
   * *Problem.* Wrong number (trivial fix). Over the 18 theorem derivations the decodable overhead ranges from 3.4% to 7.5%, not from 3.6%. The minimum is T_LNP assoc: 4219.8/4081.9 = +3.4%.
   * *Evidence.* c6_theorem_data.out (a), columns D and D(dec); recomputed in scratch/mathC_checks/memo_single_beta.out (last column).
   * *Fix.* Write "3.4-7.5%".

15. **C15 [major]** `paper/sections/app-pa.tex`, Euler paragraph (line 208): "mass 0.0049 (rho=0.9) and 0.0727 (rho=0.97)".
   * *Problem.* Wrong number (trivial fix). c5_euler.py sums the unconditioned geometric mass of the false k over k < 200 only. For rho = 0.97 the tail matters, and the true mass is 0.0737. The rho = 0.9 value, 0.0049, is right.
   * *Evidence.* c5_euler.py l.114: mass_false = sum over FALSE_K (k in [0, 200)); independent sum to k < 4000 in scratch/mathC_checks/arith_checks.out: 0.0737 (rho = 0.97), 0.0049 (rho = 0.9).
   * *Fix.* Write 0.0737, or say "for k < 200". No conclusion changes.

16. **C16 [minor]** `paper/sections/experiments.tex`, E2 item (2) (line 96).
   * *Problem.* The text attributes the 5 accepting seeds to "Q-lumped or its trim beats SeenQ ... and V then accepts". In seed 1 (n = 16) the unsound MAP is the data-derived skeleton cluster skel4@16 (mass 0.999), and Q-lumped has 0.001.
   * *Evidence.* e2_pa.md, "Seeds and n at which a delta = 0.05 verifier accepts": seed 1, n = 16, MAP skel4@16, 0.999. Recomputed in scratch/mathC_e2_json.out.
   * *Fix.* Write "an unsound lump (Q-lumped, its trim, or in one seed a data-derived skeleton cluster) beats SeenQ".

17. **C17 [minor]** `paper/sections/experiments.tex`, E8 paragraph (line 169): "(0.202 against 0.074 bits per datum)".
   * *Problem.* These are marginal rates between n = 1024 and 4096: (817.04 - 196.52)/3072 and (299.59 - 72.05)/3072. The results file reports "mean gain per datum at n = 4096: L1 0.1995, L0 0.0731". The paper does not say which it quotes.
   * *Evidence.* e8_split_l1.md last line; arithmetic in scratch/mathC_checks/arith_checks.out.
   * *Fix.* Add "between n = 1024 and 4096" (as the notes do), or quote 0.200/0.073 as the mean gain at n = 4096.

18. **C18 [minor]** `paper/sections/experiments.tex`, rem:exp:limits (v) (line 179) and its status line (line 174).
   * *Problem.* "5 [seeds] otherwise" also covers E4, which uses 400 streams in (A), 100 per row in (B, C) and 1e5 Monte Carlo streams. The status "(ii)-(v) proved (properties of the code)" assigns "proved" to (v), which is a list of run sizes.
   * *Evidence.* app-experiments.tex l.208 (seeds: E4 streams 0-399 (A), 0-99 (B, C)); tab:exp:e4.
   * *Fix.* Write "...5 in E1, E3 and E6; E4 100-400 streams". Change the status to "(i), (v) computed; (ii)-(iv) properties of the code".

19. **C19 [minor]** `paper/sections/experiments.tex`, tab:exp:e1 caption (line 65).
   * *Problem.* The caption averages over phi only "where the three formulas agree". The L_sel row averages the generator mass over phi even though the formulas disagree: H_sch is 0.516 for x+0=x and 0+x=x but 0.731 for -Sx=0 at n = 256, giving 0.59.
   * *Evidence.* e1_universal.md, L1sel blocks; scratch/mathC_e1_table.out.
   * *Fix.* Report the L_sel masses per phi (0.39/0.38/0.47/0.52 and 0.52/0.50/0.65/0.73), or say that this row is averaged over phi.

20. **C20 [minor]** `paper/sections/experiments.tex`, E1 setup (line 48): "The pool (15-28 theories)".
   * *Problem.* Per-row pool sizes in e1_universal.json range from 14 to 28. The notes give 15-28 "at n = 256".
   * *Evidence.* scratch check over all rows of e1_universal.json: pool sizes {14,...,28}.
   * *Fix.* Write "15-28 theories at n = 256".

21. **C21 [minor]** `paper/sections/experiments.tex`, E1 setup (line 48): "Every generator has one component, so thm:ident:doob applies".
   * *Problem.* thm:ident:doob is stated for setting W, a countable class of FIXED i.i.d. laws. The E1 pools contain multi-component theories with Dirichlet-integrated (exchangeable, non-i.i.d.) marginal laws. Concentration on the generator still holds, by Doob's theorem for a countable class of sequence laws or by the (T, w)-parameter version (rem:ident:x5), but not by the cited statement as written.
   * *Evidence.* def:ident:W (fixed laws); experiments notes X5(c): "(a) applies to it only for one-component theories".
   * *Fix.* Cite the general form, e.g. "so the generator is a prior atom and Doob's theorem for the (T, w) parametrisation applies (rem:ident:x5)".

22. **C22 [minor]** `paper/sections/app-pa.tex`, line 31: classical equivalences "need bounded collection".
   * *Problem.* The wording suggests that the fragment equivalences IS_n <=> IP_n <=> LS_n <=> LP_n need an extra axiom. Their proofs use bounded collection BS_n, which IS_n proves (Paris-Kirby). They hold over the usual base theory without extra hypotheses.
   * *Evidence.* Standard: IS_{n+1} => BS_{n+1} => IS_n, so IS_n proves BS_n for n >= 1. Kaye 1991 ch. 7; Hajek-Pudlak I.2.
   * *Fix.* Write "their proofs use bounded collection (BS_n, provable in IS_n) because theta_phi adds a bounded quantifier".

23. **C23 [minor]** `paper/sections/pa.tex`, rem:pa:streams (iii) (line 144).
   * *Problem.* "for u = 0.1, 0.5 it is Q+T_Ind plus the library". At n = 1 the MAP is Q + library for every u. T_Ind + library becomes the MAP from n = 10. The candidate "Q + library" includes all six library theorems from the first datum, so it is a hand-picked hypothesis, not one built from data seen.
   * *Evidence.* c6_theorem_data.out (d): u = 0.1 and 0.5 at n = 1, MAP "Q+lib+memorised uses".
   * *Fix.* Write "from n = 10 (the first checkpoint after n = 1)". Note that the library is fixed in advance (caveat (ii)).

24. **C24 [minor]** `paper/sections/pa.tex`, prop:pa:must(b) (line 156); app-pa.tex line 97.
   * *Problem.* "two library theorems suffice" understates the case. One theorem suffices: associativity has 17 symbols, and 17 * log2 23 = 76.9 > 72.
   * *Evidence.* tab:pa:theorems (|s| = 17 for associativity); scratch/mathC_checks/arith_checks.out.
   * *Fix.* Write "one or two library theorems suffice (e.g. associativity alone, 76.9 bits)".

25. **C25 [minor]** `paper/sections/experiments.tex`, E5(b) (line 149).
   * *Problem.* The main text names neither the hypothesis set, {L_1..L_40, L_inf}, nor the weight vector of the L_5 generator (uniform). The caption's per-datum gain 3 - log2 5 assumes uniform weights.
   * *Evidence.* e5_gold.md (b): "posterior over {L_1..L_40, L_inf}"; notes §7 "Data i.i.d. uniform on L_5".
   * *Fix.* Add "over {L_1, ..., L_40, L_inf}; L_5 data uniform on its five sentences".

26. **C26 [minor]** `paper/sections/experiments.tex`, E6 paragraph (line 161): "A redundant second form is a spare slot (<10^-9; \cref{rem:pa:e6})".
   * *Problem.* The cross-reference is wrong. rem:pa:e6 contains neither the spare-slot statement nor the bound; the numbers are in e6_equivalent.md (A_xy+A_yx <= 1e-11, A_xy+S_ab <= 4e-10).
   * *Evidence.* pa.tex l.84-86 (rem:pa:e6 text); e6_equivalent.md L1 tables.
   * *Fix.* Point to tab:exp:e6, or add the two masses to its caption.

27. **C27 [minor]** `paper/sections/app-experiments.tex`, app:exp:pools (line 68): "in E3 and E4(B, C), in no case checked".
   * *Problem.* The phrase is ambiguous: it can be read as "not checked" or as "no case among those checked". check_bounded.py re-ran E3 and E4 for seed 0 only. The per-row "bounded" fields of e3_misspec.json and e4_ville.json are 0 for every seed, so the claim holds, but for E6 only seed 0 was checked. The main-text sentence (experiments.tex l.27) "never exceeded 8e-14" covers E6 seeds 1-4 without evidence.
   * *Evidence.* check_bounded.out ("E3(a) (seed 0)", "E6 (seed 0)"); scan of all result JSONs: E1 max 8.43e-14, E2-E4 0; E6-E8 have no "bounded" field.
   * *Fix.* Write "in E3 and E4(B, C), recorded per run: none; in E6, seed 0 only (Mem, 0)".

28. **C28 [minor]** `paper/sections/app-pa.tex`, line 156: "The same holds for any theory whose induction-type templates are all term-only: by prop:pa:readonce(b)".
   * *Problem.* prop:pa:readonce(b) is stated for read-once templates. The argument (a fixed formula skeleton) applies to every term-only template, read-once or not. The claim also needs the theory's other components to be Q axioms or theorems of a fixed IS_k.
   * *Evidence.* pa.tex l.191.
   * *Fix.* Write "by the argument of prop:pa:readonce(b), which needs only a fixed formula skeleton, any theory of Q axioms and term-only induction-type templates lies in some IS_k".

29. **C29 [minor]** `paper/sections/pa.tex`, line 263: "L_eps is the minimal model that credits derivations without killing gaps".
   * *Problem.* The superlative "the minimal model" is not proved anywhere.
   * *Evidence.* pa notes §5.6 uses the same phrase without proof.
   * *Fix.* Write "a minimal model" or "a simple model".

30. **C30 [minor]** `paper/sections/experiments.tex`, E7 paragraph (line 164): "it slightly favours small unsound lumps".
   * *Problem.* "Slightly" fits tau = 1 (unsound MAP in 9 instead of 7 seeds). At tau = 4, the largest change in a reported mass is 0.563, the mean unsound mass at n = 8 rises from 0.256 to 0.372, and accepting seeds at n = 8 go from 2 to 5.
   * *Evidence.* e7_prior.md; tab:exp:e7.
   * *Fix.* Write "favours small unsound lumps (slightly at tau = 1, markedly at tau = 4)".

31. **C31 [minor]** `paper/sections/experiments.tex`, E3(a) discussion (line 138).
   * *Problem.* "On heavy tails the deepest nesting available wins" and "the winner keeps changing as n grows". In 2 of 5 heavy seeds the MAP is the two-component {phi(z), phi(SSz)}, not C_2, the deepest nesting in the pool. Under heavy data the winners are the same at n = 512 and 1024. The second phrase is true only of the numeral data.
   * *Evidence.* e3_misspec.md heavy L0: MAP "C_2 x3; skel2@8 x2" at both n = 512 and 1024.
   * *Fix.* Write "a depth-2 nesting (C_2, or {phi(z), phi(SSz)}) wins", and "on numerals the winner keeps changing".

32. **C32 [minor]** `paper/sections/app-pa.tex`, proof of prop:pa:readonce(a) (line 132).
   * *Problem.* The proof needs every SIBLING SUBTREE on the path (a read-once formula, not an atom) to be forceable to T and to F by constant instantiation. The text gives only "each metavariable occurs once, so these choices are independent", and skips the induction over the connectives and quantifiers.
   * *Evidence.* The claim is true: by induction, a read-once formula over atoms that can each be set to T or F can itself be set to T or to F (for <-> use (T,T) and (T,F); quantifiers become vacuous). The track notes say "a read-once formula is not constant in its atoms".
   * *Fix.* Add one sentence: "By induction on its structure, every read-once subformula can be made logically equivalent (over Q1) to T and, by another choice, to F."

33. **C33 [minor]** `paper/sections/app-pa.tex`, proof of prop:pa:lower, step 2 (line 37): "and no instance has a forall-prefix".
   * *Problem.* With parameters, schema instances in closure-normal form are universally closed, so an Ind instance can have a forall prefix. The argument does not need the claim, because the antecedent-root comparison (conjunction against forall) after removing the prefix already excludes ax.
   * *Evidence.* pa.tex l.35 (parameters allowed); app-pa l.37.
   * *Fix.* Delete the clause, or write "even after removing a forall-prefix".

34. **C34 [minor]** `paper/sections/experiments.tex`, E1 item (3) (line 71): "Mem(D_n) has mass <= 2.4*10^-12".
   * *Problem.* The largest value over runs is 2.419e-12, so "<= 2.4e-12" is violated by rounding.
   * *Evidence.* scratch/mathC_e1_json.out: max Mem@8 (sch, L0/L1) = 2.41891539876831e-12.
   * *Fix.* Write "<= 2.5*10^-12" or "about 2.4*10^-12 at most".

35. **C35 [minor]** `paper/sections/experiments.tex`, E2 item (3) (line 97): "it loses the prior difference (698.9 bits) plus 4.2 bits per doubling".
   * *Problem.* At small n the likelihood part favours frag-complete. Its code-length excess is 696.9 at n = 8 and 698.2 at n = 16, below the 698.9-bit prior difference. "Loses the prior difference plus ..." is accurate only from about n = 32.
   * *Evidence.* tab:exp:e2seen middle columns; e2_pa.md code-length table.
   * *Fix.* Write "it trails by about the prior difference (696.9 bits at n = 8), and the gap grows by 4.2 bits per doubling from n = 64 to 512".

36. **C36 [minor]** `paper/sections/pa.tex`, rem:pa:usage (iii) (line 73): "every form used at a rate above about 5*10^-4 per use is primitive".
   * *Problem.* The threshold, about 0.29/650, uses the library's upper-bound overheads. With the proved lower bounds of prop:pa:lower (44-53 bits), the provable threshold is only below about 0.29/44 = 7*10^-3. The remark is prefaced "for this library", but (iii) reads as a general fact.
   * *Evidence.* arith_checks.out: 0.29/646.4 = 4.5e-4, 0.29/1468 = 2.0e-4, 0.29/44 = 6.6e-3.
   * *Fix.* Add "(for this library; with only the lower bounds of prop:pa:lower, the threshold is at most about 7*10^-3)".

37. **C37 [minor]** `paper/sections/pa.tex`, prop:pa:gibbs (line 148): "(e.g. l(s) = beta|s|)".
   * *Problem.* The example l(s) = beta|s| satisfies sum 2^{-l} <= 1 only for a prefix (Polish) code with beta >= log2|alphabet|. The pa notes state this condition, but the paper drops it, and beta = log2 23 does not meet it for the roughly 25-symbol alphabet (see C9). The consequence sentence ("at most the prior cost of memorising") depends on it.
   * *Evidence.* pa notes-final Prop 3.2: "for a Polish-notation code over at most 2^beta symbols"; §0 caveat.
   * *Fix.* Write "(e.g. l(s) = beta|s| for a Polish-notation code with beta >= log2 of the alphabet size)".
