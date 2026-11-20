# Verification inventory

All new manuscripts are solely authored by **ChatGPT-6 Astra** and have **not received independent mathematical review**. A successful script below verifies its stated finite task, not every theorem in the associated paper.

## Lean: selected deterministic statements

The five files in [lean](../lean) contain 53 theorems:

- [IndependentReluStability.lean](../lean/IndependentReluStability.lean) proves the actual affine-ReLU direction projection, its uniform-cube feature error, and a finite-network weighted projection bound. It imports the sharp minimum-coordinate inequality from the existing repository formalization.
- [IndependentRawFeatureObstruction.lean](../lean/IndependentRawFeatureObstruction.lean) proves an actual six-bit source representation, the raw four-bit target obstruction, and the exact optimal squared error 64/65, and impossibility of perfect affine-readout classification under either fixed tie rule, using kernel-checked finite integer identities.
- [IndependentInitialization.lean](../lean/IndependentInitialization.lean) proves the exact mixed-lattice sine gap and the odd-lattice resonant witness identities. The kernel integral and asymptotic results remain conventional.
- [IndependentLowRankTransfer.lean](../lean/IndependentLowRankTransfer.lean) proves the exact projection-error identity, its squared-error and coefficient-norm bounds, the rank/trace relation, existence of the orthogonal kernel projection, and the resulting existential coefficient lemma used in raw transfer.
- [IndependentTransfer.lean](../lean/IndependentTransfer.lean) proves the square-objective identity, weighted error and bounded-modulation estimates, finite orthogonal-target capacity, exact and perturbed annihilator obstructions, and the ridge coefficient budget.

The [axiom-audit log](../results/independent_transfer_lean.log) and [machine-readable record](../results/independent_lean_verification.json) record successful checks with only Lean's standard `propext`, `Classical.choice`, and `Quot.sound` dependencies. No result from these new papers is inserted as an axiom or admitted proof.

With the repository Lean project and its dependencies built, run from this collection:

```sh
python tools/check_independent_lean.py --lean-project ../../lean --lean /path/to/the/repository/lean
```

The posterior-conditioning arguments, the exact Fourier coefficient-ratio identities, the integral estimates, the asymptotic theorems, and the full main statements are **not** thereby formalized.

## Exact arithmetic and interval certificates

Install `requirements-checks.txt`, then run from this collection:

```sh
python baseline-copy/d4/verify_d4_foundations.py
python experiments/verify_observed_margin_certificates.py
python experiments/check_fivebit_enumeration.py
python experiments/check_fivebit_certificates.py
python experiments/verify_orientation_patterns.py
python experiments/verify_feature_transfer.py
python experiments/verify_standard_softplus_critical_mean.py
```

- The inherited foundation checker verifies completeness of the 1,882 four-bit activation chambers. Its source and provenance are archived unchanged in [baseline-copy/d4](../baseline-copy/d4).
- The observed-margin checker verifies all fifteen new strict energy gaps using integers and rational numbers. Numerical optimizer tolerances are not used in the conclusion. See [the exact verification record](../results/observed_margin_exact_verification.json).
- The five-bit checkers independently reconstruct all 94,572 affine activation chambers using exact rational separation/Farkas certificates and verify 17 additional strict mistake gaps. See [the verification record](../results/fivebit_certificates/independent_verification.json).
- The orientation checker independently counts and validates 807,980 balanced patterns. This reproduces a known combinatorial count; it is not claimed as a new enumeration result. See [the record](../results/orientation_exact_verification.json).
- The feature-transfer checker contains exact coefficient and blind-feature checks, with separately labeled floating-point matrix diagnostics.
- The softplus check uses outward-rounded interval arithmetic for the stated upper certificate on the critical mean. It is a numerical interval certificate, not a Lean proof. See [the certificate](../results/standard_softplus_critical_mean_certificate.json).

## Second-round finite and high-precision checks

```sh
python experiments/verify_polynomial_transfer.py
python experiments/verify_power_and_readout_bounds.py
python experiments/verify_continuous_initialization.py
python experiments/check_log_smoothing_asymptotic.py
python experiments/check_codimension_smoothing.py
python experiments/check_raw_feature_obstruction.py
python experiments/check_orientation_raw_transfer.py
python experiments/check_path_norm_refinement.py
python experiments/check_low_rank_transfer.py
python experiments/exact_lattice_kernel.py
python experiments/exact_lattice_bias.py
python experiments/exact_lattice_midpoint.py
python experiments/check_scalar_condensation.py
python experiments/check_independent_posterior_identities.py
python experiments/check_critical_tail_density.py
```

The first script includes exact rational Fourier coefficients and coefficient-ratio bounds, plus floating-point perturbed-network checks. The second directly checks the power-cost transfer bounds, square-objective identity, and sequential ridge identity on finite examples. The remaining scripts compare independent positive-integral, Hamming-level, and Hermite-witness formulas at high precision and record their finite-dimensional approach to the asserted asymptotics.

The low-rank script checks 24 rational matrix cases exactly and 18 actual ReLU feature maps in floating point, including the sharp obstruction formula. The lattice scripts evaluate exact rational population kernels through dimension 8,192 and biased kernels through 2,048; displayed asymptotic constants use non-interval arithmetic.

The path-norm refinement script checks 135 perturbed actual networks and 270 transfer bounds under the narrower continuous bias prior. These are floating-point checks.

The independent-posterior checker verifies 12 rational matrix cases and 1,344 exact local ReLU output identities. These finite checks do not certify the asymptotic sampling theorem.

The scalar-conditioning checker verifies five symbolic identities and 84 exact integer evaluations of critical-ridge classification error. The local-density script performs full-support importance Monte Carlo of the actual four-bit ReLU coefficient, with three seeds at each tested tail level. Its standard errors are empirical diagnostics, not certified coverage.

The raw-feature obstruction script checks its annihilating functional, exact population-risk formula, kernel block, and source representation using integer sums through dimension 12. The orientation script exhausts all 807,980 six-bit balanced patterns, with floating-point least-squares projections and numerically estimated covariance weights. These finite calculations do not prove the large-dimension orientation concentration theorem.

High-precision quadrature is **not interval certified**. Monte Carlo rows are estimates, not probability guarantees or proof certificates. In particular, the asymptotic ratios can converge slowly at the displayed dimensions.

## Longer numerical campaigns

See the [numerical diagnostics report](numerical-diagnostics.md) for completed versus planned jobs and the interruptions. The new full-label posterior construction has no end-to-end numerical implementation; its finite checks cover algebra only.

The sources `parity_relu_cold_transfer.cpp` and `parity_fourier_mitm.cpp` implement the second-round posterior and initialization diagnostics. Compile either with a C++17 compiler. Their Python campaign scripts record seeds, dimensions, sample counts, and wall-clock limits. The first uses coordinate, gauge, and uniform-pair rotation moves; it has no mixing certificate. The second evaluates finite-cube ReLU Fourier coefficients by a meet-in-the-middle sum, in floating-point arithmetic, before averaging over random initializations.

`analyze_cold_transfer.py` recomputes stored posterior observables and fits fresh Gaussian readouts. Its readout formula is exact linear algebra conditional on a sampled feature map; it does not certify that the feature map is a well-mixed posterior draw. Large raw chains are not mathematical evidence for any of the conventional posterior limit proofs.

`scalar_posterior_independent.py` implements the scalar-conditioned independent construction at dimension four. Its finite-width importance diagnostics cover the prescribed largest-neuron cones, so its reported weight discrepancy is not a full-posterior total-variation certificate. The total-variation limit is proved conventionally in the manuscript, without a numerical finite-width rate.

## Publication checks

Each paper's `verification` directory contains source hashes and fresh build logs. The collection publication records include PDF hashes, isolated rebuild comparisons, and rendered layout checks. Those checks concern reproducibility and presentation, not independent proof review.
