# p10_codes: discrete bar codes on the recovered topology (Part 10, image builder)

Part 10 image builder (angle: discrete local codes on the data-recovered topology). It changes one component of v2
(`part9/hyb_portfolio2/learner.py`, md5 `e38af40493816ef1bc82e4f16428dcdf`): the feature bank and LightGBM layout of the
image member `ggbt`. Everything else is v2's code, unchanged: the toy and tabular paths, the Part 8 members, `gknn`, the
pooling sets, the stacker and every budget guard. Frozen file: `learner.py` (class `Learner`, default constructor, name
`p10_codes`), md5 in §7 and in `learner.md5`.

Data used: development only (PROTOCOL.md). Validation rows of the seed-0 training pool (train = pool[:n], validation =
pool[50000:55000]) of `qd_dev`, `qd_a`, `qd_b`, Fashion-MNIST; MNIST and Fashion-MNIST/qd_dev for the topology
diagnostics. No test set was used before the freeze. `qd_c`, `qd_d` and `dlheld7` were never loaded, generated or read.

## 1. What changed

**ggbt's bank.** v2's `ggbt` is LightGBM on [x, pooled sums at k = 4, 9, 16, 300 prototype-pair projections]
(≈ 3100 columns). p10_codes replaces it by

  [x, pooled sums at k = 4, 9, 16, **bars**]  (no prototype pairs; ≈ 5500 columns on QuickDraw, ≈ 6250 on Fashion-MNIST),

and changes two LightGBM settings: the per-tree column fraction 0.12 → **0.07** (≈ 390 columns per tree, about v2's 373),
and **`force_col_wise=True`**. The bank is now built separately for the booster's fitting rows and its inner-validation
rows, and the binned dataset is freed after training (memory only). Every other setting of `ggbt` (31 leaves, lr 0.1,
63 bins, bagging, `min_data_in_leaf`, 100 rounds below 5000 training points, early stopping on the inner-validation
error with patience 50 / 150–400 rounds above, refits) and all of `gknn` are v2's.

**The bars** (a discrete local code on the data-recovered topology; `pool_sets_topo`, `_match_axes`, `bar_sets`).
1. *Recovered neighbourhood.* For every non-constant pixel i, its 8 most correlated pixels (ranks 2–9 of the same ranked
   correlation lists that give v2's pooling sets, from the same rounded correlations and fingerprint tie-breaks).
2. *Axes.* The 8 are paired greedily, least-correlated pair first: on a grid, opposite neighbours are the least
   correlated pair (distance 2), so the 4 pairs are the 4 lines through i (horizontal, vertical, two diagonals). The axes
   are ordered by the rank of their first member (a canonical, layout-free order).
3. *Go straight on.* From an axis end j reached from i, the next pixel is the partner of i in j's own pairing (the pixel
   "opposite i" as seen from j); the bar stops if i is not among j's 8.
4. *Bar of (i, axis), half-length L = 2:* i, the two axis ends and one further step at each end: up to 5 pixels on a
   straight run through i. Feature: the bar sum Σ_{j ∈ bar} x_j (weights in {0, 1}). 4 bars per pixel (2704 on
   QuickDraw, 3132 on Fashion-MNIST).

Splits on a bar sum, [Σ_{bar} x > t] with t a histogram bin, are oriented stroke detectors at a position: a 5-pixel
oriented sum-pool (the pooling sets S_i(k) are isotropic blobs). They are the "convolution window with a canonical order"
of the brief, used per position: the window's order is canonical at each pixel, but the orientation labels are not
consistent across pixels (§4.1), so the codes are not pooled across positions; the trees combine them per position.

**Why these and not the other local codes tried** (§4): the oriented-pooling and histogram-of-codes variants needed a
recovered *frame* consistent across pixels; the correlation topology does not give one reliably (§4.1), and the
orientation-free code histograms gained nothing on validation (§4.2). Bars need only the local pairing, which is local
and errs gracefully (a wrong pairing gives a bent 5-pixel set, still a local subset sum).

**Prototype pairs dropped.** On validation they did not help next to the new bank's columns (§4.2: v2's bank without
pairs 0.1720 against 0.1766 with them, `qd_dev` n = 5000), the Part 9 post-hoc ablation found −0.02 in log2 for them at
n = 60000, and they were the one borderline-continuous feature of the image member (normals x_a − x_b with continuous
entries; discreteness audit D2). Dropping them makes `ggbt`'s bank purely {0, 1}-weighted subset sums of pixels.

## 2. Discreteness and permutation invariance

- **Features:** pixels, isotropic pooled sums (v2's) and bar sums: subset sums with weights in {0, 1} over pixel sets
  chosen by rank statistics of the training-row correlations. Nothing in a feature is fitted; no continuous direction is
  used anywhere in the image member now (v2's prototype pairs are gone).
- **Thresholds:** LightGBM histogram bins (data quantiles), chosen by the booster's exhaustive split search.
- **Continuous fits:** only boosting's Newton leaf values on fixed partitions and the stacker's weights, as in v2.
- **Permutation invariance.** The bars are built from the ranked correlation lists only (rounded correlations,
  fingerprint tie-breaks, rank-position tie-breaks in the pairing), never from a column index or the 28 × 28 layout.
  `test_perm.py`: on `qd_dev` and Fashion-MNIST (n = 2000, two random column permutations each), the bars, as sets of
  original columns, and v2's pooling sets are identical. As in v2, LightGBM's per-tree column sampling makes `ggbt`
  invariant in distribution, not bit for bit (the bank's column order follows the active-column order).
- **Not layout-free in spirit** (as v2, and slightly more so): the correlation ranks recover local neighbourhoods, and the
  pairing recovers local lines; §4.1 measures how well, against the true layout of the dev sets (a diagnostic only; the
  learner never sees the layout).

## 3. Cost

__COST__

## 4. Development (validation rows only)

About 45 minutes of design and experiments on a heavily shared machine (load 12–20 on 4 cores). Scripts and logs:
scratchpad `p10_codes/` (`codes.py`, `diag_frames.py`, `diag_nb.py`, `diag_transport.py`, `exp1.py`, `e1_*.log`,
`r4_*.log`, `check_same.py`, `check_tab.py`, `smoke*.py`).

### 4.1 How much topology do the correlations recover? (diagnostic against the true layout; not used by the learner)

The angle needs a neighbourhood with a canonical order, ideally a consistent *frame* (which neighbour is "left" at every
pixel), so that one code can be pooled across positions like a convolution. Measured against the true 28 × 28 layout
(MNIST and Fashion-MNIST are unpermuted; `qd_dev`'s stored permutation is known from data.py), n = 5000 unless stated:

| statistic | qd_dev | MNIST | Fashion-MNIST |
|---|---|---|---|
| ranks 2–5 are the 4 true 4-neighbours | 0.89 (n = 1000: 0.88) | 0.78 | 0.74 |
| ranks 2–9 are in the true 3 × 3 | 0.83 (n = 1000: 0.82) | 0.78 | 0.63 |
| ... with correlation-profile similarity instead | 0.78 | 0.74 | 0.56 |
| ... with Jaccard of binarised pixels instead | 0.82 | 0.73 | 0.59 |
| axes from the pairing that are straight lines through i | 0.57 | – | – |

**Consistent frames failed.** Two propagation schemes were tried (`codes.local_frames`: 8-neighbour lattice votes;
`codes.frames4`: 4-neighbour axes, propagated by "k = nb(i, D) ⇒ nb(k, D + 4) = i" and parallel transport by end
correlations, diagonals by composition). They are self-consistent (at `qd_dev` n = 10000 every pixel with ≥ 6 of 8
correct directions agrees on one global dihedral transform), but only 0.56–0.64 of all directions are right on `qd_dev`
and 0.21–0.25 on MNIST; per pixel, 5.6–5.9 of 8. Local "parallel transport" of an axis to the pixels of S_c(16)
(largest |cosine| of correlation-profile differences) picks the parallel axis 0.57 of the time (random: 0.22). With
frames this unreliable, oriented codes pooled over regions (a HOG-like histogram of oriented responses) would mix
orientations; they were not pursued. What survives is per-position use of the local pairing: the bars.

### 4.2 ggbt alone on validation rows (`exp1.py`)

LightGBM with ggbt's settings (31 leaves, lr 0.1, 63 bins, `min_data_in_leaf` 20, `force_col_wise`), trained on
pool[:n], error on 5000 validation rows pool[50000:55000], seed 0; 150 rounds at n = 5000, 100 at n = 1000 (the k-fold
regime's count). ff = per-tree column fraction. "v2 bank" = [x, pooled 4/9/16, 300 pairs]; "np" = without the pairs.

| bank | ff | columns | qd_dev 5000 | qd_a 5000 | Fashion 5000 | qd_dev 1000 | Fashion 1000 |
|---|---|---|---|---|---|---|---|
| v2 bank | 0.12 | 3112 | 0.1766 | 0.1768 | __F5V2__ | 0.2396 | 0.1774 |
| np | 0.12 | 2812 | 0.1720 | | | | |
| np | 0.07 | 2812 | 0.1756 | | | | |
| np + code histograms (5 codes × cells S_c(16), S_c(36) + global) | 0.12 | 4097 | 0.1712 | | | | |
| np + global code histograms only | 0.12 | 2817 | 0.1722 | | | | |
| np + bars L = 2 | 0.12 | 5516 | 0.1660 | | | 0.2340 | 0.1822 |
| **np + bars L = 2 (chosen)** | **0.07** | 5516 | **0.1624** | **0.1698** | __F5B5__ | **0.2312** | 0.1826 |
| np + bars L = 2 | 0.05 | 5516 | 0.1614 | | | | |
| np + bars L = 2 + code histograms | 0.12 | 6801 | 0.1598 | | | | |
| np + bars L = 2 and L = 4 | 0.12 | 8220 | 0.1592 | | | | |

Code histograms: per pixel, binarise at the median of the training rows' non-zero values and count the ink among its
8 most correlated pixels; 5 indicator codes (end ≤ 1, thin 2–3, fill 4–6, interior ≥ 7 for an ink centre; boundary
for a blank centre with ink around), pooled by sums over S_c(16) and S_c(36) at 128 centres (a greedy independent set
in fingerprint order) and over the whole image. They are orientation-free, so they need no frame, but they gave nothing
over the plain bank (0.1712 / 0.1722 against 0.1720) and little on top of the bars (0.1598 against 0.1660), for 1285
more columns; dropped. Bars at a second length (L = 4) gave a further −0.06 in log2 on `qd_dev` but 50% more columns and
were not tested elsewhere; not taken (CPU, §3). The validation s.e. of one error is ≈ 0.005; differences between banks
on the same rows are less noisy than that, but these are single seeds.

**Reading.** On QuickDraw, bars cut ggbt's error by 0.06–0.12 in log2 against v2's bank at n = 5000 and by 0.05 at
n = 1000; on Fashion-MNIST at n = 1000 they cost +0.04 (__FREAD__). The column fraction matters with the larger bank
(0.12 → 0.07: 0.1660 → 0.1624) and keeps the per-tree work near v2's.

### 4.3 Checks
- `check_same.py`: p10_codes with v2's image settings (no bars, 300 pairs, ff 0.12) and `force_col_wise=True` gives
  predictions identical to v2's (`qd_dev` n = 600, 2000 validation rows; 75 against 84 CPU s).
- `check_tab.py`: on optdigits n = 300 (tabular; the image member does not run) predictions and FLOP counts identical
  to v2's.
- `test_perm.py`: see §2. `smoke.py` / `smoke2.py`: both `fit_ggbt` paths (early stopping, small n) and the default
  learner end to end (`qd_dev` n = 600: __SMOKE__).

## 5. Fixed dev evaluation (frozen code, run once; test sets)

__EVAL__

## 6. Weaknesses

__WEAK__

## 7. Freeze

__FREEZE__
