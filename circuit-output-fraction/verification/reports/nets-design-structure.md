# Trained networks, design round: structure

WHAT I BUILT. I wrote analysis scripts only, all in experiments/nets_structure/ (README lists every script and its output). Everything is measured against exact p:
- Exhaustive enumeration of all 21 suite nets with d <= 28. All counts match suite.json; I recorded exact moments, the exact lower-tail curve (k-th smallest f) and the failure sets.
- 676 nets trained here with train_constant: d = 12..24, 1 and 2 hidden layers, both losses, widths 8..128, 3-4 seeds, snapshots. Exact p for each; 40% have p = 0.
- Failure-set statistics for about 70 failure sets, exact Walsh spectra, witnesses against relaxations for all 30 suite nets, exact largest failure-free subcubes (d <= 20), counterexamples, and checks at d = 32..128 against the SMC reference values in experiments/nets_lower.
- Heuristics were scored at 3075 (net, level) points with exact P (547 nets). The levels are each net's threshold plus every k-th smallest value of f, where P = k/2^d.

A. STRUCTURE, squared loss, one hidden layer (your observations hold, with refinements).
1. f is almost even. corr(f(x), f(-x)) = 0.82-0.99. The odd part carries 1-9% of the Walsh weight at d=24. sum_j a_j w_j is 1.4% of its natural scale. 27-84% of failing inputs also fail at -x.
2. Failure is the collapse of E+ = (1/2) sum_{a_j>0} a_j |z_j|. E+ carries 54-140% of the drop of f at failures; the linear part carries about 0.
   - The small ball is at the lattice scale. At a failure, 9-15 positive units sit within one coordinate-flip step (2|w_ji|) of zero, against 4-8 typically; their median |z_j| is 1.2-1.6 steps against 2.6.
   - Width changes the mechanism. When there are more positive units than inputs (m+ >= d), the negative units' |z_j| also rise: E- takes 45% of the drop at d=28 w64, and 79-102% late in training at d=20 w64.
3. Small ball for E+ is the same event as a large deviation of the complementary projection.
   - All width-32 nets have m+ = 19-20 < d = 24, so W+ has a 4-5 dimensional null space, and failing inputs are the cube points best aligned with it.
   - The single failure of s2000 ranks 320th of 16.7M cube points by null-space share (0.70 against 0.17 typical).
   - Failures are 200x to 17000x over-represented among the 1000 most aligned points, but only 0.1-7% of those points fail.
   - E[x x^T | fail] has 8-15 eigenvalues below 0.5 and 1-3 expanded axes (top eigenvalue 3-10). The top axis is the most negative eigenvector of the degree-2 Walsh part (|cos| about 0.9); about 30% of failures lie within Hamming distance d/5 of ±sign(axis).
4. There is no first-moment direction, and this is rigorous. For every squared-loss failure set examined (except dying-unit 2-layer nets), 0 lies in conv(S). So every halfspace containing all failures has mass at least 1/2: K >= 1/(2p), which is 5e4 for s1500 and 1.5e6 for mse_d28_w64_s1000. Even a quarter of the failures needs a halfspace with K = 460-7000.
5. Many modes, clumped locally.
   - F failures sit in roughly F/2 to F/4 single-flip local minima: 163 failures in 90 minima, 6012 in 1600, 16155 in 5684. Half of S needs 19-580 basins.
   - Pair correlation g(1) = 10 to 6e4 (1 for a random set). Nearest failing neighbour is at distance 1.1-3, against 4-8 for a random set; mean pairwise distance is about d/2.
   - Failure-free subcubes are 1-9 dimensions (median 5) larger than for a random set of the same size. The exact lower bound on the pieces of any subcube partition, sum_x 2^-k(x), is 0.001-1 times F (median 0.1F), so the failure set is cheap to isolate combinatorially.
6. Training moves the residual to higher even degrees: mean degree 2.6 to 4.6, weight on degree 2 from 0.82 to 0.21, participation ratio 131 to 1551, no single coefficient above 3% of the variance. This behaves like a random high-degree function, which is why the output is close to Gaussian (|excess kurtosis| < 0.13). Training also adds positive units and fills the null space (BCE: m+ 19 to 26; w64: smallest singular value of W+ 0.23 to 0.41); that is what eventually makes p = 0.

B. LOGISTIC LOSS works differently.
- f is not even: corr -0.5 to +0.25, odd Walsh share 0.2-0.74, and the linear part carries 32-72% of the drop.
- Failures have a direction: mean |x_i| 0.2-0.7, mean pairwise distance 8-11 < d/2 at d=28, antipodes never fail.
- A halfspace holds 25% of failures at K = 3-38 and 50% at K = 6-150 (squared loss needs 1700-6e4 for half).
- Few dominant basins: 1-10 hold half of S at d <= 24, 23-98 at d=28. The positive units still collapse (normalized |z_j| at 0.58-0.95 of typical).
- The lower tail is lighter than Gaussian (skew +0.15 to +0.47): (mean - min f)/sd is 4.1 at d=28, against 6.5 for squared loss.

C. TWO HIDDEN LAYERS. f is mixed even/odd (corr 0.1-0.4); both parts drop.
- In 3 of the 4 squared-loss runs at d=20/24 that still fail late in training, the last failures are the shrinking activation region of one "dying" second-layer unit. Its activation probability falls from 25% to 0.8%; at a failure it deviates 10-54 sd from typical and carries 86-97% of the drop.
- This is a naturally planted region far out in the tail: p = 1.2e-7 at z = 9.35, where the output Gaussian gives 4.5e-21.
- I did not see it with logistic loss or in the suite's d=28 two-layer nets (top unit carries at most 41% of the drop).

D. SCALING WITH TRAINING AND d.
- Squared loss: sd falls as step^-0.74..-0.81 (one layer) or step^-0.57..-0.63 (two layers), so log(1/p) is about z^2/2 and grows faster than linearly in steps. Logistic loss: sd stays about constant while the mean grows.
- p = 0 is the usual end state.
- Steps until half the seeds reach p = 0:

  | | d=12 | d=16 | d=20 | d=24 | d=28 (suite w64) |
  |---|---|---|---|---|---|
  | squared loss, 1 layer, w32 | 500 | 700 | 700 | 1000 | 1500 |
  | logistic loss | 70 | 150 | 150 | 200 | - |

- At a fixed step p grows with d (for example at s500: 1.8e-4, 7.4e-4, 1.8e-3 at d = 16, 20, 24). Wider nets reach p = 0 faster with logistic loss (w8 never within 300 steps, w128 by step 50).
- Squared loss behaves like an extreme-value (random-energy-model) picture. p = 0 when the Gaussian expected count 2^d Phi(-z) is below 1: p = 0 in 97% of nets when the count is < 0.01, 15% in [1,10), 0% when > 100. Median (mean - min f)/sd is about 0.9 sqrt(2 d ln2). Logistic loss reaches p = 0 earlier (63-94% at counts 1-100).

E. HEURISTICS. Per-method numbers are in METHODS.
- Best single estimator: mcfit, a quadratic fit to log Pr[f < s] from 1e5 samples, extrapolated. Median error x1.5, 93% within x10, right about p = 0 for 96% of nets. It misses dying units by up to 7.5 orders of magnitude.
- The sphere/Gaussian-input surrogate (CLT for the pre-activations) is the best estimator for logistic loss, two layers and d >> width. It overestimates one-layer squared-loss small balls at d close to width by 1-5.7 orders.
- On trained nets, every estimator's large errors were overestimates except output-moment methods on dying units.
- Picking mcfit for one-layer squared loss and the sphere surrogate otherwise gives median x1.5, 95% within x10, worst 3.3 orders, and predicts p = 0 correctly for 98% of 547 nets. On the 21 suite thresholds it is within x1.8 on 17 of 18 nets with p > 0 (x5.4 on the single-failure net). It fails at d=128 (mcfit is +6.3 orders off at p = 2e-30, where the sphere is -1.2).
- Cost: 1e4-1e6 forward passes. Monte Carlo needs about 1.1e3/p (1e8 at p = 1e-5, 1e33 at p = 1e-30).
- Presumption of independence over hidden units is hopeless: it ignores the trained cancellation, corr(E+, E-) = 0.84, so its variance is 7.5x too large.

F. WHAT ANY SOUND METHOD MUST DO.
T1. The hard cases are inside the architecture and they are small balls.
- Width-2 nets f = |w.x - y| with integer weights and threshold 1/2 fail exactly when w.x = y (SUBSET-SUM). Deciding p > 0 is NP-hard, so by Prop. worstcase(a) no sound procedure is complete on them unless NP is in BPP.
- With modular subset sum (two hidden layers of width O(d)), Prop. worstcase(b) turns subset-sum pseudorandomness of hardness T into t log t >= T/poly for every sound procedure. Every 3-CNF is also such a net (nets_verify).
- These are small balls at the exact lattice scale. Trained failures sit at about one flip step per unit, jointly in about 10 units. Efficiency can only come from trained-net structure, and nothing measured here puts trained nets in a provably easy class.

T2. Upper bounds below the sampling scale need the weights.
- Adding one unit -M relu(sum_{i<k} s_i x_i - (k-1)) plants a failing subcube of mass 2^-k and changes nothing else. So Thm. blackbox applies inside the architecture: with T evaluations no method can certify U < 1/(2T).
- Training produces such regions on its own (dying units, C).

T3. Relaxations of the input domain cannot see the discreteness.
- Any argument valid on the box (interval, CROWN/LP, any convex relaxation, Lipschitz bounds, per-unit linear tilts) is limited by min over the box of f. Any norm or spectral argument is limited by min over the sphere |x|^2 = d.
- Local search finds box points with f < t for 29 of 30 suite nets (all d <= 28) and sphere points for 30 of 30. f(0) < t for all 13 squared-loss nets with d <= 28.
- For the three p = 0 nets the box minimum is at least 0.41 below the cube minimum.
- On the 3 nets inspected, the witness points are interior (|y|^2/d = 0.3-0.5) and the positive pre-activations vanish there (|z_j|/|w_j| = 0.05-0.27 against 0.81 on the cube). That is exactly the small ball the cube forbids.
- So a sound upper bound must prove a cube-specific anti-concentration statement ("W+ x + b+ is not small outside the envelope"). Options are input branching down to faces with about 8-24 free coordinates (nets_verify), or arguments that use x_i^2 = 1 jointly (SDP/SOS, certified Esseen/Littlewood-Offord bounds). When m+ < d this is a closest-vector or discrepancy question about cube points near null(W+).

T4. Envelopes.
- Product-measure and halfspace envelopes cannot be tight for squared loss: K >= 1/(2p) for all failures, >= 460 for a quarter. They can be tight for logistic loss (K = 3-150 for 25-50% of failures).
- Small-ball envelopes need the joint law of about 10 dependent pre-activations. It does not factor, and exact dynamic programming over k units costs range^k.
- Subcube envelopes are combinatorially cheap (A5), but every certified piece is a ReLU verification problem, and T3 says relaxations fail until faces are small.

T5. Regimes.
- (i) p >~ 1/T: Monte Carlo is already a sound two-sided method.
- (ii) p > 0 with d up to about 30: exact counting by branch and bound at roughly enumeration cost.
- (iii) p = 0: a coNP-side statement (Thm. ma). It is certifiable only if the margin min f - t exceeds the relaxation gap at a feasible depth. The heuristics predict p = 0 for 98% of nets but cannot certify it.
- (iv) d >= 64 with 0 < p << 1/T: upper bounds need deduction (T2), box-based deduction needs at least 2^(d - r*), about 2^40 or more, faces, and no complete alternative exists for the architecture (T1, Thm. ma). A two-sided sound interval within a constant ratio is hopeless there with known techniques. Sound lower bounds remain feasible, but proposals must cover hundreds of basins or exploit the local clumping (SMC).

## Methods

### Output Gaussian: Phi((s-mean)/sd), exact moments or 1e4 samples (heuristic point estimate)

**Soundness.** Not sound. It assumes the lower tail of f continues a Gaussian. It fails (a) on lattice small balls: 10^0.5 too high at d=24, 10^15.7 at d=400 (adversarial.py); (b) on mass invisible to the bulk: dying second-layer units (4.5e-21 against 1.2e-7) and a planted 2^-16 subcube (x1/36 too low); (c) on light-tailed logistic-loss logits (x37-4600 too high at d=28, x2e8 for bce_d64_w64x64_s300 against SMC).

**Results.** All 3075 points: median |log10(est/exact)| 0.68, 63% within x10, worst 43 orders. Thresholds: median 0.05, 90% within x10. Squared loss: median 0.42. Logistic loss: median +1.1 (overestimate). P <= 1e-6: median 1.47 orders. p = 0 predicted correctly for 90.5% of nets. Cost 1e4 forward passes.

**Verdict.** Works for squared loss in the bulk and moderate tail (P >= 1e-4, within x2-5). Not for logistic loss or deep tails.

### Edgeworth expansion (exact skewness and kurtosis) (heuristic point estimate)

**Soundness.** Not sound. It goes negative (no estimate) far in the tail and diverges on heavy-tailed planted mass (gives 8.8 for a probability).

**Results.** Gives no estimate at 869 of 3075 points, mostly logistic loss. Where defined: median 0.18 orders, but worst 40. Thresholds: median 0.01, 98% within x10. Very good for squared loss down to about 1e-7 (s1500: 9.4e-6 against 9.7e-6).

**Verdict.** Excellent when the tail is near-Gaussian (one-layer squared loss), unusable otherwise.

### mcfit: quadratic fit of log Pr[f<s] on the empirical lower tail of 1e5 samples, extrapolated (heuristic point estimate)

**Soundness.** Not sound. It extrapolates the curvature of the bulk. Off by 10^-7.5 on dying-unit tails, +0.4 to +1.6 orders on logistic loss at d=28, +1.7 to +6.3 orders at d=128 (width 64) against SMC references. Misses planted mass smaller than about 1/1e5.

**Results.** Median |error| 0.18 orders (x1.5), 90% within 0.85, 93% within x10, worst 7.45. Thresholds: median 0.03, 98% within x10. One-layer squared loss at P <= 1e-4: median 0.23. p = 0 prediction 96.2%. Cost 1e5 forward passes, against Monte Carlo 1.1e3/p.

**Verdict.** Best single estimator for one-hidden-layer squared loss. Unreliable whenever the tail has structure the bulk does not show.

### Linear Walsh part (exact cube law) plus independent Gaussian rest, saddlepoint (heuristic point estimate)

**Soundness.** Not sound. Same failure modes as the output Gaussian.

**Results.** Median 0.63 orders, worst 43, about the same as the output Gaussian. The light logistic tail is not explained by the linear part's discreteness.

**Verdict.** No gain over the output Gaussian.

### Gaussian-input surrogate (CLT for hidden pre-activations): Pr_{g~N(0,I_d)}[f(g)<s] by subset simulation in Gaussian space (heuristic point estimate)

**Soundness.** Not sound. It replaces the cube by a continuous law with the same first two moments, so it is wrong exactly where the event depends on discreteness.

**Results.** Too high on one-layer squared-loss small balls at d close to width (median +1.5 orders at P <= 1e-4, up to 5.8). Too low by 10^-8 on the lattice gadget, x5-19 too high on a planted subcube. Logistic loss d=28: x1.06-1.15. Dying units: x3.4. d=128 against SMC: within x6, x1.0 at p = 2e-30. Cost 2-7e5 forward passes.

**Verdict.** Accurate when the small ball is coarse (d >> width) or the event is a large deviation (logistic loss, dying units). Not for squared-loss small balls at d close to width.

### Sphere surrogate (g uniform on the sphere of radius sqrt(d)) (heuristic point estimate)

**Soundness.** Not sound, for the same reason as the Gaussian-input surrogate. Up to 5.7 orders too high at the cube minimum of long-trained d=20 squared-loss nets, where a quarter of the sphere lies below the cube minimum.

**Results.** Overall median 0.36 orders, 77% within x10. Logistic loss: median 0.19, 96% within x10. Two layers: 0.23. One-layer squared loss at P <= 1e-4: median +1.06. Against SMC at d=32-128: -1.2 to +1.9 orders. Threshold p = 0 accuracy 94%.

**Verdict.** Best for logistic loss, depth 2 and d >> width. Biased high on lattice-scale small balls.

### Presumption of independence over hidden units (relu or even form, Lugannani-Rice) (heuristic point estimate)

**Soundness.** Not sound. It ignores the dependence that training creates: E+ and E- are 84% correlated, which cancels most of the variance (true Var f 0.012 against 0.092 under independence).

**Results.** Median +2.65 orders (relu form) and +1.57 (even form), up to 7.6 orders too high. p = 0 prediction 59-70%.

**Verdict.** Hopeless: trained nets are exactly where independence fails.

### Presumption of independence in the Walsh basis (diagnostic, d <= 20) (heuristic (diagnostic))

**Soundness.** Not sound. It needs the whole spectrum, so it is not efficient.

**Results.** Median 0.52 orders, roughly the output Gaussian. Participation ratio of about 1e2-1e3 explains the near-Gaussian marginals of squared-loss nets.

**Verdict.** Explains why the output Gaussian works for squared loss; adds nothing.

### Selector: mcfit for one-layer squared loss, sphere surrogate otherwise; p = 0 predicted when 2^d times the estimate is < 1 (heuristic point estimate and p = 0 predictor)

**Soundness.** Not sound (inherits both failure modes). An evenness-based switch, corr(f(x), f(-x)) > 0.5, fails on long-trained nets. A width-based switch fixes d=128 but breaks d=20 widths 8 and 16 (up to 5.7 orders).

**Results.** Median 0.18 orders, 90% within 0.73, 95% within x10, worst 3.3 orders. Thresholds: 100% within x10 (worst 1.4 orders). Suite thresholds within x1.8 on 17 of 18 nets with p > 0 (x5.4 on the single-failure net). p = 0 predicted correctly for 98.0% of 547 nets. Wrong at d=128 (+6.3 orders) where the sphere alone is within 1.2.

**Verdict.** Good practical heuristic for d <= 64. Disagreement between the two components flags structure (lattice-scale small ball against a rare-unit or large-deviation tail). Not a substitute for a sound method.

### Relaxation-based certification (any argument valid on the box [-1,1]^d or on the sphere) (sound upper bounds / p = 0 certificates (class))

**Soundness.** Sound for every net, but limited by min over the relaxed set of f.

**Results.** Local-search witnesses with f < t: box for 29 of 30 suite nets, sphere for 30 of 30, f(0) < t for 13 of 13 squared-loss nets with d <= 28. On the three p = 0 nets the box minimum is at least 0.41 below the cube minimum (for example 0.099 against 0.511). On the 3 nets inspected the witnesses are interior points where the positive units' pre-activations vanish.

**Verdict.** Provably cannot certify at the root; must branch until faces are small. The small ball is the reason. Needs arguments that use x_i^2 = 1 jointly.

### Subcube-partition certificates (decision tree; perfect certification engine) (sound two-sided (exact count, or certify and sample the rest))

**Soundness.** Sound. Lower bound on its size: sum_x 2^-k(x), where k(x) is the largest monochromatic subcube through x, computed exactly for d <= 20.

**Results.** Failure-free subcubes are 1-9 dimensions larger than for a random set of the same size. Lower bound 0.001-1 times F (median 0.1F); the best speedup over Monte Carlo it allows grows from x2 when p is large to x1e3-1e6 when F is small.

**Verdict.** The structure of the failure set is not the obstacle. Proving each piece failure-free (ReLU verification, blind relaxations) is.

### Halfspace or product-tilt envelopes (exact mass) (sound two-sided (envelope estimator))

**Soundness.** Sound by domination. Looseness K = mass / p.

**Results.** Squared loss: 0 is in conv(S), so any halfspace containing all failures has K >= 1/(2p) (5e4 for s1500, 1.5e6 for mse_d28_w64_s1000); a quarter of the failures needs K = 460-7000. Logistic loss: K = 3-38 for 25% and 6-150 for 50% of the failures.

**Verdict.** Hopeless for squared loss. Partially workable for logistic loss (mixture or partial envelopes).

## Adversarial soundness check

**Verdict.** not applicable (analysis only)

