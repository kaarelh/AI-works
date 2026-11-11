# p9_gates: the Part 8 portfolio plus a discrete, permutation-invariant image member (builder I1)

Part 9, builder I1. Frozen code: `learner.py` (class `Learner`, default constructor, name `p9_gates`), md5 in
`learner.md5` and §8. Development used only the dev data of the protocol: MNIST, Fashion-MNIST and `qd_dev`, and only a
validation split of their training pools (train = pool[:n], validation = pool[50000:60000], seed 0) - the test sets were
first touched by the single frozen full dev evaluation (§6). No toy suite was used (the member never runs there), and no
held-out set (`dlheld4`, `qd_a`, `qd_b`) was loaded or looked at.

## 1. Algorithm

`p9_gates` is `hyb_portfolio` (Part 8, `hybrid/hyb_portfolio/learner.py`, md5 063bcd91…) with one more member family,
**gates**, which runs only when every input column is continuous and d ≥ 256 (images). On every other input (toy
suites, tabular data) the code path, the random-number stream and therefore the predictions are those of v1: the new
block is skipped and uses its own generator (`default_rng([seed, 9])`) when it runs.

**Two discrete objects, built from the training data of the fit.**
- *Pooling sets.* For every non-constant column i and k ∈ {4, 9, 16}, S_i(k) = the k columns most correlated with column
  i over the first ≤ 20000 training rows (i itself first, correlation 1). The pooled feature is the subset sum
  p_i(x) = Σ_{j∈S_i(k)} x_j:
  a signed sum of a small input subset with all signs +1, the subset chosen by a data statistic. On images the most
  correlated pixels are, in practice, the near neighbours, so p_i is a learned "blob" detector; but the construction never
  uses pixel adjacency or the 28 × 28 layout - it sees only the data matrix, and a column permutation permutes the sets
  exactly (correlations are rounded to 1e-9 and ties are broken by a column fingerprint, never by column index;
  `test_perm.py`).
- *Prototype pairs.* 300 pairs (a, b) of training points of different classes, drawn uniformly by row index; feature
  (x_a − x_b) · x. The hyperplane (x_a − x_b) · x = (|x_a|² − |x_b|²)/2 is "closer to a than to b", so the gates on it are
  two-prototype comparisons. a and b are data, not fitted parameters.

**Members** (each gives class probabilities to the same stacker as every Part 8 member):

| member | what it is | out-of-fold predictions |
|---|---|---|
| `gknn_<k>`, k ∈ {1, 3, 9, 27} | k-nearest-neighbour votes in the pooled representation at scale 9 (Euclidean on the a ≈ 640–700 subset sums p_i, S_i(9)) | leave-one-out votes of the stacking points against all n (as `knn`) |
| `ggbt` | LightGBM on the gate bank [x, p(x) at scales 4, 9 and 16, (x_a − x_b)·x] (F ≈ 784 + 3a + 300 ≈ 3000–3200 columns): every split is a gate [u · x > t], u a pixel, a pooling set or a prototype pair, t a data quantile (histogram bin, 63 bins). 31 leaves, lr 0.1, 12% of the columns per tree, bagging 0.5 when the member's training set exceeds 20000 rows, `min_data_in_leaf` = clip(n/25, 2, 20). Rounds: 100 when the training set has < 5000 points; otherwise early stopping on the error of a stratified inner validation split of min(10%, 5000) points (patience 50 rounds, at least 150, at most 400; ties go to the later round) | fitted on each fold's training part (k-fold regime, n ≤ 3000) or on the n − h non-holdout points (holdout regime), pairs drawn from that part only |

**Refit (as Part 8's `gbt`).** k-fold regime: `ggbt` is refitted on all n with 100 rounds. Holdout regime with
n·d ≤ 1e7 (n = 10000 on images): refitted on all n with the early-stopped round count. n·d > 1e7: the holdout-trained
booster is the final one (trained on 90% of n − h points; 48600 at n = 60000). `gknn` uses all n directly.

**Stacking, budgets, guards** are v1's. The gates block runs after the Part 8 members; each of its two parts is skipped if
its projected cost would take the total above 0.9 of the budget (never triggered on dev).

## 2. What is discrete

- Features: pixels, subset sums over correlation-chosen pixel sets, and prototype-pair projections - all with weights in
  {−1, 0, +1} on pixels or on two training points; no weight is fitted.
- Gates: thresholds are LightGBM histogram bin boundaries (data quantiles), chosen by the booster's exhaustive
  split search; trees are conjunctions of gates.
- Continuous quantities fitted: only the boosting leaf values (Newton steps on fixed partitions), and the stacker's
  convex weights - the same allowances as Part 8.
- Not used: neural networks, gradient descent on any feature parameter, continuous kernels, eigenvectors (no PCA), or
  class means.

**Permutation invariance.** Nothing uses the pixel layout. The pooling sets and `gknn` are exactly equivariant /
invariant (`test_perm.py`: identical sets, identical leave-one-out votes, identical pair projections on three random
permutations of `qd_dev`, MNIST). LightGBM's per-tree feature sampling draws column subsets by index, so `ggbt` (like
Part 8's `gbt` and `et`) is invariant in distribution, not bit-for-bit.

## 3. FLOP accounting (multiply-add = 2)

Everything of the Part 8 portfolio is counted as in Part 8. The gates block adds:
- pooling sets: 2·r·a² (correlation matrix, r ≤ 20000 rows, a ≈ 650–700 active columns) + 4·r·a + 2·a²·log2 a (ranking);
- pooled features (scale 9) of all n rows, for `gknn`: 2·n·d·a (dense matrix product; the 0/1 matrix would need 2·9·a);
- `gknn`: v1's kNN count, 2·q·n·a + 3·q·n, q = stacking-set size;
- `ggbt`, per fit: projections 2·n·d·(3a + 300); binning 16·n·F (F ≈ 3100 columns); per trained tree (all trained trees,
  including the early-stopping patience rounds) the compute audit's count (audit F1, `hybrid/audit/compute.md`):
  2·d_used·n_bag·2.6 (histograms, Σ min(n_left, n_right) ≤ 1.6 n) + 12·B_used·59 (split search over the bins actually
  built, read from `Dataset.feature_num_bin`, times the feature fraction) + 2·B_used·29 (histogram subtraction) + 22·n
  (gradients, partition, score update); + 20 per inner-validation row per tree; out-of-fold predictions 2·d·(3a + 300) +
  10 per tree per row.
- The budget is `common.budget_real` (3 MLP training runs), unchanged.

## 4. Prediction cost (not counted, as for every learner)

Per query, on top of v1's (v1: up to 2 kNN scans of all n training points, 1.9e8 FLOPs at n = 60000):
- `gknn` (when the stacker keeps it): pooling 2·d·a ≈ 1.1e6, plus a scan of all n pooled training rows, 2·n·a ≈ 8.4e7 at
  n = 60000;
- `ggbt`: projections 2·d·(3a + 300) ≈ 3.7e6, plus ≈ 10 FLOPs per tree (≤ 4000 trees) ≈ 4e4.
So at n = 60000 the portfolio's prediction is ≈ 2.8e8 FLOPs per query (≈ 500× an MLP's 2P = 5.4e5), ≈ 2.8e12 for the
10000 test points (≈ 0.45 of the fit budget). Stored: the n pooled training rows (≈ 0.17 GB float32 at n = 60000) in
addition to v1's.

## 5. Development history (dev validation split only)

All numbers in this section are validation errors on pool[50000:60000] of the seed-0 training pool (10000 points), for
models trained on pool[:n]; they are not test errors and are not comparable digit-for-digit with §6. Scripts and logs:
scratchpad `p9_gates/` (`exp1.py`–`exp6.py`, `run_dev.py`, `dev_*.log`, `exp*.log`). About 1.5 hours, on 2 shared cores.

**1. Which engine for oblique gates?** (MNIST, n = 10000 unless stated.)

| what | validation error |
|---|---|
| LightGBM, raw pixels, 100 rounds (≈ Part 8's `gbt`) | 0.0452 |
| LightGBM on 500 random prototype-pair projections only / "nearest-enemy" pairs only | 0.0480 / 0.0488 |
| LightGBM on raw + 500 pair projections | 0.0420 |
| LightGBM on raw + pooled sums (k = 9 and 25) | 0.0418 |
| LightGBM on raw + pooled (k = 9) + 300 pairs (20% of columns per tree) | **0.0386** |
| ridge (least squares on one-hot) over 4000 quantile gates [u·x > t]: 1000 pair directions × 4 thresholds / 4000 pairs × 1 | 0.0540 / 0.0642 |
| same, u = random signed sums of 20 pixels / signs of the 30 largest pair differences / single prototypes | 0.0698 / 0.0546 / 0.1204 |
| same, pairs selected per class pair by a Fisher-ratio test from 200–1000 candidates | 0.0580–0.0603 |
| ridge over 4000 pair gates at n = 50000 | 0.0399 |

A convex readout over a random gate bank is capacity-limited: its cost is 2·n·F² for F gates, so F ≈ 5000 is the most the
budget allows at n = 60000, and 4000 gates give 4.0% at n = 50000. Abandoned. Boosted trees over an augmented gate bank
were the engine kept. Fashion-MNIST n = 10000, 100 rounds: raw 0.1184, raw + 500 pairs 0.1153.

**2. Pooling for nearest neighbours.** kNN in the pooled representation (sets of k most correlated pixels):

| dataset (n = 10000) | raw 1 / 3 / 9-NN | pooled k = 4 | pooled k = 9 | pooled k = 16 |
|---|---|---|---|---|
| MNIST | 0.0507 / 0.0465 / 0.0556 | 0.0474 / 0.0435 / 0.0484 | **0.0441 / 0.0411 / 0.0447** | 0.0493 / 0.0452 / 0.0492 |
| Fashion-MNIST | 0.1825 / 0.1771 / 0.1771 | 0.1784 / 0.1691 / 0.1708 | 0.1819 / 0.1722 / 0.1681 | 0.1855 / 0.1797 / 0.1712 |
| qd_dev | 0.2433 / 0.2249 / 0.2353 | 0.2149 / 0.2027 / 0.1993 | 0.2046 / **0.1919** / 0.1929 | 0.2044 / 0.1930 / 0.1912 |

k = 9 was kept for `gknn`.

**3. Large n** (MNIST, n = 50000, LightGBM, bagging 0.5, 63 bins). Raw pixels (30% of columns per tree): 0.0263 / 0.0235
/ 0.0219 after 100 / 200 / 300 rounds. Raw + pooled (k = 9) + centre-minus-surround signed sums + 300 pairs (15% of
columns): 0.0252 / 0.0207 / **0.0191**, at 95 ms per tree on one contended core.

**4. The full portfolio** (`run_dev.py`; v1 = `hyb_portfolio` on the same split):

| dataset | n | v1 | p9_gates (dev versions) | log2 ratio | what the stacker weights most |
|---|---|---|---|---|---|
| MNIST | 1000 | 0.0819 | 0.0771 | −0.09 | ggbt 0.22, gknn_3/9 0.20/0.19 |
| Fashion-MNIST | 1000 | 0.1773 | 0.1757 | −0.01 | lin, et, ggbt |
| qd_dev | 1000 | 0.2666 | 0.2259 (final: 0.2262) | −0.24 | ggbt 0.28, gknn_9 0.23 |
| MNIST | 10000 | 0.0343 | 0.0342 → **0.0330** after the early-stopping fix | −0.06 | gbt, gknn_1, ggbt |
| qd_dev | 10000 | 0.1690 | 0.1469 | −0.20 | ggbt 0.31 |
| Fashion-MNIST | 10000 | – | 0.1097 | – | ggbt, gbt, et, lin |
| MNIST | 50000 | – | 0.0189 (fit 334 CPU s, peak RSS 2.6 GB, 0.33 of the budget) | – | ggbt 0.34 |

Member out-of-fold errors: `ggbt` is the best single member on every dev cell (e.g. qd_dev n = 10000: 0.165 against
`gbt` 0.189 and the best Part 8 kNN 0.228; MNIST n = 50000: 0.0208 against 0.0282 and 0.0259), and `gknn` beats the
Part 8 kNN members on MNIST and qd_dev (qd_dev n = 10000: 0.190 against 0.228).

**5. Changes along the way.**
- *Early stopping.* Stopping on the inner-validation log-loss (patience 25) stopped `ggbt` at 57 rounds at MNIST
  n = 10000: the probabilities become over-confident long before the error stops falling. Replaced by stopping on the
  validation error, patience 50, at least 150 rounds (179 rounds there; validation 0.0342 → 0.0330).
- *Exact permutation equivariance.* Ranking correlations with column-index tie-breaking changed 1 of 644 pooling sets
  under a column permutation (exact ties between pixels that are non-zero in the same few images). Fixed by rounding the
  correlations to 1e-9 and breaking ties by a column fingerprint; `test_perm.py` now passes on all permutations tried.
- *Multi-scale pooled bank* (the last change before freezing). LightGBM only, n = 10000, 250 rounds: pooled sums at
  scales 4, 9, 16 + pairs (12% of columns) against scale 9 + pairs (20%): qd_dev 0.1503 against 0.1560, Fashion-MNIST
  0.1091 against 0.1088. Kept for `ggbt`; the full portfolio with it was run once before freezing (qd_dev n = 1000:
  0.2262, stack out-of-fold 0.239 against 0.248), and not on MNIST.

## 6. Full dev evaluation (frozen code, run once)

(filled in below)

## 7. Weaknesses (honest)

- **It is still a tree ensemble.** The new member is LightGBM over a richer, discrete feature bank, plus kNN in a pooled
  representation. Neither learns a continuous direction. On MNIST at large n the dev numbers suggest the gap to the
  strong MLP narrows but does not close (validation 1.89% at n = 50000; the strong MLP's test error at 60000 is 1.43%).
- **The pooling sets exploit pixel correlations.** They are built from the data matrix alone and are exactly
  permutation-equivariant, so they do not use the layout. But on images the most correlated pixels are the spatial
  neighbours, so the sets recover local neighbourhoods from data. An MLP is free to learn the same; the auditor should
  still read p_i as "blob" features found by a correlation test, not as layout-free in spirit.
- **Partial invariance of `ggbt`.** LightGBM's per-tree column sampling draws columns by index, so `ggbt` is invariant in
  distribution, not bit-for-bit (as Part 8's `gbt` and `et`).
- **The last change was tested lightly.** The multi-scale bank was compared only as a LightGBM-only model on qd_dev and
  Fashion-MNIST at n = 10000 (not on MNIST), and the full portfolio with it was run once (qd_dev n = 1000) before
  freezing. Its CPU cost at n = 60000 was not measured before freezing (the n = 50000 measurement used the scale-9 bank).
- **CPU time at n = 60000 exceeds the ~15-minute target (found during the frozen run).** The MNIST n = 60000 fit took
  1352 CPU s (22.5 min). Cause, from stack samples of the running fit and a post-freeze diagnostic
  (scratchpad `p9_gates/diag_lgb_layout.py`, which does not change the learner): on the multi-scale bank (3175 mostly
  sparse columns) LightGBM picks its row-wise multi-value-bin layout automatically, and with a feature fraction it then
  copies the sampled column subset for every tree (`MultiValBinWrapper::CopyMultiValBinSubset`). At n = 30000 this
  costs 198.5 ms per tree against 73.2 ms with `force_col_wise=True`, with the same validation error after 10 rounds.
  The n = 50000 timing run before the freeze used the smaller scale-9 bank (334 CPU s for the whole fit), so the
  regression came with the last change. Adding `force_col_wise=True` to `ggbt`'s LightGBM parameters leaves the
  predictions unchanged - bit-identical class probabilities on qd_dev n = 8000 after 40 rounds (max |ΔP| = 0, scratchpad
  `p9_gates/diag_lgb_same.py`; 72.8 → 33.3 ms per tree) - and cuts `ggbt`'s time about 2.2–2.7×. Per the freeze rule this was **not** applied; whoever integrates the member should
  apply it as a recorded deviation, re-check identical predictions on a dev cell, and re-time. The FLOP count is not
  affected: the copies are data movement, which the analytic count does not charge.
- **Memory at n = 60000: ~6 GB peak RSS** (6.2 GB on Fashion-MNIST, 4.4 GB on MNIST, process total, measured every
  5 s), about twice v1's ~3 GB: the gate bank (54000 × 3175 float32, plus the row subset LightGBM bins from) and
  LightGBM's multi-value bins come on top of v1's members. In the shared 14.3 GB memory cgroup this got the frozen run's
  n = 60000 fits OOM-killed three times while other jobs ran (§6). Freeing the bank after binning, or building the
  booster's `Dataset` from row chunks, would cut the peak; not done (frozen).
- **CPU time, smaller n.** `ggbt` adds 75–200 CPU s per fit at n = 1000–10000 (the k-fold regime fits it 6 times). The
  whole fit is 1.5–3.5 CPU-min there, against tens of seconds for the MLP runs the FLOP budget corresponds to.
- **Data given up for early stopping.** At large n the final booster is the holdout-trained one, trained on 90% of
  n − h points (48600 at n = 60000): 10% for its early stopping, h for the stacker.
- **Prediction cost.** `gknn` adds a second scan of all n training rows per query (§4): ≈ 500× an MLP per query at
  n = 60000, ≈ 0.45 of the fit budget for the 10000 test points.
- **Small n untested.** The dev grid starts at n = 1000. With 5 more members the stacker has ~22 inputs; at n = 100–300
  (on the held-out grids) the stacking noise Part 8 saw at n = 100 may grow.
- **Dev in-sample.** Every choice was made on dev validation splits; the full dev evaluation (§6) is on dev test sets,
  seed 0 only, and is not evidence about `qd_a` / `qd_b`.
- **FLOPs of library trees are estimates.** `ggbt` uses the compute audit's per-tree formula with measured bin counts;
  it is not a measured count.

## 8. Freeze

Frozen 26 October 2026, 21:48 UTC, after about 1.5 hours of development. `learner.py` md5
`2728ac2b80597d9e559dedca6a70cb7c` (also in `learner.md5`; `run_full_dev.py` asserts it before running). Checked
before freezing: on optdigits (tabular) the predictions and FLOP counts are identical to v1's at n = 300 and 1000;
`test_perm.py` passes. The learner was not changed after the freeze.

Files: `learner.py`, `__init__.py`, `learner.md5`, `DESIGN.md`, `test_perm.py` (invariance checks), `compare_dev.py`
(the §6 table from the result files). The full dev evaluation was run with scratchpad `p9_gates/run_full_dev.py`
(`small`: n ∈ {1000, 10000}, `large`: n = 60000, then `merge`), each part one `standard_tasks` `harness.evaluate`
call with seeds (0,), merged into `standard_tasks/results/p9_gates-dev__<ds>.json`.
