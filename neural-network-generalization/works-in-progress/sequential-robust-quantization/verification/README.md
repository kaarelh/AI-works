# Review and verification scope

The [paper](../paper.pdf) improves depth dependence under the unchanged calibrated internal-noise support. Both the quartic stronger-scale theorem and the sextic all-scales extension have conventional proofs; neither improvement is Lean formalized.

The main proof includes the Gaussian target cylinder, deterministic sampled compressor, posterior total-energy tail and sample bound. The all-scales appendix imports specified active-direction and bounded-prefix reconstruction estimates from the [earlier paper](../../improved-polynomials/original-support-all-scales/), then proves the modification. It explicitly distinguishes imported estimates from the new quantization argument.

Independent AI-agent reviews checked:

- Rounding during the virtual pass preserves independence from the next fresh source list. Conditional Bernstein estimates therefore remain valid for the rounded prefix.
- The sampled unrounded coefficients retain their energy expectation; the energy event and successful approximation event need not be independent to intersect.
- Every quantization discrepancy is included in a disturbance of the original network. No robustness of a compressed network is assumed.
- Deterministic prefix rounding adds no future-entropy message in the all-scales construction. Its stochastic-kernel, bounded-prefix, transport-coupling and coefficient hypotheses still match the imported estimates.
- The all-scales hidden injection bound `41e`, exceptional probability below `0.686α`, and successful total disturbance below `r/2`, including the small-width branch.
- Finite grid counts, fixed sample events uniform in width/scale, posterior-tail normalizers, and the ramp-risk conversion.
- The new `L⁷` and `L¹⁷` exponents, the depth-independent target gain obtained by multiplying bulk probabilities, and the conventional degree-45 envelope.
- The complete integrated manuscript, read independently of the preceding research conversation.

The stronger-scale theorem applies to sufficiently small positive scales at each fixed width and to all finite `t≤N^−1/2` (`γ≥2`). The all-scales theorem applies to every positive `t≤1` (`γ≥1`). The confidence conclusion follows by rescaling the posterior-average margin-error tolerance. Arbitrary posterior weak limits at an exact closed margin boundary are not silently inferred from a bound at positive scale.

The original support and target class are preserved. Boolean width counts a reserved constant wire at every stage and uses `C≥2`. The improvements do not establish a quartic rate at mean field, a quadratic rate for this support, or optimal depth powers. No optional martingale-based logarithm improvement is claimed.

The [collection publication record](../../../verification/depth-improvements-2026-10-29.md) and [build/hash record](../../../verification/depth-improvements-2026-10-29.json) identify the final sources and independent rebuilds. Existing Lean files and their earlier certified degree-46 result are unchanged.
