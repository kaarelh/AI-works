# Final nine-source integration review
The earlier eight-source review remains applicable. The new expectation module reproduces the independently audited arbitrary-prior, conditional-sub-Gaussian all-data leave-one-out theorem, omitting only the irrelevant logarithmic-comparison corollary.

For smooth bounded activations, the existing direct averaged-risk comparison with precision r and KL K r^(-q) gives the sharp expected remainder (sK/(n+1))^(1/(q+1)). For the bounded-Lipschitz extension, the L2 comparison gives approximation increase 2 sqrt(A_g r)+r. Optimizing against u r^(-q) yields A_g^(q/(2q+1)) u^(1/(2q+1)) + u^(1/(q+1)), exactly as stated. The two-regime choice of r is valid; bounded excess risk handles u>1. Taking an infimum over deterministic comparators in expectation requires no confidence union.

The revised prose correctly distinguishes fixed-temperature sharp expectation, fixed-temperature near-sharp high probability, and calibrated bounded-label sharp high probability. All nine sources pass.

This is an independent mathematical source review, not a Lean verification.
