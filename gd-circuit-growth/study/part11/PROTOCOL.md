# Part 11 protocol: DFG alone

Written on 2 November 2026, before any Part 11 result was produced (one disclosed timing check below), and committed
before the runs start.

## The object

The user asked for a discrete method that is "one thing" rather than an ensemble, possibly one component of v3, as a
specific object worth studying, and for a paper about it like the Part 10 paper.

The object is **DFG v1.3, run alone**:
- the file `study/part10/hyb_portfolio3/dfg13.py`, md5 `69cabe5c50345cb24079198ed52b562f`, frozen at 19:44 UTC on
  27 October 2026 by Part 10's toy builder (identical to `part10/p10_sum/dfg13.py`);
- run as `DFG(readout="logit").fit(X, y, rng)`: its own cross-validation between the default and the forced variant at
  n ≤ 512, its own kernel background, and its own compute budget (shares of one network run, capped at 0.75 of one
  run per fit plus the small-n cross-validation, as in its docstring);
- every fit sees its input columns in a fresh random order (`discrete_learner/harness.Permuted`), as the Part 8–10
  portfolios did; name `dfg13-perm`.

Inside v3 the same code ran as two stacked members (default and forced), with a share of the budget and the stacker
choosing between them. Alone it chooses between them itself, by its paired cross-validation test. No line of
`dfg13.py` changes in Part 11, and nothing is tuned. Runner: `part11/eval_dfg.py` (toy suites) and
`part11/dfg_real.py` (tabular).

**Why this object** (chosen after Part 10's results were read): it is the one component of v3 that is a new learning
algorithm (the others are LightGBM, ExtraTrees, kNN, logistic regression and a stacker, or LightGBM on a fixed feature
bank); Part 8 found that the portfolios' toy results come from it; and its fitted model is an explicit, short list of
features. Its domain is ±1 inputs with two classes: of the study's tabular sets it runs on kr_vs_kp and mushroom only,
and it does not run on images.

## Questions and runs (all fixed here)

- **Q1, held out.** On `dlheld7` (12 targets, generated in Part 10 from the blind family, fixed in commit `dc70266c`
  before DFG v1.3 was designed, never used in its development): DFG alone against `nets_best` (the per-target best of
  the three network variants run there), each variant, `lin`, `hgb`, v3 and v2. Mean log2 n* ratio over targets both
  learn; clearly better / worse counts (|log2 ratio| > 0.25, or only one of the two reaches 10% error); per target.
- **Q2, every suite.** The same on all 11 toy suites (138 targets), each with its status, and DFG alone against v3:
  does the portfolio add anything on Boolean targets?
- **Q3, the dictionary without the search.** The thresholded low-degree algorithm `lowdeg`
  (`discrete_learner/sparse_fourier.py`, Part 6's feasibility check, unchanged): every character of degree ≤ 4, kept
  if |mean(y χ_S)| passes a union bound over its degree (c = 1, δ = 0.1), products of kept characters, readout
  sign(Σ kept coefficients). On all 11 suites, inputs permuted. It shares DFG's character dictionary and union-bound
  test but has no residual, no greedy rounds, no sum blocks or block moves, and no refitted readout.
- **Q4, input dimension.** DFG alone at d = 15, 60 and 120 on the `designed` targets the networks were trained on at
  that d (7, 7 and 4 targets; seeds 0 and 1, as Part 6's DFG v1.1 runs): n* against d, against the networks.
- **Q5, what the parts do.** Ablations: DFG alone with one constructor argument changed, on `designed`, `dlsymdev`,
  `dlfamdev`, `dlheld6` and `dlheld7` (65 targets), each compared with DFG alone on the same seeds.
  Seeds 0 and 1:
  - `nosums` `{"sums": false}`: no sum blocks (characters, linear and spectral blocks only);
  - `strict` `{"delta": 1e-4}` and `lenient` `{"delta": 0.9}`: every test threshold's log term moved by +6.9 and −2.2
    nats. If a target's data cost is set by the test, a stricter test raises its n*; if it is set by the search, it
    should move little;
  - `noeig` `{"sum_seeds": [0, 3, 2]}`: the block search without its eigenvector seeds;
  - `noblocks` `{"blocks": false}`: no linear block and no spectral block;
  - `nocomp` `{"max_ext_bases": 0, "local_max": 0}`: no extension or local (composition) classes.
  Seed 0 only:
  - `noweighted` `{"sum_inner": false}` (v1.2's block class);
  - `nosmalln` `{"small_n": false}` (no forced variant, no cross-validation);
  - `nobg` `{"background": false}` (no kernel background);
  - `lsread` `{"readout": "ls"}` (least-squares readout, no logistic refinement);
  - `K3` `{"K": 3, "K_hi": 3}` (global character search to degree 3 only);
  - `labelnoise` `{"noise": "label"}` (tests scaled to the labels' noise, not the residual's).
- **Q6, tabular.** DFG alone on kr_vs_kp and mushroom (binary / categorical inputs one-hot as ±1, as v3's DFG view),
  the standard learning curves and 3 seeds, against the MLP references, `hgb` and v3. For real-valued data the record
  is Part 7's three adaptations of DFG (frozen there), reported as context.
- **Q7, what it learns** (descriptive; seed 0 unless stated; checked by independent verifiers):
  - what DFG's fitted models contain, across target families (parities, staircases, multiplexers, majorities and
    halfspaces, compositions, formulas, symmetric and signed-sum targets), against the target's own representation in
    DFG's dictionary;
  - when a target's structure first appears in the model, against when its test would admit it;
  - the order in which DFG admits a target's characters, against the order in which the Part 5 networks acquire them
    (on the Part 5 targets);
  - false admissions: DFG on labels independent of the inputs;
  - where the compute goes.

## Fixed in advance

- Grids, seeds, test sets, n*, the clearly better / worse rule and the suite means are those of Parts 8–10. Network,
  `lin`, `hgb`, v1, v2 and v3 results are the existing files; nothing is re-run for them.
- If a run crashes, only harness-level fixes are allowed (paths, sharding, resumption), never a change to the learner;
  the crash is reported.
- **Held out.** For DFG v1.3, only `dlheld7` is held out. Every other suite was used in developing some version of
  DFG (v1.1 on `designed`, `random`, `dlheld`; v1.2 after exposure to `dlheld4`, `dlheld5`; v1.3 on `designed`,
  `dlsymdev`, `dlfamdev`, `dlheld6`) or was held out only for an earlier version. The ablations and the analyses are
  descriptions of the frozen learner, not tests of a design.

## Disclosures

- Before this file was written, a timing check fitted DFG alone on `dlheld7`'s f7_03 and f7_08 (seed 0; n = 64, 512,
  4096, 16384) and printed their test errors (0.246, 0.008, 0, 0 and 0.465, 0.012, 0.002, 0). Smoke tests of the
  ablations and of `lowdeg` used `designed` targets (maj9, stair5, par4). A first choice of `lenient`, δ = 10, crashed
  (a negative logarithm in the linear block's test) and was replaced by δ = 0.9 before any run.
- The object was chosen knowing v3's results on every suite, including `dlheld7`, where DFG is v3's toy member. The
  choice is post hoc; the code is not.

## Addendum (3 November 2026, 02:30 UTC): a post-hoc "core DFG" run

Written after every pre-registered run above had finished and its results had been read, so this is **post hoc**: an
analysis of the frozen learner, not a test of a design.

The single ablations change n* by less than the seed-to-seed spread for eight parts of DFG (`strict`, `lenient`,
`noeig`, `noblocks`, `nocomp`, `noweighted`, `lsread`, `K3`), and removing the kernel background lowers it slightly
(`nobg`, mean −0.10); only the sum blocks (`nosums`, +0.91), the small-n machinery (`nosmalln`, +0.12) and the
residual-scaled tests (`labelnoise`, +0.14) cost data when removed. Single ablations cannot show whether the removable
parts substitute for one another. One combined run asks whether a much smaller learner keeps DFG's results:

- **`core`**: `{"readout": "ls", "sum_inner": false, "sum_seeds": [0, 3, 2], "blocks": false, "max_ext_bases": 0,
  "local_max": 0, "K": 3, "K_hi": 3, "background": false}`, i.e. global characters of degree ≤ 3 and the signed-sum
  blocks (unweighted, searched from pair and single-input seeds; modulated, product and split blocks, the beam and
  forced blocks as in v1.3), union-bound tests scaled to the residual, a least-squares readout, and the small-n
  cross-validation between the default and forced variants. The code is the frozen `dfg13.py`; only constructor
  arguments change.
- Run on all 11 suites (138 targets), seeds 0 and 1, the standard grid, inputs permuted; compared with DFG alone on the
  same seeds and with the networks. Reported as post hoc wherever it is used.
