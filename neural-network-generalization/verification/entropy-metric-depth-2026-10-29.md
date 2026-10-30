# Quartic all-scale and multilevel depth bounds, 29 October 2026

The new [paper](../works-in-progress/entropy-metric-compression/paper.pdf) proves, under the unchanged internal-noise restriction on the Gaussian tanh prior:

| Scale range | Sufficient samples, up to logarithms |
|---|---|
| Every `0<t≤1`, hence every `γ≥1` | `C⁴L¹¹` |
| Every `t²≤N⁻¹ᐟ⁷`, hence every `γ≥8/7` | `C⁴L⁹` |
| Every `t²≤N⁻¹`, hence every `γ≥2`, or the strong-prior limit at each fixed width | `min{C⁴L⁷,C⁹ᐟ²L⁶}` |

All finite-scale statements have one sample event common to every eligible learner width `N≥C` and scale. The teacher is a layered Boolean circuit of width `C≥2` and `L−1` gate stages, counting a reserved constant wire at every stage and any compilation overhead. Shallower teachers may be padded; the learner's actual depth enters the bound. The input dimension, robustness calibration, accuracy and confidence are fixed in this table. Training and test inputs have any common iid law.

The posterior conditions on the stated robustness support and all signed training outputs being strictly greater than `1/2`. Its risk is posterior-average test failure at margin `1/4`. Rescaling the tolerance gives strict `>2/3` posterior confidence outside the allowed test mass. The optional initial condition is the label-independent absolute margin `|z(x)|>1/2`, not agreement with unknown labels at unobserved inputs.

## Mathematical contributions and checks

The new source files are [entropy-metric.tex](../works-in-progress/entropy-metric-compression/source/entropy-metric.tex), [scale-interpolation.tex](../works-in-progress/entropy-metric-compression/source/scale-interpolation.tex), and [multilevel-code.tex](../works-in-progress/entropy-metric-compression/source/multilevel-code.tex). The manuscript also reproduces the target-cylinder, energy-code, bounded-density, and factor-code arguments used as supporting ingredients. The nontrivial active-direction and canonical reconstruction estimates imported from the earlier all-scale paper are stated explicitly; this publication does not claim a new proof of those imported estimates.

Independent AI-agent mathematical checks covered:

- A single positive semidefinite entropy matrix controlling all Gaussian channel directions, obtained by integrating the Ornstein–Uhlenbeck relative Fisher-information matrix. The audit corrected the factor from rescaling the total Gaussian variance; the resulting variance is at most two.
- Independent-batch regression in that metric, leverage sampling at the actual active rank, exact interpolation when residual variance is zero, and the positive estimate of total variance. An audit corrected the normalization when the actual rank is below its upper bound.
- Metric projection and square-root decoding, finite matrix messages, explicit coefficient clipping and rounding, and the finite arithmetic decoder's parameter count. The comparison functions need not be ordinary neural networks.
- The input-independent law of the entire reconstructed function. Input-specific couplings may recouple the retained active matrix, but disintegration preserves the original full-weight marginal and the outgoing prefix/future marginal. Abort paths remain in the canonical law. Quantization uses the already rounded incoming prefix.
- Propagation of bounded density with the additional entropy-matrix message. This uses the actual conditioning posterior, not a claim about every law controlled only in relative entropy.
- The direct posterior risk bound in the small-information branch and the finite Gaussian scale grid. A factor-two threshold mismatch was corrected before publication. One tagged reference prior gives the simultaneous width/scale event and the minimum of the raw-prior and compression bounds.
- The scale interpolation and its threshold `γ=8/7`. For `F₀=1+log²(2+C)` and `G=log(2+CL)`, the all-scale and intermediate-scale rates retain the common factor `F₀⁴G²`.
- Antithetic multilevel sampling of two consecutive tanh layers, row-adaptive inner sample sizes, weighted storage costs, coefficient truncation and quantization, and fresh conditional sampling at the already constructed virtual states.
- Energy-adaptive spectral cutoffs and the resulting code budget of order `(K+L)³/r³ + (d+1)(K+L)²/r²`, apart from the stated logarithms. The target-cylinder substitution gives `C⁹ᐟ²L⁶`; the width exponent is **not** four on this branch.
- Final headline statements, common sample-event quantifiers, optional global-margin extension, and the strong-prior statement at each fixed width.

The all-scale exponent improves the preceding `C⁵L¹²` result. The stronger-scale improvement is a tradeoff: `C⁹ᐟ²L⁶` is smaller than `C⁴L⁷` at the level of powers when `C<L²`. It does not resolve a lower depth exponent with uniform quartic width. No optimality, efficient posterior sampling, or typicality for trained networks is asserted.

## Formalization and reproducibility

These are conventional proofs with AI-agent review, not human peer review or Lean certification. No Lean file or existing PDF is changed. Earlier formalized guarantees retain exactly their previous coverage. A documentation pointer in the preceding sequential-quantization paper's README identifies the later improvement; that paper's mathematical source and PDF remain unchanged.

The [machine-readable check record](entropy-metric-depth-2026-10-29.json) records source/PDF hashes, the source build and isolated rebuild, matching extracted PDF text, final LaTeX warnings, collection links, and preservation of earlier mathematical files. The collection now contains 69 canonical manuscripts. The older verification records remain historical snapshots.
