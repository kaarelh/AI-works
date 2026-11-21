# Verification inventory

All new manuscripts are solely authored by **ChatGPT-6 Astra** and have **not received independent mathematical review**. A successful script below verifies its stated finite task, not every theorem in the associated paper.

## Lean: selected deterministic statements

The seventeen files in [lean](../lean) contain 120 selected theorems:

- [IndependentReluStability.lean](../lean/IndependentReluStability.lean) proves the actual affine-ReLU direction projection, its uniform-cube feature error, and a finite-network weighted projection bound. It imports the sharp minimum-coordinate inequality from the existing repository formalization.
- [IndependentRawFeatureObstruction.lean](../lean/IndependentRawFeatureObstruction.lean) proves an actual six-bit source representation, the raw four-bit target obstruction, and the exact optimal squared error 64/65, and impossibility of perfect affine-readout classification under either fixed tie rule, using kernel-checked finite integer identities.
- [IndependentInitialization.lean](../lean/IndependentInitialization.lean) proves the exact mixed-lattice sine gap and the odd-lattice resonant witness identities. The kernel integral and asymptotic results remain conventional.
- [IndependentLowRankTransfer.lean](../lean/IndependentLowRankTransfer.lean) proves the exact projection-error identity, its squared-error and coefficient-norm bounds, the rank/trace relation, existence of the orthogonal kernel projection, and the resulting existential coefficient lemma used in raw transfer.
- [IndependentTransfer.lean](../lean/IndependentTransfer.lean) proves the square-objective identity, weighted error and bounded-modulation estimates, finite orthogonal-target capacity, exact and perturbed annihilator obstructions, and the ridge coefficient budget.

The 21 November additions are:

- [IndependentEnsembleTransfer.lean](../lean/IndependentEnsembleTransfer.lean): finite ensemble and antithetic algebra.
- [IndependentMetropolisAlgebra.lean](../lean/IndependentMetropolisAlgebra.lean): deterministic acceptance and correction identities.
- [IndependentCondensateSplitting.lean](../lean/IndependentCondensateSplitting.lean): finite splitting inequalities.
- [IndependentFourierCompletion.lean](../lean/IndependentFourierCompletion.lean): signed-Fourier completion and dual algebra.
- [IndependentSmoothingGeometry.lean](../lean/IndependentSmoothingGeometry.lean): finite smoothing geometry identities.
- [IndependentControlCalibration.lean](../lean/IndependentControlCalibration.lean): control dual, invariant support, missing-character rigidity, and teacher margins.
- [IndependentExactPenalty.lean](../lean/IndependentExactPenalty.lean): exact hinge penalties under explicit dual and uniqueness hypotheses.

- [IndependentCalibrationSparsity.lean](../lean/IndependentCalibrationSparsity.lean): sparsification on an exposed dual face, preserving all observed coordinates and coefficient cost with at most the observation-space dimension in atoms. The neural identification remains an explicit hypothesis.

- [IndependentSpectralOrdering.lean](../lean/IndependentSpectralOrdering.lean): finite Cauchy–Binet identity, preservation and iteration of likelihood-ratio order, tridiagonal and radial adjacent-minor positivity, common coefficient reweighting, and normalized upper-tail comparison. The analytic Fourier and tangent-kernel identification remains outside this file.

- [IndependentGaussianPrecision.lean](../lean/IndependentGaussianPrecision.lean): weighted stationary-mean bounds and the effective precision row-sum inequality. Gaussian integration and concentration remain explicit analytic steps outside this file.

- [IndependentKernelRecursion.lean](../lean/IndependentKernelRecursion.lean): nonpositive and strictly negative next-prefix predictions, plus the uniform relative-gap margin, for the arithmetic/harmonic spectral recursion. The matrix block-identification and random-feature convergence are not formalized in this file.

- [IndependentCubeWalkOrdering.lean](../lean/IndependentCubeWalkOrdering.lean): same-parity ordering of the radial cube-walk recurrence, strictness for every reachable parity class when the augmented dimension is at least three, and consecutive pair-sum ordering. The Walsh identification and infinite power-series argument remain outside this file.

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

See the [numerical diagnostics report](numerical-diagnostics.md) for completed versus planned jobs and the interruptions. That earlier round had no end-to-end full-label implementation. The [21 November payload](../rounds/2026-11-21/README.md) adds independent full-label ReLU and softplus proposals, exact restricted-sector weight formulas, empirical correction diagnostics, and separate critical-moment integrations. These are not finite-width full-posterior TV certificates.

The sources `parity_relu_cold_transfer.cpp` and `parity_fourier_mitm.cpp` implement the second-round posterior and initialization diagnostics. Compile either with a C++17 compiler. Their Python campaign scripts record seeds, dimensions, sample counts, and wall-clock limits. The first uses coordinate, gauge, and uniform-pair rotation moves; it has no mixing certificate. The second evaluates finite-cube ReLU Fourier coefficients by a meet-in-the-middle sum, in floating-point arithmetic, before averaging over random initializations.

`analyze_cold_transfer.py` recomputes stored posterior observables and fits fresh Gaussian readouts. Its readout formula is exact linear algebra conditional on a sampled feature map; it does not certify that the feature map is a well-mixed posterior draw. Large raw chains are not mathematical evidence for any of the conventional posterior limit proofs.

`scalar_posterior_independent.py` implements the scalar-conditioned independent construction at dimension four. Its finite-width importance diagnostics cover the prescribed largest-neuron cones, so its reported weight discrepancy is not a full-posterior total-variation certificate. The total-variation limit is proved conventionally in the manuscript, without a numerical finite-width rate.

## 21 November exact and numerical checks

The [new payload](../rounds/2026-11-21/README.md) gives reproduction commands and a numerical report. Integer-square-root intervals and exact prefix-symmetry transforms check the control construction at every logical frequency and all 126 stages for k=2,...,7. These do not enumerate physical activation chambers. Exact radial cosine-matrix identities cover 64 cases, and rational KKT certificates cover 332 finite stages. The general neural, conditioning, and asymptotic results remain conventional proofs.

The other checks distinguish exact arithmetic, non-interval high-precision evaluations, and floating-point identities. Long independent-proposal campaigns estimate restricted importance-weight discrepancies. Low importance effective sample sizes and finite-width bias are material. Their recorded uncertainty does not certify full-posterior total variation or the asymptotic theorems.

## Publication checks

Each paper's `verification` directory contains source hashes and fresh build logs. The collection publication records include PDF hashes, isolated rebuild comparisons, and rendered layout checks. Those checks concern reproducibility and presentation, not independent proof review.
