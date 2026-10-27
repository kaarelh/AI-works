# p9_bank: the Part 8 portfolio plus a screened bank of prototype-pair threshold bits (Part 9, builder I2)

Frozen code: `learner.py` (class `Learner`, default constructor, name `p9_bank`), md5 `51ae345ea1b0700b79c24a1ad781a139`.
`Learner` is the Part 8 portfolio `hybrid/hyb_portfolio/learner.py` (md5 063bcd91e0b221c948760ec1ba28e042) plus one
member, `bank`. The bank runs only when every input column is continuous and d >= 256 (the images); on every other input
the code path, the random stream and the result are those of the Part 8 file. The bank draws from its own random
generator (`default_rng([seed, 9209])`), so on images every other member's out-of-fold and final fit is also identical
to Part 8's; only the stacker sees one more member.

Development data: MNIST, Fashion-MNIST and `qd_dev` only, with errors measured on **validation rows of the training pool**
(the last 10000 rows of the seed-0 pool permutation, disjoint from every training prefix used, n <= 50000). See section 9
for one exception inherited from the session that was killed.

## 1. Algorithm (the `bank` member)

**Features.** Each feature is a discrete object: a pair of training points (a, b) of different classes and a threshold t,

  phi(x) = [ (x_a - x_b) . x > t ].

- a is a uniformly drawn training point; b is the nearest point of another class to a (squared Euclidean distance)
  within a random reference sample of <= 4000 training points;
- t sits halfway between the order statistic of the projection (x_a - x_b) . x over <= 2000 training points at a
  random quantile level and the next larger distinct value; each direction is offered with n_thr = 3 thresholds at
  stratified random levels (one in each third of [0.1, 0.9]). Projections are computed in float64.

**Screening (the search).** The bank is built in 8 rounds on a subsample S of the training rows (<= 15000). Each round
draws a fresh pool of 6k candidate bits (2k directions x 3 thresholds; k = F / 8), drops bits that fire on < 1% or
> 99% of S, scores each by its squared standardized correlation with the current multi-output ridge residual (one-hot
targets, summed over classes), and keeps the k best. The ridge fit on S (penalty 10 n_S / 1000, Cholesky on the
incrementally grown Gram matrix) is updated after every round, so later rounds look for what the earlier bits miss.
This is a forward-selection test over discrete candidates; nothing continuous is optimized.

**Readout (convex).** Ridge regression of the one-hot labels on the centred bits, closed form, on all training rows
(Gram matrix, sums and cross-products accumulated over row chunks, so adding rows is additive). The penalty lambda
(in units of N / 1000) is chosen on an internal validation split V (15% of the training rows, <= 5000): grid
{1, 10, 100, 1000}, then the best value x 3 and / 3, by the validation cross-entropy of softmax(tau * scores), with the
temperature tau fitted on V (1-d bounded search). The model is then refitted on all its training rows. Class
probabilities = softmax(tau * ridge scores).

**In the portfolio.** Out-of-fold probabilities exactly like the other members: in the holdout regime (n > 3000) the
bank is fitted on the n - h non-stacking rows, predicts the h stacking rows, and its final model is the same feature set
refitted on all n rows (the Gram matrix is a sum over rows, so this costs one more Cholesky); in the k-fold regime
(n <= 3000) one fit per fold plus a final fit on all n with its own screening. The stacker (Part 8, unchanged) weights it
against the other members.

**Size from the budget.** F is the largest value in {8000, 7000, ..., 500, 250} with F <= 5 x |S| whose projected cost
(`bank_cost`) fits min(0.6 x budget, 0.9 x budget - spent so far - 0.7 x the LightGBM charge). The LightGBM reserve
is there because the Part 8 compute audit found that charge up to 1.7x low on Fashion-MNIST. Resulting F on the dev images: 2496
at n = 1000 (k-fold, 6 fits), 5000 at n = 10000, 4496 at n = 50000, 4000 at n = 60000 (from the charged totals).

**Permutation invariance.** The member uses only Euclidean distances between images, inner products with differences of
training images, per-feature quantiles and the labels. A fixed permutation of the pixel columns leaves every one of
these unchanged, so with the same random seed the fitted model and its predictions are the same; with float64
projections and between-value thresholds this holds exactly in practice (`test_perm.py`, section 5). The other members are the Part 8 ones (trees, kNN, logistic
regression), also invariant.

## 2. What is discrete

| part | what it is | how it is chosen |
|---|---|---|
| directions | differences x_a - x_b of two training images (a pair of indices) | a at random, b by a nearest-neighbour search |
| thresholds | midpoints between consecutive distinct order statistics of a projection over training points | stratified random quantile levels |
| the bank | a subset of candidate bits | forward screening by residual correlation, in rounds |
| readout | ridge weights (continuous), penalty and temperature | closed form (convex); penalty and temperature by validation |

No neural network, no gradient descent, no continuous parameter inside a feature. The only continuous fits are the
convex ridge readout, the 1-d temperature and the Part 8 stacker. Borderline: the hyperplane normal x_a - x_b has
continuous entries, but it is a pair of data points, not a fitted vector; the threshold is an order statistic of the data.

## 3. FLOP accounting (multiply-add = 2; prediction not counted)

Charged by `fit_bank` as it runs; `bank_cost` projects the same terms, with every selected bit counted as its own
direction (an upper bound), and is only used to choose F.

| step | FLOPs |
|---|---|
| reference distances for the pairs (per round) | 2 U_r n_ref d + 3 U_r n_ref |
| directions, candidate projections on S | U_r d + 2 n_S d U_r |
| thresholds (sort of <= 2000 values per candidate), candidate bits and firing rates | m log2 m x F_c + 2 n_S F_c |
| screening scores | 2 n_S F_c C |
| Gram blocks on S (cross block and new block), target cross-products | 2 n_S s k + 2 n_S k^2 + 2 n_S k C |
| ridge on S after each round (Cholesky + 2 triangular solves for C columns), residual | s^3 / 3 + 4 s^2 C + 2 n_S s C + n_S C |
| final bits for every training row (U distinct directions) | 2 N d U + N F |
| final Gram matrix (the task's rule 2 N F^2, no symmetry discount), cross-products | 2 N F^2 + 2 N F C |
| each ridge solve (centring, Cholesky, solves) | 2 F^2 + F^3 / 3 + 4 F^2 C |
| validation scores and temperature search per penalty | 2 n_V F C + 6 n_V C x (function evaluations) |
| out-of-fold scores of the stacking rows | 2 h F C |

(U_r directions and F_c = 3 U_r candidate bits per round, s bits selected so far, k new ones, N training rows, C classes.)
The other members are charged as in Part 8 (kNN, LightGBM analytic, ExtraTrees, logistic, stacker).

## 4. Development (development data only; errors on validation rows of the training pool)

Validation rows: the last 10000 rows of the seed-0 pool permutation (`data.splits`), disjoint from every training
prefix used (n <= 50000; the n = 60000 cell has no free pool rows, so 50000 stands in for it). Scripts and logs:
`/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p9_bank2/` (`lib.py` (validation
loader), `bank2.py`, `exp15`-`exp20*.py`, `run_val.py`, `ident.py`, `r*.txt`, `rv_*.txt`; the frozen-run drivers in
`final/`); not kept in the repository.

**Member alone (F bits, ridge readout), n = 10000, validation error** (rows 1-7: scratch `bank2.py` or the
in-progress `fit_bank`, float32 projections and interpolated thresholds; rows 8-9: the frozen `fit_bank`):

| variant | MNIST | Fashion-MNIST |
|---|---|---|
| no screening, F = 4000 / 8000 (random pairs, 3 thresholds each) | 0.0463 / 0.0410 | 0.1409 / 0.1412 |
| same bits, multinomial logistic readout instead of ridge (F = 4000) | 0.0457 | 0.1419 |
| killed session's screening (one pool of 6F, round 0 random), F = 4000 | 0.0396 | 0.1366 |
| **fresh pool every round, round 0 screened, rate filter (adopted)**, F = 4000 | **0.0389** | **0.1289** |
| same, half the candidates aimed at low-margin points (b in the confused class) | 0.0392 | 0.1298 |
| same, 1 threshold per direction | 0.0380 | 0.1341 |
| same, pool 12F per round, all candidates aimed | 0.0373 | 0.1303 |
| adopted, F = 5000 (the size the budget gives at n = 10000) | 0.0371 | 0.1303 |
| adopted + second-layer AND gates (gates = 0.5 / 1.0), F = 5000 | 0.0387 / 0.0379 | 0.1327 / 0.1319 |

At n = 30000 (F = 4500): MNIST 0.0295 (gates 1.0: 0.0307), Fashion 0.1222 (0.1174), qd_dev 0.1591 (0.1593). The gates
help Fashion at n = 30000 and hurt MNIST everywhere; they are off. At n = 1000 more bits keep helping although F > n
(ridge): F = 1000 / 2500 / 5000 gives qd_dev 0.2752 / 0.2642 / 0.2525, MNIST 0.1134 / 0.0921 / 0.0907, Fashion
0.2005 / 0.1951 / -, which is why the cap is F <= 5 |S| and the penalty grid reaches 1000 (n = 1000 picks 300).
Screening is worth about a doubling of F on MNIST; the readout's loss (squared vs logistic) does not matter here.

**Whole learner, validation error, seed 0** (`run_val.py`; v1 = `hyb_portfolio`, same seed and stream; the versions differ
from the frozen file only as noted):

| dataset | n | v1 | p9_bank | bank member's out-of-fold error | best other member | bank's stacking weight | F |
|---|---|---|---|---|---|---|---|
| MNIST | 1000 | 0.0819 | 0.0792 | 0.106 | gbt 0.135 | 0.31 | 2496 |
| Fashion-MNIST | 1000 | 0.1777 | 0.1777 | 0.202 | gbt 0.206 | 0.04 | 2496 |
| qd_dev | 1000 | 0.2665 | 0.2381 | 0.290 | et 0.338 | 0.59 | 2496 |
| MNIST | 10000 | 0.0343 | 0.0326 (a) | 0.036 | gbt 0.047 | 0.38 | 5000 |
| Fashion-MNIST | 10000 | 0.1140 | 0.1140 (a) | 0.147 | gbt 0.134 | 0.05 | 5000 |
| qd_dev | 10000 | 0.1689 | 0.1598 (a) | 0.183 | gbt 0.189 | 0.43 | 5000 |
| Fashion-MNIST | 50000 | 0.1006 | 0.0996 (a) | 0.125 | gbt 0.105 | 0.08 | 4496 |
| MNIST | 50000 | 0.0206 | 0.0205 | 0.028 | knn_raw_1 0.026 | 0.23 | 4496 |

(a) before the float64 / midpoint-threshold change (section 5), which changes which bits are selected but not the
method. Every other member's out-of-fold error is identical between v1 and p9_bank in every row (same random stream).

**Non-image inputs.** `ident.py` (scratch): on satimage (n = 600), optdigits (n = 400) and a toy parity through
`common.ToyAdapter`, p9_bank and hyb_portfolio give identical predictions and identical FLOP counts.

## 5. Permutation invariance

`python3 test_perm.py qd_dev 2000` fits the member twice with the same seed, on the pixels as stored and with the
columns permuted by a random permutation, and compares scores on 2000 held-back pool rows. With float32 projections and
interpolated quantile thresholds (the killed session's version) it failed: prediction agreement 0.939, different
selected bits. The selection is a chain of discrete choices (argmax over candidates, threshold comparisons at tied
pixel values), and float32 summation order flips some of them. The frozen version computes projections in float64 and
puts each threshold halfway between an order statistic and the next larger distinct sample value; the test then gives
max |score difference| = 0, prediction agreement 1.0000, same features, same penalty, same FLOP count. (The Part 8
members are permutation invariant up to rounding: kNN distances, trees on single pixels, logistic regression.)

## 6. Compute

**Fit FLOPs** (own count, fraction of `common.budget_real` = 3 MLP runs): p9_bank uses 0.67-0.80 of the budget on the dev
cells, against 0.16-0.32 for v1; the bank takes 1.3e12 of 2.4e12 at n = 10000 and 3.1-3.2e12 of 6.2e12 at n = 50000-60000.
The Gram matrix is charged 2 N F^2 (no symmetry discount). `bank_cost` (the projection used to choose F) is 3-8% above
the charged count.

**CPU** (process seconds per fit under load from other jobs, validation runs): n = 1000: 49-116 s (v1 26-99 s);
n = 10000: 116-189 s (v1 80-161 s); n = 50000: 170-244 s (v1 181 s on Fashion). The bank member itself: 2-4 s at
n = 1000, ~35 s at n = 10000, ~50 s at n = 50000. Peak memory of a fit at n = 50000: 2.4-2.5 GB (v1: 1.9 GB).

**Prediction cost** (not counted, as for every learner): per query the bank needs U projections in d = 784 dimensions
(U = 2500-3900 distinct directions), F comparisons and an F x C product: about 2 d U + 2 F C = 4-6e6 FLOPs, ~10x an MLP's
2P = 5.4e5, and ~3% of the portfolio's kNN members (1.9e8 per query at n = 60000). Stored: U x d directions (float64,
16-25 MB), thresholds, F x C weights.

## 7. Full dev evaluation (frozen file, run once)

Run 27 October 2026, 00:26-00:42 UTC, with the frozen `learner.py` (md5 `51ae345ea1b0700b79c24a1ad781a139`, checked
before and after every call): `harness.evaluate(Learner(), [ds], ns=..., seeds=(0,))` on the **test sets** of MNIST,
Fashion-MNIST and `qd_dev`, as two calls per dataset (n = 1000 and 10000 under the tag `p9_bank-dev-small`; n = 60000
under `p9_bank-dev-large`, one n = 60000 fit at a time), merged into
`standard_tasks/results/p9_bank-dev__<ds>.json` (learner `p9_bank-dev`, seed 0; the part files
`p9_bank-dev-small__<ds>.json` and `p9_bank-dev-large__<ds>.json` stay next to it). Driver: `run_dev.py`, `merge.py`, `compare.py` (scratch). v1 and the MLP references are the
existing result files (seed 0 column).

| dataset | n | p9_bank | v1 (hyb_portfolio) | mlp_strong | log2(p9 / v1) | p9 vs mlp_strong | v1 vs mlp_strong | p9 budget fraction | v1 budget fraction | p9 CPU s |
|---|---|---|---|---|---|---|---|---|---|---|
| MNIST | 1000 | **0.0739** | 0.0789 | 0.0836 | -0.094 | better (-0.18) | tie (-0.08) | 0.67 | 0.29 | 53 |
| MNIST | 10000 | **0.0289** | 0.0318 | 0.0326 | -0.138 | tie (-0.17) | tie (-0.04) | 0.71 | 0.16 | 123 |
| MNIST | 60000 | 0.0194 | 0.0198 | **0.0143** | -0.029 | worse (+0.44) | worse (+0.47) | 0.73 | 0.26 | 191 |
| Fashion-MNIST | 1000 | 0.1844 | **0.1839** | 0.1930 | +0.004 | tie (-0.07) | tie (-0.07) | 0.70 | 0.32 | 123 |
| Fashion-MNIST | 10000 | 0.1299 | 0.1300 | **0.1271** | -0.001 | tie (+0.03) | tie (+0.03) | 0.79 | 0.24 | 184 |
| Fashion-MNIST | 60000 | 0.1077 | 0.1072 | **0.0966** | +0.007 | worse (+0.16) | worse (+0.15) | 0.81 | 0.34 | 258 |
| qd_dev | 1000 | **0.2402** | 0.2622 | 0.2696 | -0.126 | better (-0.17) | tie (-0.04) | 0.67 | 0.30 | 80 |
| qd_dev | 10000 | **0.1612** | 0.1680 | 0.1749 | -0.060 | tie (-0.12) | tie (-0.06) | 0.72 | 0.17 | 175 |
| qd_dev | 60000 | **0.1302** | 0.1341 | 0.1324 | -0.043 | tie (-0.02) | tie (+0.02) | 0.74 | 0.26 | 237 |

Verdicts: the Part 8 rule (error ratio beyond 10% and difference beyond 2 s.e., 10000 test points); log2 error ratio in
brackets. `mlp_strong` is the per-cell hindsight best of the MLP result files at all nine cells (`mlp`, `mlp_l2unit`,
`mlp_strong`, `mlp_strong1`; the `mlp_best__mnist/fashion_mnist.json` files hold the older Part 7 best, which is worse
at every cell, and `qd_dev` has none), so the means against `mlp_best` and against `mlp_strong` coincide:

- **mean log2(err / mlp_best err) over the 9 dev cells: p9_bank -0.011, v1 +0.043** (difference -0.054);
- by dataset (mean log2 p9 / v1): MNIST -0.087, Fashion-MNIST +0.003, qd_dev -0.076;
- by n: 1000: -0.072, 10000: -0.066, 60000: -0.022;
- against `mlp_strong`: 2 cells better (MNIST 1000, qd_dev 1000), 5 ties, 2 worse (MNIST and Fashion-MNIST at 60000,
  both also worse for v1); v1 has 0 better, 7 ties, 2 worse.

The test results follow the validation picture: clear gains on MNIST and QuickDraw at n <= 10000 (the bank is the best
or second-best single member there), small gains at n = 60000 on those two, and nothing on Fashion-MNIST (within 0.05
points of v1 at every n). The large-n gap to the strong MLP on MNIST and Fashion-MNIST is essentially unchanged.
Budget: 0.67-0.81 of `common.budget_real` (own count), all fits within budget; CPU 53-258 s per fit (machine shared with
three other jobs); peak memory 2.55 / 2.56 / 2.75 GB at n = 60000 (MNIST / Fashion / qd_dev).

## 8. Weaknesses

- **It does not close the large-n gap.** The member alone is far from the strong MLP at large n (Fashion n = 50000:
  12.5% out of fold, against LightGBM's 10.5% and the MLP ensemble's 9.7% on test); its stacking weight there is 0.08.
  The gain at n = 60000 (test) is 0.04 points on MNIST and 0.4 on qd_dev, and none on Fashion-MNIST. A ridge readout on F <= 5000 bits is a fixed-feature
  linear model; F is capped by the 2 N F^2 Gram cost, and an iterative solver (to allow F ~ 10^4 at n = 60000) was not
  built.
- **Fashion-MNIST:** no gain at any n (validation ties at 1000 and 10000; test within 0.05 points of v1 at all three
  cells, slightly above it at 1000 and 60000).
- **Budget:** the bank takes most of the remaining budget (0.6 x budget at most); the learner uses 0.7-0.8 of the
  budget against v1's 0.2-0.3, and more CPU. The F schedule (`bank_cost`) relies on the LightGBM charge, which the
  Part 8 audit found up to 1.7x low; a reserve of 0.7x that charge is kept, and the total stays below 0.9 by
  construction except for the final refits of the other members.
- **Selection on a subsample:** features are screened on <= 15000 rows; the penalty and temperature on a 15% split.
- **Borderline discreteness:** the hyperplane normals x_a - x_b are differences of data points (continuous entries),
  the thresholds are order statistics; nothing is fitted inside a feature, but the features are not Boolean formulas of
  pixel bits.
- **Development on the dev cells:** the design choices were made on validation rows of the same three datasets whose test
  cells the integration rule scores; the held-out QuickDraw sets are the real test.
- **Dead option:** `fit_bank(gates > 0)` (second-layer AND gates) is in the file but off in `Learner`.

## 9. The restart and the resumption

The first I2 session worked from about 22:50 to 23:45 UTC on 26 October and was killed by a container restart before
it froze. It left: `learner.py` (portfolio + an earlier bank: one candidate pool of 6F bits, round 0 random, linear-
interpolated quantile thresholds, float32, Gram counted as N F (F + 1), share 0.45, F <= 4500), `test_perm.py`, and
scratch experiments `p9_bank/exp1`-`exp14.py` with a few result lines (most stdout logs were lost). Its experiments
covered dense random and sparse signed-subset directions, random vs nearest-other-class prototype pairs, n-tuple cells
over bits with a sparse logistic readout, ExtraTrees leaves + logistic, one-vs-one pair banks, a hard-example second
stage, ball features ||x - c||^2 < r, logistic vs ridge readouts and LightGBM on the bits; the surviving lines show
ExtraTrees-leaf embeddings at 3.8-5.1% (MNIST n = 10000) and the bank at 3.1% (MNIST n = 60000, F = 4000).

**Deviation found on resumption.** That session's loader (`lib.get`) and its full-learner runner (`run_one.py`) scored
on the **test split** of MNIST and Fashion-MNIST during development (e.g. its whole-learner runs at n = 60000: MNIST
0.0192, Fashion 0.108). The protocol asks for validation splits during development. MNIST and Fashion-MNIST test results
were already known from Part 8, but these were new test-set looks by a Part 9 builder. No surviving log shows `qd_dev`
test use; whether the lost logs included any is unknown. The resumed session switched every development evaluation to
validation rows and touched the test sets only in the frozen run (section 7).

**What the resumed session changed** (23:50-00:26 UTC on 26-27 October): the fresh-pool screening with a screened first
round and the rate filter; stratified thresholds; the Gram charge 2 N F^2 (the task's rule); budget share 0.45 -> 0.6,
F up to 8000 and <= 5 |S|; the penalty grid with refinement; float64 projections and midpoint thresholds (exact
invariance); the optional gate layer (off); `test_perm.py` scoring held-back pool rows instead of test rows. Freeze:
00:26 UTC, md5 `51ae345ea1b0700b79c24a1ad781a139`.

## How to run

```
cd gd-circuit-growth/study/part9/p9_bank
python3 test_perm.py qd_dev 2000                      # invariance check
python3 - <<'PY'                                       # one fit
import sys, numpy as np, importlib.util
sys.path.insert(0, "../../hybrid"); sys.path.insert(0, "../../standard_tasks")
spec = importlib.util.spec_from_file_location("p9_bank_learner", "learner.py"); M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
import harness
harness.evaluate(M.Learner(), ["qd_dev"], ns=[1000], seeds=(0,), tag="p9_bank-try")
PY
```
As a `common.load_learner` spec from `study/hybrid`: the module is outside `hybrid/`, so load it by path as above.
Prefix with `nice -n 5 env OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1` on the shared machine.
