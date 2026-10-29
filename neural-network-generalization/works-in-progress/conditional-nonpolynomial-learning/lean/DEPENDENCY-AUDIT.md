# Formal dependency audit

The closed entry point is [conditionalImpossibility](ClosedConditionalImpossibility.lean). Its type is exactly `PPoly ≠ TC1 → ∀ T, ¬ UniversalPolynomialGuarantee T`. The analytic posterior ceiling is proved, rather than assumed as a structure field or axiom.

## Actual objects

The shared `NeuralGeneralization` library supplies finite weight arrays, the augmented Boolean input, neuronwise tanh, the linear readout, finite products of independent Gaussians, strict full-cube margin events, exact training-label conditioning, and normalized posterior probabilities. `realizesAtComplexity` requires an actual width-C teacher with every coefficient bounded by C. The learning statement uses these definitions directly.

The circuit classes use literal finite circuits. NAND circuits define P/poly; polynomial-size logarithmic-depth threshold circuits define nonuniform TC¹. Threshold gates count Boolean inputs, with wires included in the size budget. The polynomial NAND simulation and the inclusion TC¹ ⊆ P/poly are proved. There is no abstract complexity oracle or assumed circuit-class inclusion.

## Analytic connection to the posterior

1. **Conditioning-event lower bound.** The memorizer construction gives an actual finite-width Gaussian mass lower bound. Its width and excess-action estimates are uniform in the full positive interval `0<t≤1`.
2. **Event-to-path extraction.** Conditional Gaussian entropy, finite quadrature, consistent feature repair, and normalized width bounds extract an actual controlled margin path from a sufficiently massive event. The normalization avoids an inverse-t blow-up in the width requirement.
3. **Small-action branch.** Occupation and entropy estimates produce actual canonical features and finite arithmetic programs. Quantized Picard evaluation and a literal output classifier yield a threshold circuit with polynomial size and logarithmic depth.
4. **Far-strong branch.** Actual covariance entropy gives two-ball covers. Normalization and contraction give a short prefix with a polynomial number of labeled representatives. The prefix evaluator and finite-distance classifier are compiled into an actual threshold circuit.
5. **Long nearcritical branch.** Actual Gaussian/non-Gaussian entropy accounting controls blocks of canonical feature maps. Good blocks contract after gain normalization. A cover by genuine input representatives, a bounded normalized Picard program, and the finite-distance classifier give the same circuit resource guarantee. All parameter, quadrature, bit precision, grid, and gate counts are included.
6. **Uniform assembly.** The three regimes exhaust every `0<t≤1`. Constants are chosen before dimension, depth, width, target and sample. The concrete path bound is converted back to at least `5/6` posterior mass on a circuit class independent of the sample, scale and learner width.

These steps culminate in `analyticPosteriorCeiling : AnalyticPosteriorCeiling`; they are not inferred merely from a no-sorry scan.

## Statistical and complexity reduction

Posterior averaging gives a weak circuit predictor for each input law if the putative learning guarantee holds. Finite boosting constructs an exact majority of 400(d+1) voters. The NAND-to-tanh compiler gives polynomially bounded teacher width and depth for every P/poly family. Depth padding, a sufficiently large finite learner width, and polynomial resource accounting then put every such family in TC¹. Together with the proved converse inclusion, this contradicts the explicit separation hypothesis.

The learner width and prescribed prior scale are fixed before varying the input law in the finite reduction. The circuit class does not depend on the sample or input law. Those quantifiers are essential: a separate bound for each depth would not imply the claimed circuit-class collapse.

## Exact verification scope

The central impossibility theorem and its explicit finite counterexample formulation are fully proved. The statement concerns positive finite scales, IID samples and arbitrary common input laws. It does not itself prove the exact zero-temperature limit, an exponential depth lower bound, uniform-input hardness, the auxiliary every-beta ceiling, or the paper's stronger fixed-hard-family corollary. See the [verification record](../verification/README.md) for source hashes, builds and independent audits.
