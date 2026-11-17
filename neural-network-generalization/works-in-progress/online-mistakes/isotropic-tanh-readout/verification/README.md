# Verification record

An additional readout-variance divisor `A_N` tending to infinity gives ordinary tanh networks exponential online mistakes at every sufficiently large learner width `N`, together with a polynomial IID guarantee. This manuscript is mathematically reviewed but **not Lean formalized**.

The prior uses first-layer variance `τ² N^(1−γ)/d` and readout variance `τ² N^(−γ−1)/A_N`, where `d` is input dimension, `γ` is the prior exponent, and `τ` is the positive prefactor.

The review covers the statements as well as the proof steps:

- The exact scalar-optimality dual argument and its explicit penalty bound, including the rational KKT bound for Boolean data.
- The full affine calibration calculation and the correct-next-label energy gap.
- The fixed ordinary-tanh model, unchanged first-coordinate isotropy, and the explicit additional readout divisor A_N.
- The Gaussian-ball and chi-square comparison for every diverging A_N, every fixed γ ≥ 1, and every fixed τ > 0.
- The bounded-weight Fourier teacher construction and the same-prior IID guarantee with the >2/3 confidence convention.
- The distinction between sufficiently large width and every realizable width, and the reference case `A_N = 1`, which this argument does not resolve.

Independent reviews are recorded in [independent-review.md](independent-review.md) and [numerics-review.md](numerics-review.md). Despite the second review's filename, its conclusions concern the mathematical proofs; the main result does not depend on numerical optimization.

The [publication build manifest](publication-build.json) records source and PDF checksums. The build uses three `pdflatex` passes. An isolated rebuild is compared with the published PDF's extracted text, and representative pages are checked visually. These build checks do not substitute for mathematical verification.
