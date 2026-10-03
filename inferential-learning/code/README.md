# `cil`: Coherent Inferential Learning (experiment code)

This directory holds the experiments of the inferential-learning project (see `../research/00-brief.md`).
The question is whether a learner can learn *inference rules* from examples of human steps, and then use
coherence (refuted derivations of a contradiction) and sparse world feedback to become a verifier that is
sound against an adversarial prover, not just accurate on average.

There are three experiments:

* **A. Algebra.** Learn 41 guarded rewrite schemas of school algebra over partial terms from simulated
  human derivations. The derivations contain sporadic noise and systematic fallacies. The rules are then
  repaired by pure coherence or by world feedback.
* **B. Propositional natural deduction.** Learn the 13 rules of classical natural deduction, in sequent
  form, from simulated human proofs. Then prune by coherence on designated contexts, with or without sparse
  world feedback. Also test Post-completeness with a "bold" learner and contrast with intuitionistic logic.
* **C. Adversarial prover.** Put statistical step classifiers (PRM-like, calibrated) and rule-learned
  verifiers under the same black-box proof search on false and true algebra goals.

Everything is pure Python and deterministic given the seeds. The JSON results of the full grids are
checked in, and every report can be rebuilt from them in seconds (`--report-only`).

## Layout

| path | content |
|---|---|
| `cil/terms.py` | first-order terms, parsing and printing, matching, unification, Plotkin anti-unification (LGG) |
| `cil/rules.py` | rewrite schemas with guards, difference chains, licensing of a step by a rule |
| `cil/domains/algebra.py` | partial field algebra: exact evaluation with UNDEF and Kleene equality, sound syntactic guard entailment, the 41 target schemas, 5 fallacies, the human-derivation simulator, the random-point world oracle, the total "complex meadow" semantics (diagnostic only) |
| `cil/learners.py` | MDL-clustered anti-unification learner (`LGGLearner`), the conservative verifier (`LearnedCalculus`), the Lakatos repair loop (`CoherenceRepairer`: numeral coherence, bag-level or step-level world feedback) |
| `cil/evaluation.py` | algebra evaluation only (ground truth lives here): recovery and fallacy reports, held-out valid and invalid step sets (in and out of distribution), white-box attack, a small gradient-boosting baseline |
| `cil/domains/prop.py` | propositional formulas, sequent rules with `mem` guards, exact truth-table soundness of rule schemas, Kripke countermodels, a generic backward prover, the human-proof simulator, the sparse world |
| `cil/seqlearn.py` | sequent-rule learner (`SeqLearner`), conservative verifier, coherence pruner (Post probes, minimum-weight hitting-set blame, guard / split / delete repairs), bold learner |
| `cil/prop_eval.py` | propositional evaluation only: unsound active rules, recovery, fallacy fates, the search-based adversary, completeness, held-out steps |
| `cil/baselines.py` | statistical step verifiers (logistic regression, histogram gradient boosting, random forest on hashed n-gram and tree-edit features), datasets, threshold calibration |
| `cil/provers.py` | the black-box adversarial prover (bidirectional best-first search over a broad proposal distribution) and the false, true and fresh goal sets |
| `experiments/exp_algebra_learning.py` | experiment A |
| `experiments/exp_prop_learning.py` | experiment B |
| `experiments/exp_adversarial_prover.py` | experiment C (and its `--retrain` extension) |
| `results/` | JSON data, auto-generated Markdown reports and plots; `*_quick.*` are smoke-test outputs |
| `tests/` | 85 unit tests (`pytest`) |
| `run_all_quick.sh` | tests, quick modes, report regeneration and all theory checks in one go |

Ground truth (target calculi, fallacy lists, truth tables, the labelling oracles) is read only by the
simulators and by `evaluation.py`, `prop_eval.py` and the experiment scripts. Learners see human steps
with the rule name the human cites, plus whatever feedback channel the configuration grants (none, numeral
arithmetic, a world oracle, designated coherent contexts). The hidden generation label `kind` of a step is
never read by a learner.

## Requirements

Python 3.11 with numpy, scipy, scikit-learn, matplotlib, mpmath and pytest; sympy for some theory checks.
The versions used were numpy 2.4.6, scipy 1.17.1, scikit-learn 1.9.1, matplotlib 3.11.2, mpmath 1.3.0,
sympy 1.14.0 and pytest 9.1.1.

## How to run

All commands are run from this directory. Times are wall-clock times on the 4-core container used for
the project, which was often shared with other jobs.

| what | command | time |
|---|---|---|
| unit tests | `python3 -m pytest -q` | 1.5 min |
| everything quick (tests, quick modes, report regeneration, theory checks) | `./run_all_quick.sh` | 16 min (all 55 steps PASS in the review) |
| A, smoke test | `python3 experiments/exp_algebra_learning.py --quick` | 1 min |
| B, smoke test | `python3 experiments/exp_prop_learning.py --quick` | 2 min |
| C, smoke test | `python3 experiments/exp_adversarial_prover.py --quick`, then `... --quick --retrain` | 35 s + 45 s |
| rebuild a full report and its plots from the saved JSON | `python3 experiments/<script>.py --report-only` | 2 to 4 s |
| A, full grid (687 tasks) | `python3 experiments/exp_algebra_learning.py` | 19 min on 3 workers (56 CPU-min) |
| B, full grid (126 learning tasks, plus Post and IPC parts) | `python3 experiments/exp_prop_learning.py --workers 6` | 58 min (about 3.2 CPU-hours) |
| C, main run | `python3 experiments/exp_adversarial_prover.py` | 22 min (20 CPU-min) |
| C, adversarial retraining | `python3 experiments/exp_adversarial_prover.py --retrain` | 14 min (12 CPU-min) |

The full grids checkpoint every finished task to `results/<stem>.partial.jsonl`, and `--resume` continues
an interrupted run. The quick modes write only `results/*_quick.*`. `--report-only` reproduces the
full-grid reports in `results/` byte for byte; this was checked for all three reports in the review, after
the fixes listed in the review notes.

## Main results

Means ± population standard deviations are over seeds 0, 1 and 2, unless stated otherwise. The full
tables are in `results/algebra_learning.md`, `results/prop_learning.md` and `results/adversarial_prover.md`.

### A. Algebra (`results/algebra_learning.md`)

The setting is N = 500 human derivations with 5% sporadic noise and five systematic fallacies (each taken
with probability 0.3 at every opportunity), and the learner that buckets by the cited rule name. *FA* is
the acceptance rate of held-out invalid steps and *C* the acceptance rate of held-out valid steps. ID means
in distribution (about 10-node terms) and OOD out of distribution (about 40-node terms). *Exploits* counts
accepted invalid steps found by the white-box attack.

| verifier | exact schemas /41 | unsound active schemas | FA ID / OOD | C ID / OOD | exploits | oracle queries |
|---|---|---|---|---|---|---|
| positive examples only (support ≥ 2) | 30.0 ± 0.0 | 15.7 ± 0.5 | 0.506 / 0.507 | 1.00 / 1.00 | 65 ± 2 | 0 |
| + pure coherence (numeral contradictions, no world) | 33.0 ± 0.0 | 8.3 ± 0.5 | 0.166 / 0.156 | 1.00 / 1.00 | 27.3 ± 5.6 | 0 |
| + bag-level world feedback (derivation endpoints only) | 41.0 ± 0.0 | 0.0 | 0.000 / 0.000 | 1.00 / 1.00 | 0 | 11524 ± 1461 |
| + step-level world feedback | 41.0 ± 0.0 | 0.0 | 0.000 / 0.000 | 1.00 / 1.00 | 0 | 13329 ± 450 |
| supervised gradient boosting (34 features, threshold 0.5) | n/a | n/a | 0.533 / 0.503 | 0.888 / 0.728 | n/a | labels |

Across the whole coherence grid there are 90 runs per mode (N from 20 to 500, three noise settings, tagged
and untagged learners, three seeds). Runs ending with at least one unsound active schema: 0/90 with step
feedback, 2/90 with bag feedback and 88/90 with pure coherence. The unsound schemas left by pure coherence
are almost all sound in an alternative total semantics in which 1/0 = 0 (the "complex meadow"). For
N ≥ 200 (36 runs) that holds for 304 of the 315 surviving schemas (96.5%); of the other 11, 10 mention an
object constant such as `z`. So coherence without a world that can observe "undefined" converges to a
different, coherent meaning of `/` and `sqrt`.

Caveats:

* The setting is realizable. Valid human steps are exact instances of the target schemas, and the guard
  language (`defined`, `nonzero`, `nonneg` on schematic variables) contains every true guard.
* Soundness is measured, not proved. Schema soundness is a random test with 250 assignments that include
  undefined and irrational values. Held-out invalid steps are kept only if a 60-point oracle refutes them,
  and the white-box attack is heuristic. As an independent check, the review re-tested every active schema
  of five final calculi (N = 500 both / step / tagged and untagged; N = 500 both / bag; N = 200
  fallacies / bag / untagged; N = 100 clean / step). It used 20,000 random assignments plus a grid over
  {undefined, 0, ±1, ±2, 1/2, −3/7, ±√2} for every variable (all combinations, capped at 200,000 per
  schema). No unsound schema was found.
* World feedback is cheap here: random evaluation is close to a perfect oracle for polynomial identities.
* The gradient-boosting baseline in this experiment is weak (34 hand-made features, uncalibrated
  threshold). Experiment C has the careful comparison with calibrated baselines.
* There are only three seeds. Fresh seeds 3, 4 and 5 (N = 200, both, tagged) reproduce the pattern:
  positive only gives 30/41 exact with 14 to 15 unsound schemas; numeral gives 33/41 with 8 to 9 unsound;
  bag gives 40 to 41/41 with 0 unsound; step gives 41/41 with 0 unsound and 0 exploits.

### B. Propositional natural deduction (`results/prop_learning.md`)

The learner is the version-space learner `vs`: tag buckets, MDL anti-unification and most-specific `mem`
guards. The rows below cover noise `both` (fallacies AC, DA and ID at rate 0.3, plus 5% corrupted steps)
and N ∈ {50, 100, 200}, which is 9 runs. Rule soundness is decided exactly by truth tables. The adversary
searches with the learned rules for derivations of 34 invalid goals, including ⊢ ⊥. *Sound completeness*
is the fraction of 25 random tautologies proved by the sound active rules within the search budget; the
target calculus scores 0.88 ± 0.03.

| phase | unsound active rules | tonk-like | adversary exploits /34 | runs deriving ⊢ ⊥ | target rules exact or stronger guard /13 | sound completeness | FA held-out | world queries |
|---|---|---|---|---|---|---|---|---|
| positive examples only | 45.6 ± 19.3 | 30.2 ± 12.2 | 34.0 ± 0.0 | 9/9 | 13.0 | 0.87 ± 0.04 | 0.86 ± 0.02 | 0 |
| + coherence (designated contexts, no world) | 1.2 ± 0.9 | 0.0 | 1.7 ± 4.1 | 0/9 | 13.0 | 0.87 ± 0.04 | 0.00 ± 0.01 | 0 |
| + sparse world (2 of 16 valuations observed) | 0.2 ± 0.4 | 0.0 | 0.0 | 0/9 | 13.0 | 0.87 ± 0.04 | 0.00 | 910 ± 309 |

* On clean data every phase ends with 0 unsound rules for N ≥ 50, and 13/13 target rules are recovered
  exactly or with a stronger guard.
* Over all 72 `vs` runs (N from 5 to 200, four noise settings), runs with an unsound active rule are 47
  (positive only), 19 (coherence) and 6 (world). ⊢ ⊥ is derivable in 32, 0 and 0 runs.
* The aggressive Plotkin learner (plain LGG per coarse bucket, 18 runs) produces tonk-like rules, and ⊢ ⊥
  is derivable in 18/18 runs. After coherence pruning this drops to 0/18.
* Post-completeness: for 177 structural candidate schemas, "coherent with classical ND" coincided with
  "classically valid" (59 valid and coherent, 118 invalid and incoherent, no misclassification within
  the budget).
* Intuitionistic contrast: excluded middle, double negation elimination, Peirce, weak excluded middle and
  Dummett linearity are coherent additions to intuitionistic ND, each with a Kripke countermodel.

Caveats:

* The designated coherent contexts are certified satisfiable by the environment; the code uses
  ground-truth satisfiability for that, which is a modelling assumption.
* Coherence search is budgeted. What survives pruning is mostly *non-structural*: 38 of 45 surviving rule
  instances mention specific atoms, where Post's ⊥/¬⊥ substitution is unavailable.
* World probes are capped at 8 literal instantiations per rule. The 3 schematic rules that survive the
  world phase all have at least 4 metavariables. Re-running the two affected runs with `world_probes=64`
  (all instantiations) removed them; this was a review check, and the stored grid still uses 8.
* Most-specific guards make ∧E, ∨E (and sometimes ¬E) *stronger* than the target, because the simulated
  humans only eliminate from open assumptions. This is sound but incomplete out of distribution.
* Fresh seeds 3 and 4 (N = 50, both) reproduce the pattern: 24 unsound rules and 34/34 exploits after
  positive learning; 0 and 0 after coherence; 0 and 0 after world feedback.

### C. Adversarial prover (`results/adversarial_prover.md`)

All verifiers are trained on the same N = 500 noisy algebra derivations, except `lgg_ms_clean`, which uses
a clean corpus. The prover sees only accept or reject. It has 3000 verifier queries per false goal and
1500 per true goal. *ID* metrics are on a held-out split of fresh human-like steps. `pX` is a threshold
calibrated to in-distribution balanced precision X.

| verifier | ID balanced precision | ID recall | false goals proved /23 | true goals proved /33 | false equations derived per 1000 queries |
|---|---|---|---|---|---|
| gradient boosting, threshold 0.5 | 0.9752 | 0.958 | 22.3 ± 0.9 | 31.0 | 281 |
| gradient boosting `p0.99` | 0.9925 | 0.885 | 16.3 ± 2.4 | 28.3 | 259 |
| gradient boosting `p1.0` | 1.0000 | 0.450 | 1.7 ± 0.5 | 4.7 | 43 |
| random forest `p0.99` | 0.9918 | 0.796 | 13.0 ± 0.8 | 24.0 | 168 |
| logistic regression `p0.99` | 0.9749 | 0.061 | 3.3 ± 1.9 | 1.7 | 104 |
| LGG, positive only, no guards | 0.9064 | 1.000 | 20.7 ± 0.9 | 32.3 | 269 |
| LGG, positive only, most-specific guards | 0.9158 | 0.995 | 14.0 ± 0.8 | 32.3 | 141 |
| LGG, most-specific guards, CLEAN corpus | 1.0000 | 0.988 | 0.0 | 32.3 | 0 |
| LGG + pure coherence | 1.0000 | 0.997 | 5.0 ± 0.0 | 32.3 | 99 |
| LGG + bag-level world feedback | 1.0000 | 0.997 | 0.0 | 32.3 | 0 |
| LGG + step-level world feedback | 1.0000 | 0.997 | 0.0 | 32.3 | 0 |
| ground-truth target calculus | 1.0000 | 0.997 | 0.0 | 32.3 | 0 |

* Every one of the 11 statistical configurations derives false equations under search. Those with
  in-distribution balanced precision ≥ 0.99 still prove 1.7 to 16.3 false goals.
* The rule-learned verifiers fail only through named schemas: 154 of 154 invalid proof edges are licensed
  by a schema that the soundness test flags.
* PRM800K-style adversarial retraining (gradient boosting at `p0.99`, 4 rounds) brings false proofs on
  the harvested goals from 15.5 to 0.0 of 23. The patched model still proves 1.5 of 12 fresh false goals
  and derives 14.3 false equations per 1000 queries, while true goals proved fall from 28.0 to 24.5.

Caveats:

* There is one small closed domain.
* The prover's proposal distribution is built from domain knowledge: target rules with guards ignored,
  the known fallacies, near-miss schemas, arithmetic, mutations and goal-directed leaps. So it is an
  informed black-box adversary.
* A derived equation counts as false when exact evaluation at 5 fixed points refutes it. This is a
  one-sided test, so the counts are lower bounds.
* In-distribution precision does not rank verifiers by soundness: `lgg_coherence` has ID precision 1.000
  and still proves 5 false goals.
* The retraining extension uses only seeds 0 and 1.

## Review notes (2026-10-03)

An independent review re-ran the tests, all quick modes and all `--report-only` modes. It spot-checked
headline numbers of the three full grids against the JSON (all matched) and checked determinism by
recomputing several stored runs exactly. It then looked adversarially for ground-truth leakage into
learners, verifiers consulting the target calculus, wrong soundness checks, unfair baselines,
cherry-picked seeds and unsupported report claims.

The reproduced runs gave identical results: five algebra coherence runs (the same active schemas), the
B run vs|100|both|1 (positive phase, the same 42 unsound rules) and the B runs vs|10|noise|0 and
vs|100|noise|0 (world phase, the same surviving rules). The learners' feedback channels were confirmed as
described in the layout section. The seeds are fixed (0, 1, 2) for every experiment, and fresh seeds
reproduce the patterns (see above).

Issues found and fixed:

1. **Experiment B, fallacy fates** (`cil/prop_eval.fallacy_report`). An ACTIVE unsound *special case* of a
   fallacy schema was reported as `inactive`. An example is affirming the consequent for the atom p only:
   `G |- p -> X1 ; G |- X1 / G |- p`. It now counts as `survived`, and there is a regression test in
   `tests/test_seqlearn.py`. `experiments/exp_prop_learning.py --report-only` upgrades the stored statuses
   from the stored lists of unsound rules; the one truncated list was re-checked by refitting. Affected
   numbers: only the table "Fallacy fates" in `results/prop_learning.md`. In survived/removed/inactive/never
   form, the changed cells are:
   * AC at N = 10: positive 4/0/2/0 → 5/0/1/0, coherence 0/4/2/0 → 1/4/1/0;
   * AC at N = 20: positive 5/0/1/0 → 6/0/0/0;
   * DA at N = 100: positive 4/0/1/1 → 5/0/0/1, coherence 0/2/2/2 → 1/2/1/2;
   * ID at N = 100: positive 2/0/2/2 → 3/0/1/2;
   * ID at N = 200: positive 4/0/2/0 → 6/0/0/0.

   So after coherence, one AC run (N = 10) and one DA run (N = 100) keep a specialised fallacy. After world
   feedback, none does. The unsound-rule counts and all other numbers were always right.
2. **Experiment B, report claim.** Interpretation item 4 said that one observed valuation is a complete
   soundness test for every schematic rule. That holds only if all 2^k literal instantiations are probed,
   while the code probes at most 8. The text now says so and counts the 3 schematic survivors (k ≥ 4) from
   the data. A rerun of the two affected runs with `world_probes=64` removes them; see the caveats above.
3. **Experiment A, latent inconsistency** (`cil/evaluation.fallacy_report`). An unsound active schema
   *more general* than a fallacy was not counted as letting the fallacy survive. This is fixed. No stored
   run is affected, so `results/algebra_learning.md` is unchanged.

Checked and found sound: Kleene equality of undefined values (a design choice, and it keeps equality
transitive, so a false proof needs an invalid step); guard entailment; difference-chain licensing; the
exact truth-table soundness test for sequent rules, including set metavariables and `mem` guards;
one-sided oracles; calibration of the statistical baselines; and equal treatment of rule-based and
statistical verifiers by the prover (accept in either orientation, the same budgets, the same trusted
arithmetic). `paper/sections/experiments.tex` is still a placeholder.

## Theory check scripts

These are the computational checks of the theory notes in `../research/theory/` (T1 to T7) and of three
literature memos in `../research/lit/`. Each script is self-contained Python (numpy, scipy, sympy) and is
run from its own directory: `cd ../research/theory/T3-checks && python3 pendulum.py`. `run_all_quick.sh`
runs all of them except those marked *slow*.

Status is from the review run on 2026-10-03. **PASS** means the script ran to completion; for the
`run_all.sh` scripts and the scripts with self-checks it also means that every reported check came out as
the theory note states (for example "mismatches 0", "violations 0", "all assertions passed"). Several scripts
print numbers to compare with the note by eye. The times are for one core.

### `run_all.sh` scripts

| script | reproduces | result |
|---|---|---|
| `theory/T1-code/run_all.sh` | the [computed] claims of T1 §7: escalation dimension of single schemas and k-unions (Thm 3.4, 3.7); subcubes; partition abstraction (Thm 3.7(ii)); exact identification of toy ND by per-rule LGG (Thm 5.3); noise collapse, trimming and systematic fallacy (Prop 6.1, Thm 6.2, Cor 6.5); Ville tightness (Prop 4.3); Conj 3.8 tight at k = 2; Remark after Thm 5.4; Thm 4.2(a) needs unforeseeable noise; Thm 3.7(i) sequences and Prop 3.5 | PASS, 11 s |
| `theory/T4-checks/run_all.sh` | T4: exact minimax objects vs bags (Thm 4.3, 4.4); M_bag ≤ el* and the refuted M_bag = el* (Thm 4.4(a)); product classes (Thm 4.5, Prop 4.6); conjecture M_bag^(r) ≤ r·M_obj; Frege, Russell and Zermelo comprehension toy (§5); sorites and robust core, steeper simplicity (Prop 6.4, §7); post-verification checks V1 to V5 | PASS, 194 s |
| `theory/T6-checks/run_all.sh` | T6: bilateral (Scott) completeness; probabilistic coherence polytopes; counting sequents (Thm 3.1); completeness of a multi-context calculus; local-to-global for context covers; Nullstellensatz and Galois-closed sets; multiplicity search; post-verification repair checks (Thm 1.5, Prop 1.3, Def 4.0 and Cor 4.2) | PASS, 98 s |

### Individual scripts (no `run_all.sh`)

`T1-code/` also has helper modules and slow variants that its `run_all.sh` skips; they are listed under "T1-code extras".

| script | checks | time | result |
|---|---|---|---|
| **T2-checks** (`T2-coherence-as-negative-data.md`) | | | |
| `carnap_check.py` | Carnap's categoricity problem on the 16 formulas of depth ≤ 1 over two atoms; denial ranks (Thm 4.3: 0 mismatches) | 1 s | PASS |
| `fallacy_check.py` | Post witnesses for propositional fallacies: constant substitutions that make the premises tautologies and the conclusion a contradiction (Cor 6.2 table) | <1 s | PASS |
| `matrix_check.py` | all 2-element matrices: which validate the CPC rules (§4) | <1 s | PASS |
| `repair_checks.py` | repairs after verification (Prop 2.9(b),(d) and others) | 1 s | PASS |
| **T3-checks** (`T3-contexts-idealization-export.md`) | | | |
| `realizability.py`, `_deep.py`, `_sup.py` | brute-force realizability of contexts and bridges vs the anchored criterion (Thm 2.4(a)), with deep trees and suppositional contexts | 59 s, 1 s, 2 s | PASS (0 mismatches) |
| `realizability_frame.py` | frame semantics: Thm 2.4(b) necessity, 2.4(c) non-sufficiency, Prop 2.7 exactness | 9 s | PASS |
| `realizability_uninformative.py` | the informativeness hypothesis is needed: with uninformative bridges the criterion rejects realizable instances (117 mismatches, the expected outcome) | 15 s | PASS |
| `hygiene.py` | local essential use does not certify a reductio (Thm 1.9(c)) | <1 s | PASS |
| `pendulum.py`, `drag_sign.py` | pendulum example: export certificate, corrections, air effects; non-monotone drag-induced period error | 55 s, 87 s | PASS |
| `projectile.py` | projectile with quadratic drag: rigorous export certificate vs simulation (Thm 3.7) | 4 s | PASS |
| `learn_regions.py` | learning bridge validity regions: enclosure, analytic and Lipschitz certificates, conformal vs adversarial, coherence-only drift (§4) | 5 s | PASS |
| `leg_exact.py` | chair-leg problem (EuPhO 2025 T1(a)): exact reflected illuminance, flux conservation, comparison with Monte Carlo | 11 s | PASS |
| `sps_checker.py` | mini structured-physics-solution checker for the chair-leg problem; the adversarial variants are rejected (§6, revised after verification) | 1 s | PASS |
| `leg_mc_flux.py` | 40-million-ray Monte Carlo flux check of `leg_exact.py` | *slow, several GB of memory* | not run |
| **T5-checks** (`T5-steeper-simplicity-and-normativity-from-imitation.md`) | | | |
| `c1_user_example.py` | the user's 100-bit vs 10,000-bit example: windows of c and λ in which the good model wins | <1 s | PASS |
| `c2_pricing_and_kink.py` | private vs shared randomness pricing; the kink on a parity teacher | <1 s | PASS |
| `c3_rate_threshold.py` | rate-threshold theorem, hull tracing, product classes (0 violations) | 2 s | PASS |
| `c4_rules_toy.py` | inference-rule specialisation toy: which errors survive simplicity, coherence, Post and world filters | <1 s | PASS |
| `c5_incontext_persona.py` | in-context error learning (the "persona" pathology) | <1 s | PASS |
| `repair_checks.py` | re-checks of every referee issue in T5's verification log | 11 s | PASS |
| **T7-checks** (`T7-two-tier-coherent-inferential-learner.md`, §7) | | | |
| `lemma61.py` | Lemma 6.1: a pure schema is invalid iff some T/F substitution falsifies a closed instance (30,000 schemas, 0 mismatches) | 2 s | PASS |
| `ttl_sim.py` | end-to-end simulation of the two-tier learner (Cor 6.2) with an exhaustive step prover | 22 s | PASS |
| `duality.py` | Lemma 2.3: minimal hitting sets vs minimal conflicts | 1 s | PASS |
| `overlap.py`, `depth_nonmono.py`, `noisefree.py`, `ind_lgg.py`, `ind_sub_lgg.py` | referee checks: Prop 2.4(c), depth non-monotonicity of the audited set (Thm 4.1(iv)), noise-free variant of N₁, LGG does not recover induction or ∀E, and does with Sub-judgments (Thm 6.6(e)) | <1 s each | PASS |
| `prop32_voting.py`, `thm56_finite_d.py`, `two_point_bounds.py` | voting audit with mis-designated positions (Prop 3.2), finite-depth suboptimality (Thm 5.6(c)), rare-tag bounds (Thm 5.5, Thm 6.6(e)) | <2 s each | PASS |
| `hilbert_blame.py`, `matrix_witness.py` | blame ambiguity in a Hilbert practice with affirming the consequent (collateral {K, MP}); search for 2- and 3-valued matrices witnessing the cleanness of {S, DN, AC} (none, as reported) | <1 s each | PASS |
| `matrix4.py` | exhaustive search for 2-, 3- and 4-valued matrices witnessing cleanness of {S, DN, AC} (Open Problem 2) | 240 s, *slow* | PASS: no witness, 5.0M nodes for n = 4, \|D\| = 3, as in the note |
| **T1-code extras** | | | |
| `rho.py` | ρ_x ≤ 1 − max F ≤ 2ρ_x, with the constant 2 tight (Thm 6.4 consequences) | 6 s | PASS (worst ratio 2.0) |
| `ville.py` | Monte Carlo of Bayesian-conservative acceptance under the Ville bound (Prop 4.3; `ville2.py` is the exact version run by `run_all.sh`) | 2 s | PASS (every estimate below its bound) |
| `elast.py ... 4 2`, `abstr2.py 2 4 15`, `icclimb.py`, `icsearch.py`, `thm31b_counterexample.py` | the slow variants listed in `run_all.sh` (Conj 3.8 evidence, the Thm 3.1(b) counterexample) | *slow, minutes* | not run |
| `terms.py`, `unify.py` | helper libraries imported by the other scripts | n/a | n/a |
| **lit/L11-scripts** (`L11-justification-and-reflective-equilibrium.md`) | | | |
| `coherence_checks.py` | twelve exact or brute-force checks: witness-model posteriors and coherence measures (Lewis, Bovens–Hartmann, Olsson), agreement and conditional independence, the gambler's fallacy chain, Miller–Sanjurjo, frame validity of p → □p, rules vs premises, imitation-MDL absorbing systematic errors | <1 s | PASS |
| **lit/L3-scripts** (`L3-learning-to-reason-and-limit-inquiry.md`) | | | |
| `axiom_induction_coherence.py` | are the read-outs of "Solomonoff axiom induction" coherent probabilities? (two read-outs are not, the random completion is) | <1 s | PASS |
| `sigma2_weak_coherence.py` | Thm D'(c): computable, weakly coherent credences that gradually verify Σ₂ sentences (0 pair violations, false sentences at 0 at every change stage, blocked true sentences explained) | 21 s | PASS |
| **lit/L9-scripts** (`L9-physics-solutions-verification.md`) | | | |
| `ballistics.py` | olympiad worked example: minimum launch speed to clear a sphere from its top (v_min² = 4.5 gR) | 29 s | PASS |
| `protostar.py` | free-fall collapse time, exact vs constant g (0.85% error), Kepler limit, when collapse halts (γ > 4/3) | 2 s | PASS |
| `leg.py`, `leg2.py` | Monte Carlo of the chair-leg reflection (4 and 8 million rays) vs the far-field formula; MC/theory ratios within about 3% far from the leg and up to 34% close to it, as discussed in L9 | 5 s each | PASS |
