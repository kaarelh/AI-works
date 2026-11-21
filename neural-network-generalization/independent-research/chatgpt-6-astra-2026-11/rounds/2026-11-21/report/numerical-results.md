# Numerical diagnostics for the 21 November round

These records support debugging and finite-scale interpretation of conventional proofs. They are not independent proof review, interval enclosures, or certified full-posterior total-variation estimates.

## ReLU independent proposals

The completed six-dimensional campaign has 42 runs across widths and square/logistic losses. The two longer runs use width 16,777,216. Their diagnostic is one half of the empirical mean absolute normalized importance-weight deviation on the implemented restricted proposal support.

| Loss | Status | Raw proposals | Retained | Importance ESS | Discrepancy | sqrt(N) × discrepancy | Gaussian limiting coefficient |
|---|---|---:|---:|---:|---:|---:|---:|
| square | time_limit | 4,504 | 578 | 577.727 | 0.00858308 | 35.1563 | 35.0048 |
| logistic | time_limit | 4,511 | 2,020 | 2019.38 | 0.00703227 | 28.8042 | 28.6458 |

The [rolling uncertainty snapshot](live_validation.json) reports empirical bootstrap intervals. These quantify resampling variation in stored weights, conditional on the proposal and estimated inputs; they do not cover omitted posterior sectors or asymptotic bias. The Gaussian limiting coefficients themselves use separately estimated critical moments.

The empirical Metropolis report constructs the exact finite-state independence transition on stored proposal atoms, checks stationarity, and evaluates successive corrections. It is not an exact simulation of the continuous neural posterior.

## Softplus independent proposals

The activation inverse temperature is one, the source dimension is six, and the likelihood is square loss. Every width uses its own fixed pilot. The largest job is allowed to stop at the recorded deadline; a partial run is retained as such.

| Width | Status | Raw proposals | Retained | Importance ESS | Discrepancy | N^(1/4) × discrepancy |
|---:|---|---:|---:|---:|---:|---:|
| 65,536 | complete | 2,000 | 650 | 11.9947 | 0.651087 | 10.4174 |
| 262,144 | complete | 2,000 | 628 | 199.263 | 0.417578 | 9.44872 |
| 1,048,576 | complete | 1,500 | 468 | 172.911 | 0.339585 | 10.8667 |
| 4,194,304 | complete | 1,200 | 403 | 260.632 | 0.24711 | 11.1829 |
| 16,777,216 | deadline_partial | 235 | 75 | 65.0958 | 0.15228 | 9.74593 |

The independently integrated quarter-power limiting coefficient is 10.697809, with conditional Monte Carlo standard error 0.003705. The smallest-width run has very low importance ESS; its apparent agreement with a scaling curve must not be treated as reliable asymptotic evidence.

## Smoothing responses

The signs of the second- and third-order normalizer coefficients are proved analytically. Two independent importance proposals estimate their numerical values:

| Proposal | Samples | A6 (beta^-2) | Empirical SE | J6 (beta^-3) | Empirical SE |
|---|---:|---:|---:|---:|---:|
| critical_normalizer_third_reference.json | 39,321,600 | -0.396972 | 0.000270696 | 0.601061 | 0.0001953 |
| critical_normalizer_third_alternate.json | 39,321,600 | -0.397234 | 0.000340085 | 0.600709 | 0.000269326 |

A paired finite-beta calculation uses 9,830,400 samples and estimates beta^3 × (M_beta − M_ReLU − A6/beta^2). At beta = [8, 32, 128, 512], its values are [0.699423, 0.642856, 0.613287, 0.60457]. The limiting boundary integral is approximately 0.601113. This calculation couples the differences before averaging; it does not subtract unrelated normalizer estimates.

The six-bit covariance analysis includes centering and normalization. Its jackknife errors condition on separately estimated ReLU reference moments. The highest-finite-moment checks cover the third moment in dimension eight and the fourth in dimension ten. Positive Fourier integrals and a separate arc-cosine formula agree for the smoothing second-moment coefficient; high-precision quadrature is not an interval enclosure.

Positive random-feature and tangent-kernel quadratures verify 3,705 degree ratios and 785 normalized upper tails. The tangent-kernel coefficient argument also has 141,167 exact matrix-minor and 78,288 coefficient cross-product checks. These support separate analytic proofs; the quadratures are not interval enclosures. The [normalized spectrum figure](../figures/normalized_spectral_order.pdf) shows dimension twelve.

The softplus/tanh inverse-spectrum checker evaluates 18 softplus cases through dimension 101 and 18 tanh cases through dimension 100 with two positive Gauss-Laguerre meshes and an independent quadrature cross-check in smaller dimensions. Seven rational hinge and seven integer sign interpolation cases are exact; the corresponding softplus and tanh margins are evaluated at 80 digits. The analytic inverse-remainder bound, not this quadrature, establishes the all-dimensional result.

## Actual Gaussian cosine posterior

The exponential-slack proposal integrates the truncated Gaussian posterior using independent proposals with exact weight exp(−sᵀWs/2) ≤ 1. It integrates the next conditional normal coordinate analytically. This is a Gaussian-limit experiment; it does not simulate a finite-width neural posterior.

| Dimension | Prior scale | Histories checked | Largest estimated correct probability | Smallest importance ESS |
|---:|---:|---:|---:|---:|
| 3 | 0.2 | 7 | 2.54358e-12 | 290615 |
| 3 | 0.35 | 7 | 0.063703 | 274159 |
| 3 | 0.5 | 7 | 0.245883 | 258599 |
| 3 | 1 | 7 | 0.441264 | 53213.3 |
| 5 | 0.2 | 31 | 2.54316e-09 | 194392 |
| 5 | 0.3 | 31 | 0.0242002 | 187825 |
| 5 | 0.4 | 31 | 0.163797 | 181408 |
| 7 | 0.2 | 10 | 7.67454e-08 | 486630 |
| 7 | 0.3 | 10 | 0.0332043 | 472447 |
| 9 | 0.3 | 7 | 0.0396201 | 948385 |

All lexicographic stages are checked at dimensions three and five; only the explicitly listed prefixes are checked at dimensions seven and nine. Floating-point zeros at very small probabilities are underflow, not claims of exact zero probability. Corresponding unresolved standard errors are null and flagged in the records.

A separate sequential conditional-normal importance campaign has status **complete** and 168 recorded histories. It explores the stronger conjecture that lexicographic predictions remain wrong at arbitrary fixed prior scale. 144 histories have ESS at least 100; low-ESS rows are explicitly inconclusive. This stronger statement is not claimed as a theorem. The proved fixed-scale theorem permits a mean-selected order.

## Actual width-one cosine posterior

This separate calculation integrates the Gaussian readout analytically and draws independent incoming weights from their prior. The exact history probability reweights those incoming parameters. It therefore samples neither an MCMC chain nor a Gaussian-process approximation. Boundary empirical probabilities and low ESS are explicitly flagged; point estimates are not theorem certificates.

| Dimension | Prior scale | Status | Incoming draws | Histories with ESS ≥ 100 | Wrong-majority point estimates among those histories |
|---:|---:|---|---:|---:|---:|
| 3 | 0.5 | complete | 100,000,000 | 6 | 6 |
| 3 | 1 | complete | 100,000,000 | 7 | 3 |
| 3 | 2 | complete | 100,000,000 | 7 | 2 |
| 5 | 1 | complete | 100,000,000 | 31 | 5 |
| 5 | 2 | complete | 100,000,000 | 31 | 5 |
| 7 | 2 | complete | 100,000,000 | 127 | 4 |

These are finite low-dimensional comparisons. The [five-bit comparison figure](../figures/cosine_width_comparison.pdf) contrasts width one with the Gaussian limit at prior scale one; both integrations have substantial ESS for all 31 histories. The manuscript gives the lifetime polynomial upper bound and the wide-network asymptotic separation analytically.

## Exploratory depth extension

The separate equal-bias-variance Gaussian-kernel recursion was evaluated through depth six in dimensions 2, 3, 4, 6, 8, and 12. Comparing 128- and 256-node quadratures gives 909 heuristically resolved upper-tail increases, 0 candidate decreases, and 135 unresolved comparisons. Mesh agreement is not a certified error bound. The deeper ordering remains a [conjecture](follow-up-directions.md), not a theorem in the paper.

## Degree-ordered kernel interpolation

The separate recursion checker compares 960 exact rational next predictions with 320 exact matrix solves and evaluates 43,682 ReLU random-feature predictions and 87,362 ReLU tangent-kernel predictions at 90 digits through dimension fifteen. The tangent cases include both-layer and pure incoming-gradient kernels; an exact symbolic identity checks adjacent-degree integrand ordering. All recorded recursive predictions also satisfy the proved dimension-uniform gap r/3^(d-1). The [interpolation figure](../figures/kernel_lexicographic_margins.pdf) uses exact output observations and a fixed Gaussian ReLU kernel. These are distinct from the positive-margin Bayesian experiments. Finite positive KKT multipliers are recorded as evidence for an open conjecture, not a proof of margin activity in every dimension.

Exact integer checks cover 1,040 augmented-cube walk cases and 429 monomial Walsh identities for the positive-power criterion. Separate 90-digit calculations check 13,562 wrong predictions in 62 cases of the specified fixed deep ReLU NNGP/NTK recursions; these do not simulate finite deep-network training.

The prefix margin-activity conjecture was also tested on 1,000,000 independently generated increasing spectra in dimensions three through twelve, with no negative multiplier found. This is exploratory floating-point evidence. A separate exact symbolic computation verifies every ordered positive spectrum for every prefix through dimension four: Cramer numerators have nonnegative coefficients in consecutive spectral gaps, with a positive constant-gap term; full and one-missing-vertex sets use exact reciprocal-spectrum identities. An additional all-dimensional proof covers dyadic and two-block prefix families; 15 exact rational checks verify its half-cube-plus-one multiplier formula in dimensions two through six. The general prefix conjecture remains open. A separate exact rational example proves that activity can fail for an arbitrary observed set: spectrum (1,2,16,17), observed vertices {0,1,3,6}, and a negative fourth equality multiplier. Its constrained margin solution has fourth value 143/141, so the prefix restriction is substantive.

## Exact finite checks and partial LP calculations

Control-rail checks enclose actual radical costs by integer square roots, use exact prefix symmetry, and verify all logical frequencies and all 126 stages for k = 2,...,7. Cosine checks give 64 radial matrix identities, 332 finite KKT stages, 465 prefix maximum-principle cases, and 332 separate lexicographic mode stages. Their scope excludes the analytic neural and Gaussian limits.

The independent rational-simplex run with geometric base 2 has 247 recorded rows. Its last finite-case summary is `{"base": 2, "desired_vertex_is_optimal": true, "q": 7, "query": 63, "seconds": 29.000366833992302, "step": 126}`. Full rational primal and dual vectors are in the raw archive. A capped partial enumeration is not described as exhaustive; the all-dimensional Fourier path theorem has a separate inductive proof.
The independent rational-simplex run with geometric base 4 has 406 recorded rows. Its last finite-case summary is `{"base": 4, "desired_vertex_is_optimal": true, "q": 8, "query": 121, "seconds": 528.4607090409845, "step": 158}`. Full rational primal and dual vectors are in the raw archive. A capped partial enumeration is not described as exhaustive; the all-dimensional Fourier path theorem has a separate inductive proof.

## Reproduction and timing

See the [payload README](../README.md), [finite replay record](payload-replays.json), [data provenance](data-provenance.json), and [round timing](round.json). Raw independent-proposal and rational-LP rows are compressed in `../results/raw-diagnostics.tar.gz`; small critical-moment block arrays are retained. Large raw Gaussian-limit arrays are omitted, with their seeded generators and summary inputs preserved. Historical absolute input paths in original result records identify the corresponding basename in the published results directory.

The requested reporting window is measured in wall-clock time from 07:17:32 to 17:17:32 UTC. Concurrent computation times are not added together as elapsed research time.
