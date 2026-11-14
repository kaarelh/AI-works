# Standalone fresh-reader review

Reviewed `paper.tex`, `gaussian-section.tex`, `bayes-section.tex`, `discussion.tex`, and the subsequently supplied `smooth-section.tex` as a standalone manuscript on 14 November 2026. This review checks the mathematical reasoning and the relationship between the claims; it is not a Lean verification, an external literature audit, or a check of the prior research note. The manuscript was not edited by this reviewer.

## Overall assessment

I found no mathematical blocker in the elementary Gaussian theorem, the continuous-prior final-posterior-mean theorem, or their neural-network applications. The smooth-loss appendix also has a sound absorption argument and sound teacher-energy tuning, conditional on the cited smooth-loss inequality with its stated constant. The improvement is obtained from an actual inequality, not from assuming that the desired statistical conclusion already holds.

The manuscript correctly distinguishes two different improvements. Retaining the selected learner's energy penalty improves the fixed-depth strong-prior Gaussian sample exponent to `1/(L−1)`. The expected parameter-count rate comes from a different architecture prior and a bounded prediction convention. The latter is not a theorem about the original dense product-Gaussian prior. Its expectation guarantee is also not a replacement for the Gaussian theorem's common high-probability event.

## Gaussian proof checks

- The teacher cloning construction preserves the represented function at every integer width `N ≥ m`. The ratios of clone group sizes and the readout normalization give the displayed energy bound, including when `N` is not a multiple of `m`.
- The variable-threshold clipping argument is valid with the stated additive `1/(2 sqrt(n))` term. The positive mixture representation of `tanh(su)/s` has total mass one. These two facts support the recursive convex-hull argument for arbitrary hidden-layer weights.
- The capacity proof correctly uses the `H` energy terms after the first layer, and therefore has the exponent `H/2`, not `(H+1)/2`. Ignoring the first-layer energy here is legitimate because the halfspace bound controls that layer without a norm constraint.
- The halfspace comparison is valid for arbitrary real input values. No bounded-input assumption is used in this section. Countability across widths and continuity in finite-dimensional parameters give the stated measurability convention.
- The dyadic peeling event covers every learner width at once. On the optimizer's energy range `q ≤ 1/λ`, the calibration `λ^(H/2) = a_n` genuinely gives `a_n q^(H/2) ≤ λq` when `H ≥ 2`.
- Coercivity yields global minimizers at each finite width. The bounded-risk Laplace argument proves a pointwise-in-width limit. It does not assert, and the theorem correctly does not claim, a uniform convergence rate in `σ` over all widths.
- The one-hidden-layer calculation uses the correct maximization `sup_q [a sqrt(q) − λq] = a²/(4λ)`. Its optional energy-cap tuning has the stated teacher dependence.
- The growing-teacher corollary is valid. It chooses a deterministic population-risk minimizer over a compact class, so no sample-dependent teacher or unproved simultaneous-in-teacher concentration is introduced. The Bernstein term has the required powers. The thresholds `α < 1/(4H)` for `H ≥ 2` and `α < 1/4` for `H = 1` follow.

The initially ambiguous choice between the Hoeffding and Bernstein teacher concentration terms was reported and has been clarified in the current source: each preselected choice gives its own event. One cannot automatically use their minimum on the same `1−δ` event at the original failure allocations.

## Final posterior mean and architecture prior

- The delete-one-observation lemma is valid. The variance comparison follows from the independent-pair formula and the density bound along the exponential interpolation. Its condition is exactly `4(exp(4η)−1) ≤ 1`.
- The leave-one-out argument uses `n+1` observations to bound the expected risk of the posterior mean trained on `n` observations. This correctly explains the `n+1` denominator; it is not an off-by-one error.
- The Gibbs variational comparison legitimately drops the nonnegative posterior KL term. The comparator distribution is fixed independently of the sample, but may depend on the data law. The result applies to an arbitrary prior, including continuous parameter laws.
- The proof relies on the posterior mean's reduction in squared loss. It does not establish the same fast guarantee for a random posterior draw or a fast high-probability oracle inequality. These limits are stated accurately.
- The architecture masses normalize, and truncation only increases the mass of every allowed architecture. The perturbation estimate `K = L A^L` is valid for a globally Lipschitz activation even when its value at zero is nonzero. Taking a logarithm of this sensitivity is what produces polynomial depth dependence in the KL bound.
- Both the Cauchy neighborhood mass calculation and the Gaussian scale-mixture variant give the stated penalties. The fixed-depth rates and the special linear-in-width parameter count for one hidden layer follow.
- A mixture over actual depths is not an embedding into a fixed deepest tanh architecture. The manuscript explicitly makes that distinction.

## Raw-output appendix

The following checks include the late-added one-hidden-layer tuning.

- The deterministic output bound `|z_w| ≤ sqrt(Q_N(w))` is valid because the last hidden layer has bounded tanh activations. It gives the required square-loss range on each energy ball, despite unbounded raw predictions over the full parameter space.
- The energy-ball class is symmetric under readout sign reversal, so the absolute-supremum Rademacher convention in the cited theorem agrees with the convention in the elementary capacity lemma.
- The shell estimate and all four absorption terms are correct. The deep calibration leaves enough of the energy penalty to pay the deviations. Its residual `q_n/λ_n` is no slower than `n^(−1/H)` for `H ≥ 2`.
- For `H = 1`, the shell terms split into `C_0(a_n + 2 sqrt(2q_n)) sqrt(k)` and `C_0(a_n² + 8q_n) k`. The stated calibration and Young inequality give the displayed remainder.
- The energy-cap tuning is valid. Writing `x = sqrt(V_n/(E_0+1))` and `λ_n = max{x,v_n}`, one has `λ_n ≤ x+v_n` and `V_n/λ_n ≤ V_n/x`. Thus `λ_n E + V_n/λ_n ≤ 2 sqrt(V_n(E_0+1)) + v_n E`. The resulting rate is `O-tilde(sqrt((E_0+1)/n) + E_0/n)`. With `E_0 = O(n^(4α))` and population-optimal teacher risk at most one, all terms vanish for `0 ≤ α < 1/4`, with leading power `n^(2α−1/2)`.

Two refinements were sent to the authoring agent:

1. The appendix uses a new, more conservative calibration of `λ`. Its opening should identify the same model and likelihood family **with the appendix's calibration**, rather than imply that the main theorem's exact calibration automatically controls raw risk.
2. The unbounded-risk posterior limit needs a weighted Laplace estimate. The argument is valid, but the reference to such an estimate already being displayed in the main section is inaccurate. For `F = Q_N + λ^(−1) Rhat` and `β > β_0`, explicitly write
   `∫_{F ≥ f_*+ε} (1+Q_N)e^(−βF) ≤ e^(−(β−β_0)(f_*+ε)) ∫(1+Q_N)e^(−β_0F)`.
   The last integral is finite, and division by the same positive-neighborhood normalizer bound proves the required tail decay. This makes the uniform-integrability step self-contained.

The appendix states that `C_0 = 10^5` suffices in the external smooth-loss theorem. I did not independently inspect that external source during this standalone review. That numerical constant should be retained only if checked against the cited theorem/proof; alternatively, an unspecified sufficiently large universal `C_0` preserves every rate and all schedules stated in terms of `C_0`.

## Presentation and scope

The nearby-input obstruction is valid, including its uniformity over samples. It is appropriately restricted to the stated fixed-prior Bayesian rule; it is not an impossibility theorem for every learning algorithm. Clipping the constructed teacher, if needed, preserves its exact fit on the two support points.

The initial abstract's wording “inputs are continuous” was potentially misleading because atomic input distributions are allowed; the authoring agent reports replacing this with a continuous-domain formulation. “At least the teacher width” is more precise than “above the teacher width.” A pointer from the main section's clipping caveat to the raw-output appendix would help readers find the stronger prediction-convention result.

The author order was left unchanged. The statements that the work is not Lean-formalized, not externally peer reviewed, and does not supply an efficient learning algorithm accurately limit the scope of the claims.
