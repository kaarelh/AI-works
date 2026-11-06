# Verification record

This manuscript is mathematically reviewed but **not Lean formalized**.

The review covers the statements as well as the proof steps:

- The exact scalar-optimality dual argument and its explicit penalty bound, including the rational KKT bound for Boolean data.
- The full affine calibration calculation and the correct-next-label energy gap.
- The fixed ordinary-tanh model, unchanged first-coordinate isotropy, and the explicit additional readout divisor A_N.
- The Gaussian-ball and chi-square comparison for every diverging A_N, every fixed γ ≥ 1, and every fixed τ > 0.
- The bounded-weight Fourier teacher construction and the same-prior IID guarantee with the >2/3 confidence convention.
- The distinction between sufficiently large width and every realizable width, and the unresolved reference case A_N = 1.

Independent reviews are recorded in [independent-review.md](independent-review.md) and [numerics-review.md](numerics-review.md). Despite the second review's filename, its conclusions concern the mathematical proofs; the main result does not depend on numerical optimization.

The [publication build manifest](publication-build.json) records source and PDF checksums. The build uses three `pdflatex` passes. An isolated rebuild is compared with the published PDF's extracted text, and representative pages are checked visually. These build checks do not substitute for mathematical verification.
