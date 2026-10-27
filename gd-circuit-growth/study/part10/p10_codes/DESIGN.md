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

**One more member, `cgbt`.** v2's image member family `gates` has `gknn` and `ggbt` (LightGBM on [x, pooled sums at
k = 4, 9, 16, 300 prototype-pair projections], ≈ 3100 columns). p10_codes keeps both exactly and adds

  `cgbt` = LightGBM on [x, pooled sums at k = 4, 9, 16, **bars** at half-lengths L = 2 and L = 4] (no prototype pairs;
  8220 columns on QuickDraw, ≈ 9360 on Fashion-MNIST),

with `ggbt`'s settings (31 leaves, lr 0.1, 63 bins, bagging 0.5 above 20000 rows, `min_data_in_leaf` = clip(n/25, 2, 20),
100 rounds below 5000 training points, otherwise early stopping on an inner-validation error with patience 50 and
150–400 rounds, the same refits) except the per-tree column fraction: **0.05** (≈ 410 columns per tree; `ggbt`: 0.12 of
3100 ≈ 373). It draws from its own generator (`default_rng([seed, 10])`), so `ggbt`'s pairs, splits and fits are v2's.
The stacker (v2's, unchanged) weights `cgbt` against `ggbt` and every other member.

**Two engineering changes to both boosters.** `force_col_wise=True` (Part 9 found bit-identical predictions and a 2–3×
faster booster on this bank; `check_same.py` confirms identical predictions of the whole learner here), and each bank is
built separately for the booster's fitting and inner-validation rows, with the binned dataset freed after training
(memory). Neither changes a prediction of `ggbt`.

**The bars** (a discrete local code on the data-recovered topology; `pool_sets_topo`, `_match_axes`, `bar_sets`).
1. *Recovered neighbourhood.* For every non-constant pixel i, its 8 most correlated pixels: ranks 2–9 of the same ranked
   correlation lists (same rounded correlations, same fingerprint tie-breaks) that give v2's pooling sets.
2. *Axes.* The 8 are paired greedily, least-correlated pair first. On a grid opposite neighbours are the least
   correlated pair (distance 2), so the 4 pairs are the 4 lines through i (horizontal, vertical, two diagonals). The axes
   are ordered by the rank of their first member: a canonical order without layout.
3. *Go straight on.* From an axis end j reached from i', the next pixel is the partner of i' in j's own pairing (the
   pixel "opposite i'" as seen from j); the bar stops early if i' is not among j's 8.
4. *Bar of (i, axis), half-length L:* i, the two axis ends and L − 1 further steps at each end, up to 2L + 1 pixels on a
   straight run through i (5 pixels for L = 2, 9 for L = 4). Feature: the bar sum Σ_{j ∈ bar} x_j (weights in {0, 1}).
   4 bars per pixel per length (2704 per length on QuickDraw).

A split on a bar sum, [Σ_{bar} x > t] with t a histogram bin, is an oriented stroke detector at one position: an
elongated sum-pool, where v2's pooling sets S_i(k) are isotropic blobs. Bars are the brief's "convolution window with a
canonical order", used per position. The window's order is canonical at each pixel, but the orientation labels are not
consistent across pixels (§4.1), so the codes are not pooled across positions; the trees combine them per position.

**Why a second member and not a replacement** (§4.2). As a replacement bank (no pairs, column fraction 0.07) the bars
cut the booster's validation error on QuickDraw (`qd_dev` n = 5000: 0.1766 → 0.1624; `qd_a`: 0.1768 → 0.1698) but not on
Fashion-MNIST (n = 5000: 0.1196 → 0.1254). There the loss comes from dropping the prototype pairs and diluting them (no
pairs: 0.1262; pairs + bars at fraction 0.07: 0.1242), not from the bars (no pairs + bars: 0.1254 against no pairs
0.1262). Adding `cgbt` next to the unchanged `ggbt` lets the stacker use each where it helps, at the cost of a second
booster. The second bar length (L = 4) and the fraction 0.05 were the best tried for the bar bank (§4.2).

**Why not the other local codes tried** (§4): pooled oriented codes (HOG-like histograms) need a frame that is
consistent across pixels, and the correlation topology does not give one reliably (§4.1); orientation-free code
histograms gained nothing on validation (§4.2). Bars need only the local pairing, which errs gracefully: a wrong pairing
gives a bent 5- or 9-pixel set, still a local subset sum.

## 2. Discreteness and permutation invariance

- **New features:** bar sums: subset sums with weights in {0, 1} over pixel sets chosen by rank statistics of the
  training-row correlations. Nothing in a bar is fitted. `cgbt`'s bank has no continuous direction at all (pixels,
  pooled sums, bars); `ggbt` keeps v2's prototype pairs (x_a − x_b, continuous entries, not fitted; discreteness audit
  D2), unchanged.
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

About 35 minutes of design and experiments on a heavily shared machine (load 12–20 on 4 cores). Scripts and logs:
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

### 4.2 One booster alone on validation rows (`exp1.py`)

LightGBM with ggbt's settings (31 leaves, lr 0.1, 63 bins, `min_data_in_leaf` 20, `force_col_wise`), trained on
pool[:n], error on the 5000 validation rows pool[50000:55000], seed 0; 150 rounds at n = 5000, 100 at n = 1000 (the
k-fold regime's count). ff = per-tree column fraction. "v2 bank" = [x, pooled 4/9/16, 300 pairs] (= ggbt); "np" =
without the pairs; "bars 2" = bars of half-length 2; "bars 2+4" = both lengths.

| bank | ff | columns (QD) | qd_dev 5000 | qd_a 5000 | Fashion 5000 | qd_dev 1000 | Fashion 1000 |
|---|---|---|---|---|---|---|---|
| v2 bank (= ggbt) | 0.12 | 3112 | 0.1766 | 0.1768 | **0.1196** | 0.2396 | **0.1774** |
| np | 0.12 | 2812 | 0.1720 | | 0.1262 | | |
| np | 0.07 | 2812 | 0.1756 | | | | |
| np + code histograms (5 codes × cells S_c(16), S_c(36) + global) | 0.12 | 4097 | 0.1712 | | | | |
| np + global code histograms only | 0.12 | 2817 | 0.1722 | | | | |
| np + bars 2 | 0.12 | 5516 | 0.1660 | | | 0.2340 | 0.1822 |
| np + bars 2 | 0.07 | 5516 | 0.1624 | 0.1698 | 0.1254 | 0.2312 | 0.1826 |
| np + bars 2 | 0.05 | 5516 | 0.1614 | | | | |
| v2 bank + bars 2 | 0.07 | 5816 | | | 0.1242 | | |
| np + bars 2 + code histograms | 0.12 | 6801 | 0.1598 | | | | |
| np + bars 2+4 | 0.12 | 8220 | 0.1592 | | | | |
| **np + bars 2+4 (= cgbt)** | **0.05** | 8220 | **0.1582** | **0.1678** | | **0.2296** | 0.1830 |

Code histograms: per pixel, binarise at the median of the training rows' non-zero values and count the ink among its
8 most correlated pixels; 5 indicator codes (end ≤ 1, thin 2–3, fill 4–6, interior ≥ 7 for an ink centre; boundary for
a blank centre with ink around), pooled by sums over S_c(16) and S_c(36) at 128 centres (a greedy independent set in
fingerprint order) and over the whole image. They are orientation-free, so they need no frame, but they gave nothing
over the plain bank (0.1712 / 0.1722 against 0.1720) and little on top of the bars (0.1598 against 0.1660), for 1285
more columns; dropped. The validation s.e. of one error is ≈ 0.005; differences between banks on the same rows are less
noisy than that, but every entry is a single seed.

**Reading.** On QuickDraw the bar bank cuts one booster's error by 0.08–0.16 in log2 against v2's bank at n = 5000
(`qd_dev` 0.1766 → 0.1582, `qd_a` 0.1768 → 0.1678) and by 0.06 at n = 1000 (`qd_dev`). On Fashion-MNIST it does not
help: the prototype pairs carry ggbt's edge there (no pairs: 0.1196 → 0.1262), and adding the bars to the pair bank
dilutes them (0.1242). Hence the final design (§1): `cgbt` as a second member next to the unchanged `ggbt`, the stacker
choosing. The stacked combination itself was not measured before the freeze (one end-to-end run at `qd_dev` n = 600 with
the L = 2 bank: validation 0.2475, equal to v2's 0.2475; stacker weights `cgbt` 0.147, `ggbt` 0.143).

### 4.3 Checks
- `check_same.py`: p10_codes with v2's image settings (no bars, 300 pairs, ff 0.12) and `force_col_wise=True` gives
  predictions identical to v2's (`qd_dev` n = 600, 2000 validation rows; 75 against 84 CPU s).
- `check_tab.py`: on optdigits n = 300 (tabular; the image member does not run) predictions and FLOP counts identical
  to v2's.
- `test_perm.py`: see §2 (bars at L = 2 and L = 4). `smoke.py`: both `fit_ggbt` paths (early stopping, small n);
  `smoke2.py` (replacement design) and `smoke3.py` (two-member design, L = 2): the learner end to end at `qd_dev`
  n = 600 (validation 0.2470 and 0.2475; v2 0.2475; budget fractions 0.33 and 0.42; `cgbt` 63 CPU s against `ggbt`'s
  47 s). The frozen defaults (L = 2 and 4, fraction 0.05) were first run end to end by the fixed evaluation (§5).

## 5. Fixed dev evaluation (frozen code, run once; test sets)

__EVAL__

## 6. Weaknesses

- **It is one more tree ensemble.** `cgbt` is LightGBM over a richer bank of fixed subset sums; the gain, where there is
  one, is a better representation for the trees (oriented 5- and 9-pixel strokes), not a new kind of learner. Boosting is
  functional gradient descent, as before.
- **The local codes are not shared across positions.** The angle's goal, a discrete convolution (one code pooled over
  positions), needs a frame consistent across pixels; correlation ranks recover only 57–64% of directions consistently
  on `qd_dev` and 21–25% on MNIST (§4.1). So the bars are per-position features: nothing like weight sharing or
  translation invariance is gained, which is what a CNN has over v2 (the `cnn` context at `qd_a` n = 10000: 0.120 against
  v2's 0.150).
- **The topology is recovered from pixel correlations.** As for v2's pooling sets (discreteness audit D1), and more so:
  the pairing recovers local lines. The learner never reads the layout and is exactly permutation-equivariant in its
  objects, but "layout-free" holds in the letter, not in spirit.
- **No gain expected on Fashion-MNIST.** On validation the bar bank did not help there (§4.2); `cgbt` costs CPU there for
  whatever the stacker finds in it.
- **Cost.** A second booster: about 1.3× `ggbt`'s per-tree work and a 2.6× larger bank to build and bin; at n = 3000 the
  portfolio's projected FLOPs come close to the 0.9-of-budget guard (§3), and where the guard would trip `cgbt` is
  skipped and the fit is v2's. Prediction adds a second bank projection (2·d·7436 ≈ 1.2e7 FLOPs per query) and ≈ 4000
  more tree traversals per query.
- **Development was short and single-seed.** About 35 minutes of experiments on a machine at load 12–22; every
  validation number is one seed on 5000 rows; the stacked two-booster combination was not measured before the freeze
  except once at n = 600; the frozen defaults (L = 2 and 4, fraction 0.05) were first run end to end by the fixed
  evaluation. `qd_b` was not used in development (the round that included it was cut for CPU).
- **Invariance in distribution only** for both boosters (LightGBM samples columns by index), as in v2.
- **FLOPs of library trees are analytic estimates** (the compute audit's per-tree formula, with measured bin counts), as
  in v2; bank projections are charged as dense products (what the code executes), although the 0/1 matrices are sparse.

## 7. Freeze

Frozen 27 October 2026, 22:10 UTC, after about 35 minutes of development (started 21:37). `learner.py` md5
**`fd688acdfd6a70eca27ea712d666627d`** (also in `learner.md5`; every result cell of §5 records the md5 of the file it
ran). The learner was not changed after the freeze; the fixed dev evaluation started at 22:10 UTC
(scratchpad `p10_codes/run_dev_eval.sh`).

Files: `learner.py`, `__init__.py`, `learner.md5`, `DESIGN.md`, `test_perm.py`. Development scripts and logs are in the
scratchpad folder `p10_codes/` (working-branch material).
