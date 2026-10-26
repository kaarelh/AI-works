# Independent audit of the assembled positive nearcritical crossover

26 October 2026.

Source: nearcritical-positive-crossover.tex.
SHA256: 6da0c2ea12a91be699714cfcbe427794ac2af88ad5d5a34170fe441728ec28b0.

Final-source confirmation: `3983ca89775173e5abb80ce0c94876495ac3317188e1118c929bdc8bdb5d8ca1`. The only subsequent change explicitly states that training inputs are iid from the test distribution. This is the hypothesis used in the audited proof and leaves the verdict unchanged.

**Verdict: PASS.** I checked the complete assembly, with particular attention to Section 3's compression of the scalar-channel target-mass proof and the final sample-bound substitution.

The proof retains the actual perpendicular covariance t²R throughout. Holding/growth chooses the full conditional-mean component exactly; there is no discarded component injected into the residual barrier. The invariant barrier requires Delta at least a constant times delta, purification requires p at least a constant times delta, and scalar continuation has bounded t^(2m) amplification because m=O(1/p). All three conditions are included. The scalar Gaussian-reference identity has the correct sign and adds O(delta²) per increasing scalar transition. No high-dimensional Gaussian covariance rescaling is charged as if it were scalar.

Exact-depth holding, the square-root budget, minimum component and score bounds, actual finite-width Gaussian reference, and all-cube concentration remain the same objects as in the audited source note. The finite-width channel acquires the explicit H log t amplification factor. The binary-entropy probability conversion includes its success-probability denominator and the width condition controls the log2/N term.

The occupation bootstrap's critical reference-change identity is correct. Young's inequality yields the linear delta H term, not a quadratic delta²H term. Substitution of the actual target mass gives exp(O(S+delta H)) as stated. The small-width parameter-count argument concerns only realizable widths, which is explicitly required.

The resource S depends on the Fourier absolute sum AF(f). The manuscript correctly states the polynomial conclusion for polynomial Fourier variation and does not infer that hypothesis from arbitrary small deep tanh or Boolean circuits. The prior keeps the original width powers, but t>1 lies above the canonical prefactor range; this is a positive crossover theorem, not a resolution of the unrestricted canonical depth problem.

Imported results are explicitly identified. This audit verifies the assembled mathematical chain and its compatibility with those imported statements; it is not a Lean formalization.

