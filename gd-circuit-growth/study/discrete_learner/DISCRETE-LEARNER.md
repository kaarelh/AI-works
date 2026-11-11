# DFG: a discrete learner that needs less data than the study's networks on the toy Boolean suite

Part 6 of the study (25 October 2026). All tables: [`RESULTS.md`](RESULTS.md), generated from `results/*.json`.

**Question (from the user).** Use the picture of what gradient descent does (Parts 1–5 of this study) to build a *more
discrete* learner. It should get test performance at least as good as gradient descent's with similar compute and data,
at least on the toy problems where gradient descent does well.

**Proposal.** *Discrete feature growth*, DFG (`dfg.py`), keeps the networks' strategy and replaces their search.

What it keeps:
- It grows features greedily, cheapest first.
- Each feature is tested against the noise of the current residual.
- A feature on inputs it already uses is cheaper.
- It fits a linear background.
- It predicts with the sign of a fitted readout on what it has grown.

What it replaces: it finds features by exhaustive enumeration of Fourier characters, with union-bound tests, instead of
by noisy local search in weight space. Each search runs on a subsample whose size is set by the compute budget, so a fit
stays within a fixed fraction of one network run.

**Result** (Numerical; details below). Against the study's networks (μP MLP d-128-128-1, Adam, 20000 steps or 40000 at
d = 120, the same training sets and test set):
- **Blind test of the final version** (v1.1 on held-out suite 2, committed after v1.1): smaller n* on
  all 7 targets. The median factor is 3.1× less data, and per fit DFG uses at most 0.26 of one network run's FLOPs.
- **Blind test of the frozen first version, without its degree-5/6 search** (held-out suite 1, 12 targets; that search
  was added knowing par5 was in the suite): smaller n* on 11 of 12, median 2.7×. It never learns par5, which needs that
  search. With the search, frozen v1 gets 12 of 12 (median 2.8×), but that run is not blind.
- **Development suites:** 21 designed targets and 20 random formulas. Clearly smaller n* on 40 of 41, median 5–6×; the 41st, and3, is a tie (101 against 94).
  The advantage grows with d. On the same 7 targets the median factor is 6.0× at d = 15, 17.8× at d = 30 and 31.7× at
  d = 60, and 45.5× on 4 of them at d = 120. The networks' n* for par2 and par3 grows like d^{k−1}; for par4 it grows
  like d^{2.4} between d = 30 and 60.
- **Where it is worse.** Per (target, n), DFG is worse by more than 0.02 in 0–10% of cells, mostly at n = 16–64,
  where both learners are near the constant predictor's error (DFG sometimes above it). The persistent exception is MAJ5 ⊕ MAJ5 at n = 64–256. So "at least as good"
  holds for n* on every target of the blind tests except par5 in the K_hi = 4 run. It does not hold for every
  (target, n) cell.
- **Compute.** DFG uses less compute than the networks in FLOPs everywhere: at most 0.46 of a network run per fit, and
  under 0.08 at n ≤ 512 at d = 30. In recorded CPU time it is comparable at d = 30 (0.25–1.7× a network at n = 16384)
  and 2–4× faster at d = 120.

**What this says about gradient descent** (Heuristic). This is a reading consistent with these results, not tested by
them. On these targets the networks' extra data cost is the price of *searching in weight space*. Part 3's heuristic law,
fitted to the networks, has gradient descent paying for search in samples: n* ≈ c·N(k)/ρ² with
N(k) = d·max(1, d/a)^{k−2}, which is about d^{k−1} for a k-parity. The measured exponents are 1.0, 1.9 and 2.4 for
k = 2, 3 and 4, and k = 4 is also limited by the networks' step budget. DFG pays for search in compute, N candidates per
class, and only about 2 ln N in samples (its test needs n ≳ 2 ln(4KN/δ)/ρ²). That is roughly 2k ln d for a k-parity, the
Occam rate. Under the networks' own FLOP budget, exhaustive search is affordable at d = 30 up to degree 4 on all the
data, and up to degree 6 on a subsample. So at d = 30, DFG is limited by data, not by the FLOP budget, for features up
to degree 4. At d ≥ 60 the budget binds for DFG too. Heuristically, gradient descent spends data where an exhaustive
search spends FLOPs.

One caveat: search is not the only difference between the two learners. DFG's dictionary, Fourier characters on the
uniform cube, is the class the targets were built from, and these experiments do not separate the two effects. DFG is
in effect a greedy, budgeted form of the classical low-degree algorithm, designed for this function class. The networks
are generic and use one untuned configuration.

## 1. The learner, and where each piece comes from

| what the networks were seen to do (Parts 1–5) | DFG's discrete counterpart |
|---|---|
| Features are grown greedily, one bundle at a time, in order of detectability (plateaus and drops; Part 5) | rounds of exhaustive search; everything that passes the test this round is added |
| A feature's cost is set by its correlation with the **residual** against the noise of the competing directions ("noise-limited greedy growth", Part 2) | test \|mean(r χ_S)\| > c·s·sqrt(2 ln(4KN/δ)/n), with s = rms(residual) and N the size of the candidate class (c = 1, δ = 0.1, K = 4). s falls as features are fit, so weaker features become detectable later |
| Composition: features on a term's own inputs make it cheaper (the user's x1x2, x3x4 → x1x2x3x4 prediction, confirmed in Part 4) | small candidate classes, hence low thresholds: *extensions* S ∪ {j}, S ∪ {j, l} of current features; *local* search over every subset of the inputs in use (Walsh transform on V, up to junta completion) |
| A kernel background plus a few grown features (Part 3) | a *linear block* (all d inputs at once, when a χ²_d test says the linear part has signal) and a final Hebbian step on the residual |
| Dense targets: one direction grown from many weak correlations; spiked-estimation shrinkage 1 − N/(nρ²) | a *spectral block*: eigen-directions of the residual pair matrix above the noise edge 2s·sqrt(d/n) (spiked-eigenvalue shrinkage), features (u·x)² |
| On every plateau the network computes the sign of a truncated Fourier expansion of the target (Part 5) | readout: sign of the fit on the grown features; least squares (v1), refined by logistic regression (v1.1) |

The search classes are:
- global: degrees 1–3 every round and degree 4 in the first round, on all the data at d ≤ 30 (subsampled at d = 60 and
  120), and degrees 5–6 in the first round on a subsample sized by the budget;
- extension;
- local;
- the two blocks.

Engineering:
- *Stopping.* Stop when nothing passes, or when every training sign is right.
- *Least squares.* Kept to p ≤ n/2 features, so it never sits at its interpolation peak.
- *Small n.* With few points the union bound passes nothing: at n = 16 even a perfect one-input target fails it. For
  n ≤ 512, a "forced" variant takes the best-scoring character anyway, at most twice. Cross-validation chooses it over
  the default only if it wins a paired (McNemar) test.
- *Compute budget.* Each search runs on the first m training points, with m chosen to keep it within a fixed share of
  one network run:
  - degree 4: 15% (25% in v1);
  - degree 3 and extensions: 3% per round each;
  - degrees 5 and 6: 3% each.

  In v1.1, a degree-3, degree-4 or two-input-extension search whose m would fall below 32 is skipped; v1 used at least
  32 points instead. In both versions, degrees 5–6 are skipped below m = 64. The cross-validation folds share half the
  budget (v1.1). A new round starts only below 75% of the budget. At d = 30 the budget binds only for degrees 5–6
  (m ≈ 1400 and 150). At d = 60 and 120 it binds for degree 4 (m ≈ 2200 and 360), and at the largest n for degree 3 too
  (m ≈ 13000 and 4400).

**What is discrete.** The hypothesis is a set of Boolean features — parities χ_S and, for dense targets, a few quadratic
forms — found by enumeration and admitted by explicit tests. The only continuous parameters are the readout weights.

**v1 and v1.1.**
- *v1* (`dfg_frozen_359a6b61.py`, frozen at commit 359a6b61) is the version run blind on held-out suite 1.
- *v1.1* (`dfg.py` with `readout="logit"`, commit 0220cf04) was made after that run. It fixes one problem the run
  showed, the readout, and one an audit found, the budget:
  - *Readout.* On a dense halfspace (thr30) v1's least-squares readout plateaued at 5–7% error, where the networks reach
    1%. Square loss is the wrong readout for a halfspace: sign(LS) of a threshold function stays a few percent off. 15
    Newton steps of L2-regularized logistic regression on the same features (λ = 1e-4, when n ≥ 8p) fix it:
    - on a dense halfspace used during development, from 0.056 to 0.007 at n = 16384 (a console run, not recorded);
    - on thr30, from 0.054 to 0.010 (RESULTS.md, post-hoc).
  - *Budget.* An independent compute audit found that v1's small-n cross-validation gave every fold the whole budget.
    At d = 120 that cost up to 2.7 runs of a 20000-step network per fit, about 1.4 of the 40000-step runs the networks
    actually had there.

  v1.1 also changes:
  - the degree-4 share, from 25% to 15%;
  - a 0.75 hard cap per fit;
  - the 40000-step budget at d = 120;
  - the small-search rule: it skips searches with m < 32, so at n = 16 it searches no character of degree ≥ 3. That
    rule is why v1.1's par3 / par4 n* at d = 30 (28 / 52) are higher than v1's (16 / 21).

  Held-out suite 2 was committed after v1.1 (70c604eb). DFG's code was not changed afterwards except for its name and
  the input-permutation wrapper (5716239b), and DFG was first run on the suite after that. So it is blind for v1.1.

## 2. Protocol

- **Same data as the networks.** An audit checked `harness.train_data` against `nn_train.make_data` row for row, for
  every n and seed, across the suites and d values. The networks' saved weights reproduce their recorded training error
  on these sets. The test set is the same 4096 points, and DFG sees only (X, y) and an rng.
- **Network reference.** The networks' final test error at each (n, seed). The step count is 20000, or 40000 at d = 120,
  where the study trained longer.
- **Compute.** FLOPs (multiply-add = 2), counting everything DFG does in a fit, including the cross-validation fits. An
  audit's independent ufunc-level count agrees with DFG's counter to within 0.98–1.00. Prediction is counted for
  neither side. The budget unit is one network run, 6P·64·T + 10P·T with T the step count (1.62·10¹¹ FLOPs at d = 30),
  which is what each (n, seed) network costs; vmap shares no computation between networks.
  - *CPU time.* DFG's FLOPs run at about 8–12 GFLOP/s at d = 30 and 15–18 GFLOP/s at d = 60 and 120, measured as CPU
    time recorded in `results/*.json`; that is float64 numpy driven from Python. The networks run at 32–50 GFLOP/s
    (float32 under XLA; audit timing). So at n = 16384 a DFG fit takes 0.25–1.7× a network's CPU time at d = 30, and
    0.26–0.52× at d = 120. The main claim is about FLOPs.
- **What is in-sample.**
  - *Designed suite.* DFG's settings — notably the small-n rules and the n ≥ 4d gate on the spectral block — were chosen
    by looking at its test error here, so these results are in-sample.
  - *Random-formula suite.* It was run twice with intermediate versions and read, so it is a development check, not
    out-of-sample.
  - *Held-out suite 1* (12 targets, `make_dl_heldout_suite`, commit 805bff0e). Its networks were trained, and their
    curves inspected, before DFG v1 was frozen; DFG was run on it only after the freeze. One exception: the degree-5/6
    search was added knowing that par5 was in the suite, and par5's result depends on it entirely. The table therefore
    also shows v1 *without* that search (K_hi = 4). That row is blind except for one point that git cannot settle. The
    spectral block was committed together with the suite (805bff0e), and its docstring works through MAJ5 ⊕ MAJ5,
    which is the suite's majxor. majxor's win (1.7×) depends on that block.
  - *Held-out suite 2* (7 targets, `make_dl_heldout2_suite`) is blind for v1.1. dfg.py is unchanged since 0220cf04
    apart from its name, and the permutation wrapper was added before any run on the suite. The suite was written by
    DFG's designer, mostly from families already in the development suites. So it is blind to tuning, not to the choice
    of targets. Its smallest win, sym8 (1.3×), is marginal across seeds.

## 3. Results

The summary below is copied from `RESULTS.md`, which also has the per-target tables: n* and the test error at
n = 64 / 256 / 1024 / 4096 for both learners. Definitions:
- *Data factor:* the networks' n* divided by DFG's.
- *Cells:* the 11 values of n on the grid, for each target.
- *s.e.:* from the seed-to-seed spread of both learners.

| suite, learner | DFG clearly better (n* ratio < 2^-0.25, or networks never) | clearly worse | median data factor (networks' n* / DFG's) | geometric-mean data factor | (target, n) cells where DFG's error exceeds the networks' by > 0.02 (of these, by > 2 s.e.) | max FLOPs per fit / one GD run |
|---|---|---|---|---|---|---|
| held-out 2 (7 targets), v1.1, inputs permuted per fit - blind | 7 | 0 | 3.1x | 3.4x | 6 (3) of 77 | 0.26 |
| held-out 1 (12), frozen v1 without the degree-5/6 search - blind | 11 | 1 | 2.7x | 3.7x | 13 (12) of 132 | 0.17 |
| held-out 1 (12), frozen v1 (degree-5/6 search added knowing par5 was in the suite) | 12 | 0 | 2.8x | 5.2x | 11 (10) of 132 | 0.23 |
| held-out 1 (12), v1.1 - post-hoc | 12 | 0 | 3.0x | 5.3x | 6 (5) of 132 | 0.43 |
| random formulas (20), v1 - used as a check during development | 20 | 0 | 6.0x | 6.8x | 9 (5) of 220 | 0.14 |
| designed (21), v1 - in-sample | 20 | 0 | 5.4x | 7.0x | 7 (2) of 231 | 0.19 |
| designed at d = 15 (7), v1 (the budget binds only for the degree-6 search at n = 16384) | 7 | 0 | 6.0x | 6.3x | 1 (0) of 77 | 0.08 |
| designed at d = 60 (7), v1.1 | 7 | 0 | 31.7x | 36.3x | 0 (0) of 77 | 0.46 |
| designed at d = 120 (4), v1.1 | 4 | 0 | 45.5x | 30.7x | 0 (0) of 29 | 0.18 |

![DFG's n* against the networks' n*](../figures/dfg_nstar.png)

*Figure (`plot_nstar.py`).* DFG's n* against the networks' n*, for every target of every suite, on log axes. Points
below the dashed line are targets where DFG needs less data. Blind: held-out 2 (v1.1) and held-out 1 (frozen v1 without
the degree-5/6 search; par5, which it never learns, is drawn at the top). Development: designed and random at d = 30,
frozen v1, inputs not permuted. Other d: v1 at d = 15, v1.1 at d = 60 and 120.

**Reading the table.**
- **Blind tests.** These are rows 1 and 2.
  - *Held-out 2* is the blind test of the final proposal, v1.1: DFG has the smaller n* on all 7 targets (median factor 3.1, geometric mean 3.4), at
    most 0.26 of a network run per fit. The worse cells are 6 of 77, and 3 of them beyond seed noise, all at n ≤ 64:
    dnf4x2@64 and sym8@32 and @64. The smallest gains are on the dense symmetric function sym8 (|x1 + … + x8| ≥ 4,
    1.3×), the random formula h2rf1 (1.5×) and the 2-DNF (1.9×).
  - *Held-out 1* blind (frozen v1 without the degree-5/6 search): DFG has the smaller n* on 11 of 12 targets, by a
    median factor of 2.7. It never learns par5: it has no route to a degree-5 character without the degree-5 search,
    while the networks learn par5 at n ≈ 7200.
- **Size of the advantage.** It depends on the target.
  - *Dense targets* — majorities, halfspaces, intersections of halfspaces, MAJ5 ⊕ MAJ5, sym8: a factor 1.2–4.4. The
    4.4 is thr20 on held-out 2; all the others are at most 3.5. Heuristically (no linear baseline was run), this is the
    difference between a well-fitted linear readout and the networks' learned features.
  - *Sparse targets* — parities, staircases, majorities of parities, multiplexers, random formulas: a factor 1.5–250,
    growing with d. The low end (1.5–3×) is mux6, the DNFs and the small random formulas. The parities at d = 60 and
    120 reach about 250×. The d-scaling rows are in-sample designed targets, mostly sparse, so their median rises partly
    because the target mix changes. For maj9 the factor stays at 1.5–2.7× across d.
  - *Where the networks need large n, DFG does not.* For par3 the networks need 843 / 3410 / ~14000 at d = 30 / 60 / 120;
    DFG needs 28 / 28 / 56. For par4: 2728 / 14255 for the networks at d = 30 / 60, against 52 / 56. These DFG values
    are from v1.1 with the inputs permuted per fit (`check_parity_perm.py`, `results/parity_perm.txt`); v1.1 gives the
    same values unpermuted. That is the 2k ln d against d^{k−1} contrast from the opening section.
- **Per cell (target, n).** DFG's error exceeds the networks' by more than 0.02 in 0–5% of cells on most rows, in 8%
  (6 of 77) on held-out 2, and in 8–10% on held-out 1 under v1. Most of these are at n = 16–64, where both learners are
  near the constant predictor's error, and DFG is sometimes worse than that constant (e.g. sym8@32: 0.40, against 0.34
  for the networks and 0.28 for the constant). The others are:
  - *In v1:* thr30 at n ≥ 2048, the least-squares readout plateau, fixed by v1.1.
  - *In both versions:* MAJ5 ⊕ MAJ5 at n = 64–256, where the networks reach 0.36 at n = 256 and DFG is at chance until
    its spectral block fires; DFG then leads, 0.02–0.03 against 0.16 at n = 1024.
  - *In v1 without the degree-5/6 search:* par5 at n = 8192 and 16384 (0.50 against 0.01 and 0.00).
  - *Designed suite:* parmaj@128 (0.47 against 0.44).
- **Tie-break bias.** On the designed, random, held-out-1 and d = 15 / 60 / 120 rows, DFG saw the inputs in their natural order, and every
  suite puts the relevant inputs first. At n = 16–32, DFG's forced guess then wins ties toward the true target. The
  reproduction audit measured this on frozen v1: with the columns permuted, par4@16 goes from 0.17 to 0.40 error and
  par3@16 from 0.00 to 0.13. On the designed suite the mean log2 n* ratio moves by about +0.03. Held-out 2 and the
  ablations were run with the inputs permuted at random per fit (`harness.Permuted`), which removes the bias. For the
  parities at d = 30, 60 and 120, v1.1 gives the same n* permuted or not (`results/parity_perm.txt`).
- **Compute.** The largest per-fit compute is 0.08–0.46 of one network run, depending on the suite. It occurs at
  n = 16384, in the degree-4 search, the extensions, least squares and the logistic refinement. At n ≤ 512, DFG uses at
  most 7.5% of a run at d = 30 (under 0.3% at n ≤ 32), and up to 14–15% at d = 60 and 120. The networks always spend
  their full 20000 steps (40000 at d = 120).
- **Robustness.**
  - *Fresh training seeds* (5–7) at the two grid points bracketing DFG's n* reproduce the recorded errors for stair5,
    rmaj9, parmaj and par3 (reproduction audit). The audit scripts and logs for this bullet, the FLOP count and the
    permutation numbers are in the session scratchpad, not in the repository.
  - *mux is the exception:* on 9 fresh seeds its n* is about 87 rather than the recorded 65, so its factor is about 13,
    not 18.
  - *An alternative n* definition* (smallest grid n from which the error stays ≤ 0.1) changes the mean log2 ratios by at
    most 0.10–0.15 (two audits).

## 4. Ablations: which ingredient carries the gain

DFG v1.1 with the inputs permuted per fit, on 7 designed targets. Each row removes one ingredient; the entries are n*,
from `RESULTS.md`.

| variant | maj9 | thr10 | par4 | stair5 | mux | rmaj9 | sparsepoly | mean log2 n* vs full |
|---|---|---|---|---|---|---|---|---|
| full | 107 | 146 | 52 | 111 | 64 | 167 | 93 | +0.00 |
| K3-no-hi | 107 | 152 | never | 113 | 158 | 167 | 93 | +1.34 |
| coef-readout | 309 | 295 | 52 | 112 | 63 | 210 | 99 | +0.42 |
| label-noise | 107 | 148 | 56 | 165 | 111 | 188 | 97 | +0.25 |
| ls-readout | 107 | 170 | 52 | 112 | 65 | 167 | 101 | +0.05 |
| no-background-no-small-n | 107 | 146 | 52 | 112 | 110 | 167 | 107 | +0.14 |
| no-blocks | 168 | 144 | 52 | 111 | 61 | 178 | 80 | +0.07 |
| no-composition | 107 | 142 | 52 | 196 | 107 | 167 | 108 | +0.25 |
| networks | 263 | 563 | 2728 | 1514 | 1156 | 2027 | 2205 | |

**Reading the ablations.**
- **No ablation loses to the networks on these targets, except in two cases:** par4 when the degree-4 search is
  removed (never learned), and MAJ9 with the raw-coefficient readout (309 against 263).
  - *Attribution by elimination.* The gap is therefore plausibly carried by what every variant keeps: exhaustive search
    over the Fourier dictionary with union-bound tests. That was not ablated directly, so the attribution is heuristic.
  - *Size of the other ingredients.* Each is worth 1.1–3× on one class of targets.
  - *Noise.* These are 3-seed runs without error bars, and changes below about 1.2× may be seed noise.
- **The global search depth decides which leaps are possible.** Without degree 4, par4 is never learned: it has no
  lower-order signal, so neither extensions nor local search can reach it. mux gets 2.5× worse, because its largest
  term x1x2x3x4 then has to be built by extension. This is the discrete analogue of leap complexity. The difference
  from the networks is that DFG's cost of a leap is ln C(d, k) in samples and C(d, k) in compute, rather than about
  d^{k−1} in samples.
- **The readout fitted to the residual** (least squares) against raw Fourier coefficients: 2.9× on MAJ9, 1.7× on thr10
  (295 against 170), 1.3× on rmaj9. The estimation noise of a coefficient is set by the residual, not by the label, once
  the big terms are fit. The logistic refinement adds a further 1.2× on thr10 (170 to 146), 2.0× in all.
- **Thresholds scaled by the residual's noise** against the label's: 1.5× on stair5, 1.7× on mux, 1.1× on rmaj9. These
  are the staged targets, where later terms become detectable only once earlier ones are fit. This is
  "noise-limited greedy growth".
- **Composition classes** (extensions and local subsets): 1.8× on stair5, 1.7× on mux, 1.2× on sparsepoly. These are the
  targets whose high-degree terms sit on the inputs of their low-degree terms. It is the user's composition effect (Part
  4), and it helps the discrete learner in the same direction as the networks (Part 4 measured 1.2–1.6× for them).
- **The linear block** (kernel background): 1.6× on MAJ9. Without it the nine majority inputs must each pass an
  individual test.
- **The Hebbian background and the small-n variant:** 1.7× on mux and 1.15× on sparsepoly, at the smallest n.

The ablations were run on 7 targets to save time. The no-blocks variant also shows that the blocks cost a little on
sparse targets: sparsepoly goes from 93 to 80 without them.

## 5. Where DFG is worse, and its limits

- **The cells where DFG is worse.** These are listed per suite in `RESULTS.md`, and there are three kinds.
  - *Tiny n (16–64).* Both learners are near chance there. DFG's union-bound tests pass nothing, so it relies on the
    Hebbian background and the forced guess, and these are sometimes a few points worse than what the networks
    interpolate to.
  - *The dense halfspace thr30 at large n (v1 only).* That was the least-squares readout; v1.1 fixes it.
  - *MAJ5 ⊕ MAJ5 at n = 64–256.* The networks are partly there (0.36 at n = 256) while DFG is at chance.
    - *DFG's routes.* Its first route is the spectral block, which waits for n ≥ 4d and for an eigenvalue above the noise
      edge. It fires near n = 512, giving 0.21 error against 0.45 without it. The plain pair search on the 25 pair
      coefficients of about 0.14 learns the target by n = 1024 even without the block (framing review).
    - *The networks* start using the weak pair correlations sooner, from about n = 128.
    - *DFG overtakes them by n = 1024:* 0.03 in v1 and 0.02 in v1.1, against 0.16.
- **The inductive bias is narrow.** DFG's dictionary is characters on the Boolean cube (plus a few quadratic forms), and
  its tests rely on the characters being orthogonal under the uniform distribution. It is not a general-purpose learner:
  other input distributions, real-valued inputs and images would all need a different dictionary. The networks are
  generic. The claim is only the user's: as good or better on the toy problems where gradient descent does well.
- **Compute grows as d^K.** An exhaustive degree-k search costs about n·d^k. Under a fixed budget DFG subsamples, so a
  high-degree feature must have a large coefficient to be found: at d = 30 the degree-6 search sees about 150 points.
  Degrees 5–6 are skipped at d ≥ 60 (m < 64), and degree 4 is subsampled there (m ≈ 2200 at d = 60, m ≈ 360 at d = 120, in v1.1). A
  sparse degree-7 parity at d = 30 is out of reach for DFG under this budget; at n ≤ 16384 it is out of reach for the
  networks too.
- **One network configuration.** The reference is the study's fixed configuration: width 128, Adam lr 1e-3, batch 64,
  20000 steps (40000 at d = 120), square loss, the same for every target and n and never tuned. DFG's settings, by
  contrast, were tuned on the designed suite.
  - *How much the configuration matters.* Earlier parts found its n* moves by up to about 2× with width (4-parity: 1.9×
    from width 32 to 256, still falling) and by up to 1.6× with SGD. The step budget also limits the 4-parity at
    d = 15 and 60.
  - *Consequence.* That is below the blind median factor of 3.1, but comparable to the smallest blind wins (sym8 1.3×,
    h2rf1 1.5×, dnf4x2 1.9×).
- **CPU time.** Comparable to the networks at d = 30 (0.25–1.7× a network at n = 16384) and 2–4× faster at d = 120,
  despite float64 numpy against float32 XLA (Section 2).
- **DFG was designed knowing the task class.** Its dictionary (characters on the uniform cube) was chosen knowing the
  targets are Boolean functions of uniform ±1 inputs, and most of its settings were tuned on the designed suite. The
  networks were given no such knowledge. The comparison answers the user's question, whether a discrete learner can be
  at least as good on these problems. It does not say that DFG is a better general learner.

## Reproduce

```
cd study/discrete_learner
python run_eval.py dfg_frozen_359a6b61:DFG designed        # frozen v1; also random, dlheld (two halves were run), designed_d15
python run_eval.py 'dfg_frozen_359a6b61:DFG:{"K_hi": 4, "name": "dfg-c1.0-Khi4"}' dlheld
python run_eval.py 'dfg:DFG:{"readout": "logit", "permute": true}' dlheld2   # v1.1, inputs permuted
python run_eval.py 'dfg:DFG:{"readout": "logit"}' dlheld    # v1.1; also designed_d60, designed_d120
python check_parity_perm.py 30                              # also 60, 120 -> results/parity_perm.txt
./run_ablations.sh
python make_tables.py                                     # RESULTS.md
```
The network reference files are the study's `fixed_adam_<fn>.npz` (Part 1; held-out suites from
`SUITE=dlheld[2] python nn_train.py --fns all --out <dir>`).
