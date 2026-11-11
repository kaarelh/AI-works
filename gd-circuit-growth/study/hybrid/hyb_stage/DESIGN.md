# hyb_stage: a stagewise discrete learner (DFG search + nearest-neighbour votes, then boosted trees on the margins)

Learner `hyb_stage`, `learner.py` (class `Learner`; the default constructor is the frozen version,
sha256 `d4840417178e99d977cbabe115107aa517e233bdb46082209feb14858ec905df`). Dependencies: numpy, scipy (L-BFGS for the
multi-class readout), lightgbm (stage 2). Design angle "stagewise". Developed on the toy `designed` suite and the five
standard DEV datasets only.

**What is discrete.** Every feature is a discrete object chosen by search, tests or a finite grid:
- Fourier characters (products of ±1 bits) admitted by union-bound tests;
- linear and spectral blocks admitted by χ² / permutation-null tests;
- nearest-neighbour votes, where the prototypes are training points and k comes from a finite grid;
- axis-aligned regression trees (LightGBM).

Continuous parameters are only the readout weights. They are fitted by convex losses (penalised logistic / softmax
regression) and by the trees' leaf values (Newton steps of the boosting loss). There is no gradient descent on any
feature parameter, no network and no continuous kernel.

## 1. Algorithm

**Encodings** (fitted on the training rows).
- `z`, the linear encoding: continuous → standardized (clipped at ±6); binary → ±1; categorical → one-hot 0/1.
- `bits`, the search encoding: binary → 1 bit; categorical → one ±1 bit per value with ≥ 3 points on each side;
  continuous → thermometer bits [x > t] at the training quantiles q/(nb+1), with nb = clip(round(240 / #continuous), 1, 8).
- The bits of one input form a *group*. Characters only multiply bits from different groups.
- On the toy suite both encodings are the ±1 inputs themselves.

**Stage 1a: DFG search** (`_grow`, a multi-class port of `study/discrete_learner/dfg.py`).
- *Residual.* R = Y − LS fit on the current features (ridge 1e-3·n). Y is ±1 for C = 2, centred one-hot otherwise.
  Each residual column is normalised by its rms.
- *Statistic.* A candidate character φ has T(φ) = m Σ_q mean_m(R_q φ)².
- *Acceptance.*
  - C = 2: φ is accepted if T > c²·2L, with L = ln(4KN/δ). This is exactly DFG's test |mean(rφ)| > c s √(2L/n).
  - C > 2: the Laurent–Massart χ² tail with C degrees of freedom, T > c²(C + 2√(CL) + 2L).
  - c = 1, δ = 0.1, K = 4 (DFG's constants). N is the size of the candidate class (a union bound per class).
- *Candidate classes.*
  - Global characters:
    - degree 1 and 2 every round;
    - degree 3 every round;
    - degree 4 in the first round;
    - degrees 5–6 in the first round, only when there are ≤ 40 bits.

    Each class above degree 1 is searched on the first m points, with m set by a FLOP share of the search allowance:
    3% (degree 2), 3% (degree 3), 12% (degree 4), 3% (extensions), 3% (degrees 5–6). A class with m < 32 is skipped.
    On wide data (hundreds of bits) this switches off degrees ≥ 3 automatically.
  - Extensions S∪{j} and S∪{j,l} of the 32 strongest current characters (composition).
  - Local Walsh transform: every subset of the ≤ 12 bits in use (junta completion).
- *Block moves.*
  - Linear: the whole z block, when its χ² statistic passes.
  - Spectral: (u·z)² for the top eigen-directions of mean(R_q z zᵀ). The edge is Wigner's for ±1 inputs, and the max
    of Wigner's and 1.1 × a permutation-null top eigenvalue for correlated inputs.
- At most one character per input signature per round, at most 64 per round, p ≤ min(256, n/2).
- *Stopping.* Stop when nothing passes, when every training label's sign (argmax) is already right, or when 75% of
  the search allowance (min(share of budget, 4e10 FLOPs)) is spent.
- *Forced variant* (n ≤ 128, as in DFG): if nothing passes, take the best global character anyway, at most twice. It
  is used only if it wins a paired McNemar test on the validation errors.

**Stage 1b: nearest-neighbour votes** (`_nn_prep`, `_votes`).
- *Prototypes.* The first P training points, with P = min(n, 4096, 0.3·budget / (2 n d)).
- *Metric.* One of two, chosen by leave-one-out 3-NN error on the first ≤ 1000 training points:
  - z (standardized);
  - every column at one pooled scale ("raw"). This is what wins on pixel-like data (optdigits).
- *Features.* For k ∈ {1, 3, 9, 27} and each class c: log((#class-c among the k nearest + 0.5) / (k + 0.5 C)).
- Training rows get leave-one-out votes (self excluded). Validation rows get votes from training-fold prototypes only.

**Stage-1 readout.** Penalised logistic regression (C = 2, damped Newton) or softmax regression (C > 2, L-BFGS) on
[tested characters, block features, z background, NN votes].
- Tested characters get the small penalty min(λ, 1e-3).
- Everything else gets λ ∈ {0.1, 0.01, 1e-3, 1e-4}, chosen on validation.
- The NN block on or off is also chosen on validation.

**Stage 2: boosted trees on the margins** (LightGBM, `init_score` = stage-1 margins). This is the "trees only model
what stage 1 left" stage.
- Settings: lr 0.1; leaves clip(n/25, 4, 31); min leaf clip(n/50, 2, 20); L2 1; feature fraction 0.8 (0.3 when d > 100);
  bagging 0.8; up to 600 rounds; early stopping (patience 40, min_delta 2e-4).
- A second family, trees alone (prior margins), is also evaluated.
- The number of trees is the argmin of the validation log-loss curve, summed over folds.

**Selection.**
- *Validation scheme.*
  - n ≤ 1000: stratified F-fold cross-validation, with F = 10 (n ≤ 64), 5 (n ≤ 200) or 3.
  - Larger n: one stratified 20% hold-out.
- *Choices.* Each search variant, NN on/off and λ, then the stage set {stage 1 alone, stage 1 + trees, trees alone}, by
  validation error + 0.1 × log-loss.
- *Final fit on all n.* Cross-validation mode reruns the search on all n. Hold-out mode reuses the 80% search. Then:
  - the readout is refitted with the chosen λ;
  - the trees are refitted with T·F/(F−1) rounds (cross-validation) or 1.1 T rounds (hold-out).

**Large problems** (n·d_z·C > 5e7: no DEV dataset, but MNIST / Fashion-MNIST at large n):
- λ ∈ {1e-3, 1e-4} only;
- 100 L-BFGS iterations;
- the NN block always on;
- trees at lr 0.2, bagging 0.5, feature fraction 0.2, ≤ 200 rounds;
- no trees-alone family.

These were set for time and memory, from the synthetic MNIST-shape check (§4). They are untested on real image data.

**Compute (FLOPs, multiply-add = 2).**
- Counted:
  - every search matrix product, LS solve and eigendecomposition;
  - the LOO kNN distance products (2·n·P·d) and the metric-choice products;
  - every logistic/softmax evaluation (4npC + 12nC per L-BFGS evaluation; 2np² + p³/3 + 8np per Newton step);
  - trees by the analytic estimate below.
- Tree estimate, per tree: 2 × rows × bagging × features × feature-fraction × ⌈log2 leaves⌉ (histogram building,
  gradient + hessian) + 4 × max_bin × features × leaves (split search). Times C trees per round for multi-class,
  plus 2 × n_val × trees × log2(leaves) for validation scoring.
- Not counted: sorting / argpartition of distances (comparisons) and prediction (as for every learner in the study).

## 2. Which part handles which structure

| structure | handled by | evidence (dev) |
|---|---|---|
| parities / sparse Fourier characters (par2–4, majpar, andxor, sparsepoly, rand*) | stage 1a exhaustive search with union-bound tests; trees cannot see these (no marginal signal) | tree-alone CV error ≈ 0.5 on par3 at n ≤ 1024 while stage 1 is exact; stage 1 chosen |
| staircases, multiplexers, decision lists (stair5, mux, dlist5) | stage 1a extensions + local Walsh; stage 2 trees at small n | |
| halfspaces / majorities (maj9, thr10, rmaj9) | linear block + logistic readout; trees on the margins add a little at n ≤ 256 | |
| DNFs, small juntas (dnf3, and3) | trees (stage 2 alone often chosen at n ≤ 256) or local Walsh | dnf3 n = 256: trees-alone CV 0.01 vs stage 1 0.06–0.2 |
| image-like / prototype structure (optdigits, satimage) | stage 1b nearest-neighbour votes (pooled-scale metric on optdigits) | optdigits n = 100: 0.12 → 0.09–0.10 with the NN block |
| axis-aligned interactions, thresholds on continuous features (magic, spambase, kr_vs_kp) | stage 2 trees on the stage-1 margins, or trees alone | |
| small-n tabular | the penalised linear background (λ by CV), NN votes, and CV selection of the stage set | |

## 3. Dev results (full protocol, after freezing; one run each, learner unchanged afterwards)

**Toy `designed` suite** (d = 30, n = 16…16384, 3 seeds; `results/toy__hyb_stage__designed.md`). n* is the training
size to reach 10% test error (log-interpolated).

| target | n* hyb_stage | n* networks | log2 ratio | n* DFG v1 (ref.) |
|---|---|---|---|---|
| dict | 16 | 47 | −1.55 | 22 |
| and3 | 25 | 94 | −1.89 | 101 |
| maj3 | 45 | 112 | −1.30 | 57 |
| maj9 | 79 | 263 | −1.73 | 107 |
| thr10 | 117 | 563 | −2.27 | 164 |
| par2 | 52 | 200 | −1.95 | 16 |
| par3 | 43 | 843 | −4.29 | 16 |
| par4 | 52 | 2728 | −5.71 | 21 |
| stair5 | 107 | 1514 | −3.82 | 112 |
| majpar | 55 | 1380 | −4.64 | 62 |
| parmaj | 290 | 743 | −1.36 | 221 |
| mux | 62 | 1156 | −4.23 | 65 |
| dnf3 | 120 | 505 | −2.07 | 220 |
| dlist5 | 36 | 110 | −1.60 | 61 |
| rmaj9 | 169 | 2027 | −3.58 | 167 |
| andxor | 50 | 376 | −2.90 | 43 |
| sparsepoly | 92 | 2205 | −4.58 | 73 |
| rand0 | 56 | 222 | −1.99 | 23 |
| rand1 | 100 | 463 | −2.21 | 104 |
| rand2 | 16 | 91 | −2.50 | 28 |
| rand3 | 187 | 1016 | −2.44 | 189 |

Overall:
- Mean log2 n* ratio: −2.79 over 21 of 21 targets. Both learn every target, so there are no "never" cases.
- Clearly better on 21 of 21 (DFG v1: −2.80, 20 of 21).
- Cells more than 0.02 worse than the networks: 5 of 231, all at n ≤ 128, none beyond 2 s.e.
- Max FLOPs 0.59 of a GD run (maj9 at n = 16384), with typical fits at 0.07–0.09.
- Total CPU 1028 s.

Against DFG v1, per target:
- *Better* on the halfspaces, DNFs and decision lists: and3, maj9, thr10, dnf3, dlist5. Here the trees on the margins
  and the CV-tuned logistic readout help at small n.
- *Worse* on the pure parities at tiny n: par2–4 n* ≈ 45–50 against 16–21. The forced variant is now tried only for
  n ≤ 128, and it competes with more configurations (NN block, λ grid) under the same small validation sets. Also worse
  on parmaj (290 vs 221).

**Standard DEV datasets** (full grids, 3 seeds; `study/standard_tasks/results/hyb_stage__<ds>.json`). Errors are seed
means. Better / worse means > 10% relative to min(mlp, mlp_l2), with errors floored at 0.002.

| dataset | n | hyb_stage | mlp | mlp_l2 | hgb | log2(err / min MLP) | max FLOPs / budget |
|---|---|---|---|---|---|---|---|
| optdigits | 100 | 0.0994 | 0.1310 | 0.1077 | 0.1744 | −0.12 | 0.072 |
| optdigits | 300 | 0.0520 | 0.0600 | 0.0560 | 0.0883 | −0.11 | 0.061 |
| optdigits | 1000 | 0.0266 | 0.0306 | 0.0280 | 0.0403 | −0.08 | 0.360 |
| optdigits | 3000 | 0.0157 | 0.0230 | 0.0180 | 0.0266 | −0.20 (better) | 0.187 |
| optdigits | 4215 | 0.0147 | 0.0159 | 0.0138 | 0.0199 | +0.10 | 0.260 |
| magic | 100 | 0.2128 | 0.2071 | 0.2104 | 0.2206 | +0.04 | 0.008 |
| magic | 300 | 0.1778 | 0.1786 | 0.2191 | 0.1867 | −0.01 | 0.039 |
| magic | 1000 | 0.1468 | 0.1553 | 0.1516 | 0.1499 | −0.05 | 0.053 |
| magic | 3000 | 0.1402 | 0.1384 | 0.1398 | 0.1300 | +0.02 | 0.038 |
| magic | 10000 | 0.1237 | 0.1369 | 0.1291 | 0.1216 | −0.06 | 0.041 |
| magic | 14265 | 0.1185 | 0.1288 | 0.1261 | 0.1199 | −0.09 | 0.041 |
| kr_vs_kp | 100 | 0.0642 | 0.0930 | 0.0780 | 0.1076 | −0.28 (better) | 0.014 |
| kr_vs_kp | 300 | 0.0342 | 0.0613 | 0.0572 | 0.0426 | −0.74 (better) | 0.021 |
| kr_vs_kp | 1000 | 0.0129 | 0.0313 | 0.0167 | 0.0121 | −0.37 (better) | 0.063 |
| kr_vs_kp | 2397 | 0.0033 | 0.0050 | 0.0046 | 0.0013 | −0.46 (better) | 0.071 |
| satimage | 100 | 0.1705 | 0.1566 | 0.1705 | 0.1871 | +0.12 | 0.012 |
| satimage | 300 | 0.1351 | 0.1413 | 0.1359 | 0.1411 | −0.01 | 0.027 |
| satimage | 1000 | 0.1057 | 0.1146 | 0.1063 | 0.1025 | −0.01 | 0.071 |
| satimage | 3000 | 0.0856 | 0.0880 | 0.0847 | 0.0777 | +0.01 | 0.142 |
| satimage | 4826 | 0.0727 | 0.0874 | 0.0787 | 0.0677 | −0.11 | 0.203 |
| spambase | 100 | 0.1214 | 0.1467 | 0.1507 | 0.1313 | −0.27 (better) | 0.029 |
| spambase | 300 | 0.0875 | 0.0986 | 0.1020 | 0.0901 | −0.17 (better) | 0.044 |
| spambase | 1000 | 0.0713 | 0.0788 | 0.0730 | 0.0699 | −0.03 | 0.075 |
| spambase | 3000 | 0.0499 | 0.0571 | 0.0516 | 0.0458 | −0.05 | 0.063 |

Overall:
- Mean over the 24 cells of log2(err / min(mlp, mlp_l2)): −0.122.
- 7 cells better, 0 worse, 17 ties (within ±10%).
- Largest losses (ties): satimage n = 100 (+0.12, against the baseline MLP) and optdigits at full n (+0.10, against
  mlp_l2).
- Max FLOPs 0.36 of the budget (3 MLP runs).
- Total CPU 644 s; the slowest fit is 29 s.

Dev history (all on these dev data; the counts are approximate):
1. *v0*: search + softmax + trees. Quick-dev mean −0.08. optdigits +0.2 to +0.44 behind.
2. *Added the NN-vote block* (kNN on pooled-scale pixels matched mlp_l2 on optdigits by itself).
3. *Fixed a readout bug.* The linear block moved all z columns into the low-penalty "grown" set, so the background
   penalty had no effect at small n.
4. *Speed changes:* vectorised anchor masks, Newton for C = 2, 3-fold CV above n = 200, ≤ 600 tree rounds, and
   ≤ 4096 prototypes.
5. *Large-problem regime*, from a synthetic timing check.

## 4. MNIST-shape scaling check (synthetic arrays, timing and memory only)

Synthetic data: n = 60000 (+2000 test), d = 784, C = 10, sparse uniform pixels (60% zeros). Measured under a machine
load of about 5–6 on 4 cores (other jobs), single-threaded BLAS / LightGBM. Budget = 3 MLP runs = 6.21e12 FLOPs.

| version / target | wall | CPU | peak RSS | FLOPs (fraction of budget) | stages chosen |
|---|---|---|---|---|---|
| frozen (sha d4840417…), labels from 40 random axis-aligned AND-pairs + a weak linear part | 535 s | 382 s | 3.08 GB | 1.09e12 (0.18) | stage 1 + 45 tree rounds |
| pre-freeze (before the large-regime edit), labels from a random 2-layer ReLU function | 549 s | 360 s | 3.25 GB | 1.44e12 (0.23) | stage 1 only |

Where the time goes:
- the LOO kNN distances (60000 × 4096 prototypes);
- one search round with the 784-column linear block (an LS refit at p ≈ 850);
- 2 softmax fits on 48000 × ~890 × 10 (100 L-BFGS iterations each) plus the final refit;
- the trees.

At the cap of 200 tree rounds (instead of 45), the trees would add roughly another 1–2 minutes. So a real MNIST fit
should take about 7–9 min of CPU, but the wall time on a loaded machine can exceed 10 minutes. Memory is dominated by
the dense float64 bit / z / design matrices (~0.3 GB each at 48000 × 784).

## 5. Weaknesses (honest)

**Toy suite.**
- *Parities at tiny n.* par2–4 n* ≈ 45–50, against DFG v1's 16–21. That is still 2–5.7 doublings better than the
  networks. Cause: more configurations compete on small CV folds, and the forced variant is tried only at n ≤ 128.
  parmaj is also behind DFG v1 (290 vs 221), and slightly behind the networks at n = 128 (0.48 vs 0.44, not
  significant).
- *Compute on the toy suite.* Up to 0.59 of a GD run: halfspace targets at n = 16384 run many search rounds with
  ~250 features and LS refits. That is within budget but about 4× DFG v1's maximum.

**Real data.**
- *Ties, not wins, on most real cells.* 17 of 24 dev cells are within ±10% of the better MLP. The wins are kr_vs_kp
  (all n), spambase at n ≤ 300 and optdigits at n = 3000. On magic and satimage it is essentially on par.
- *Trees are under-used at large n.* Default `hgb` beats hyb_stage at full n on magic, satimage, spambase and
  kr_vs_kp (e.g. satimage 0.068 vs 0.073, kr_vs_kp 0.0013 vs 0.0033). Likely causes:
  - the 20% hold-out costs the trees 20% of the data during selection;
  - the trees start from *in-sample* stage-1 margins, so on the training rows they see a residual that is smaller than
    the true one;
  - stage 1 is chosen first, and the trees are fitted on top.

  Cross-fitted (out-of-fold) margins would be the principled fix. They were not done for time.
- *Selection leaks* (minor):
  - the NN metric (z vs pooled scale) is chosen by LOO 3-NN error on up to 1000 training rows, including the
    validation rows;
  - the z encoding used for NN distances is standardized on all training rows (unsupervised);
  - the number of trees is the argmin of the summed validation curve, a slightly optimistic choice;
  - in CV mode the final search is rerun on all n, so the readout's features differ from the ones validated.

**Images / scale.**
- *Untested on real images at scale.* The large-problem regime (n·d·C > 5e7) was set only from synthetic timing.
- *Fewer prototypes than kNN wants.* Only ≤ 4096 prototypes are used, so on MNIST the NN block is far weaker than
  full-data kNN. There, stage 1 is mainly the linear background, plus whatever trees add in ≤ 200 rounds.
- *Expect a clear loss to the MLP on MNIST / Fashion-MNIST at n ≥ 10000.* hyb_stage has no learned convolution-like
  features, and trees on pixels plateau around 2–3% (MNIST).
- *Close to the limits.* Memory peaks at 3.25 GB at MNIST shape (dense float64 matrices), close to the 4 GB limit.
  Time is ≈ 6 min CPU without trees, more with them; on a loaded machine wall time can exceed 10 min.

**FLOP accounting.**
- LightGBM is charged by an analytic estimate (histogram passes and split search), not measured.
- Sorting / argpartition of distances is not counted.
- Prediction (including test-time kNN) is not counted, as for every learner in the study.
