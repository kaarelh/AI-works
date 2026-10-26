# hyb_portfolio: a portfolio of discrete learners combined by cross-validated stacking

Part 8, design 3 ("portfolio + stacking"). Frozen code: `learner.py` (class `Learner`, default constructor, name
`hyb_portfolio`). Development used only the toy `designed` suite and the 5 standard DEV datasets (optdigits, magic,
kr_vs_kp, satimage, spambase), plus synthetic random arrays of MNIST shape for timing and memory.

## 1. Algorithm

**Members.** Each member is a discrete learner that outputs class probabilities.

| member | what it is | what is discrete | structure it is there for |
|---|---|---|---|
| `dfg`, `dfg_forced` | DFG v1.1 (`discrete_learner/dfg.py`, `readout="logit"`), run unchanged through its `_fit`: exhaustive search over Fourier characters of degree ≤ 4 (degrees 5–6 on a budgeted subsample), union-bound tests on the least-squares residual, extensions, local Walsh search, linear and spectral blocks, LS + logistic readout. `dfg_forced` is DFG's own small-n variant (take the best-scoring character when nothing passes, at most twice), offered for n ≤ 512 | characters χ_S chosen by enumeration and tests | parities, staircases, majorities of parities, multiplexers, sparse polynomials: features with **no marginal signal**, which trees cannot find. Used only when every column is binary or categorical (→ ±1 bits, ≤ 256 bits) and C = 2 |
| `gbt` | LightGBM gradient-boosted trees: 100 rounds, lr 0.1, 31 leaves, `min_child_samples` = clip(n/25, 2, 20), categorical columns as categories | axis-aligned threshold splits, greedy | thresholds and interactions on tabular data (magic, spambase, kr_vs_kp at large n), ANDs / DNFs on the toy suite |
| `et` | sklearn ExtraTrees: 100 trees, √d features per split, bootstrap; **out-of-bag** probabilities are its out-of-fold predictions (no refit) | random axis-aligned thresholds | smooth, small-n problems (it is the best single member at n = 100 on magic and satimage) |
| `knn_<metric>_<k>` | k-nearest-neighbour vote fractions, k ∈ {1, 3, 9, 27}, under two metrics: `std` (the MLP's encoding: z-scored continuous, ±1 binary, one-hot categorical) and `raw` (every column numeric, one common scale; the natural metric for pixel data; offered only when continuous scales differ by > 1.5× or there are categorical codes). **Leave-one-out** votes are the out-of-fold predictions | prototypes = training points; the vote is a count | images and other smooth, prototype-like data (optdigits, satimage) |
| `lin_<C>` | multinomial L2 logistic regression on the `std` encoding, C ∈ {0.05, 1} (only C = 1 above n = 10000) | none (the convex readout alone, the "kernel background") | linear structure, small-n images (optdigits n = 100) |

**Combination (stacking).** Each member's out-of-fold log-probabilities L_m (h × C) on a stacking set give the score

  s_c(x) = b_c + Σ_m w_m L_m(x)_c,   w_m ≥ 0,

fitted by multinomial log-loss with L2 penalty 1e-2 on w and b (convex; L-BFGS-B with bounds). This contains selection
(one w_m > 0) and log-linear pooling; it has only M + C parameters (M ≈ 6–14), so it can be fitted at n = 100.
Members with w_m ≤ 1e-3 · max w are dropped and never refitted.

**Stacking set.** n ≤ 500: stratified 10-fold cross-validation; 500 < n ≤ 3000: 5-fold; n > 3000: one stratified
holdout of min(n/5, 6000) points. DFG, GBT and logistic regression are refitted on all n after the weights are
chosen (except GBT on inputs with n·d > 1e7, see compute); kNN and ExtraTrees already use all n (leave-one-out /
out-of-bag).

**Compute (FLOPs, multiply-add = 2; prediction not counted, as for the networks).** DFG: its own counter. kNN:
2·q·n·d for distances + 3·q·n for selection (q = stacking-set size). Logistic: 5·n·(p+1)·C per L-BFGS iteration, with
the iteration count sklearn reports. LightGBM (analytic): per tree 10·n_rows·d_cols (histogram passes over ≤ 5 levels
with the subtraction trick, 2 FLOPs per row-feature) + 8·31·d_cols·255 (split search over 255 bins), + 16·n·d for
binning. ExtraTrees: 4·mtry·(samples reaching the node) summed over the internal nodes of every fitted tree (min/max
scan, random threshold, partition). Stacker: 6·h·M·C per L-BFGS evaluation. Budgets: toy = one network run
(1.62e11 at d = 30); real = `common.budget_real` (3 MLP runs). DFG's out-of-fold fits share 35% of the budget and its
final fit(s) at most 50% (DFG's own search sizes scale with that share); every other member is skipped if its projected
cost would exceed 90–95% of the budget (never triggered on dev).

**Large inputs (n·d > 1e7, i.e. MNIST / Fashion-MNIST at n ≥ ~13000).** Float32 encodings; LightGBM with row
subsampling 0.5 and column subsampling 0.25 per tree, and the holdout-trained booster (on n − h points, 90% of n at
n = 60000) is the final one. Reason: an unsubsampled 100-round, 10-class LightGBM fit on 48000 × 784 took 301 CPU s,
which would break the ~10-minute-per-fit limit. These settings are never exercised on the dev datasets (largest n·d is
optdigits, 2.7e5), so they are untested for accuracy.

## 2. Which part handles which structure (from the dev runs)

- **Toy targets with parities** (par2–4, majpar, stair5, mux, sparsepoly, rmaj9, rand*): the stacker puts almost all
  weight on `dfg` / `dfg_forced` once their out-of-fold fits find the characters. Trees, kNN and logistic regression are
  at chance there.
- **Toy ANDs / DNFs / thresholds** (and3, dnf3, maj9, thr10): GBT and DFG share the weight; the combination is better
  than DFG alone (and3 n* 101 → ~41–64, dnf3 220 → ~125–159, thr10 164 → ~112–136 in dev runs).
- **optdigits**: kNN (raw metric, k = 1–9) + ExtraTrees + GBT; logistic regression at n = 100.
- **satimage**: kNN (raw, k = 3–9) + ExtraTrees (+ logistic at n = 100).
- **magic, spambase**: GBT + ExtraTrees (+ kNN std k = 27 on spambase).
- **kr_vs_kp**: GBT + ExtraTrees + DFG.

## 3. Development history (dev data only)

1. First portfolio (5-fold everywhere, DFG.fit as is inside every fold): real dev seed 0 already better than the
   better MLP in 9 of 10 cells at n = 100 / 1000, budget use < 7%. Toy: better than DFG v1 on maj9, thr10, dnf3, and3,
   stair5; worse on par3 / par4 / mux at n = 32–64, and DFG's internal small-n CV inside every fold made fits slow.
2. DFG's two variants (default and forced) became two members fitted once per fold (the stacker makes the choice DFG's
   own CV made); 10 folds at n ≤ 500. mux n* 101 → 77. The par3 / par4 cost remains: at n = 32 the out-of-fold DFG fits
   see < 32 points, where DFG v1.1 skips its degree-3 search by design, so they cannot see the parity that the final fit
   finds.
3. Stacker L2 1e-3 / 1e-2 / 3e-2: no material difference (mean log2 at n ≤ 300: −0.214 / −0.220 / −0.210); 1e-2 kept.
   Fewer kNN members (k ∈ {1, 5, 15}) and 300 ExtraTrees: worse on optdigits@100, not kept.
4. MNIST-shape timing (synthetic): the full-data LightGBM was the bottleneck (above); subsampling + no refit on large
   inputs only.

## 4. Full dev evaluation (frozen code, run once)

Run 26 October 2026, 08:36–09:05 UTC (about 30 min wall). Commands: `eval_real.py hyb_portfolio.learner:Learner
optdigits,magic,kr_vs_kp,satimage,spambase` as given. The toy run `eval_toy.py ... designed` was split into three
target shards run in parallel (same frozen file, md5-checked before and after; learner name suffixed `-s1/-s2/-s3`,
so `results/toy__hyb_portfolio-s{1,2,3}__designed.*`), then merged in suite order with the harness's own `report`
into `results/toy__hyb_portfolio__designed.{json,md}`. Real results: `standard_tasks/results/hyb_portfolio__<ds>.json`.

### Toy, designed suite (d = 30, 3 seeds, n = 16 ... 16384)


| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 16 | 47 | -1.55 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 1.9e-01 |
| and3 | 35 | 94 | -1.41 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 1.9e-01 |
| maj3 | 29 | 112 | -1.96 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 1.9e-01 |
| maj9 | 89 | 263 | -1.57 | 0.15 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 6.0e-01 |
| thr10 | 122 | 563 | -2.21 | 0.16 / 0.05 / 0.01 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 4.8e-01 |
| par2 | 16 | 200 | -3.64 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.00 / 0.00 / 0.00 | 1.9e-01 |
| par3 | 52 | 843 | -4.02 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.48 / 0.00 / 0.00 | 1.9e-01 |
| par4 | 55 | 2728 | -5.63 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.9e-01 |
| stair5 | 106 | 1514 | -3.83 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.9e-01 |
| majpar | 60 | 1380 | -4.53 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.12 / 0.00 | 1.9e-01 |
| parmaj | 213 | 743 | -1.80 | 0.46 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.34 / 0.02 / 0.00 | 1.9e-01 |
| mux | 70 | 1156 | -4.04 | 0.11 / 0.01 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 1.9e-01 |
| dnf3 | 150 | 505 | -1.75 | 0.26 / 0.01 / 0.00 / 0.00 ; 0.30 / 0.17 / 0.02 / 0.00 | 2.0e-01 |
| dlist5 | 23 | 110 | -2.26 | 0.04 / 0.00 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.0e-01 |
| rmaj9 | 164 | 2027 | -3.63 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 2.5e-01 |
| andxor | 34 | 376 | -3.48 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.19 / 0.00 / 0.00 | 1.9e-01 |
| sparsepoly | 86 | 2205 | -4.68 | 0.13 / 0.01 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 1.9e-01 |
| rand0 | 16 | 222 | -3.80 | 0.04 / 0.02 / 0.00 / 0.00 ; 0.43 / 0.05 / 0.00 / 0.00 | 2.0e-01 |
| rand1 | 91 | 463 | -2.34 | 0.21 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.18 / 0.00 / 0.00 | 1.9e-01 |
| rand2 | 22 | 91 | -2.04 | 0.06 / 0.02 / 0.00 / 0.00 ; 0.13 / 0.06 / 0.03 / 0.00 | 2.0e-01 |
| rand3 | 195 | 1016 | -2.38 | 0.38 / 0.07 / 0.00 / 0.00 ; 0.44 / 0.32 / 0.10 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 231 (maj3@16: 0.38 vs 0.33; maj9@16: 0.37 vs 0.35; thr10@16: 0.45 vs 0.39; mux@16: 0.49 vs 0.46; rmaj9@32: 0.35 vs 0.32; rand1@16: 0.42 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.98 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 21; clearly worse: 0; of 21. Largest compute used: 6.0e-01 of a GD run.

For comparison, DFG v1 alone (`discrete_learner/results/dfg-c1.0__designed.md`) has mean log2 −2.80, 20 clearly better.
The portfolio gains on targets with AND / threshold structure, where GBT adds to DFG (and3 101 → 35, dnf3 220 → 150,
thr10 164 → 122, maj3 57 → 29, dlist5 61 → 23), and loses on the pure parities at n = 16–32 (par3 16 → 52,
par4 21 → 55; see weaknesses). The 0.60 maximum (maj9) and 0.48 (thr10) are fits where DFG keeps growing for several
rounds; every other target stays below 0.25.

### Real, DEV datasets (3 seeds; seed-mean test error)

| dataset | n | hyb_portfolio | mlp | mlp_l2 | hgb | log2(ours / min(mlp, mlp_l2)) | verdict (>10%) | verdict (>10% and >2 s.e.) | max FLOPs / budget |
|---|---|---|---|---|---|---|---|---|---|
| optdigits | 100 | 0.0923 | 0.1310 | 0.1077 | 0.1744 | -0.22 | better | better | 0.112 |
| optdigits | 300 | 0.0465 | 0.0600 | 0.0560 | 0.0883 | -0.27 | better | better | 0.116 |
| optdigits | 1000 | 0.0225 | 0.0306 | 0.0280 | 0.0403 | -0.31 | better | better | 0.069 |
| optdigits | 3000 | 0.0161 | 0.0230 | 0.0180 | 0.0266 | -0.16 | better | tie | 0.099 |
| optdigits | 4215 | 0.0133 | 0.0159 | 0.0138 | 0.0199 | -0.05 | tie | tie | 0.041 |
| magic | 100 | 0.2268 | 0.2071 | 0.2104 | 0.2206 | +0.13 | tie | tie | 0.002 |
| magic | 300 | 0.1821 | 0.1786 | 0.2191 | 0.1867 | +0.03 | tie | tie | 0.002 |
| magic | 1000 | 0.1464 | 0.1553 | 0.1516 | 0.1499 | -0.05 | tie | tie | 0.002 |
| magic | 3000 | 0.1292 | 0.1384 | 0.1398 | 0.1300 | -0.10 | tie | tie | 0.003 |
| magic | 10000 | 0.1201 | 0.1369 | 0.1291 | 0.1216 | -0.10 | tie | tie | 0.002 |
| magic | 14265 | 0.1172 | 0.1288 | 0.1261 | 0.1199 | -0.11 | tie | tie | 0.003 |
| kr_vs_kp | 100 | 0.0676 | 0.0930 | 0.0780 | 0.1076 | -0.21 | better | tie | 0.024 |
| kr_vs_kp | 300 | 0.0313 | 0.0613 | 0.0572 | 0.0426 | -0.87 | better | better | 0.067 |
| kr_vs_kp | 1000 | 0.0100 | 0.0313 | 0.0167 | 0.0121 | -0.74 | better | better | 0.065 |
| kr_vs_kp | 2397 | 0.0021 | 0.0050 | 0.0046 | 0.0013 | -1.14 | better | tie | 0.139 |
| satimage | 100 | 0.1527 | 0.1566 | 0.1705 | 0.1871 | -0.04 | tie | tie | 0.043 |
| satimage | 300 | 0.1237 | 0.1413 | 0.1359 | 0.1411 | -0.14 | tie | tie | 0.045 |
| satimage | 1000 | 0.0978 | 0.1146 | 0.1063 | 0.1025 | -0.12 | tie | tie | 0.028 |
| satimage | 3000 | 0.0744 | 0.0880 | 0.0847 | 0.0777 | -0.19 | better | tie | 0.043 |
| satimage | 4826 | 0.0690 | 0.0874 | 0.0787 | 0.0677 | -0.19 | better | better | 0.019 |
| spambase | 100 | 0.1191 | 0.1467 | 0.1507 | 0.1313 | -0.30 | better | better | 0.011 |
| spambase | 300 | 0.0791 | 0.0986 | 0.1020 | 0.0901 | -0.32 | better | better | 0.011 |
| spambase | 1000 | 0.0629 | 0.0788 | 0.0730 | 0.0699 | -0.22 | better | better | 0.007 |
| spambase | 3000 | 0.0423 | 0.0571 | 0.0516 | 0.0458 | -0.29 | better | better | 0.015 |

cells 24; mean log2 -0.248; better/worse (>10%): 14/0; with >2 s.e.: 10/0; max FLOPs/budget 0.139

The reference per cell is the better of the baseline MLP and the L2-regularised MLP (protocol rule). Max FLOPs / budget
is the largest over the 3 seeds; per-fit CPU time is at most 10.9 s on dev.

### MNIST-shape scaling check (synthetic, timing and memory only)

60000 × 784 continuous inputs in [0, 1] (pixel-like: per-column density falls off from the centre, so both kNN metrics
are used), 10 classes, labels argmax(XW + noise), plus 10000 test points; `common.budget_real` = 6.21e12.
- Fit: 257 CPU s (650 s wall, because 5 jobs shared 2 cores at the time); peak RSS 2.14 GB; FLOPs 1.38e12 = 0.22 of
  the budget. Per member, CPU s: kNN std 37, kNN raw 25 (6000 leave-one-out queries each), LightGBM 93 (holdout
  booster, reused as final), ExtraTrees 79, logistic 10 + 20 (holdout + refit), stacker 0.3.
- Prediction of 10000 test points: 224 s wall, dominated by kNN against all 60000 training points.
- Before the large-input settings, a single full-data LightGBM fit on 48000 × 784 took 301 CPU s.

## 5. Weaknesses (honest)

- **Tiny-n parities.** The out-of-fold DFG fits at n = 32 see < 32 points, where DFG v1.1 skips its degree-3 search by
  design. So the stacker cannot see the parity that the final fit finds. par3 / par4 n* are 52 / 55 against 16 / 21
  for DFG v1 and 28 / 52 for v1.1 alone (permuted inputs). On the toy suite, 6 of 231 cells are worse than the networks
  by > 0.02, all at n = 16–32, none by more than 2 s.e.
- **Stacking noise at n = 100.** magic n = 100 is +0.13 (0.227 against 0.207, just inside the 10 % tie band) and
  n = 300 +0.03. ExtraTrees alone gets 0.202 there, so the stacker's choice among about 14 members on 100 points costs
  accuracy. A stronger L2 penalty on the stacker did not fix it.
- **Prediction cost is not counted** (as for the networks, per the protocol), and kNN makes it large: 2·n·d FLOPs per
  query per metric. At MNIST size that is about 1.9e12 FLOPs for the 10000 test points, roughly a third of the fit
  budget, and about 100–220 s of wall time.
- **Large-input settings are untested for accuracy.** The settings above (booster subsampling, no booster refit,
  float32) apply only when n·d > 1e7, and no dev dataset reaches that. On MNIST / Fashion-MNIST at n ≥ ~13000 they are
  blind. Fit time there is about 4–5 CPU min, inside the 10-minute limit but not by a wide margin under contention.
- **Library FLOPs are analytic estimates.** For LightGBM and ExtraTrees the counts are analytic (section 1), not
  measured, and FLOP rates differ a lot between members: LightGBM runs at about 0.5–0.7 GFLOP/s by this count, BLAS kNN at
  about 15–23.
- **Where the gain comes from.** On the real tasks it is classical: kNN on the raw metric and ExtraTrees (optdigits,
  satimage), boosted trees (magic, spambase, kr_vs_kp), all combined by stacking. Default `hgb` alone loses to the MLPs
  on optdigits and at small n. On the toy suite the gain is almost entirely DFG's. The design is an AutoML-style
  ensemble; it does not unify the structure classes.
- **Dev in-sample.** The design choices (members, 10 folds at n ≤ 500, the stacker penalty, the kNN k grid) were made
  looking at dev results, so these numbers are in-sample. The large-n regime (holdout stacking, n > 3000) was exercised
  on dev only by magic (n = 10000, 14265), optdigits (4215), satimage (4826) and the toy suite (n ≥ 4096).
- **Code nits.** The module docstring says "5-fold cross-validation for n ≤ 3000"; the code uses 10 folds at n ≤ 500.
  It also does not mention the large-input settings, which are documented in the code comments and here. These were
  left unchanged after the freeze.

