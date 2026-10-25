# dfg_bits: DFG on Boolean encodings of standard tabular data

Learner `dfg_bits-v1`, `learner.py` (class `Learner`, default constructor = the frozen version). numpy only. No trees,
kNN, SVMs or library kernels. No gradient descent on any feature parameter: the features are discrete objects found by
enumeration and admitted by statistical tests, and only the readout weights are continuous.

Design angle "bits", the most faithful of the adaptations. Every input becomes ±1 bits, and DFG
(`study/discrete_learner/dfg.py`) then runs on those bits essentially as it is. It is generalised in two ways: to C
classes, and to bits that are correlated and not uniform.

## 1. Algorithm

**Encoding** (fit on the training set only).
- *binary* → 1 bit.
- *categorical* → one ±1 bit per value (one-hot). A value needs ≥ 3 points on each side.
- *continuous / ordinal* → thermometer bits [x > t_q] at the training quantiles q/(nb+1), q = 1..nb, with
  nb = clip(round(480 / #continuous inputs), 6, 12). Splits that coincide are dropped.
- The standardized continuous values z (clipped at ±6) are kept as extra inputs for the linear block and the spectral
  block.
- All the bits of one original input form a *group*. A product of bits from the same group lies in the span of that
  group's bits (it is an interval indicator), so characters only multiply bits from different groups.

Dev sizes: 33–38 bits (kr_vs_kp), 120 (magic), about 300–430 (satimage, optdigits, spambase).

**Rounds** (at most 12).
- *Residual.* Y holds ±1 labels (C = 2) or one-hot rows (C > 2). The residual is R = Y − LS fit on the current
  features, with a small ridge of 1e-3·n.
- *Whitening.* R is whitened by its own covariance, dof-corrected as SSR/(n − p), which gives Rw (n × k) with
  k = rank (k = C − 1 for one-hot).
- *Test.* A candidate character φ = ∏_{i∈S} b_i has φ² = 1, but on real data it is no longer mean-zero, and two
  characters are no longer orthogonal. Its statistic is

      T(φ) = m · Σ_q mean_m(Rw_q φ)² / max(var(φ), 0.05)

  which is about χ²_k when φ carries no signal. It is the multi-class score test, and the gain in residual sum of
  squares from adding φ, in the whitened metric.
- *Acceptance.* φ is accepted if T > c²(k + 2√(kL) + 2L), with L = ln(4KN/δ) (Laurent–Massart χ² tail with a union
  bound over the N members of its class), c = 1, δ = 0.1 and K = 4, exactly DFG's constants. For C = 2 this reduces
  to DFG's test |mean(rφ)| > s·√(2 ln(4KN/δ)/n), up to the variance correction.
- *Candidate classes.* Each class has its own N.
  - Global:
    - degree 1: all bits;
    - degree 2: all pairs of bits from different groups;
    - degree 3: all triples;
    - degree 4: first round only.

    Each search above degree 1 runs on the first m training points, with m set by a FLOP share of the budget: 3% per
    round for pairs, 3% for triples, 8% for degree 4. A search with m < 32 (degree 2) or m < 64 (degrees 3–4) is
    skipped, as in dfg.py.
  - Extension: S ∪ {j} (all data) and S ∪ {j, l} (subsample, 2% per round), for the 24 current characters with the
    largest readout weight.
  - Local: every subset of degree ≥ 2 of V, the bits of the strongest current characters, with |V| ≤ 10. It uses a
    Walsh–Hadamard transform of the residual histogram on V. The histogram of counts gives the means of the
    characters, which are not zero here.
- *Deduplication.* At most one character per *group signature* (the set of original inputs it touches) is accepted
  per round, and at most 64 per round in all. Thermometer bits of one input are nearly collinear; without this, a
  round fills with near-copies of one interaction.
- *Blocks.*
  - Linear: the z block, and the block of all remaining degree-1 bits. Each is added when a χ² test on the whole block
    passes and it fits in the room left.
  - Spectral: on U = (z, non-continuous bits), compute the eigen-directions u of mean(Rw_q · U Uᵀ), for each whitened
    residual column q, on a FLOP-share subsample. Directions whose eigenvalue clears 1.1 × a permutation-null noise
    edge become features (u·U)², standardized. The null edge is the top eigenvalue for a randomly permuted residual;
    it replaces DFG's Wigner edge, which assumed uniform inputs. At most 8·k per round.
- *Stopping.* Stop when nothing passes. Also stop when p reaches min(n/2, 1200), since least squares is kept to
  p ≤ n/2 as in DFG. Also stop when the next round together with the reserved readout cost would exceed 0.92 of the
  budget.

**Readout.**
1. *Ridge least squares.* Fit on [grown features + every linear input not already grown] (the kernel-like linear
   background) after centering. The ridge comes from a grid of 15 values chosen by exact leave-one-out: primal
   eigendecomposition when P ≤ n, kernel (dual) form with the intercept direction removed when P > n.
2. *Refinement* (n ≥ 200, primal case only). L2-penalised softmax regression (C > 2) or logistic regression (C = 2),
   by majorise–minimise. It uses Böhning's fixed curvature bound ½FᵀF/n (or ¼ for logistic), reuses the
   eigendecomposition, and runs 30 iterations, warm-started from the LS weights after a 1-D scale search. The penalty
   (α/n · {1, 0.1, 0.01}), or keeping plain LS, is chosen on a 20% hold-out, and the chosen readout is refit on all n.

**Compute.** Every matrix product, solve, eigendecomposition (10p³), LOO grid evaluation, hold-out fit and MM iteration
is counted in FLOPs, with a multiply-add counted as 2. The total is reported as `flops`, and the per-fit budget is
`harness.mlp_flops` (one MLP training run at this n). Prediction is not counted, for either learner.

## 2. Which DFG element maps to what

| DFG (Boolean ±1 cube) | dfg_bits |
|---|---|
| inputs x_i ∈ {±1}, uniform | thermometer / one-hot / binary bits, correlated, not uniform; groups per original input |
| test \|mean(rχ_S)\| > c·s·√(2 ln(4KN/δ)/n) | whitened multi-class score statistic T vs a χ²_k tail at δ/(4KN); var(χ_S) correction; s dof-corrected |
| global degrees 1–3 every round, 4 in round 1, 5–6 on a subsample | degrees 1–2 every round, 3 when the budget allows it, 4 in round 1; all budget-subsampled; degrees 5–6 dropped (no gain on dev, costly at d_bits ≈ 400) |
| extension classes S∪{j}, S∪{j,l} | same, on the strongest characters; partners from other groups only |
| local Walsh transform on V (junta completion) | same, with counts to give the character means |
| linear block (χ²_d test) | z block + bit block, χ² test each |
| spectral block, Wigner edge 2s√(d/n) | per-class residual-weighted second-moment matrices on (z, non-continuous bits), permutation-null edge |
| readout: LS (v1), logistic refinement (v1.1) | ridge LS (LOO ridge), softmax / logistic refinement (MM, hold-out penalty) |
| Hebbian kernel background | ridge on all linear inputs alongside the grown features |
| budget: FLOP shares of one network run | FLOP shares of one MLP run (harness.mlp_flops), readout cost reserved in advance |
| small-n "forced" variant, CV | not used: LOO ridge on the linear background covers small n |

## 3. Choices made on dev data

Development runs used seeds 0–1, n ∈ {100, 300, 1000, 3000}, and occasionally magic at the full pool.
- **nb.** 12 bits was better than 6 on magic, spambase and satimage. 6 was better on optdigits, whose inputs are
  counts 0–16, and more bits there leave fewer rounds affordable. The compromise nb = clip(480 / #continuous, 6, 12)
  gives 12 for magic and satimage, 9 for optdigits and 8 for spambase.
- **c.** c = 0.6 or 0.8 instead of 1 was not consistently better on magic and spambase, so DFG's c = 1 is kept.
- **Spectral features per round, 8·k instead of 1·k.** optdigits n = 3000 went from 0.032 to 0.027 (one seed).
- **Bugs fixed on dev:**
  - the dual LOO, which needed the intercept direction removed (small-n errors had been 0.2–0.35 because it picked
    tiny ridges);
  - the spectral subsample formula;
  - the readout-cost reservation.
- **Softmax refinement.** It helped in most hold-out comparisons, with typical hold-out gains of 0.5–2.5 points, so it
  is kept.

## 4. Dev results

Full run of the frozen version, 3 seeds; test error is the mean over seeds. The `linear` column is the existing
`results/linear__*.json` baseline, shown for context only. The FLOPs fraction is the maximum over seeds of
dfg_bits-v1's FLOPs over one MLP run's FLOPs. log2 ratio = log2(max(err, 0.002) / max(err_mlp, 0.002)).

| dataset | n | MLP | dfg_bits-v1 | linear | log2 ratio | FLOPs frac |
|---|---|---|---|---|---|---|
| optdigits | 100 | 0.1310 | 0.1369 | 0.1098 | +0.06 | 0.02 |
| optdigits | 300 | 0.0600 | 0.0716 | 0.0657 | +0.26 | 0.01 |
| optdigits | 1000 | 0.0306 | 0.0467 | 0.0403 | +0.61 | 0.08 |
| optdigits | 3000 | 0.0230 | 0.0323 | 0.0318 | +0.49 | 0.29 |
| optdigits | 4215 | 0.0159 | 0.0294 | 0.0313 | +0.89 | 0.81 |
| magic | 100 | 0.2071 | 0.2188 | 0.2303 | +0.08 | 0.00 |
| magic | 300 | 0.1786 | 0.1968 | 0.2196 | +0.14 | 0.01 |
| magic | 1000 | 0.1553 | 0.1557 | 0.2089 | +0.00 | 0.06 |
| magic | 3000 | 0.1384 | 0.1435 | 0.2051 | +0.05 | 0.15 |
| magic | 10000 | 0.1369 | 0.1346 | 0.2031 | -0.02 | 0.23 |
| magic | 14265 | 0.1288 | 0.1340 | 0.2034 | +0.06 | 0.28 |
| kr_vs_kp | 100 | 0.0930 | 0.1114 | 0.0847 | +0.26 | 0.00 |
| kr_vs_kp | 300 | 0.0613 | 0.0538 | 0.0580 | -0.19 | 0.00 |
| kr_vs_kp | 1000 | 0.0313 | 0.0355 | 0.0409 | +0.18 | 0.02 |
| kr_vs_kp | 2397 | 0.0050 | 0.0079 | 0.0300 | +0.66 | 0.06 |
| satimage | 100 | 0.1566 | 0.1817 | 0.1759 | +0.21 | 0.00 |
| satimage | 300 | 0.1413 | 0.1324 | 0.1603 | -0.09 | 0.01 |
| satimage | 1000 | 0.1146 | 0.1148 | 0.1421 | +0.00 | 0.08 |
| satimage | 3000 | 0.0880 | 0.1030 | 0.1342 | +0.23 | 0.26 |
| satimage | 4826 | 0.0874 | 0.0936 | 0.1367 | +0.10 | 0.52 |
| spambase | 100 | 0.1467 | 0.1371 | 0.1504 | -0.10 | 0.01 |
| spambase | 300 | 0.0986 | 0.0864 | 0.1078 | -0.19 | 0.03 |
| spambase | 1000 | 0.0788 | 0.0707 | 0.0852 | -0.16 | 0.08 |
| spambase | 3000 | 0.0571 | 0.0571 | 0.0800 | +0.00 | 0.21 |

**Summary over the 24 dev cells.**
- Mean log2(err / err_MLP) = **+0.147**, so dfg_bits is about 11% worse than the MLP on average.
- Better than the MLP by more than 10% relative in **3** cells; worse by more than 10% in **10**.
- Max FLOPs fraction: **0.81** of one MLP run. Typical fractions are 0.01–0.3.
- CPU time per fit: at most 6.7 s, and 0.7–2.3 s at n = 3000.

**Per dataset.**
- *spambase:* better than or equal to the MLP at every n.
- *magic:* within 0–6% of the MLP at n ≥ 1000, slightly better at n = 10000. It is far better than linear, so the grown
  interactions do the work.
- *satimage:* even with the MLP at n = 300–1000, 7–17% worse above that.
- *kr_vs_kp:* better at n = 300, worse at n = 100, 1000 and 2397 (0.0079 against 0.0050 at the full pool).
- *optdigits:* the clear loss. It is 1.4–1.9× the MLP's error at n ≥ 1000, and no better than the linear baseline
  (worse than linear at n ≤ 1000).

## 5. Weaknesses

- **Smooth, image-like data (optdigits).** Products of thermometer bits are a poor dictionary for digit shapes. Most of
  the fit is the linear background, and dfg_bits barely beats a linear model. The spectral quadratic block is the
  only part that helps there.
- **Very small n.** At n = 100 the encoding has 300–430 bits on three datasets, the union-bound tests pass almost
  nothing, and the readout is ridge regression on the bits. That is worse than both the MLP and the linear baseline on
  optdigits and kr_vs_kp.
- **Conservative tests on dense real-world signal.** With c = 1 the search stops after 1–3 rounds on magic and spambase
  and uses only 6–30% of the budget. Many weak effects each fall below the union-bound threshold, so spare compute
  cannot be turned into accuracy. Lowering c was not a consistent fix on dev.
- **Hold-out noise in the readout.** The choice of softmax penalty (20% hold-out), and LOO-ridge choices at small n,
  are noisy, and seed-to-seed spread is 0.5–1 point.
- **Budget use near the limit at the largest optdigits n** (0.81 of an MLP run). This is because the softmax readout on
  about 1000 features with 10 classes is expensive. At 800+ bits (held-out images) the budget-aware subsampling will
  skip degree ≥ 3 global searches entirely.
- **Memory at held-out image scale.** No memory guard was tested. At MNIST size (n = 60000, about 2000+ bits) the bit
  matrix and the readout design matrix [grown features, all bits, all z] each take on the order of 1–2 GB in float64.
  The readout's Gram matrix and eigendecomposition (P ≈ 4000) would dominate both CPU time and the FLOP reservation.

**Post-run change, no change in behaviour.** After the full dev run, the preallocated feature-matrix width was cut from
cap + 2·max_new + 64 + d_bits + d_z to cap + 1. The rounds never hold more than cap columns, so this only saves memory.
Re-running six dev cells (optdigits n = 3000 and 4215 at seeds 0 and 2, magic and kr_vs_kp at n = 1000, seed 1)
reproduced the recorded errors exactly.
