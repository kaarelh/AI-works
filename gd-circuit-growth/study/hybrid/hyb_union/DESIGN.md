# hyb_union: unified boosting over discrete weak-learner families

Part 8 builder "unified boosting". Code: `learner.py`, class `Learner`; the default constructor is the frozen version
(name `hyb_union`, md5 of the frozen file `d780099c98f6551a374775a3ee7de6dd`). Development used only the toy
`designed` suite and the 5 standard DEV datasets. The module docstring of `learner.py` was written for an early draft
(Laurent-Massart thresholds, no ExtraTrees or stacking) and was not edited after the freeze, to keep the frozen file
unchanged; this file describes the frozen algorithm.

## Algorithm

Loss: logistic (C = 2, one logit) or softmax (C > 2, one score per class). The model is
F = F0 + (stacked honest blocks) + sum_t eta_t u_t. Every u_t is a discrete feature, or a block of discrete features,
times convex-fitted coefficients.

1. **Encodings** (fitted on the training rows only):
   * linear: the MLP's encoding (standardised continuous, +-1 binary, one-hot categorical);
   * parity bits: +-1 binary columns, one bit per category (<= 16 categories), and a median bit per continuous
     column; on the toy suites the bits are the inputs;
   * tree input: raw values, categorical codes as LightGBM categories;
   * kNN scale: the linear encoding, except that commensurate (image-like) continuous columns share one global scale.
2. **F0 = ridge logistic / softmax regression** on the linear encoding (L-BFGS, convex).
   * lambda in {1e-3, 1e-2, 1e-1, 1}, or intercept only, chosen by 5-fold cross-validated log-loss (an 80/20 holdout
     at n >= 4000, on a subsample of <= 8000 rows when n d K > 2e7).
   * For n < 4000 boosting starts from the **out-of-fold** linear scores (honest stacking). At test time F0 is the LR
     refit on all rows.
   * The lambda floor of 1e-3 matters: with 1e-4 the LR nearly separates kr_vs_kp. Its scores are then overconfident,
     the Hessians collapse, and the trees find nothing.
3. **Honest blocks**, computed once, with features that are out-of-sample for every training row:
   * **kNN votes**, leave-one-out, k in {1, 3, 7, 15, 31}, as smoothed log vote shares. If the distance cost would
     exceed min(20% of the budget, 2.5e11 FLOPs), the kNN keeps the 128 highest-variance columns and a random
     reference subset (MNIST: about 16000 references).
   * **ExtraTrees votes** (sklearn, 100 trees; 30 at very large n x d). Cross-fitted 5-fold (50 trees per fold) for
     n < 2000, out-of-bag above that. OOB votes are pessimistic at small n: each tree sees about 63% of the rows.
   * **lr**: the centred linear scores themselves, so that the stack can re-weight the linear start.
4. **Stacking init.** Per class, a joint ridge-Newton fit (8 iterations, lambda = 1) of the weights of the three honest
   blocks (the best k for kNN). These are a handful of convex stacking weights, with no search and no test. This is
   what makes the method competitive at n = 100-300, where ExtraTrees alone beats the MLPs on magic, satimage and
   spambase. A single significance-gated block step could not pass at n = 100.
5. **Boosting rounds.** In each round, take the gradient g and diagonal Hessian h of the loss at F. Score one proposal
   per family by its Newton statistic S = sum_c G_c^2 / (H_c + lambda). This is 2x the second-order loss decrease of a
   full Newton step, and with no signal it is ~chi^2_q because Var(g) = h. Subtract the family's union-bound threshold
   pen(q, L) = the exact chi^2_q quantile at level exp(-L), with L = ln(N / delta), delta = 0.1 and N the number of
   candidates searched.

   | family | proposal | q, N |
   |---|---|---|
   | **tree** | one LightGBM regression tree per output (31 leaves, histogram splits, max_bin 63, lambda_l2 1) fitted to (g, h) | without validation (n < 1000) every split must pass min_gain_to_split = 2 ln(N_split / delta), N_split = number of candidate thresholds, and the score is S - (#splits) x that - K. With validation the tree grows freely, and only the comparison charges 0.2 x that per split |
   | **parity** | the best Fourier character chi_S on the bits. Round 0: exhaustive degrees 1-4, plus degrees 5-6 on a subsample when there are <= 32 bits (DFG's table product). Later: degree <= 3 re-search every 10 rounds while parities are being picked (at most 5). Every round while parities are in use: degree <= 2, extensions S u {j} of the chosen characters, and the Walsh transform over the inputs of the chosen characters (all subsets, <= 12 inputs: junta completion). Subsample sizes are set by FLOP shares (4% per full search, 3% per high degree). Candidates go into a pool that is rescored on all rows every round | q = K; N = C(d_b, k) x 6 per degree; extension and local classes have their own N |
   | **linear** | ridge Newton step on all encoded inputs (when K (d + 1) <= 300) | q = K (d + 1), N = 1 |
   | **knn / forest / lr** | a further Newton step on one honest block | q = K, N = 5 / 1 / 1 |

   The family with the best S - pen takes the step: shrinkage 0.1 for trees, a full Newton step (eta = 1) for the
   others. Shrinkage on honest blocks made the next test fail after half a step.
6. **Stopping.**
   * n < 1000: stop when no family passes its test (DFG's regime: at small n only significant structure enters).
   * n >= 1000: 10% of the rows are held out. A tree step is taken even when nothing passes. Stop after 40 rounds
     without improvement in validation log-loss and truncate to the best round. The model keeps the 90% fit, as
     HGB's early stopping does.
   * Always: stop when every training and validation label is right, after 600 rounds, at 90% of the FLOP budget, or
     after 480 s.
7. **Prediction:** F0 + stacked blocks + all steps. The kNN reference set is all n training rows (subsampled when
   capped). ExtraTrees votes come from the full-data model.

**What is discrete.** Characters, tree splits, nearest-neighbour sets and ExtraTrees trees, all chosen by search
(exhaustive for characters, greedy for tree splits) or by randomisation. The continuous parts are convex readouts:
the LR, the stacking weights, the Newton coefficient of each step, and tree leaf values (Newton steps on a fixed
partition). There is no gradient descent on feature parameters and no kernel machine.

## Which part handles which structure

* **LR start:** halfspaces, majorities, decision lists and AND on the toy suite; the bulk of small-n tabular signal.
* **Exhaustive character search, with local Walsh and extension moves:** parities, majorities of parities, sparse
  polynomials and MAJ xor MAJ on the toy suite. Trees cannot find these, because the inputs have no marginal signal.
  parmaj is learned at n = 256 only with the exact chi^2 threshold; the Laurent-Massart bound was 60% higher at
  q = 1.
* **Trees** (with characters): staircases, multiplexer, DNF and recursive majority at n >= 1000; tabular interactions
  and thresholds at n >= 1000 (kr_vs_kp 0.0144 / 0.0019 at n = 1000 / 2397, against mlp_l2's 0.0167 / 0.0046, in dev
  smoke runs).
* **ExtraTrees votes:** small-n nonlinear tabular structure (magic, satimage, spambase at n = 100-300).
* **kNN votes:** prototype-like image structure (optdigits).

## FLOP accounting (multiply-add = 2; prediction not counted, as elsewhere in the study)

* **Exact:**
  * LR: function evaluations x (4 n p K + 12 n K);
  * kNN distances: 2 n_q n_ref d + 6 n_q n_ref for selection;
  * all character-search matrix products, Walsh transforms, extensions and pool rescoring;
  * linear Newton steps, the stacking Newton steps, gradients and validation losses.
* **Analytic, for library trees:**
  * LightGBM, per round: 2 n d_used (1 + ceil(log2 leaves)) K for histogram building, plus 10 d max_bin leaves K for
    split search, plus 2 n K log2(leaves) for the output on training rows; plus 10 n d for binning.
  * ExtraTrees: (trees + 4 x fold trees) x 4 n mtry log2(n)^2 to build, plus 2 trees n log2 n per vote pass. This is
    a deliberate over-estimate: ExtraTrees does not sort.

## Dev results (the single full run of the frozen version)

Commands: `eval_toy.py hyb_union.learner:Learner designed`, and `eval_real.py hyb_union.learner:Learner
optdigits,magic,kr_vs_kp,satimage,spambase`. For wall time, the toy run was executed as two processes. Each made
the same `harness.evaluate` call on alternating targets. The results were merged into
`results/toy__hyb_union__designed.{json,md}` with `harness.report`. The learner is deterministic given the fit rng,
so `eval_toy.py` gives the same result. The real-data results are `study/standard_tasks/results/hyb_union__<ds>.json`.

**Process note.** A first launch of the full run at 06:58 was killed after about 30 s, once it was clear that
development time remained. It had printed only 3 optdigits seed-0 lines, values already seen in smoke runs, and wrote
no files. Development then continued, and the version frozen at 07:29 is the only one run in full.

### Toy, designed suite (d = 30, 3 seeds, n = 16 ... 16384): n* (10% test error)

| target | hyb_union | networks | log2 ratio |
|---|---|---|---|
| dict | 27 | 47 | -0.80 |
| and3 | 47 | 94 | -1.00 |
| maj3 | 51 | 112 | -1.13 |
| maj9 | 82 | 263 | -1.67 |
| thr10 | 122 | 563 | -2.21 |
| par2 | 28 | 200 | -2.84 |
| par3 | 29 | 843 | -4.88 |
| par4 | 42 | 2728 | -6.01 |
| stair5 | 110 | 1514 | -3.78 |
| majpar | 99 | 1380 | -3.81 |
| parmaj | 310 | 743 | -1.26 |
| mux | 114 | 1156 | -3.35 |
| dnf3 | 252 | 505 | -1.00 |
| dlist5 | 58 | 110 | -0.93 |
| rmaj9 | 175 | 2027 | -3.53 |
| andxor | 59 | 376 | -2.67 |
| sparsepoly | 145 | 2205 | -3.93 |
| rand0 | 29 | 222 | -2.94 |
| rand1 | 109 | 463 | -2.09 |
| rand2 | 34 | 91 | -1.42 |
| rand3 | 319 | 1016 | -1.67 |

* **n\*:** smaller than the networks' on 21 of 21 targets (all ratios < -0.25; none "never" on either side). The
  mean log2 ratio is **-2.52**, a factor of about 5.7. DFG v1 had -2.80 with 20 of 21 clearly better.
* **Per cell:** worse than the networks by more than 0.02 in 16 of 231 (target, n) cells, all at n = 16-64 near
  chance. 3 of these are beyond 2 s.e.: par2@16, mux@16 and sparsepoly@16.
* **Compute:** at most 0.24 of one network run per fit (FLOPs), and at most 13 s CPU per fit.

### Standard dev datasets (3 seeds; test error), against the better of mlp and mlp_l2 per cell

| dataset | n | hyb_union | mlp | mlp_l2 | log2(ours / min) | hgb (ref.) |
|---|---|---|---|---|---|---|
| optdigits | 100 | 0.1053 | 0.1310 | 0.1077 | -0.03 | 0.1744 |
| optdigits | 300 | 0.0472 | 0.0600 | 0.0560 | -0.25 | 0.0883 |
| optdigits | 1000 | 0.0244 | 0.0306 | 0.0280 | -0.20 | 0.0403 |
| optdigits | 3000 | 0.0164 | 0.0230 | 0.0180 | -0.14 | 0.0266 |
| optdigits | 4215 | 0.0145 | 0.0159 | 0.0138 | +0.07 | 0.0199 |
| magic | 100 | 0.2095 | 0.2071 | 0.2104 | +0.02 | 0.2206 |
| magic | 300 | 0.1896 | 0.1786 | 0.2191 | +0.09 | 0.1867 |
| magic | 1000 | 0.1531 | 0.1553 | 0.1516 | +0.01 | 0.1499 |
| magic | 3000 | 0.1313 | 0.1384 | 0.1398 | -0.08 | 0.1300 |
| magic | 10000 | 0.1180 | 0.1369 | 0.1291 | -0.13 | 0.1216 |
| magic | 14265 | 0.1143 | 0.1288 | 0.1261 | -0.14 | 0.1199 |
| kr_vs_kp | 100 | 0.0718 | 0.0930 | 0.0780 | -0.12 | 0.1076 |
| kr_vs_kp | 300 | 0.0421 | 0.0613 | 0.0572 | -0.44 | 0.0426 |
| kr_vs_kp | 1000 | 0.0146 | 0.0313 | 0.0167 | -0.19 | 0.0121 |
| kr_vs_kp | 2397 | 0.0042 | 0.0050 | 0.0046 | -0.14 | 0.0013 |
| satimage | 100 | 0.1552 | 0.1566 | 0.1705 | -0.01 | 0.1871 |
| satimage | 300 | 0.1191 | 0.1413 | 0.1359 | -0.19 | 0.1411 |
| satimage | 1000 | 0.0974 | 0.1146 | 0.1063 | -0.13 | 0.1025 |
| satimage | 3000 | 0.0816 | 0.0880 | 0.0847 | -0.05 | 0.0777 |
| satimage | 4826 | 0.0694 | 0.0874 | 0.0787 | -0.18 | 0.0677 |
| spambase | 100 | 0.1180 | 0.1467 | 0.1507 | -0.31 | 0.1313 |
| spambase | 300 | 0.0861 | 0.0986 | 0.1020 | -0.20 | 0.0901 |
| spambase | 1000 | 0.0658 | 0.0788 | 0.0730 | -0.15 | 0.0699 |
| spambase | 3000 | 0.0461 | 0.0571 | 0.0516 | -0.16 | 0.0458 |

* **Overall:** mean over the 24 cells of log2(err / min(err mlp, err mlp_l2)), with errors floored at 0.002:
  **-0.127**, about 8% lower error.
* **Better / worse:** better by more than 10% relative in 9 cells, worse by more than 10% in 0. With the protocol's
  additional > 2 s.e. condition: 5 better and 0 worse.
* **Compute:** at most 0.088 of the budget (3 MLP runs) per fit, and at most 14 s CPU per fit.
* **Against default HGB** (reference only): ours is lower on most cells, and higher on kr_vs_kp at n >= 1000, magic
  at 1000, and satimage at n >= 3000.

### MNIST-shape scaling check (synthetic uniform arrays, n = 60000, d = 784, C = 10; timing and memory only)

* **Time and memory:** fit 487 s wall, with the two toy processes running on the same 2 cores; predicting 10000
  points took 5 s. Peak RSS 3.04 GB.
* **FLOPs:** 1.09e12, which is 0.18 of the budget (3 x 2.07e12).
* **Stage times:** LR 31 s (lambda on an 8000-row subsample), kNN 43 s (16276 references, 128 columns),
  ExtraTrees 28 s (30 trees).
* **Boosting:** 51 rounds before the 480 s limit.

## Weaknesses (honest)

* **Large n x d is time-limited, not FLOP-limited.** At the MNIST shape only about 50-80 boosting rounds fit in the
  480 s limit, using 0.18 of the FLOP budget. The trees (eta = 0.1) are therefore under-trained there, and on
  MNIST / Fashion-MNIST at n >= 30000 the method will lean on LR + capped kNN + 30 ExtraTrees. Default HGB (100 full
  iterations) gets 2.2% on MNIST. hyb_union at that scale is untested on real images and may trail the MLPs. The cap
  is wall-clock and depends on machine load.
* **On real data the "union" is mostly a stack of standard discrete learners.** The gain over the MLPs comes from
  ExtraTrees votes and the stacking weights (n <= 300), LightGBM trees without a split threshold (n >= 1000), and kNN
  votes (optdigits). The parity family is rarely picked on real data. The penalised-Newton comparison between
  families matters mainly on the toy suite, where the character search does the work. On real data a simpler
  "LR + ExtraTrees + kNN stack, then gradient boosting" would probably do about as well; this was not ablated.
* **Two different regimes, switched at n = 1000** (no validation with strict tests, versus a validation split with
  free trees). The 10% validation rows are not refit, so the final model loses them.
* **Smallest n on the toy suite:** at n = 16-32 it is a little worse than the networks in some cells (3 cells beyond
  2 s.e.). There is no equivalent of DFG's forced small-n variant, and 5-fold LR cross-validation at n = 16 is noisy.
* **Everything was tuned in-sample** on the designed suite and the 5 dev datasets: the lambda floor, ExtraTrees with
  cross-fitting, stacking, the exact chi^2 thresholds, threshold-free tree growth, 31 leaves and the all-labels-right
  stop. The dev numbers are therefore optimistic.
* **FLOPs are partly analytic.** LightGBM and ExtraTrees are charged analytic estimates, documented above, not
  measured counts. Prediction is not counted.
* **Not the best discrete learner everywhere.** Default HGB is still lower on kr_vs_kp at n >= 1000 (0.0121 /
  0.0013, against 0.0146 / 0.0042), magic at 1000 and satimage at n >= 3000. Several real cells are within noise of
  the MLPs (magic 100-1000, optdigits full, satimage 100).
