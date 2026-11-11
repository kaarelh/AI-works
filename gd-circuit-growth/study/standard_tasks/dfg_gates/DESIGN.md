# dfg_gates: DFG over a dictionary of threshold / AND gates

Learner `dfg_gates.learner.Learner()` (name `dfg_gates-v1`), frozen as `learner.py`. It adapts DFG
(`../../discrete_learner/dfg.py`, `DISCRETE-LEARNER.md`) to standard classification data: continuous, binary
and categorical columns, and C ≥ 2 classes. numpy and scipy only. It uses no trees, kernels-by-library or
gradient descent on feature parameters.

## 1. The algorithm

**Dictionary.**
- A *literal* is one of:
  - `[x_j > t]`, with t one of Q = 16 training-set quantiles of a continuous or ordinal column;
  - `[x_j = 1]` for a binary column;
  - `[x_j = v]` for each value v of a categorical column;
  - the negation of any of these.

  A literal needs at least 5 training points on each side.
- A *gate* is an AND of 1–3 literals: a 0/1 feature whose column is the product of its literals' columns.

**Growth (rounds).**
1. **Least squares.** Fit the one-hot labels Y (n × C) by least squares (ridge 1e-4·n) on the current features:
   a constant, the linear block if accepted, and the gates.
2. **Residual whitening.** Drop one class column of the residual, since residual rows sum to 0. Then whiten:
   R̃ = R′ Σ^{-1/2}, with Σ = R′ᵀR′/n. Only eigen-directions of Σ above 10⁻³ of the largest are kept; C′ is their
   number.
3. **Test statistic.** For a candidate gate z, with z̃ = z − mean(z):

   T(z) = ‖z̃ᵀR̃‖² / ‖z̃‖² ~ χ²_{C′} under "no signal".

   This is a chi-square statistic summed over classes. For C = 2 it is DFG's (mean(r z)/s)² n / var(z).
4. **Candidate classes**, each with its own union bound over its N candidates:

   | class | candidates | N |
   |---|---|---|
   | singles | every literal | L |
   | pairs | every l_a ∧ l_b, all 4 polarities | 2L² |
   | extensions (composition) | g ∧ l and g ∧ ¬l, for the B ≤ 24 most important current gates g of degree < 3 | 2BL |

   - *Pairs* are computed exactly from the per-class matrices Zᵀ diag(r̃_k) Z on a budgeted subsample: 10% of the
     FLOP budget in round 0, 2% per later round.
   - *Extensions:* importance is ‖readout row‖ · std(column).
5. **Acceptance.** Accept z if T(z) > c² · χ²_{C′}.isf(δ / (4N)), with c = 0.5 and δ = 0.1.
   - The passing candidates (top 96 by T / threshold) are taken greedily, at most 24 per round.
   - Each is re-tested after Gram–Schmidt against the ones already taken this round. Redundant copies, such as
     neighbouring thresholds or a ∧ b ≈ a, therefore fail.
6. **Linear block** (block move, round 0). Add all standardized encoded inputs at once if ‖QᵀR̃‖²_F exceeds the
   Laurent–Massart χ²_{rank·C′} tail at level δ, with Q an orthonormal basis of the inputs.
   - If the encoded width exceeds n/3, the block is the top n/3 principal components (rank cap).
7. **Stopping.** Stop when nothing passes, at p ≥ min(1500, n/2) features, after 40 rounds, or at 75% of the growth
   budget.

**Readout and model selection.**
- **Validation split.** As for the MLP: the features are grown on 90% of the training set. The held-out 10% picks the
  readout:
  - least squares; or
  - L2-regularized softmax regression, with λ ∈ {0.1, 0.01, 0.001, 0.0001}, fitted by 60 FISTA steps on Böhning's
    quadratic bound H ≤ ½(I − 11ᵀ/C) ⊗ AᵀA/n. That costs one Cholesky, then 4npC FLOPs per step.
  - Ties go from least squares to softmax, and then to the stronger ridge.
- **Final readout.** It is refit on all n points.
- **Small n.** At n ≤ 1000 the growth is also redone on all n points. Above that, the gates grown on the 90% are kept.
- **Prediction.** argmax of the readout.

**Compute.**
- Every matrix product, solve, QR, eigendecomposition and Cholesky is counted (multiply-add = 2), including all
  readout fits during selection.
- The growth passes get 80% of `harness.mlp_flops` (n > 1000), or 45% + 40% (n ≤ 1000). Growth stops at 75% of that.
- The readout selection stops at 90% of the total.
- In practice a fit uses at most the fraction of one MLP run reported in §3.

## 2. What maps to what

| DFG (Boolean ±1, binary labels) | dfg_gates (standard data) |
|---|---|
| Fourier characters χ_S | AND gates of ≤ 3 threshold / category literals |
| test \|mean(r χ_S)\| > c s √(2 ln(4KN/δ)/n) on the LS residual | T(z) = ‖z̃ᵀR̃‖²/‖z̃‖² > c² χ²_{C′}-tail at δ/(4N): residual whitened over classes, chi-square summed over classes |
| global degree-1..4 searches, budgeted subsample | singles (all literals) and pairs (all literal pairs × 4 polarities), pairs on a budgeted subsample |
| composition: extensions S ∪ {j}, S ∪ {j, l}; local subsets | extensions g ∧ l, g ∧ ¬l of the top current gates (degree ≤ 3); a product of two accepted gates within degree 3 is an extension of a degree-2 gate by one literal |
| linear block on χ²_d test | linear block on the standardized encoding, χ²_{rank·C′} test, rank capped at n/3 |
| spectral block (u·x)² | implemented (`quad=`), but off in the frozen version (§4) |
| accept everything that passes, refit LS, next round | the same, with Gram–Schmidt inside the round, because gates are not orthogonal |
| readout LS + logistic refinement (v1.1) | LS + softmax refinement (Böhning / FISTA), picked on a 10% validation split |
| FLOP budget as a fraction of one network run | FLOP budget = `harness.mlp_flops` (one MLP training run at that n) |
| no gradient descent on features | none: gates come only from enumeration and tests. The continuous parameters are the readout weights and the linear block's standardization (and the PCA when its rank is capped) |

## 3. Dev results (frozen version, 3 seeds; error = mean test error over seeds)

Run once after freezing (`harness.evaluate` on the 5 dev datasets, seeds 0–2, every grid n); files
`../results/dfg_gates-v1__<dataset>.json`. The MLP is `../results/mlp__<dataset>.json`. Columns:
- *log2 ratio* = log2(max(err, 0.002) / max(err_MLP, 0.002));
- *FLOPs* = the largest fit's FLOPs over the 3 seeds, as a fraction of one MLP training run at that n
  (`harness.mlp_flops`);
- *CPU* = the largest process CPU time of a fit (1 core, float64/float32 numpy).

| dataset | n | MLP err | dfg_gates err | log2 ratio | max FLOPs / MLP run | max CPU s |
|---|---|---|---|---|---|---|
| optdigits | 100 | 0.1310 | 0.1302 | -0.01 | 0.028 | 0.7 |
| optdigits | 300 | 0.0600 | 0.0707 | +0.24 | 0.121 | 1.4 |
| optdigits | 1000 | 0.0306 | 0.0396 | +0.37 | 0.460 | 5.6 |
| optdigits | 3000 | 0.0230 | 0.0287 | +0.32 | 0.794 | 8.3 |
| optdigits | 4215 | 0.0159 | 0.0249 | +0.65 | 0.864 | 9.8 |
| magic | 100 | 0.2071 | 0.2259 | +0.13 | 0.004 | 0.2 |
| magic | 300 | 0.1786 | 0.1811 | +0.02 | 0.010 | 0.3 |
| magic | 1000 | 0.1553 | 0.1616 | +0.06 | 0.040 | 0.4 |
| magic | 3000 | 0.1384 | 0.1431 | +0.05 | 0.043 | 0.4 |
| magic | 10000 | 0.1369 | 0.1244 | -0.14 | 0.136 | 3.3 |
| magic | 14265 | 0.1288 | 0.1235 | -0.06 | 0.152 | 6.8 |
| kr_vs_kp | 100 | 0.0930 | 0.0809 | -0.20 | 0.000 | 0.1 |
| kr_vs_kp | 300 | 0.0613 | 0.0526 | -0.22 | 0.001 | 0.1 |
| kr_vs_kp | 1000 | 0.0313 | 0.0171 | -0.87 | 0.008 | 0.3 |
| kr_vs_kp | 2397 | 0.0050 | 0.0096 | +0.94 | 0.025 | 0.4 |
| satimage | 100 | 0.1566 | 0.1711 | +0.13 | 0.015 | 0.4 |
| satimage | 300 | 0.1413 | 0.1461 | +0.05 | 0.147 | 1.1 |
| satimage | 1000 | 0.1146 | 0.1187 | +0.05 | 0.429 | 3.2 |
| satimage | 3000 | 0.0880 | 0.1017 | +0.21 | 0.631 | 3.9 |
| satimage | 4826 | 0.0874 | 0.0976 | +0.16 | 0.776 | 7.0 |
| spambase | 100 | 0.1467 | 0.1270 | -0.21 | 0.008 | 0.3 |
| spambase | 300 | 0.0986 | 0.0942 | -0.07 | 0.027 | 0.4 |
| spambase | 1000 | 0.0788 | 0.0745 | -0.08 | 0.128 | 1.1 |
| spambase | 3000 | 0.0571 | 0.0652 | +0.19 | 0.152 | 1.3 |

**Summary.** Mean log2 ratio over the 24 (dataset, n) cells: **+0.071** (about 5% higher error than the MLP on a
geometric average). By more than 10% relative: better in **5** cells, worse in **8**, within 10% in 11. Max FLOPs:
**0.86** of one MLP run (optdigits, n = 4215). The whole dev run took about 150 CPU-seconds.

**By dataset.**
- **Better than the MLP:**
  - kr_vs_kp at n ≤ 1000 (0.017 against 0.031 at n = 1000);
  - spambase at n ≤ 1000;
  - magic at n ≥ 10000 (0.124 against 0.137 and 0.129).
- **Within ~5–13%:** magic at n ≤ 3000; satimage at n ≤ 1000.
- **Worse:**
  - optdigits at n ≥ 300, by 1.2–1.6× (0.025 against 0.016 at the full pool);
  - satimage at n ≥ 3000, by 1.12–1.16×;
  - kr_vs_kp at the full pool (0.0096 against 0.0050);
  - spambase at n = 3000 (0.065 against 0.057).

**Against the plain linear baseline** (`../results/linear__<dataset>.json`, for context). The gates carry
most of the gain on magic (0.203 → 0.124 at the full pool), satimage (0.137 → 0.098), kr_vs_kp (0.030 → 0.010) and
spambase (0.080 → 0.065). On optdigits they add little: 0.031 → 0.025. At n = 100 and 300 dfg_gates is *worse* than
the linear model on optdigits (0.130 and 0.071 against 0.110 and 0.066).

## 4. Choices made on dev data

All of these were chosen on the 5 dev datasets, mostly at n ∈ {300, 1000, 3000} with 1–2 seeds, so the dev numbers
above are in-sample for these choices.

- **Threshold multiplier c = 0.5, not DFG's c = 1.**
  - At c = 1 growth stopped after 2–4 rounds with 5–15 gates on magic and spambase.
  - c = 0.5 helped on spambase (n = 3000: 0.064 → 0.050–0.057), magic (0.150 → 0.143) and optdigits (0.033 → 0.029),
    in single-seed runs.
  - The test stays a union bound in form, but with c² = 0.25 it admits some false positives. The greedy cap of 24
    per round and the validated ridge limit the damage.
- **Checkpoint selection dropped.** A first version chose the number of rounds on the 10% split, like the MLP's early
  stopping. With 100 validation points this was too noisy: optdigits at n = 1000 got 0.072 against 0.045 without it.
  Only the readout is selected now.
- **Ridge grid widened to include 0.1, with ties to the stronger ridge.** Mean log2 ratio against the MLP over 14 dev
  cells (2 seeds): +0.016 → −0.032. The main gains were optdigits n = 300 (0.085 → 0.069), spambase n = 300
  (0.112 → 0.094) and magic n = 300.
- **Q = 16 thresholds rather than 32.** Q = 32 was worse on spambase and satimage: +0.032 against −0.032.
- **Projection literals** (`proj`: thresholds on the linear-fit class directions and their differences). Not better:
  mixed, slightly worse on optdigits. Off.
- **Spectral block** (`quad`: DFG's (u·x)² on eigen-directions of the residual-weighted second moment of whitened
  inputs). Not better on average. With 2 seeds: optdigits 1000/3000 0.037/0.026 without it against 0.053/0.033 with
  it; satimage roughly equal. Off.
- **Small-n fixes, after a first full run gave 0.57 error on optdigits at n = 100.**
  - *Whitening floor.* Σ had near-zero eigenvalues: classes with almost no residual. Whitening blew those up, so
    everything passed. Hence the 10⁻³ floor and C′ degrees of freedom.
  - *Linear-block rank cap.* The 90-column encoding did not fit under p ≤ n/2, so the linear block was rejected.
    Hence the n/3 principal-component cap.
  - *Stop rule tried and removed.* A DFG-style stop "every training label right" was tried as well. It hurt spambase
    at n = 300–1000 and was removed.

## 5. Weaknesses

- **Dense, smooth signal (optdigits, satimage).** Axis-aligned threshold gates of ≤ 3 literals are a poor
  dictionary for digit images and multispectral pixels. There the MLP's dense hidden units win by 1.2–1.6× at
  n ≥ 1000. The two denser moves tried did not close the gap on dev: projection literals and DFG's spectral (u·x)²
  block.
- **Small n with wide inputs.** On optdigits at n = 100–300 it is worse than a plain linear model. The causes are the
  rank-capped linear block (top n/3 principal components) and readout selection on a 10–30 point validation split.
- **Depth cap.** kr_vs_kp at the full pool is 2× the MLP's error while using 2.5% of the budget. Growth stops because
  nothing more passes at degree ≤ 3, so the chess rules that need deeper conjunctions are not reached.
- **The union bound is loosened.** c = 0.5 (c² = 0.25) was chosen on dev data. At DFG's c = 1 growth stops too early
  on these datasets. So the test is a union bound in form, with false positives traded against the greedy cap and the
  validated ridge.
- **Above n = 1000 the gates are grown on 90% of the data.** The other 10% is used only for readout selection and the
  final readout refit.
- **Compute.** The literal-pair search costs up to 0.86 of an MLP run on optdigits (L ≈ 800 literals, 10 classes).
  On the other datasets the cost is ≤ 0.78 of a run, and ≤ 0.16 on magic, kr_vs_kp and spambase.
  - *Not counted:* elementwise work, namely comparisons building the literal matrix (counted once per growth),
    products forming the gate columns of the design matrices, and elementwise statistics on the L × L pair arrays.
    By our estimate this is below 1% of the budget.
- **In-sample choices.** Every choice in §4 was made on these 5 datasets, so the dev numbers are optimistic for the
  held-out ones.
