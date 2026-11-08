# Residual and periodic analysis verification

The modules listed here have been checked by Lean 4.32 against the repository's pinned Mathlib. The principal endpoint declarations depend only on `propext`, `Classical.choice`, and `Quot.sound`; no `sorry` or additional axiom occurs in this branch.

## Actual signed residual limit

`OnlineLowerTanhResidualCLT.ResidualSequence.uniform_residual_clt` concerns the literal normalized finite Boolean-cube tanh correlation `parityCorrelation`. The sequence data contain:

- dimensions tending to infinity;
- a fixed finite alphabet of positive odd integers with an explicit integer Bézout identity;
- a positive lower frequency for every alphabet symbol;
- gains in a compact positive interval, converging to a positive limit;
- residual coordinates whose maximum magnitude tends to zero;
- exact orthogonality to the odd-integer label vector;
- bounded residual squared energy with a convergent value.

There is no central-limit, localization, Gaussian approximation, or other analytic conclusion among these hypotheses.

Writing `V = sum q_i^2`, `E = sum d_i^2`, `u_i = A q_i + d_i`, and
`sign = (-1)^(sum ((q_i-1)/2) + floor(n/2))`, the theorem proves, uniformly over all real biases `B`,

`√V |C(u,B) - sign √(2/(πV)) exp(-B²/(2A²V)) T_(A,E)(B+(n mod 2)A)| → 0`.

The response `T_(A,E)` is the explicit sine series with coefficients
`(π/A)/sinh((2l+1)π²/(4A)) * exp(-E ((2l+1)π/(2A))²/2)`.

The proof uses the actual tanh sine transform, exact odd-lattice phase algebra, a quartic log-cosine estimate, explicit finite-alphabet Bézout coercivity, whole-cell dominated convergence, a near-zero bound, and a dimension-sharp exponential tail bound. Uniformity in unbounded `B` follows from a genuine L¹ approximation of each rescaled cell, with the oscillatory multiplier bounded by one.

## Actual second bias derivative

`OnlineLowerTanhResidualBiasSecond.ResidualSequence.uniform_residual_bias_second` proves the analogous uniform limit for `parityBiasSecond`, the literal finite-cube average of `tanhSecond`. The latter is proved to be the classical second derivative of `parityCorrelation` in `OnlineLowerTanhBiasIntegral`.

The leading term is the Gaussian envelope times the periodic second derivative. In the implementation, `smoothedSecondMoment` is the negative of that periodic derivative, so the theorem is expressed as the actual second derivative plus a positive-frequency-square series tending to zero after multiplication by `√V`.

This is precisely the leading curvature needed for the pair-balancing argument. It does not assert that all derivatives of the complete finite-width leading expression have been identified term by term; derivatives of the slowly varying Gaussian factor are omitted in this leading-order endpoint.

## Periodic function identification and bounds

`OnlineLowerTanhResidualBalanced.periodicFourierMaximum_eq_scalarF0` identifies the Fourier-series value at its positive peak with the independent scalar `F₀` from the exact balanced binomial/hyperbolic representation, for every positive gain. The proof compares two proved limits of actual balanced tanh correlations.

`periodicFourierResponse_abs_le_one` proves the global bound `|T_A(B)| ≤ 1` at every positive gain. For gains at most two, the previously checked first-harmonic estimates prove that the value at `B=A` is the absolute maximum and yield quantitative phase stability.

The curvature argument uses a 99-percent near-maximum threshold and an explicit restoring constant `ω² c₀/1000`. This replaces a stronger threshold in the informal elliptic-function route with an elementary Fourier-tail estimate sufficient for the main proof. `OnlineLowerTanhSmoothedCurvature` proves that the same restoring estimate survives Gaussian Fourier damping, arbitrary finite averaging, and individual signs of magnitude at most one.

## Actual outside-sign conditioning and pair restoring

`OnlineLowerTanhExternalAverage` removes the Gaussian envelope after finite outside-sign averaging, provided the outside weighted squared shift is negligible on the bulk variance scale. Both ordinary values and literal second bias derivatives are covered, including arbitrary individual Walsh signs. The proof uses the actual residual theorems and the elementary estimate `1-exp(-x) ≤ x`.

`OnlineLowerTanhPairRestoring.ResidualSequence.eventual_signed_restoring_window` combines these results. Its remaining substantive premise is an actual near-maximal signed rest value at zero, together with the concrete residual-sequence and outside-energy hypotheses. It concludes the existence of fixed positive `δ,c` such that all sufficiently late rest responses have signed normalized second derivative at most `-c` throughout `|B|≤δ`. It includes individual outside signs as well as an optional overall orientation.

This endpoint supplies the analytic premise for strict pair balancing. The global optimizer classification, extraction of suitable residual sequences from arbitrary optimizers, and the final network/posterior theorem are separate modules owned by the integration branch.

## Actual conditioning and exact pair equalization

The analytic mixture interface is now connected to literal physical Boolean
coordinates in `OnlineLowerTanhConditioningMixture.lean`. For a chosen subset,
the mixture consists of the uniform complementary cube, its full parity sign,
and its actual incoming linear form. Its value and second-derivative averages
are exactly the full physical parity coefficient and its actual second bias
derivative. Its shift second moment is exactly the complementary incoming
squared norm, including when the complement is empty.

`OnlineLowerTanhGenericPair.lean` proves the exact two-coordinate difference
identity and the pair-averaging improvement for arbitrary varying physical
dimensions, using the literal finite-set erasure of the two coordinates.
`OnlineLowerTanhActualRestoring.lean` combines these concrete mixtures with the
proved residual CLT. The physical-orientation corollary cancels the residual
phase sign and gives strict negativity of the actual second derivative on a
uniform bias interval.

`ResidualSequence.actual_maximizer_pair_eventually_equal` in
`OnlineLowerTanhActualEqualization.lean` is the resulting optimizer endpoint.
It assumes the actual residual bulk identification, negligible complementary
energy, convergence of two distinct coordinate positions to the same positive
gain, and the actual near-maximal full coefficient. It concludes that the two
incoming values are exactly equal eventually. The proof derives the physical
sign, positivity of the full coefficient, the pair-difference identity,
restoring curvature, and a strictly better pair-averaged incoming vector if
the values differ; actual global maximality rules out that vector.

This endpoint's inputs are concentration/extraction facts about the actual
maximizers, not assumed curvature, assumed CLT behavior, or an assumed
pair-equalization conclusion. The global optimizer branch supplies those
concentration/extraction facts.

The three concrete mixture identities and the optimizer endpoint have been
checked with `#print axioms`; each uses only `propext`, `Classical.choice`, and
`Quot.sound`.

## Exact-bulk quantitative conditioning

`OnlineLowerTanhExactBulkAverage.lean` now proves a finite quantitative bridge
for an exactly constant selected bulk, with either even or odd bulk dimension.
For gains in `[1,2]`, all sufficiently large bulk dimensions `M`, arbitrary
outside incoming coordinates of total squared norm `E`, and arbitrary full
bias `b`, the normalized full correlation differs from the literal signed
outside periodic average by at most

`(2 * balancedGlobalConstant + 1) * (1 + b^2 + E) / M`.

This follows from the proved all-real-bias saddle estimate, retaining its
linear-in-bias error before bounding `|B|` by `1+B^2`, and from the exact outside
second moment. It does not assume a bounded number of outside coordinates or
a bound on each outside bias. In particular, if `E/M` tends to zero, the
periodic-average error tends to zero along the original sequence, without a
new extraction. Both signed and absolute-coefficient sequential versions are
proved, as are the exact average and parity reindexings used by the
odd-lattice phase-absorption theorem.
