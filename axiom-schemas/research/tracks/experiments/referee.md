# Referee report: track "experiments" (DTRC implementation and experiments)

Referee: adversarial referee (Claude), 2026-10-07. Material reviewed:
- the notes `research/tracks/experiments/notes.md` and the author's JSON summary;
- every module of `code/dtrc/`, every experiment in `code/experiments/`, the tests in `code/tests/`, and all of
  `code/results/`.

Independent checks are in `research/tracks/experiments/referee_checks/`. Run them with `sh run_checks.sh`, which
takes about 10 minutes and writes `r*.out` next to each script. Every number below comes from those outputs, or
from my full re-run of `run_all.sh`. I made no changes to the author's code or results.

Labels used here: **holds**, **holds-with-fix**, **false**, **unclear**.

---------------------------------------------------------------------------------------------------------

## 0. Summary

**Overall.** The implementation is careful, and the headline numbers reproduce exactly. The two world oracles
survived every independent soundness test I could build, and most proofs are correct. I found no bug that
invalidates a reported number. The problems are of four kinds:

1. one stated empirical claim that is false;
2. a gap in the main normal-form proposition (E1), which is false as stated once templates have rigid parameters;
3. evidence that is weaker than presented (E9, held-out acceptance, the E3 data distribution);
4. one baseline that is not quite what it is labelled.

| id | claim (short) | verdict | main reason |
|---|---|---|---|
| E1 | normal form; Min(D) = minimal normal configurations | **holds-with-fix** | false for templates with rigid parameters (parameter names are aligned literally); counterexample R1 |
| E1-comp | cross-check vs referee C's enumerator, 0 failures | holds | reproduced; coverage is narrow (arithmetic only, no parameters, no `<`/`in`/`<->`) |
| E2 | oracles sound (PA in N, ZF in V) | holds | proof checked; 0 contradictions in 6,283 independent comparisons; mutation test shows the check has power |
| E3 | merge monotonicity; within-schema merges succeed | holds-with-fix | (b) needs a target without rigid parameters (inherits from E1) |
| E4 | DTRC correct under refutation separation | holds-with-fix | proof correct given E1(c) for parameter-free targets; last clause and "same verdicts" need care |
| E5 | pure-cluster acceptance is inside the target | holds-with-fix | parameter-free targets (inherits from E1) |
| E6 | EInd is a first-order pattern in de Bruijn, not in named encodings | holds | proof checked; probes reproduced |
| E7 | exact iff heads not all equal; P = Σ p_h^N | holds | proof checked; 0 violations in 3000 random data sets (R2); prediction confirmed by 200k-run simulation |
| C-Q1 | Q1 rates and the closure-normal Gen form | holds | reproduced; accepts φ(w), not the sentence ∀xφ as written in the data (F7) |
| C-Q2 | Q2 tagged results | holds-with-fix | numbers reproduce; "pattern lgg = DT°_F on ZF" is partly by construction (F6) |
| C-Q3 | DTRC on the mixes: ARI 1, 54/55 and 45/45 exact, 0 non-target | holds-with-fix | reproduces; but not the numerals-only regime the task specified (F4), held-out leakage (F5), 35/55 and 30/45 of "exact" are ground axioms |
| C-curves | DTRC ≈ tagged; differences only from ambiguous data | holds | confirmed: 13 disagreements become 0 once the 16 ambiguous items are removed (R9) |
| C-separation | 2190/2190, 540/540, 1051/1052, 223/223 refuted | holds-with-fix | true, but only 12 / 5 / 42 / 5 distinct templates, dominated by `?P0` and `Ax.?P0(x)` (F3) |
| C-kunion | k-union with and without negatives | holds | reproduced |
| C-blowup | DT° blow-up vs DT°_F | holds | reproduced (timeouts are machine-dependent; same counts on my run) |
| C-stress | stress-set results | **false as stated** | "PA mistakes merge only into valid templates" is false: PA seed 0 merges into a false template, and DTRC accepts a sentence false in N (F1, R14, R15) |
| Conj-S | refutation separation for all mix target pairs | unclear | open; the evidence is weak (F3); suggested reduction to pairs (§4) |

---------------------------------------------------------------------------------------------------------

## 1. Reproduction

- `python3 -m pytest -q tests` (from `code/`): 31 passed, in 11.9 s on my machine.
- I ran `sh run_all.sh` in a scratch copy of `code/` (with `research/prior/induction` linked read-only). Total
  wall time was 674 s; the author reported 583 s.
- I diffed every `results/*.md` and `*.txt` against the committed results. **All tables are identical except
  for timing columns and refuter timing statistics.** The E7 timeout counts are timing-dependent but matched.
- No MinCover cap was ever hit in any DTRC run: `min_truncated` = 0 and no truncated cluster, on PA-mix, ZF-mix,
  mistakes and near-miss over all seeds (R12).

---------------------------------------------------------------------------------------------------------

## 2. Findings, most severe first

### F1. A stated stress-test claim is false: DTRC accepts a false PA sentence in E4(b) (R14, R15)

The notes (§4 E4(b)) and the claim C-stress both say: "PA merges are always into *valid* templates" and "PA
mistakes merge only into valid templates". This is false.

**What happens.** In `pa_mix(0, mistakes=8, true_nontargets=3)` (E4(b), seed 0), the two mistakes
`ind_wrong_step` and `ind_wrong_concl` merge at both budget 80 and budget 400. The cluster's only accepted
template is

```
((Ex.?P0(x,0) & ~?P1(x,0)) & (Ax.(Ey.?P0(y,x) & ~?P1(y,x)) -> (Ey.y<Sx & ~?P1(y,Sx)))) -> (Ax.Ey.y<Sx & ~?P1(y,Sx))
```

This template is false. Take P0(y,x) := (x=0) and P1(y,z) := (z=2). The instance is

```
((Ex.0=0 & ~0=2) & (Ax.(Ey.x=0 & ~x=2) -> (Ey.y<Sx & ~Sx=2))) -> (Ax.Ey.y<Sx & ~Sx=2)
```

**Proof that the instance is false in N.**
- The first premise is true.
- The second premise is true. At x=0 the consequent holds with y=0, since 1≠2. At x≥1 the antecedent is false.
- The conclusion fails at x=1, where Sx=2.

**Check.** `r15_pafalse.out` confirms that DTRC accepts this sentence at both budgets, and that it is an instance
of no PA-mix target. Neither the dtrc PA oracle nor my bounded evaluator can refute it: refuting it requires
certifying the Π1 premise by a case split on x=0. That is why the E4 probes report "0 refuted".

The other two PA mistake merges (seeds 1 and 2) are valid, as claimed. Their base clauses are `?f0<0` and
`0=S?f0`.

**Consequences.**
- The probe metric "refuted by the oracle" is a lower bound on unsoundness, never a certificate of
  truth-soundness. The summary's phrase "mostly truth-sound" should not rest on it.
- With mistakes in the data, DTRC's union is not truth-sound even in PA.

**Fix.**
- Replace the sentence by: "PA mistake merges were into valid templates in seeds 1 and 2. In seed 0 two mistakes
  merged into a false template that the oracle cannot refute (exhibit above)."
- Report a hand-verified false instance alongside the probe counts.

### F2. Prop E1 is false as stated when templates have rigid parameters (R1, R5, R6)

**The problem.**
- Data are canonicalised per datum: parameters are renamed w0, w1, … in order of first occurrence.
- Templates match data *up to injective renaming of template parameters* (`templates.match`).
- `mincover.build_tree`, however, compares parameter names literally.

So when a covering template has a rigid parameter that occurs under different canonical names in different data,
the computed Min(D) misses it.

**Counterexample (R1).** Let D = {`0=0 & w0=w0`, `w0=0 & w1=w1`}.
- Computed Min(D) = {`?f0=0 & ?f1=?f1`}.
- `?f=0 & w0=w0` is in DT°_F and covers D (the matcher maps w0↦w0 in the first datum and w0↦w1 in the second).
- It is strictly below the computed minimum and above no computed minimum.

This refutes E1(b), and E1(c)'s "Min(D) = minimal normal configurations".

**Where the proof breaks.** Step 0 ("rigid symbols of T agree with every datum"), and the leaf case of Step 1,
hold only modulo a per-datum parameter renaming.

**E1(c)'s last clause also fails.** "If D ⊆ inst(T*) then some member of Min(D) is ≤ T*" fails for T* with a
rigid parameter. `r5_mincover.py ZF` generates random ZF templates that may contain the rigid parameter c. In
21 of 300 data sets, no computed minimum is ≤ T*. All 21 involve a misaligned c.

**Downstream claims.** E3(b), E5 and Thm E4 use E1(c), so they need the hypothesis "targets have no rigid
parameters".

**Impact on the reported numbers: none that I could find.**
- All targets in the experiments are parameter-free, because the axioms are written with explicit ∀.
- Truth-soundness is preserved: the computed minimum generalises a rigid parameter to a closed term or
  parameter, which is a substitution instance.
- R6 recomputed Min exactly on all E2 data sets (N=2,3,4; 30 seeds; Sep, Rep, EInd, Ind) by enumerating every
  injective per-datum parameter alignment. Min differed in 0 of 360 data sets, and the exactness counts were
  unchanged.
- R5b checks E1(b) for parameter-free templates by random specialisation walks from the generating template. All
  1576 covering templates reached (740 PA, 836 ZF, including `<`, `in` and `<->`) are ≥ some computed minimum,
  and none is strictly below one.

So E1 holds for templates without rigid parameters, and that is the setting of every experiment.

**Fix.** Either:
- state E1, E3(b), E4 and E5 for parameter-free templates and targets; or
- compute Min as the minimal elements over all injective per-datum parameter alignments. The method is in
  `referee_checks/alignmin.py`, and it is cheap for the few parameters in these data.

Also note this if the brief's full closure-normal form (stripping ∀a in Separation) is ever used: it creates
rigid parameters in targets (see F7).

### F3. The refutation-separation evidence (E9, C-separation) is mostly degenerate (R7)

E9 reports "2190/2190 PA-mix and 540/540 ZF-mix cross-target merges refuted". I re-ran E9's sampling with the
same seeds and counted the distinct minimal templates that were actually tested:

| set | merges | distinct minimal templates | most frequent |
|---|---|---|---|
| PA-mix targets | 2190 | 12 | `?P0` (1240), `Ax.?P0(x)` (720), `Ax.Ay.?P0(y,x)` (120), `?f0=?f1` (77) |
| ZF-mix targets | 540 | 5 | `Ax.?P0(x)` (240), `?P0` (225), `Ax.Ey.Az.z in y <-> ?P0(z,x)` (45) |
| PA near-miss | 1052 | 42 | `?P0` (600), `?f0=?f1` (129), `?f0+?f1=?f2` (123) |
| ZF near-miss | 223 | 5 | `?P0` (120), `Ax.?P0(x)` (60) |

The refuter's own statistics in `e9_separation.md` say the same: 12 templates and 21 oracle calls for PA-mix, 5
templates and 16 calls for ZF-mix.

**What E9 actually shows.** The mix targets have different skeletons, so almost every cross-target merge
collapses to a template that ⊥ or naive comprehension refutes. E9 confirms (S) only in this trivial regime.
"Near-miss ZF" is not near-miss for refutation: its 223 merges also give only 5 templates.

**E9 also missed a real failure.** For the PA near-miss pair (U_add0, U_add1), E4 exhibits an unrefutable valid
cross-target merge, `5+?t=S⁵?t`. E9's random sampling never hit it (it reports only U_0add/U_add00). The notes
mention this valid merge in E4 and in §5, but §3's remark that "the only unrefuted near-miss case (1/1052) is
between U_0add data and nested U_add00 data" understates the failures.

**Fix.**
- Report distinct-template counts with E9.
- Say explicitly that ARI 1 on the mixes says little about separation between *similar* schemas.
- Add hard ZF pairs: two non-nested true schemas whose merged minimal template is not refuted by ⊥ or by naive
  comprehension.

### F4. E3 does not use the specified "numeral instances only" regime; most "exact" counts are ground axioms (R16)

**The deviation.** The task specified universal axioms "observed only through numeral instances".
`datasets.universal_instance` draws:
- a numeral with probability 0.6;
- a random closed term with probability 0.25;
- a parameter with probability 0.15.

A parameter instance `w0+0=w0` is the closure-normal form of the axiom ∀x(x+0=x) itself.

**Effect.** I re-ran E3's PA-mix seeds 0–4 with numerals only (`r16_numerals.out`):

| target | as in E3: DTRC / tagged | numerals only: DTRC / tagged |
|---|---|---|
| U_add0 | 4/5 / 5/5 | **1/5 / 3/5** |
| U_mul0 | 5/5 / 5/5 | **2/5 / 2/5** |
| U_0add | 5/5 / 5/5 | 4/5 / 2/5 |

Exactness of the universal targets drops sharply, as E1/E7 predict for numerals (p_0 = 1/8 per instance). DTRC
is worse than tagged on U_add0 and better on U_0add. Both effects come from the ambiguous datum 0+0=0.

**What the headline counts contain.** 35 of the 55 PA "exact" counts are Q1–Q7, and 30 of the 45 ZF counts are
the six single axioms. These are single ground sentences whose "exactness" only means "stayed a singleton
cluster". The non-trivial counts are:
- PA: Ind 5/5, U targets 14/15;
- ZF: Sep, Rep, EInd 15/15.

**Fix.**
- Report the numerals-only regime, or state the distribution next to "54/55".
- Report schema-level exactness separately from single-axiom exactness.

### F5. Held-out sets overlap the training data (R8)

`heldout_pa` and `heldout_zf` use the same generators as training, with seeds 10⁶+seed and no de-duplication
against the training data. Overlap with the E3 training data:

| mix | target | overlap with training |
|---|---|---|
| PA | U_add0 | 8–13 of 20 |
| PA | U_mul0 | 4–8 of 20 |
| PA | U_0add | 5–15 of 20 |
| PA | Ind | 0–1 of 40 |
| ZF | Sep | 4–7 of 30 |
| ZF | Rep | 0–6 of 30 |
| ZF | EInd | 1–10 of 30 |

**Effect.** "Held-out accepted" is inflated for every learner that accepts its own data.
- DTRC's "11/20" on the non-exact U_add0 in E3 seed 3 includes the 10 training items.
- E4(c)'s "U_0add n=1: 4/20" and "Rep n=4: 15/30" are similarly inflated.

**Unaffected.** Exactness is a syntactic test and does not involve held-out data. So the main metric stands.

**Fix.** Remove training sentences from the held-out sets, or report overlap.

### F6. The "higher-order pattern lgg" baseline is built on the DT°_F tree (R17)

`baselines.pattern_lgg` uses `MinCover(D)`'s tree, in which an atom whose term disagreement contains a bound
variable becomes a formula slot `?P(x,…)`. A genuine pattern anti-unifier (Pfenning; BKLV) keeps the agreed atom
head and generalises the term to `f(x,…)`.

**Example.** For {Sep(x∈a), Sep(a∈x)}, the baseline returns exactly T_SEP. The genuine pattern lgg is the
strictly more specific `… x∈a & f(x,a) in g(x,a)` (or `f(x,a) in f(a,x)` after BKLV's merging).

**Effect.**
- The claim "the pattern lgg equals DT°_F on the three ZF schemas" is partly by construction.
- On the E2 data the difference is small: 3 of the 30 EInd N=2 runs counted as pattern-lgg-exact would not be
  exact for the genuine pattern lgg. Sep and Rep are unaffected at N=2,3,4.
- The qualitative conclusions (the pattern fragment suffices for the ZF schemas; T12 on induction) are not
  affected.

**Fix.** Describe the baseline as "pattern lgg with formula-level generalisation of atoms", or implement term-level
pattern generalisation.

### F7. The normal form keeps leading ∀; robustness check passes (R13)

`canon_params` renames parameters but does not strip a leading universal prefix. As a result:
- Q's and ZF's axioms are closed ∀-sentences, and Separation keeps ∀a.
- So `∀x.x+0=x` (the datum Q4) and `w0+0=w0` (a U_add0 datum) are different data for the same sentence.
- The learned U_add0 schema accepts `w0+0=w0` but not `∀x.x+0=x`.

C-Q1's "accepts φ(w), i.e. the sentence ∀xφ" is correct only for the parameter form.

This choice also hides two overlaps between targets. Under full stripping, Q4 ∈ inst(U_add0) and
Q6 ∈ inst(U_mul0). (Found would be an instance of the near-miss FoundS.)

I re-ran DTRC with all data and targets fully stripped: leading ∀ become fresh parameters, so the stripped targets
have rigid parameters.
- PA-mix seeds 0–4: ARI = 1.0 on unambiguous data. Q4 and Q6 are absorbed into the U_add0 and U_mul0 clusters,
  which is semantically right but scores as "not exact". All other targets are exact, and there are 0 non-target
  probes.
- ZF-mix seeds 0–2: 9/9 exact, 0 non-target probes.

So DTRC is robust to the choice. The notes should state the normal form explicitly and mention the Q4/U_add0
overlap that the ∀-form avoids.

### F8. Minor points

**(a) Thm E4, last clause.** "Contains inst(T_i) exactly for those i at which the tagged verifier is exact": the
"only if" direction can fail when instance sets of different targets overlap. Other clusters can cover
inst(T_i) minus Acc_i. State it per cluster.

**(b) Thm E4, "same refuter verdicts".** This is an assumption, not a fact. The refuter caches results per
template and accumulates data-guided tries across calls, so verdicts depend on call history.

**(c) E1 numerals mean.** The gap between 8.42 observed and 8.11 predicted is 1.85 standard errors (SE 0.165) in
a *single* sample. The five target rows are the same sample: same seeds, and exactness depends only on heads.
They should not be read as replications. My 200,000-run simulation of the head process gives 8.117 (R2). R2 also
found 0 violations of the head criterion in 3000 random data sets over 9 one-variable templates, including
`S?t+0=S(?t+0)` and `?t=?t`.

**(d) E0 coverage.** The cross-validation covers only arithmetic without `<`. It has no `in`, no `<->` and no
parameters, and 41 of its 48 data sets have |Min| = 1. My R5 and R5b checks cover ZF and `<` for parameter-free
templates (see F2).

**(e) Budget-400 ZF residual merges are false templates (R10).** This confirms the notes. Both surviving
Separation-capture merges are refuted at budget 3000 (478 and 604 oracle calls). The witnesses are simple, e.g.
`Ax.Ey.Az.z in y <-> (z in x & (Au.(Av.v=v) -> ~z in y))`: one metavariable ⊤, the other `~z in y`. The
bottleneck is the index-sum enumeration over large arity-3 pools. A first pass that sets all but one metavariable
to ⊤ or ⊥ would find these cheaply. The seed-1 EInd merge, `(Ax.?P0(x) -> x=x) -> (Ax.x=x)`, is valid, as claimed.

---------------------------------------------------------------------------------------------------------

## 3. Checks of the proofs

**E1.**
- I checked Steps 0–4 line by line.
- *Step 0.* The F-slot argument is correct: a 0-ary term metavariable strictly inside an atom whose subtree has an
  open slot would need a closed value containing a bound variable.
- *Step 1.* Push-down is correct, including at the template's non-pattern occurrences: the plugged body has the
  same head.
- *Step 3.* Forcedness of arguments is correct: every own hole occurs in some body, and plugging is injective in a
  hole that occurs, with unshifting under binders.
- *Step 4.* Independence is correct: the free bound variables of t̄ occur in σ's column because every hole is
  bound (`len(binding) == nar`).
- The only gap is parameter alignment (F2).
- The implementation matches the proof:
  - forced own slots;
  - independent own sets;
  - derived occurrences allowed at interior nodes but never above or below their source;
  - the `contains` rule, which forbids a derived occurrence above an own slot.

**E2.** I checked each atom rule for generics:
- G∈c false if c∈E_G or c⊆E_G;
- G=c false if c∈E_G;
- G∈G false by Foundation;
- distinct generics are unequal because of freshness.

I also checked the three-way case split per unbounded quantifier, which covers but does not partition the cases,
and that is enough. I checked the HF search, supervaluation, memo keys (generic ids are unique), Kleene tables and
vacuous-quantifier stripping. For PA I checked the polynomial classification over N, the symbolic-variable
semantics (a verdict is universal over the symbols), the bounded and one-point forms, and the numeral search. I
found no error.

The empirical checks:

| check | what it compares | result |
|---|---|---|
| R3 | 1981 PA and 702 ZF definitive verdicts logged during DTRC runs (mixes with mistakes, near-miss) | 0 contradictions |
| R4 | 3000 random PA sentences and 600 random ZF sentences | 0 contradictions (2595 of the PA verdicts were also decided by the bounded evaluator, and agreed) |
| R11 | mutation test of the ZF check | dropping the in-scope-generic case gives 39/600 contradictions; dropping the fresh-generic case gives 415/600 |

The independent evaluators:
- **PA:** a three-valued bounded evaluator, definitive only through exact bounded quantifiers, counterexamples and
  witnesses.
- **ZF:** exact evaluation in finite structures M = V_4 ∪ {6–7 extra objects}, with:
  - HF sets standard, and extras never elements of HF sets;
  - arbitrary irreflexive membership into and among the extras;
  - equality = identity.

  These structures satisfy exactly the properties the soundness proof uses: standard HF sets, irreflexivity as the
  only use of Foundation, no extensionality for generics, and a fresh element always available. So every
  True/False verdict must hold in them.

R11 shows the ZF check has power against bugs in the case analysis. Mutating the generic-vs-HF atom rules was not
detected, because on random sentences those rules almost never decide a verdict. I verified them by hand.

**E3, E4, E5.**
- Correct given E1(c) (F2 restricts the targets to parameter-free ones) and given that a sound refuter never
  refutes a template all of whose instances are true.
- The Thm E4 invariant argument is right:
  - all pairs are pushed with minimum score 0;
  - failed pairs are cross-label under (S) and E3(b);
  - inheritance therefore never blocks a same-label merge.

**E6.** The de Bruijn argument is correct: sentencehood forces loose indices ⊆ {0} at the depth-1 occurrences, so
all three occurrences read β[#0]. The level-encoding exhibit is false in V; I checked it by hand with w0 = {{∅}}.

**E7.** Correct. (⇐): no interior derived occurrence is possible, and the identical t-columns give one own slot.
(⇒): every covering minimum has h below every t-position.

---------------------------------------------------------------------------------------------------------

## 4. Notes on the conjecture and suggestions

**Reduction to pairs.** With an ideal refuter, Prop E3(a) reduces (S) to pairs of single data. If every member of
Min({a,b}) is refuted for all a ∈ inst(T_i) and b ∈ inst(T_j), then every member of Min(A∪B) is refuted for all
A ∋ a and B ∋ b. Sampling |A|,|B| ≤ 2 therefore adds nothing beyond pairs.

**Proving Conj-S for the mixes.** For the PA-mix and ZF-mix targets, the pairwise statement looks provable by a
short case analysis:
- different root symbols give `?P`, refuted by ⊥;
- `∀x…` prefixes give `∀x ?P(x)`;
- `?f+?g=?h` or `?f+?g=S?h` is refuted by 0+0=S0, once the ambiguous 0+0=0 is excluded;
- naive comprehension `∀x∃y∀z(z∈y ↔ ?P(z,x))` is refuted by the Russell instance, which the ZF oracle certifies.

For the PA *near-miss* targets, (S) is false: (U_add0, U_add1) has the valid merge `5+?t=S⁵?t`.

**Further suggestions.**
- Add a hard ZF near-miss family. Report a hand-verified false instance for every merged template counted as
  "valid" or "truth-sound".
- In the template refuter, try "all metavariables ⊤/⊥ except one, which runs through its pool" before the
  diagonal enumeration (F8e).

---------------------------------------------------------------------------------------------------------

## 5. Commands and outputs

All commands are run from `research/tracks/experiments/referee_checks/`; `sh run_checks.sh` runs them all.

| check | command | output | result |
|---|---|---|---|
| R1 | `python3 r1_params.py` | `r1_params.out` | E1 counterexample with misaligned parameters |
| R2 | `python3 r2_e7.py` | `r2_e7.out` | 3000 sets, 0 E7 violations; simulated numerals mean 8.117 |
| R3 | `python3 r3_record.py PA` and `ZF`; `r3_check.py PA` and `ZF`; `r3b_deep.py` | `r3*.out` | logged oracle verdicts: 0 contradictions (PA 1981; ZF 489 of depth ≤ 4 plus 213 of depth 5–6) |
| R4 | `python3 r4_fuzz.py PA 3000 2`, `… ZF 600 5` | `r4_fuzz_*.out` | random sentences: 0 contradictions |
| R5 | `python3 r5_mincover.py PA 400 2`, `… ZF 300 3` | `r5_mincover_*.out` | ZF: 21/300 E1(c) failures, all from a rigid parameter c; PA 0 |
| R5b | `python3 r5b_walk.py PA 400 4`, `… ZF 400 5` | `r5b_walk_*.out` | parameter-free: 1576 covering templates reached, 0 E1(b) failures, 0 below a minimum |
| R6 | `python3 r6_align.py` | `r6_align.out` | alignment-complete Min = computed Min on all E2 data sets |
| R7 | `python3 r7_e9distinct.py` | `r7_e9distinct.out` | E9: 12 / 5 / 42 / 5 distinct templates |
| R8 | `python3 r8_leak.py` | `r8_leak.out` | held-out overlap table (F5) |
| R9 | `python3 r9_e5amb.py` | `r9_e5amb.out` | 13 DTRC/tagged disagreements, 0 after removing 16 ambiguous items |
| R10 | `python3 r10_mist.py` | `r10_mist.out` | budget-400 ZF residual merges are false (refuted at budget 3000) |
| R11 | `python3 r11_mutation.py` | `r11_mutation.out` | mutation test of the ZF check |
| R12 | `python3 r12_trunc.py` | `r12_trunc.out` | no MinCover truncation anywhere |
| R13 | `python3 r13_strip.py` | `r13_strip.out` | fully stripped closure-normal form: DTRC still ARI 1 |
| R14 | `python3 r14_pamist.py` | `r14_pamist.out` | PA mistake merges and their templates |
| R15 | `python3 r15_pafalse.py` | `r15_pafalse.out` | DTRC accepts a false PA sentence (F1) |
| R16 | `python3 r16_numerals.py` | `r16_numerals.out` | numerals-only PA-mix exactness (F4) |
| R17 | `python3 r17_pattern.py` | `r17_pattern.out` | pattern-lgg baseline fidelity (F6) |
