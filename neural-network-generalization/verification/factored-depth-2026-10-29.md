# Bounded-density and factor-coding depth improvement, 29 October 2026

The revised [sequential-quantization paper](../works-in-progress/sequential-robust-quantization/paper.pdf) proves the unchanged-support sample bound

$$
O\!\left(C^5L^{12}[1+\log^2(2+C)]^5\log(2+CL)\right)
$$

at fixed input dimension, robustness calibration, accuracy and confidence. It holds at every learner width `N≥C` and every positive scale `0<t≤1`, including all `γ≥1`, under any common iid input distribution. The teacher convention is layered Boolean width `C≥2`, including a reserved constant wire at every stage, and `L−1` hidden layers. The bound controls posterior-average margin failure, and hence strict `>2/3` confidence after rescaling the error tolerance.

The stronger-scale quartic bound remains `Õ(C⁴L⁷)`. The new argument improves the former all-scale `Õ(C⁶L¹⁷)` result; it does not improve that separate quartic exponent. No prior restriction is added. Global clean-output-margin conditioning remains optional and label-independent.

## New proof ingredients

The [new appendix](../works-in-progress/sequential-robust-quantization/source/factor-code.tex) contains the exact budgets, theorem, and proofs of both new ingredients:

1. **Bounded-density propagation.** The retained exact posterior obeys `Q≤exp(NK/t²)μ`. A finite message increases the density bound by at most its log alphabet size. If the joint density of prefix/current/future blocks is bounded, the current block's conditional entropy is bounded outside a set of probability `η` by the same budget plus `log(1/η)`. This replaces the earlier `1/η` rank penalty. The resulting dense-code bound is `Õ(C⁶L¹⁵)`.
2. **Factored Gaussian reconstruction.** A shared Gaussian sketch, together with independent Gaussian row factors, approximates the residual Gaussian field at each fixed input. The candidate law is independent of that input. The active term and sketched Gaussian term together have rank at most `q+p`, so the code stores `O(Lm(q+p))` coefficients instead of `O(Lm²)`. Sequential factor rounding preserves the disturbance interpretation.

The exact posterior density hypothesis is essential. The new active-rank estimate is not asserted for every law having only a Gaussian relative-entropy bound. The manuscript explicitly states the active-direction and whitened-sampling estimates imported from the earlier all-scale paper; those estimates are not new proofs in this revision.

## Mathematical reviews

Separate AI-agent derivations and adversarial checks verified:

- Conditional density disintegration, the probability of the low marginal-density event, and finite-message domination under the same reconstruction kernel.
- Probability reference measures, a kernel defined also on reference-only messages, and an input-independent virtual prefix. Fresh-reader review corrected the density lemma to state explicitly that the prefix reference is a probability measure.
- Keeping every abort path in the canonical law, rather than conditioning intermediate laws on success.
- The shared-sketch chi-square variance calculation and the Gaussian evaluation coupling, including its full coefficient marginals and zero-variance case.
- Active-row and Gaussian-row clipping, sketch failure, bilinear factor rounding, disturbance norms, and the absence of a new activation layer.
- Sampling with replacement even when the reconstruction width exceeds the original width. The dense fallback cutoff only needs to cover message overhead.
- Factor counts, the separate dense fallback, width/scale-independent sample events, posterior tails, and confidence conversion.
- The log-retaining `C⁵L¹²` rate and the full-parameter `O(S³² log S)`, hence `O(S³³)`, envelope. Here `S=2+d+L+C+c+c⁻¹+ε⁻¹+log(1/δ)`.

Additional exploration checked layerwise allocations, readout-tail shortcuts, sparse and low-rank stage approximation, and stochastic coding for the quartic theorem. Those checks did not establish a better quartic depth exponent. In particular, the support permits simple targets represented by networks whose readout energy grows linearly with depth. This rules out a uniform support-only readout cutoff, not a sharper posterior theorem or a better learning bound.

These are conventional mathematical proofs and AI-agent reviews, not human peer review. No claim of typicality for trained networks, optimal sample exponents, or efficient posterior inference is made.

## Formalization and publication checks

No Lean source is changed and no new Lean coverage is claimed. The existing degree-46 formalized bound remains intact; the degree-33 envelope and fifth-power width rate are new conventional consequences.

The [build/hash companion](factored-depth-2026-10-29.json) records the revised source and PDF hashes, clean and isolated rebuilds, matching extracted PDF text, and FAQ/link checks. The collection retains 68 canonical manuscripts: this is a revision of one paper, not an additional paper. The [preceding publication record](depth-improvements-2026-10-29.md) remains a historical snapshot of the earlier source and PDF.
