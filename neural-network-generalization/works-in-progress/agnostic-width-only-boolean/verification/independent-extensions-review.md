# Independent review: smooth output and soft-prior extensions

The exact extensions.tex source passes independent mathematical review on 18 November 2026. This is not a Lean verification.

The final-tanh variant correctly truncates the raw comparator at logarithmic amplitude, compiles its rescaled clipped form, and rescales only the readout. Its output error, path and precision costs, prior symmetry, contraction properties, pseudodimension, and small-width representation all check. The soft-prior variant matches the independently audited full-support gain-penalized Gaussian prior, endpoint normalization, path oracle, and width split. The displayed accuracy and dimension/width factors cover both branches.

The learning.tex hash is refreshed for two presentation-only changes: referring to the compiler applied to g (whose output approximates s(g)), and splitting a long resource display. No theorem changed.
