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
- *Pooling sets.* For every non-constant column i, S_i = the k = 9 columns most correlated with column i over the first
  ≤ 20000 training rows (i itself first, correlation 1). The pooled feature is the subset sum p_i(x) = Σ_{j∈S_i} x_j:
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
| `gknn_<k>`, k ∈ {1, 3, 9, 27} | k-nearest-neighbour votes in the pooled representation p(x) (Euclidean on the ~650–700 subset sums) | leave-one-out votes of the stacking points against all n (as `knn`) |
| `ggbt` | LightGBM on the gate bank [x, p(x), (x_a − x_b)·x] (≈ 784 + 650–700 + 300 ≈ 1750 columns): every split is a gate [u · x > t], u a pixel, a pooling set or a prototype pair, t a data quantile (histogram bin, 63 bins). 31 leaves, lr 0.1, 20% of the columns per tree, bagging 0.5 when the member's training set exceeds 20000 rows, `min_data_in_leaf` = clip(n/25, 2, 20). Rounds: 100 when the training set has < 5000 points; otherwise early stopping on the error of a stratified inner validation split of min(10%, 5000) points (patience 50 rounds, at least 150, at most 400; ties go to the later round) | fitted on each fold's training part (k-fold regime, n ≤ 3000) or on the n − h non-holdout points (holdout regime), pairs drawn from that part only |

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
- pooled features of all n rows: 2·n·d·a (dense matrix product; the 0/1 matrix would need 2·9·a per row);
- `gknn`: v1's kNN count, 2·q·n·a + 3·q·n, q = stacking-set size;
- `ggbt`, per fit: projections 2·n·d·(a + 300); binning 16·n·F (F ≈ 1750 columns); per trained tree (all trained trees,
  including the early-stopping patience rounds) the compute audit's count (audit F1, `hybrid/audit/compute.md`):
  2·d_used·n_bag·2.6 (histograms, Σ min(n_left, n_right) ≤ 1.6 n) + 12·B_used·59 (split search over the bins actually
  built, read from `Dataset.feature_num_bin`, times the feature fraction) + 2·B_used·29 (histogram subtraction) + 22·n
  (gradients, partition, score update); + 20 per inner-validation row per tree; out-of-fold predictions 2·d·(a + 300) +
  10 per tree per row.
- The budget is `common.budget_real` (3 MLP training runs), unchanged.

## 4. Prediction cost (not counted, as for every learner)

Per query, on top of v1's (v1: up to 2 kNN scans of all n training points, 1.9e8 FLOPs at n = 60000):
- `gknn` (when the stacker keeps it): pooling 2·d·a ≈ 1.1e6, plus a scan of all n pooled training rows, 2·n·a ≈ 8.4e7 at
  n = 60000;
- `ggbt`: projections 2·d·(a + 300) ≈ 1.5e6, plus ≈ 10 FLOPs per tree (≤ 4000 trees) ≈ 4e4.
So at n = 60000 the portfolio's prediction is ≈ 2.8e8 FLOPs per query (≈ 500× an MLP's 2P = 5.4e5), ≈ 2.8e12 for the
10000 test points (≈ 0.45 of the fit budget). Stored: the n pooled training rows (≈ 0.17 GB float32 at n = 60000) in
addition to v1's.

## 5. Development history (dev validation split only)

(filled in below)

## 6. Full dev evaluation (frozen code, run once)

(filled in below)

## 7. Weaknesses (honest)

(filled in below)

## 8. Freeze

(filled in below)
