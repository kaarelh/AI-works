# Part 9 audit, lens "discreteness": is it discrete, and is the image member really pixel-permutation invariant?

Auditor scope: code and process of `hyb_portfolio2` (now md5 e38af404..., = 6837fa52... + the recorded post-freeze crash
fix), `p9_sum/dfg12.py`, `p9_gates`, `p9_bank`, the eval/compare scripts, the MLP references. No file under
gd-circuit-growth/ was modified. Held-out results were not read: from part9/RESULTS.md I read only the integration-rule
section (lines 1-12) and the dev image section with every qd_a / qd_b line filtered out. Disclosure: one `sed` of
boolfuncs.py lines 300-345 (to find the dlsymdev definitions) also printed the first targets of `make_dl_heldout4_suite`
(target definitions, source code, no data or results); nothing was done with it.

Experiments (dev data only; training rows pool[:n], evaluation on validation pool rows pool[50000:52000], never test
rows; about 7.5 CPU-min in all, nice 19, single-threaded, < 0.5 GB). Scripts and outputs:
`/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p9/audit/disc/`
(`e2e.py`, `spatial.py`, `dfg_seeds.py`, `dfg_noquad.py`, `e2e_qd_1000_ggbt.json`, `dfg_seeds_*.txt`, `dfg_noquad_256.txt`).

## Verdict

Nothing in Part 9 trains a neural network or optimizes a continuous feature parameter, so the Part 8 line
("no continuous feature parameters", not "no gradients") still holds. But the two image ingredients that carry the gains
are not discrete in any stronger sense:
- the pooling sets recover the pixel grid from correlations, so the member is a fixed sum-pooling (box-filter) layer on a
  data-recovered topology;
- the prototype pairs are unfitted continuous oblique projections.

Bit-for-bit, the image member is not permutation invariant. The pooling sets and gknn are exactly invariant. ggbt is
invariant only in distribution: permuting the columns changes as many predictions as changing the seed. That level of
invariance is enough against an MLP, which is also invariant only in distribution. The real issue is interpretation. On
pixel-permuted QuickDraw the member still uses spatial locality, recovered from the data, which PROTOCOL.md lines 10-11
say would call for a CNN-type comparison. The sum blocks are discrete as claimed. Their spectral search seeds are not
load-bearing on the dev cells I tried.

No blocker. Three major findings concern how the image result may be worded and attributed, and five are minor.

## Findings

### D1 (major): the pooling sets recover spatial neighbourhoods, even on the stored-permuted QuickDraw data
Evidence:
- `hyb_portfolio2/learner.py:228-248` (`pool_sets`: the k most correlated columns of each column) and `:534-544` (the
  gknn and ggbt banks).
- `spatial.py` maps each column back to its grid position (qd_*: data.py's permutation `default_rng(9192)`; MNIST and
  Fashion are stored in natural order). It then measures the Chebyshev grid distance from each column to the other
  members of its set:

| data | n | k | members at distance ≤ 1 | members at distance ≤ 2 | sets entirely in the 3x3 (k ≤ 9) / 5x5 (k = 16) | random-set baseline (≤ 1 / ≤ 2) |
|---|---|---|---|---|---|---|
| qd_dev (permuted) | 1000 | 4 | 0.983 | 0.999 | 0.950 | 0.010 / 0.034 |
| qd_dev (permuted) | 1000 | 9 | 0.823 | 0.985 | 0.281 | 0.011 / 0.032 |
| qd_dev (permuted) | 10000 | 9 | 0.834 | 0.994 | 0.345 | 0.011 / 0.032 |
| qd_dev (permuted) | 10000 | 16 | 0.491 | 0.834 | 0.107 | 0.011 / 0.033 |
| MNIST | 10000 | 9 | 0.787 | 0.966 | 0.174 | 0.012 / 0.034 |
| Fashion-MNIST | 10000 | 9 | 0.633 | 0.840 | 0.005 | 0.010 / 0.025 |

So p_i(x) is a 3x3 / 5x5 sum-pool around pixel i, on the true grid, already at n = 1000. ggbt thresholds blob
intensities at three scales, and gknn is nearest neighbours on box-blurred images. The construction is formally
layout-free and is disclosed in p9_gates/DESIGN.md:158-161 (§7). These numbers show that in practice the column
permutation hides nothing from this member. The idea is known: topology recovery from pixel correlations (Le Roux et
al. 2007), and receptive fields chosen by correlation grouping (Coates & Ng 2011).

Consequence:
- Q2's "discrete learner beats the MLP on qd_a / qd_b at n ≥ 10000" compares a learner with a built-in locality prior
  against MLPs that have none.
- PROTOCOL.md:10-11 says "a method using spatial structure would have to be compared with a CNN". The letter of the
  protocol (invariance to a fixed permutation) is met; its spirit is not.
- An MLP could in principle learn local pooling, but the comparator, a 256-256 MLP with no locality prior, in practice
  does not.
- Dev attribution points the same way. p9_bank has pair gates but no pooling, and gains −0.13 / −0.06 / −0.04 in log2
  over v1 on qd_dev at n = 1000 / 10000 / 60000. p9_gates, with pooling, gains −0.24 / −0.20 / −0.23. (RESULTS.md
  integration-rule rows.)

Fix (wording and post-hoc controls; the frozen learner stays as is):
1. Word it as "permutation-invariant, with locality recovered from pixel correlations", not "uses no spatial structure".
2. Post hoc, run `mlp_strong` on [x, p(x)], with the pooled sums computed by the same `pool_sets` from the training rows
   of each fit. This separates "the representation" from "the discrete learner".
3. Report a small CNN on unpermuted qd_a / qd_b as the protocol's "spatial" reference, or at least cite the gap.
4. Ablate hyb_portfolio2 with the pooled columns removed from ggbt and with gknn removed (D3).

### D2 (major): the prototype-pair features are continuous oblique projections drawn from the data, not discrete features
Evidence:
- `hyb_portfolio2/learner.py:251-260` (`pair_dirs`: U = x_a − x_b, float32) and `:263-270` (features x @ U^T).
- Each normal has 784 real entries in [−1, 1] (pixels/255). p9_gates/DESIGN.md:45-46 says "all with weights in
  {−1, 0, +1} on pixels or on two training points". For the pairs this holds only in the training-point basis.
- p9_bank/DESIGN.md:67-68 states the same object honestly as "borderline: the hyperplane normal x_a − x_b has
  continuous entries".
- (x_a − x_b)·x − (|x_a|² − |x_b|²)/2 = (|x − x_b|² − |x − x_a|²)/2: a two-point Euclidean comparison. With an arbitrary
  LightGBM threshold it is a general halfspace whose normal is sampled from the data.

Classification against Part 8 (HYBRID.md §9):
- They belong with kNN ("Euclidean memory"): unfitted and data-sampled.
- They are not like the spectral block, whose eigenvector direction is optimized in closed form.
- They are not Boolean features of pixels either.

How much they carry (dev validation, p9_gates/DESIGN.md §5.1, MNIST n = 10000, LightGBM 100 rounds): raw 0.0452;
+500 pairs 0.0420; +pooled 0.0418; +pooled +300 pairs 0.0386. On MNIST the pairs give roughly half of the bank's
gain. On Fashion n = 10000, +500 pairs takes 0.1184 to 0.1153.

Consequence: part of the image gain is carried by unfitted continuous projections. "Discrete image member" overstates
this.

Fix:
- Use the p9_bank wording ("oblique halfspace gates whose normals are differences of two training images; nothing in
  the normal is fitted").
- Add pairs to the §9 borderline list next to kNN.
- Post hoc, ablate ggbt without pairs. Optionally replace the pairs with random ±1 sparse sums, to test whether
  "prototype" matters or any oblique projection would do.

### D3 (major): what carries the image gains was not recorded, and ggbt's gain over Part 8's gbt is confounded with boosting rounds
Evidence:
- p9_gates/DESIGN.md:151: §6 "Full dev evaluation" says "(filled in below)" and is empty.
- The frozen dev result files (`standard_tasks/results/p9_gates-dev__*.json`) hold only err / flops / cpu.
- `part9/eval_cells.py:44` saves only n, seed, err, flops and cpu, so the held-out runs will not record
  `info["weights"]` or `info["member_oof_err"]`. This is Part 8 discreteness finding F4 (attribution not recorded),
  repeated.
- The only attribution evidence is pre-freeze and on validation data (DESIGN §5.4). There ggbt is the best single
  member and has the largest stacking weight on every cell, and gknn beats the Part 8 kNN (qd_dev n = 10000: out of
  fold 0.190 against 0.228).
- ggbt differs from v1's `gbt` in more than the feature bank:
  - rounds: early stopping on validation error, 150-400 rounds when the member's training set has ≥ 5000 points
    (`hyb_portfolio2/learner.py:298-335`), against gbt's fixed 100;
  - column fraction 0.12 against 0.25 / 1.0; 63 bins against 255; bagging.
- DESIGN §5.3 (MNIST n = 50000, validation): raw-pixel LightGBM at 100 / 300 rounds gives 0.0263 / 0.0219, which is
  −0.26 in log2 from rounds alone. The full bank at 300 rounds gives 0.0191, a further −0.20 from the features. At
  n ≤ 3000 (k-fold) both members use 100 rounds, so there is no rounds confound at small n.

Consequence: at n ≥ 10000, the Q2 cells, perhaps half of ggbt's advantage over the Part 8 tree member is "boost
longer", which has nothing to do with new discrete features. Without recorded weights, the write-up cannot say which
member carries a held-out gain.

Fix: post-hoc ablations, labelled post hoc. Each needs one seed at n ∈ {1000, 10000, 60000} on qd_a, qd_b and qd_dev,
and must save `info`:
- (a) hyb_portfolio2 without gknn (`members` = all but gknn);
- (b) without ggbt;
- (c) ggbt with bank = x only (raw pixels), keeping the early-stopping schedule: separates rounds from features;
- (d) ggbt without pairs;
- (e) ggbt without pooled columns;
- (f) v1 with gbt at the ggbt round schedule;
- (g) `mlp_strong` on [x, p(x)] (D1).

Also patch eval_cells.py, for future runs only, to dump `fit["info"]` (weights, member_oof_err, ggbt_rounds).

### D4 (minor): end-to-end, ggbt is invariant only in distribution; test_perm.py does not test the learner end to end and overstates two claims
Evidence:
- `e2e.py`, hyb_portfolio2 with only the gates members, qd_dev n = 1000, 2000 validation rows (A unpermuted, B columns
  permuted with the same rng, C unpermuted with another rng seed):
  - gknn only: A = B = C, prediction agreement 1.000.
  - ggbt only: errors 0.251 / 0.248 / 0.251; A-B agreement 0.913, against 0.899 between seeds (A-C); out-of-fold errors
    0.280 / 0.272 / 0.271. A permutation therefore acts like a reseed. The causes are LightGBM's
    `feature_fraction` (`learner.py:317`), which samples columns by index, and the column order of the pooled block
    (`act`, in index order).
- `p9_gates/test_perm.py:26` reorders the permuted run's pooled columns back to the original order (`[:, m]`) before the
  kNN check. It therefore never exercises the learner's own column order. My end-to-end check shows gknn is exact
  anyway.
- test_perm output (rerun at n = 1000, qd_dev and MNIST): pooled features differ by up to 1.9e-6, and pair projections
  by up to 6.1e-5 (float32 summation order). DESIGN.md:55 says "identical pair projections"; the test's tolerance is
  1e-3 (`test_perm.py:36`).
- `pool_sets` breaks ties by a column fingerprint (`learner.py:239-240`). Columns that are identical over the first
  ≤ 20000 rows (rare sparse corner pixels) share the fingerprint and fall back to index order. This is harmless.

Consequence: there is no bias. The data are permuted once, and in-distribution invariance is all the MLP comparison needs,
as for Part 8's gbt and et and for the MLP's own initialisation. But "exactly equivariant / invariant" should be limited
to the pooling sets and gknn.

Fix:
- Wording: "pooling sets and gknn exactly; ggbt in distribution (a permutation changes predictions about as much as a
  new seed)".
- Optionally add `e2e.py` as the end-to-end test.

### D5 (minor): sum blocks are discrete as claimed; the spectral search seeds are not load-bearing on the dev cells tried; the v1.1 spectral (u·x)² block is still in the hypothesis
Evidence:
- `dfg12.py:148-287`: the hypothesis is the group indicators of integer signed sums (optionally times a character, or
  joint cells of two blocks). The readout is v1.1's least squares + logistic, which is convex.
- `dfg12.py:197-201`: `eigh` of the residual pair matrix only orders inputs into prefix candidates. The union bound in
  `tk` covers the whole class, so the search does not affect the test's validity.
- `dfg_seeds.py`: DFG v1.2 alone, inputs permuted, seed 0, frozen default against `sum_seeds=(0, 3, 2)` (no eigenvector
  seeds):

  | n | targets | test-error difference |
  |---|---|---|
  | 1024 | sym7, ex3of8, band11, ssym9, twosym, symxpar | none (all 0.000 both ways) |
  | 256 | sym7, ssym9, ex3of8, far9 | max 0.002 (far9 0.008 → 0.006) |

  v1.1 without sum blocks: 0.04-0.51.
- The v1.1 quadratic block (`dfg12.py:486-490`, continuous eigenvector directions) was accepted in 4 of the 10 default
  fits (sym7, ssym9 and far9 at n = 256; ssym9 at n = 1024).
- `dfg_noquad.py` (`blocks=False`, so no linear and no quad block): sym7 / ssym9 / far9 at n = 256 give 0.000 / 0.000 /
  0.000, against the default's 0.001 / 0.001 / 0.008. The spectral features are redundant there.

Consequence:
- "Discrete hypothesis, with a spectral ordering heuristic in the search" is the honest classification. It is the one
  p9_sum/DESIGN.md:110 and :300-303 give.
- The only continuous-direction features in the toy hypothesis are still DFG's (u·x)² (Part 8 F3). They are unablated
  in the frozen runs, though redundant on these cells.
- Single seed, few cells.

Fix: post hoc on dlheld5, the clean suite:
- run `sum_seeds=(0, 3, 2)` and a variant without the quad block (a flag would be needed; `blocks=False` also drops the
  linear block);
- report both, so that the toy gain can be credited to the discrete blocks.

### D6 (minor): ggbt's "continuous quantities fitted: only leaf values on fixed partitions" understates boosting
Evidence: p9_gates/DESIGN.md:49-50. LightGBM chooses every split by gradient / Hessian gain, then sets the leaf values
by Newton steps. This is functional gradient descent, Part 8 F5. kNN on pooled sums is Euclidean memory under a fixed,
data-chosen linear map (a blur), Part 8 F6. `lin` on z-scored pixels is a linear model (F7).

Consequence: the wording is inherited from Part 8 and is tolerable, but the write-up should repeat Part 8 §9's
caveats for the image side, which is now gates + trees + kNN + LR.

Fix: carry HYBRID.md §9's "borderline components" list over. Add pooled kNN and the pair gates.

### D7 (minor; outside this lens, for the fairness audit): the strong MLP treats QuickDraw as tabular, not as an image
Evidence:
- `standard_tasks/mlp_strong.py:24`: `IMAGES = ("mnist", "fashion_mnist")`.
- `:111`: `image = name in IMAGES`.
- `:31-35`: so on qd_dev / qd_a / qd_b each pixel goes through a QuantileTransformer to a standard normal (sparse
  strokes, many ties at 0). MNIST pixels are scaled to [0, 1].
- `mlp_l2unit` (raw [0, 1]) on qd_dev is worse than `mlp_strong` at every n (60000: 0.1464 against 0.1324), so the
  quantile encoding is not an obvious handicap. Still, the strong recipe with image scaling was never run on QuickDraw.

Consequence: the reference for Q2 is the per-pixel quantile-transformed MLP, which differs from the MNIST recipe.
Whether that weakens or strengthens it is unknown.

Fix: run `mlp_strong` with image scaling on qd_dev (dev; a cheap check). If it is better, add it to `mlp_best` for
qd_a / qd_b and disclose.

## Answers to the lens questions

1. **Sum blocks.**
   - Hypothesis: discrete (subset, signs, value-group indicators, one character modulator).
   - Search: combinatorial (prefixes, greedy growth, local moves), plus a spectral ordering seed. Removing the seed made
     no difference on 10 dev fits.
   - Continuous parts: the readout (convex) and v1.1's (u·x)² spectral features, which co-occur in 4 of 10 fits and
     were redundant in the 3 I tested (D5).
2. **Gates.**
   - Pooling sets: a discrete subset, chosen by an unsupervised correlation statistic (the PCA matrix, ranked rather
     than eigendecomposed). In effect, a fixed box-filter layer on a recovered grid (D1).
   - Prototype pairs: unfitted continuous oblique projections drawn from the data. Same category as kNN, not as the
     spectral block (D2).
   - LightGBM: axis-aligned thresholds at histogram bins on these features, with gradient-chosen splits and Newton
     leaves. Functional gradient descent, as in Part 8 (D6).
   - (x_a − x_b)·x is not a discrete feature. Thresholded, [(x_a − x_b)·x > t] is a discrete gate with a continuous,
     unfitted normal.
3. **Permutation invariance.**
   - Exact for the pooling sets and gknn; in distribution only for ggbt (permuted-vs-unpermuted agreement 0.913, against
     0.899 seed-to-seed) (D4).
   - The pooling recovers spatial neighbourhoods from data. On qd_dev, stored permuted, 99% of S_i(9) members are
     within 2 grid steps (D1).
   - Against an MLP this is legitimate by the protocol's operational definition. But it is a locality prior the MLP
     lacks, so the protocol's "compare with a CNN" clause applies in spirit. Add the MLP-on-pooled-features control and
     a CNN reference.
4. **What carries the image gains.**
   - From dev: ggbt first, then gknn.
   - Within ggbt: the pooled sums and the pairs share the feature gain at MNIST n = 10000. At large n, longer boosting
     accounts for about as much as the features.
   - Contrast with p9_bank (pairs only): pooling, that is locality, is what separates the two on QuickDraw.
   - None of this is recorded for the frozen or held-out runs; post-hoc ablations (a)-(g) in D3.
