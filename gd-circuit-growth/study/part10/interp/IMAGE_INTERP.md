# What v3's image members encode, and how v3 differs from v2 on images

Part 10 interpretability, image side (PROTOCOL.md, "Interpretability": descriptive analysis of the best learner, not
evidence for a claim of superiority). Learner: **v3** = `part10/hyb_portfolio3/learner.py` (md5
`b045fafe1e24418620bf8c503aa601c6`); comparison: **v2** = `part9/hyb_portfolio2/learner.py` (md5
`e38af40493816ef1bc82e4f16428dcdf`). Data: QuickDraw `qd_dev` and `qd_a` (columns permuted by the fixed permutation of
`standard_tasks/data.py`, seed 9192; `qd_a` is a Part 9 held-out set whose v2 results are public), Fashion-MNIST, MNIST.
Seed 0 throughout. No result on the Part 10 held-out image sets `qd_c` / `qd_d` was opened.

**Measured vs reading.** Paragraphs marked *Measured* report numbers computed by the scripts below from the files named;
*Reading* marks my interpretation of them.

**Files.** Every number comes from one of these (paths relative to `study/part10/interp/`; `$SCRATCH` =
`/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad`):
- analysis files: `image_structure.py` (one instrumented fit per run, `hooks.fit_image`, bit-for-bit the evaluation's
  fit) wrote `$SCRATCH/p10/interp_out_final/image/<tag>/<dataset>__n<n>__s0.{json,npz}`; copies in
  `results/image_final/<tag>/` (all .npz files are under 5 MB and are copied too);
- `make_image_final.py` → `tables/img_runs.md`, `img_pooling.md`, `img_topology.md`, `img_bars.md`, `img_stack.md`,
  `img_gain.md`, `img_pairs.md`, `img_class_err.md`, `img_contrib.md`, `img_summary.json` and the figures
  `figures/fig_img_*.pdf`;
- `image_far_members.py` → `tables/img_far_members.md` (long pooling links; reads the training rows of each fit);
- `image_regions.py` → `tables/img_regions.md` (the regions named in §3).

## 0. The fits analysed

| learner | dataset | n | test error (analysis fit) | evaluation cell | equal |
|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 0.2118 | 0.2118 (`p10_codes-dev__qd_dev/n1000_s0.json`) | yes |
| v3 | qd_dev | 3000 | 0.1753 | – (no cell at n = 3000) | – |
| v3 | qd_dev | 10000 | 0.1330 | 0.1330 (`p10_codes-dev__qd_dev/n10000_s0.json`) | yes |
| v3 | qd_a | 10000 | 0.1422 | 0.1422 (`p10_codes-dev__qd_a/n10000_s0.json`) | yes |
| v3 | fashion_mnist | 10000 | 0.1238 | 0.1238 (`p10_codes-dev__fashion_mnist/n10000_s0.json`) | yes |
| v3 | mnist | 10000 | 0.0255 | – (no cell) | – |
| v2 | qd_dev | 10000 | 0.1467 | 0.1463 (`hyb_portfolio2__qd_dev/n10000_s0.json`) | **no** (4 of 10000 test points) |
| v2 | fashion_mnist | 10000 | __V2F_ERR__ | 0.1259 (`hyb_portfolio2__fashion_mnist/n10000_s0.json`) | __V2F_EQ__ |

*Measured* (`tables/img_runs.md`; cells under `$SCRATCH/p9/cells/`; v3 = `p10_codes` on images by the assembly identity
check, `hyb_portfolio3/ASSEMBLY.md`). Every v3 fit that has an evaluation cell reproduces it exactly. The v2 fit on
`qd_dev` does not: it gives 0.1467 against the cell's 0.1463. The cell's own record (`info` in the cell file) shows a
different fit: v2's booster `ggbt` early-stopped at 166 rounds there and at 123 here, `lin_1.0`'s out-of-fold error is
0.357 there and 0.3575 here, and the stacker's out-of-fold error 0.148 there and 0.1445 here; `ggbt`'s out-of-fold error
is 0.161 in both. My fit equals Part 9's evaluation of the same image member (`p9_gates`, identical to v2 on images at
this n; `standard_tasks/results/p9_gates-dev__qd_dev.json`: 0.1467). The v2 dev cells were run by `$SCRATCH/p10/v2dev.sh`,
which sets no BLAS thread variables; every analysis fit (and every v3 evaluation fit) runs with single-threaded BLAS.
*Reading:* `ggbt`'s bank features are BLAS products (x times the pooling and pair matrices), so a different summation
order can move a feature by one rounding unit and change a split; this is a plausible cause, not one I verified. The v2
analysis below describes a valid v2 fit, which differs from the evaluated one by 0.0004 in test error.

**Which booster is analysed.** Each run analyses the final `ggbt` and `cgbt` boosters. A booster with stacker weight 0
is not refitted on all n; then the last out-of-fold fit (n − 2000 rows in the holdout regime) is analysed. This happens
for `ggbt` on MNIST and on `qd_a` (`refit_on_all_n` false, 7998 and 8000 rows; `tables/img_gain.md`, "rows fitted").
At n ≤ 3000 the members' out-of-fold predictions are 5-fold; at n = 10000 they come from one holdout of 2000 rows
(standard error of an error near 0.15 about 0.008).

**The banks.** `ggbt` (v2's member, unchanged in v3): [784 pixels, pooled sums over S_i(k) for k = 4, 9, 16 and every
non-constant pixel i, 300 prototype-pair projections]. `cgbt` (new in v3): [784 pixels, the same pooled sums, bars of
half-length L = 2 and L = 4, 4 per non-constant pixel per L], no pairs. On QuickDraw 676 pixels are non-constant (8220
`cgbt` columns), on MNIST 682, on Fashion 784.

## 1. Topology: how much of the 28 × 28 grid the correlations recover

The learner sees only column statistics. The analysis maps its objects back to the true grid (for QuickDraw through the
stored permutation, `hooks.grid_of`) and measures distances in grid steps (Chebyshev: the 8 neighbours are at distance 1).

### 1.1 Pooling sets S_i(k)

*Measured* (`tables/img_pooling.md`, `tables/img_far_members.md`):

| run | k = 4: within 1 step | k = 9: within 1 / within 2 | k = 16: within 1 / within 2 | members > 2 steps away (k = 4 / 9 / 16) |
|---|---|---|---|---|
| qd_dev n = 1000 | 0.987 | 0.842 / 0.987 | 0.521 / 0.829 | 2 / 79 / 1847 |
| qd_dev n = 3000 | 0.993 | 0.848 / 0.992 | 0.522 / 0.840 | 0 / 46 / 1730 |
| qd_dev n = 10000 | 0.995 | 0.852 / 0.995 | 0.523 / 0.845 | 0 / 31 / 1682 |
| qd_a n = 10000 | 0.999 | 0.837 / 0.990 | 0.530 / 0.812 | 0 / 59 / 2029 |
| MNIST n = 10000 | 0.982 | 0.810 / 0.970 | 0.517 / 0.872 | 23 / 186 / 1394 |
| Fashion n = 10000 | 0.910 | 0.674 / 0.857 | 0.472 / 0.709 | 65 / 1006 / 3645 |

(A set S_i(k) contains i itself and k − 1 others; only 8 pixels lie within one step, so for k = 16 at most 8 of the 15
others can.) The overlap of S_i(k) with the k truly nearest pixels is 0.82 / 0.88 / 0.78 (k = 4 / 9 / 16) on `qd_dev`
at n = 10000, 0.77 / 0.83 / 0.75 on MNIST and 0.69 / 0.69 / 0.67 on Fashion.

Where the long links come from (`tables/img_far_members.md`, n = 10000):
- **Fashion:** all 65 far members at k = 4 (at 57 centre pixels) are the centre's *mirror pixel* (same row ± 1, columns
  summing to 27 ± 2); at k = 9, 619 of 1006. The centres involved are ordinary pixels (median ink frequency 0.40 on the
  10000 training images; all active pixels: 0.52).
- **MNIST:** the 23 far members at k = 4 sit at 13 centre pixels that are inked in at most 0.04% of the training images
  (median 0.01%), and none is a mirror pixel.
- **QuickDraw:** no far member at k = 4 at n ≥ 3000; at k = 9, 31 on `qd_dev` (14 of them mirror pixels).

*Reading.* On QuickDraw and MNIST the 4- and 9-pixel sets are local neighbourhoods from n = 1000 on; n mainly removes
the last few spurious links (k = 9: 79 → 31 far members from n = 1000 to 10000). On Fashion-MNIST the garments are
left-right symmetric, so a pixel correlates with its mirror image more than with some of its neighbours, and the sets mix
the two sides of the garment. On MNIST the few long links come from almost-never-inked border pixels, whose
correlations rest on a handful of images.

### 1.2 Global layout (Isomap)

*Measured* (`tables/img_topology.md`): Procrustes R² between a 2-D Isomap embedding of the pooling-set graph and the
true pixel coordinates (1 = the grid up to rotation, reflection and scale).

| run | k = 4, union | k = 9, union | k = 9, mutual | k = 16, mutual |
|---|---|---|---|---|
| qd_dev n = 1000 | 0.842 | 0.259 | 0.874 | 0.011 |
| qd_dev n = 3000 | 0.970 | 0.735 | 0.888 | 0.011 |
| qd_dev n = 10000 | 0.973 | 0.858 | 0.917 | 0.072 |
| qd_a n = 10000 | 0.988 | 0.238 | 0.827 | 0.254 |
| MNIST n = 10000 | 0.918 | 0.477 | 0.969 (674 of 682 pixels) | 0.519 |
| Fashion n = 10000 | 0.134 | 0.230 | 0.231 | 0.234 |

The same graphs' edges by true length (second table of `img_topology.md`): at `qd_dev` n = 10000 the k = 4 union graph
has 1170 edges, 99.1% of length 1 and none longer than 2; the k = 9 union graph has 24 edges longer than 2 (6 longer than
5); the k = 16 mutual graph 450 (49). At n = 1000 the k = 9 union graph has 66 (28). `qd_a`'s k = 9 union graph has 46
(10). Fashion's k = 4 union graph already has 49 (35).

*Reading.* Isomap measures the *global* layout through shortest paths, which a few long edges short-circuit: `qd_a`'s
k = 9 union graph has the local structure about as right as `qd_dev`'s (both ≥ 0.99 within 2 steps) but 10 edges longer
than 5 steps, and its R² is 0.24 against 0.86. The robust variant is the k = 4 union graph: 0.97–0.99 on QuickDraw at
n ≥ 3000, 0.92 on MNIST, 0.13 on Fashion. The learner never uses a global embedding; it uses each set as a local sum, so
§1.1 is the relevant measure for the features and this section is a summary of how map-like the recovered neighbourhoods
are. Figure `fig_img_topology.pdf` (a) draws the k = 9 mutual embedding as the true pixel lattice (an edge between every
two grid neighbours): on QuickDraw and MNIST a recognisable sheet with a fold near one corner, on Fashion a crumpled one.

### 1.3 Bars

A bar is i, the two ends of one of its 4 recovered axes, and L − 1 further "go straight on" steps at each end (up to 5
pixels for L = 2, 9 for L = 4); the bar feature is the sum of its pixels.

*Measured* (`tables/img_bars.md`; "straight" = all pixels on one horizontal, vertical or diagonal lattice line;
"elongation" = share of the pixel coordinates' variance along the principal axis, 1 for a line, 0.5 for a round blob;
"within 1 px" = every pixel within 1 pixel of the principal axis):

| run | L | mean pixels | straight | contiguous | elongation median | elong. ≥ 0.9 | within 1 px | orientation of all bars 0° / 45° / 90° / 135° |
|---|---|---|---|---|---|---|---|---|
| qd_dev 1000 | 2 | 4.75 | 0.327 | 0.291 | 0.964 | 0.748 | 0.957 | 0.27 / 0.23 / 0.27 / 0.22 |
| qd_dev 3000 | 2 | 4.76 | 0.379 | 0.344 | 0.971 | 0.757 | 0.957 | 0.29 / 0.22 / 0.28 / 0.21 |
| qd_dev 10000 | 2 | 4.78 | 0.421 | 0.381 | 0.982 | 0.765 | 0.958 | 0.29 / 0.22 / 0.28 / 0.21 |
| qd_dev 1000 | 4 | 7.68 | 0.157 | 0.136 | 0.960 | 0.723 | 0.634 | 0.27 / 0.25 / 0.26 / 0.22 |
| qd_dev 10000 | 4 | 7.83 | 0.244 | 0.221 | 0.968 | 0.746 | 0.635 | 0.30 / 0.23 / 0.27 / 0.20 |
| qd_a 10000 | 2 | 4.75 | 0.402 | 0.367 | 0.968 | 0.749 | 0.936 | 0.34 / 0.22 / 0.23 / 0.20 |
| qd_a 10000 | 4 | 7.68 | 0.245 | 0.220 | 0.964 | 0.718 | 0.651 | 0.32 / 0.23 / 0.23 / 0.22 |
| MNIST 10000 | 2 | 4.58 | 0.203 | 0.166 | 0.950 | 0.631 | 0.897 | 0.27 / 0.30 / 0.26 / 0.17 |
| MNIST 10000 | 4 | 6.98 | 0.062 | 0.042 | 0.909 | 0.530 | 0.485 | 0.26 / 0.31 / 0.26 / 0.17 |
| Fashion 10000 | 2 | 4.46 | 0.108 | 0.038 | 0.951 | 0.674 | 0.815 | 0.37 / 0.12 / 0.40 / 0.12 |
| Fashion 10000 | 4 | 6.27 | 0.037 | 0.017 | 0.933 | 0.641 | 0.524 | 0.38 / 0.11 / 0.38 / 0.12 |

(45° = '/', row decreasing as the column increases; 135° = '\'.)

*Reading.* On QuickDraw a bar is a short, nearly straight stroke template: three quarters have elongation ≥ 0.9 and 96%
of the 5-pixel bars stay within one pixel of a line, but only 42% are an exact lattice line (n = 10000); the 9-pixel bars
kink more often (each extra step can turn; 64% within one pixel of a line). Straightness grows with n (exact lines: 0.33 →
0.38 → 0.42 for L = 2, 0.16 → 0.21 → 0.24 for L = 4), as the correlation ranks become less noisy. All four orientations
occur about equally often. On MNIST the bars are less straight (exact lines 0.20 and 0.06), and on Fashion they are
rarely exact lines (0.11 and 0.04); there many bars contain a mirror pixel (§1.1), so they are not local strokes but pairs
of short pieces on the two sides of the garment (visible as long lines across the image in `fig_img_bars.pdf`, Fashion
row).

## 2. What carries the decision

### 2.1 The stacker

The stacker gives each member a weight w ≥ 0 on its log-probabilities (L2 penalty; the weights need not sum to 1). Below:
each family's share of the total weight, and the members' out-of-fold errors.

*Measured* (`tables/img_stack.md`; family shares in `tables/img_summary.json`, key `stack`):

| run | total w | cgbt | ggbt | gknn | kNN (Part 8) | gbt + et (Part 8) | lin (Part 8) | out-of-fold error: cgbt / ggbt / best other |
|---|---|---|---|---|---|---|---|---|
| v3 qd_dev 1000 | 0.797 | 0.316 | 0.089 | 0.437 | 0.158 | 0 | 0 | 0.272 / 0.280 / gknn_3 0.320 |
| v3 qd_dev 3000 | 0.784 | 0.404 | 0.078 | 0.332 | 0.186 | 0 | 0 | 0.1967 / 0.2117 / gknn_3 0.2483 |
| v3 qd_dev 10000 | 0.727 | 0.470 | 0.074 | 0.166 | 0.254 | 0.034 | 0 | 0.1495 / 0.161 / gbt 0.189 |
| v3 qd_a 10000 | 0.703 | 0.560 | 0 | 0.147 | 0.236 | 0.057 | 0 | 0.1605 / 0.1715 / gknn_9 0.1875 |
| v3 MNIST 10000 | 1.055 | 0.404 | 0 | 0.227 | 0.238 | 0.131 | 0 | 0.031 / 0.0425 / gknn_1 0.041 |
| v3 Fashion 10000 | 0.663 | 0.104 | 0.155 | 0 | 0.042 | 0.498 | 0.201 | 0.1256 / 0.1271 / gbt 0.1336 |
| v2 qd_dev 10000 | 0.849 | – | 0.413 | 0.240 | 0.240 | 0.106 | 0 | – / 0.161 / gbt 0.189 |
__V2F_STACK_ROW__

The boosters alone on the test set (each booster's own prediction; `tables/img_class_err.md`, second table):

| run | v3 (stacked) | cgbt alone | ggbt alone |
|---|---|---|---|
| qd_dev 1000 | 0.2118 | 0.2208 | 0.2478 |
| qd_dev 3000 | 0.1753 | 0.1851 | 0.1968 |
| qd_dev 10000 | 0.1330 | 0.1368 | 0.1578 |
| qd_a 10000 | 0.1422 | 0.1442 | 0.1654 (out-of-fold fit, 8000 rows) |
| MNIST 10000 | 0.0255 | 0.0278 | 0.0392 (out-of-fold fit, 7998 rows) |
| Fashion 10000 | 0.1238 | 0.1216 | 0.1222 |

*Reading.* `cgbt` has the lowest out-of-fold error of all members in every run and the largest weight everywhere except
Fashion-MNIST; it took over most of `ggbt`'s role (on `qd_dev` at n = 10000 `ggbt`'s share falls from 0.413 in v2 to
0.074 in v3, and on `qd_a` and MNIST `ggbt` is dropped). The rest of the weight goes to the nearest-neighbour members
(`gknn` on pooled sums and Part 8's kNN on pixels), which make different errors from the boosters. On QuickDraw and MNIST
the stack is better than `cgbt` alone by 0.2–1.0 points. On Fashion-MNIST the stacker spreads half of its weight over
Part 8's `gbt` and `et` and a fifth over logistic regression, whose out-of-fold errors are higher (0.1336, 0.1547,
0.1587), and the stacked learner (0.1238) is slightly worse on the test set than either booster alone (0.1216, 0.1222).
The 2000-row holdout the weights are fitted on cannot resolve differences of this size (s.e. ≈ 0.007 at error 0.125).

### 2.2 Split gain by feature type

*Measured* (`tables/img_gain.md`; share of the final booster's total split gain, `feature_importance("gain")` at its
best iteration; figure `fig_img_gain.pdf`):

| run | booster | pixels | pooled k=4 | k=9 | k=16 | bars L=2 | bars L=4 | pairs |
|---|---|---|---|---|---|---|---|---|
| qd_dev 1000 | cgbt | 0.025 | 0.033 | 0.073 | 0.152 | 0.256 | 0.461 | – |
| qd_dev 3000 | cgbt | 0.019 | 0.032 | 0.062 | 0.142 | 0.239 | 0.506 | – |
| qd_dev 10000 | cgbt | 0.012 | 0.022 | 0.045 | 0.151 | 0.241 | 0.529 | – |
| qd_a 10000 | cgbt | 0.012 | 0.027 | 0.045 | 0.124 | 0.250 | 0.543 | – |
| MNIST 10000 | cgbt | 0.013 | 0.045 | 0.071 | 0.069 | 0.295 | 0.507 | – |
| Fashion 10000 | cgbt | 0.085 | 0.096 | 0.100 | 0.118 | 0.249 | 0.352 | – |
| qd_dev 1000 | ggbt | 0.065 | 0.098 | 0.157 | 0.277 | – | – | 0.404 |
| qd_dev 3000 | ggbt | 0.056 | 0.102 | 0.151 | 0.300 | – | – | 0.391 |
| qd_dev 10000 | ggbt | 0.037 | 0.095 | 0.156 | 0.317 | – | – | 0.395 |
| qd_a 10000 (oof fit) | ggbt | 0.041 | 0.109 | 0.186 | 0.365 | – | – | 0.299 |
| MNIST 10000 (oof fit) | ggbt | 0.054 | 0.121 | 0.182 | 0.231 | – | – | 0.412 |
| Fashion 10000 | ggbt | 0.157 | 0.153 | 0.162 | 0.147 | – | – | 0.381 |

Split counts tell the same story with a different weighting (`img_summary.json`, key `gain`, `split`): at `qd_dev`
n = 10000 the bars make 0.754 of `cgbt`'s splits (L = 2: 0.324, L = 4: 0.430); the pairs make 0.218 of `ggbt`'s splits
but carry 0.395 of its gain. Almost every bar is split on at least once (`qd_dev` n = 10000: 2520 of 2704 L = 2 bars and
2596 of 2704 L = 4 bars), but the gain is concentrated: the top 10% of bars carry 0.65–0.66 of the bar gain on `qd_dev`,
0.78–0.84 on Fashion and 0.86 on MNIST (`img_bars.md`, last column).

*Reading.* In `cgbt` the bars carry three quarters of the gain on QuickDraw and MNIST and three fifths on Fashion, with the
9-pixel bars about twice the 5-pixel ones; the pooled sums keep 0.19–0.26 (0.31 on Fashion) and raw pixels almost
nothing except on Fashion, where single pixels (garment edges at fixed positions) carry 0.085–0.157. The shares hardly
change with n on `qd_dev`. In `ggbt`, the pairs and the largest pooling scale carry most of the gain.

### 2.3 Which bars are used

*Measured* (`tables/img_bars.md`, second and first tables; figure `fig_img_bars.pdf`):
- *Position.* The gain of the bars is spread over the whole drawing area (`fig_img_bars.pdf`, "all bars"). The single
  most-used bars (top 10 of each length, `qd_dev` n = 10000) cluster in a few places: at the bottom centre (rows 21–24,
  columns 13–15: five of the top ten L = 2 bars; L = 4: three '\' bars centred at (22, 10), (22, 11), (24, 11)), on a
  vertical line through the centre ((9, 14), (10, 14)) and in the upper left ((1, 6), (4, 9), both '/'). The single
  largest L = 4 bar carries 1.29% of `cgbt`'s total gain. On MNIST the largest is a 9-pixel '/' bar centred at (18, 10)
  with 2.62% of the gain, followed by a vertical bar at (12, 10) (1.87%), a horizontal bar at (11, 9) (1.65%) and a
  horizontal bar on the bottom row (25, 12) (1.27%).
- *Geometry of the used bars.* On QuickDraw and MNIST the gain-weighted bars are straighter than the average bar
  (`qd_dev` n = 10000, L = 4: 0.323 exact lines weighted by gain against 0.244 of all bars; MNIST L = 2: 0.362 against
  0.203; L = 4: 0.136 against 0.062; `qd_a` L = 4: 0.332 against 0.245). On Fashion they are not (L = 2: 0.089 against
  0.108).
- *Orientation.* On QuickDraw the gain splits over the four orientations about as the bars do (`qd_dev` n = 10000, L = 2:
  0.25 / 0.24 / 0.29 / 0.23 of the bar gain for 0° / 45° / 90° / 135°, against 0.29 / 0.22 / 0.28 / 0.21 of the bars).
  On MNIST horizontal bars carry 0.40 of the bar gain at both lengths (0.27 and 0.26 of the bars) and vertical ones 0.15
  and 0.21 (0.26 of the bars).

*Reading.* The bars are used as position-specific detectors of a short stroke, or of a short empty run, along one
direction (see §3: most of the evidence is the absence of ink). The tree search prefers the straighter bars where the
data have straight strokes; it does not prefer an orientation on QuickDraw; on MNIST the horizontal bars are favoured,
in places where a horizontal stroke or gap tells digits apart (§3.3).

## 3. Class evidence: contribution maps

**Method.** For each class, 100 test points of that class; LightGBM's per-feature contributions (TreeSHAP,
`pred_contrib`) to that class's raw score; each feature's contribution spread over pixels: a pixel to itself, a pooled
sum or a bar equally over its pixels, a prototype pair p over pixels j in proportion to |u_pj x_j|; averaged over the 100
points. Maps are split into the part on pixels inked in the point (x > 0.1) and the part on blank pixels. Maps of the v3
fits; `ggbt`'s maps are the same in v2 (§5). Figures: `fig_img_contrib_qd_dev.pdf`, `fig_img_contrib_fashion.pdf`,
`fig_img_contrib_mnist.pdf` (and `fig_img_contrib_qd_a.pdf`); rows: class mean image, `cgbt`, `ggbt`, `cgbt`'s bars
only, `cgbt` on blank pixels, `ggbt`'s pooled sums only, `ggbt`'s pairs only; each map scaled to its own maximum.

Two properties of the method matter for reading the maps. (1) Spreading a subset sum equally over its pixels places the
evidence of an *empty* bar or pooled set on blank pixels; that is where the feature looks, not where the stroke is.
(2) A pair's contribution is spread by |u_pj x_j|, which is zero on pixels blank in the point; so the pairs' maps follow
the class's own ink by construction ("pairs only" rows) and say little about location.

*Measured, all classes* (`tables/img_contrib.md`, `img_summary.json` keys `contrib`, `contrib_corr`):
- The mean maps are nearly all positive: positive values make at least 0.96 of each map's absolute mass.
- Share of the net evidence on pixels blank in the point (mean over the 10 classes): `cgbt` 0.61 (`qd_dev`), 0.56
  (Fashion), 0.69 (MNIST), 0.62 (`qd_a`); `ggbt` 0.39, 0.40, 0.44, 0.43, and 0.60, 0.53, 0.68, 0.61 once its pairs are
  removed (approximate: pair contributions on faintly inked pixels, 0 < x ≤ 0.1, count as blank).
- Correlation between the `cgbt` and `ggbt` maps of a class: 0.67–0.93 on `qd_dev`, 0.66–0.87 on Fashion, 0.63–0.94 on
  MNIST, 0.40–0.88 on `qd_a`.
- Share of `cgbt`'s |contribution| by feature type (`qd_dev`, mean over classes): bars 0.78, pooled sums 0.20, pixels
  0.02; `ggbt`: pooled sums 0.64, pairs 0.29, pixels 0.07.

The class descriptions below are my reading of the figures; for each named region, `tables/img_regions.md` gives its
share of the class's net evidence for each booster ("share"), the part of that on blank pixels ("blank"; above 1 when
the inked part of the region counts against the class), and the class's mean ink there against the other classes'. The
regions were drawn after looking at the maps, so their shares describe the maps, not an independent test.

### 3.1 QuickDraw (`qd_dev`, n = 10000)

- **ocean.** `ggbt`: the horizon line itself (rows 13–15 carry 0.395 of its net evidence on 0.107 of the image), above
  all its two ends at the image edges. `cgbt`: the ends of the horizon (0.168), and a diagonal band of *empty* pixels from
  the left edge down to the bottom centre (0.258 on 0.077 of the image, 84% on blank pixels): the place where the round
  classes (soccer ball, frying pan, washing machine) draw their outlines. The horizon line itself carries only 0.178.
- **motorbike.** The empty patch at the bottom centre, between the wheels (0.200 for `cgbt`, 0.163 for `ggbt`, on 0.026
  of the image; the class has ink 0.036 there, the others 0.275); `cgbt` adds pieces of the wheels' strokes.
- **matches.** Empty pixels beside the stick (left of it: 0.134 / 0.111), and the stick's length.
- **grapes.** The dense ink of the centre (0.355 / 0.347 on 0.069 of the image), and a ring of empty pixels near the
  border (no outline).
- **paper clip.** The clip's rounded top end at the top edge (0.107 / 0.125 on 0.031 of the image); empty sides.
- **campfire.** The base of the fire (0.358 / 0.318 on 0.080 of the image, on ink); empty left and right sides
  (0.097 / 0.084).
- **washing machine.** The corners of the square body (upper corners 0.188 / 0.236); `cgbt` draws them as short diagonal
  strokes, `ggbt` as blobs.
- **soccer ball.** The outline: `cgbt` follows the upper-left arc as a chain of diagonal bars (0.176 on 0.060 of the
  image, against 0.122 for `ggbt`), plus the left and right sides (0.223 / 0.242).
- **frying pan.** The two ends of the horizontal shape at the left and right edges (0.073 / 0.094), empty space below
  the pan (0.095 / 0.097) and above it.
- **foot.** Empty pixels in the middle (0.223 / 0.169, blank 0.95 / 0.68) and the sole along the bottom (0.091 / 0.104).

*Reading.* Both boosters use mostly the same places; much of the evidence for a class is the absence of ink where its
confusable classes draw (the round classes' outline for ocean, the space between the wheels for motorbike, the middle of
a foot). Where `cgbt` differs it follows a stroke or an empty run along a line: the arc of the soccer ball, the diagonal
empty band for ocean, the corner strokes of the washing machine.

### 3.2 Fashion-MNIST (n = 10000)

- **T-shirt.** The ends of the short sleeves (0.165 / 0.179, on ink) and the empty lower sides of the image where long
  sleeves would be (0.295 / 0.244 on 0.168 of the image, all blank).
- **trouser.** The empty gap between the legs, a vertical strip at column 13–15 from row 14 down (0.256 / 0.308 on 0.054
  of the image).
- **pullover.** The neckline (0.073 / 0.081 on 0.015 of the image); otherwise diffuse.
- **dress.** The hem (0.175 / 0.182, on ink) and empty pixels beside the waist (0.101 / 0.103).
- **coat.** Diffuse: the largest region found, outside the shoulders (0.169 / 0.155), covers 0.133 of the image.
- **sandal.** An empty region in the upper left (0.390 / 0.303 on 0.061 of the image; class ink 0.002, other classes
  0.312), the heel at the right (0.098 / 0.116), and ink in the middle of the shoe counts *against* sandal (blank 1.10 /
  1.07: the inked part of that region is negative).
- **shirt.** The left shoulder and collar (0.277 / 0.306 on 0.041 of the image, on ink).
- **sneaker.** The same empty upper-left region as sandal (0.364 / 0.261) and the heel at the right edge (0.104 / 0.137).
- **bag.** An empty top centre (0.177 / 0.128; class ink 0.104 against 0.358), the left edge of the bag's body
  (0.115 / 0.122) and the empty space under it.
- **boot.** An empty vertical strip left of the boot's shaft (0.410 / 0.246 on 0.046 of the image; class ink 0.001
  against 0.342) and the ankle (0.094 / 0.092).

*Reading.* The silhouette's outline against empty space carries most of the evidence; footwear is told apart by where the
shoe is *not* (the upper left, where garments and bags have ink) and by the heel. `cgbt` and `ggbt` agree closely here
(map correlation 0.66–0.87), and their test errors too (0.1216 and 0.1222).

### 3.3 MNIST (n = 10000)

- **0.** The empty centre, the hole (0.461 / 0.409 on 0.032 of the image).
- **1.** Empty strips on both sides of the stroke (0.456 / 0.323), drawn by `cgbt` as diagonal bars parallel to it.
- **2.** A horizontal empty segment at rows 10–12 on the left, under the open upper bowl (0.187 / 0.126), and the base
  (0.258 / 0.326, mostly on ink).
- **3.** The open left side (0.321 / 0.226).
- **4.** The open top (0.276 / 0.245): a 4 is open above, a 9 closed.
- **5.** An empty horizontal segment under the top bar on the right (0.258 / 0.190).
- **6.** The empty space right of the stem above the loop (0.146 / 0.154).
- **7.** A '/' diagonal band of empty pixels left of the stem (0.301 / 0.225), drawn by `cgbt` as a chain of bars, and
  the stem's bottom end (0.089 / 0.048).
- **8.** The central crossing of the strokes (0.262 / 0.296, on ink).
- **9.** Empty space in the lower left (0.080 / 0.075) and a horizontal segment on the bottom rows (0.084 / 0.028).

*Reading.* Here `cgbt`'s maps look like line drawings (the 7's diagonal band, the 2's horizontal segment, the parallel
strips of the 1), where `ggbt`'s are blobs; in every listed "empty" region `cgbt` puts a larger share of its evidence
than `ggbt` except for 6 and 9 (equal). The digits are told apart mostly by where they are open.

### 3.4 cgbt vs ggbt maps

*Measured:* the maps correlate at 0.63–0.94 (above); `cgbt`'s evidence is 78% bars by absolute contribution; its share
on blank pixels (0.56–0.69) equals `ggbt`'s without the pairs (0.53–0.68).

*Reading.* `cgbt` does not look at different places from `ggbt`; it looks at the same places through thinner, oriented
windows. Both boosters rely on empty regions about equally once the pairs are set aside; the pairs are what makes
`ggbt`'s evidence look ink-centred. The visible difference is shape: lines and chains of short segments (oriented
strokes and gaps) for `cgbt`, isotropic blobs for `ggbt`'s pooled sums, and class silhouettes for its pairs.

## 4. The prototype pairs of ggbt

A pair projection is (x_a − x_b) · x for two training images a, b of different classes; 300 pairs are drawn at random,
so the number of pairs per class pair varies (3–16 here).

*Measured* (`tables/img_pairs.md`, `img_summary.json` key `pairs`; figure `fig_img_pairs.pdf`):
- The pairs carry 0.38–0.41 of `ggbt`'s gain (0.30 for `qd_a`'s out-of-fold fit) and every pair is split on (299–300 of
  300).
- The gain is concentrated in a few pairs: the top 10 of 300 pairs carry 0.29 of the pair gain on `qd_dev`, 0.50 on
  Fashion and 0.36 on MNIST.
- Class pairs with the most gain per drawn pair, relative to the average pair (class pairs with ≥ 3 pairs drawn; number
  drawn in brackets):
  - `qd_dev` n = 10000: grapes–soccer ball 5.31 (3), motorbike–frying pan 3.18 (8), ocean–matches 1.96 (7), paper
    clip–soccer ball 1.94 (8), ocean–grapes 1.92 (8); lowest: motorbike–soccer ball 0.17 (5), ocean–paper clip 0.21 (9).
    At n = 3000 the top class pair is a different one, ocean–soccer ball 4.83 (7).
  - Fashion: trouser–boot 5.76 (9), shirt–sneaker 4.87 (5), T-shirt–trouser 2.30 (8), dress–bag 2.30 (4), T-shirt–sandal
    2.05 (16); lowest: T-shirt–dress 0.01 (4), sandal–boot 0.02 (5), sandal–bag 0.02 (14), T-shirt–shirt 0.04 (5).
  - MNIST: 1–2 4.02 (8), 0–1 3.50 (5), 3–4 2.64 (11), 4–6 2.48 (4), 7–8 2.40 (6), 0–9 2.39 (9); lowest: 8–9 0.11 (3),
    2–6 0.15 (6), 1–7 0.16 (8).
- By class (share of pair gain involving the class, each pair counted for both classes): Fashion: trouser 0.171, boot
  0.162, T-shirt 0.156, pullover 0.046, dress 0.052.

*Reading.* The useful pairs contrast two very different silhouettes (trouser with boot, shirt with sneaker, 1 with 2),
not two confusable classes (T-shirt with shirt or dress, sandal with boot carry almost nothing). A projection on
x_trouser − x_boot is large for anything shaped like trousers and small for anything shaped like a boot: a coarse
template for a group of classes, which the trees then refine with the local features. Which class pairs win also depends
on which drawings happened to be drawn (the top class pair on `qd_dev` changes between n = 3000 and n = 10000), so these
are properties of this fit, not of the classes.

## 5. v3 against v2

### 5.1 Same booster, new booster

*Measured* (`img_summary.json` keys `pool_same_v2_v3`, `v3_vs_v2`, `contrib_corr`): on `qd_dev` at n = 10000 the pooling
sets of v2's and v3's fits are identical, `ggbt`'s test predictions agree on 100% of the test points, its maps correlate
at 1.000 for every class, and its split gain by type is identical (both fits early-stopped `ggbt` at 123 rounds).
__V2F_SAME__ So v3 = v2's members plus `cgbt`, with a refitted stacker.

### 5.2 Where the error changes

*Measured* (`tables/img_class_err.md`; same 10000 test points):
- `qd_dev` n = 10000: v2 0.1467 (analysis fit; cell 0.1463), v3 0.1330. 2.08% of the test points are right in v3 and
  wrong in v2, 0.71% the reverse. Per class (v2 → v3): campfire 0.200 → 0.158, grapes 0.280 → 0.243, matches 0.269 →
  0.247, motorbike 0.110 → 0.095, soccer ball 0.082 → 0.075, washing machine 0.060 → 0.055, paper clip 0.138 → 0.134,
  ocean 0.087 → 0.084, frying pan 0.121 → 0.119, foot 0.120 → 0.120. `cgbt` alone vs `ggbt` alone on the same classes:
  campfire 0.155 vs 0.201, grapes 0.229 vs 0.262, matches 0.254 vs 0.288, motorbike 0.105 vs 0.126; foot is the only
  class where `cgbt` alone is worse (0.123 vs 0.121).
__V2F_ERR_BULLET__
- Evaluation cells of the same learners (`$SCRATCH/p9/cells/`, seed 0, n = 10000): `qd_a` v2 0.1509
  (`hyb_portfolio2__qd_a`), v3 0.1422; on MNIST the Part 9 evaluation of v2's image member gives 0.0299
  (`standard_tasks/results/p9_gates-dev__mnist.json`, harness of Part 9; `p9_gates` ≡ v2 on images at this n) against
  v3's 0.0255 here (no v3 cell).

### 5.3 What cgbt adds

*Measured* (§2; `img_stack.md`, `img_gain.md`, `img_class_err.md`; CPU from the fits' `member_cpu`, process seconds):
- *Weight:* `cgbt` gets the largest share of the stacker's weight on QuickDraw and MNIST (0.32 → 0.40 → 0.47 on `qd_dev`
  for n = 1000 → 3000 → 10000; 0.56 on `qd_a`; 0.40 on MNIST), and 0.10 on Fashion.
- *Out-of-fold error vs `ggbt`:* 0.272 vs 0.280 (`qd_dev` 1000), 0.1967 vs 0.2117 (3000), 0.1495 vs 0.161 (10000),
  0.1605 vs 0.1715 (`qd_a`), 0.031 vs 0.0425 (MNIST), 0.1256 vs 0.1271 (Fashion).
- *Alone on the test set:* 0.1368 vs 0.1578 (`qd_dev` 10000), 0.1442 vs 0.1654 (`qd_a`, `ggbt` out-of-fold fit), 0.0278
  vs 0.0392 (MNIST, same caveat), 0.1216 vs 0.1222 (Fashion). They agree on 0.93 (`qd_dev`), 0.92 (`qd_a`), 0.98
  (MNIST) and 0.97 (Fashion) of the test points.
- *Gain mix:* bars 0.72–0.80 of its gain on QuickDraw and MNIST, 0.60 on Fashion (§2.2).
- *Cost:* at `qd_dev` n = 10000, `cgbt` takes 293 CPU s of v3's 526 s fit (`ggbt` 131 s); on Fashion 286 of 671 s.

*Reading.* On QuickDraw and MNIST `cgbt` is a better booster than `ggbt` (lower out-of-fold and test error at every n
measured) and replaces it in the stack; v3's error drop on `qd_dev` comes from classes whose evidence is a stroke or gap
of a particular shape at a particular place (campfire's base, grapes' cluster, matches' stick, motorbike's wheels). On
Fashion-MNIST, whose bars are poor lines (§1.3) and whose evidence is silhouette outlines that pooled sums and single
pixels already capture, `cgbt` and `ggbt` are equal and the stack gains nothing from either.

## 6. Caveats

- One seed (0) per cell; one fit per run. Out-of-fold errors at n = 10000 rest on 2000 holdout rows.
- The v2 fit on `qd_dev` reproduces Part 9's evaluation of the same member but not the Part 10 v2 cell (0.1467 vs 0.1463;
  §0). __V2F_CAVEAT__
- Two boosters analysed for MNIST and `qd_a` (`ggbt`) are out-of-fold fits on 8000 rows, not final members.
- Contribution maps depend on the spreading rule (§3); pairs' maps follow the ink by construction. Regions in
  `img_regions.md` were chosen after looking at the maps.
- Geometry is measured against the true grid, which the learner never sees; the Isomap R² is sensitive to a few long
  edges and is not a property the learner uses.
- MNIST and `qd_dev` at n = 3000 have no v3 evaluation cell, so those two fits are checked only by construction (the same
  code path as the checked fits).

## 7. Figures and tables

- `figures/fig_img_topology.pdf`: Isomap lattices (k = 9 mutual) for the six v3 runs; R² by graph and n; members of
  S_i(k) within 1 / 2 steps; six S_i(16) on the true grid.
- `figures/fig_img_bars.pdf`: the 12 bars with most gain of each length, drawn on the grid (qd_dev, Fashion, MNIST at
  n = 10000); bar gain by orientation at the bar's centre (2 × 2 blocks); bar and pooled-sum gain per pixel; geometry of
  all bars vs gain-weighted; straightness vs n and dataset; orientation shares.
- `figures/fig_img_gain.pdf`: split gain by feature type for every booster analysed.
- `figures/fig_img_stack.pdf`: stacker weight by member family; members' out-of-fold errors vs n on `qd_dev`.
- `figures/fig_img_contrib_qd_dev.pdf`, `fig_img_contrib_fashion.pdf`, `fig_img_contrib_mnist.pdf`,
  `fig_img_contrib_qd_a.pdf`: per-class contribution maps (§3).
- `figures/fig_img_pairs.pdf`: `ggbt`'s pair gain by class pair, total and per drawn pair.
- Tables: `tables/img_*.md` and `tables/img_summary.json` as listed above.
