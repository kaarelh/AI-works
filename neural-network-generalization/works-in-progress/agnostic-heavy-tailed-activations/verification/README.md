# Verification record

This manuscript is a conventional mathematical proof, not a Lean formalization.

The independent audit covers the scalar tail estimates, fractional moments of native path bounds, selected-node first and second moments, conditional comparison law, disjoint embedding supports and entropy cancellation, refined teacher-width/coefficient polynomials, and uniform function-neighborhood mass.

The statistical audit covers the ordinary final-posterior oracle under conditional sub-Gaussian noise, the L2-only approximation argument that gives the same rate for every Lipschitz activation, optional smoothness refinement in the approximation factor, and the calibrated coefficient-one bounded-label theorem. It also checks the proof-only simultaneous comparator allocation, online sign-mistake bounds, and raw-mean obstruction.

The main model has one fixed independent-coordinate prior and a fixed Gaussian likelihood variance. Adaptive cutoffs and embedding mixtures are used only in the comparison proof. Outputs are bounded by the link inside the likelihood. The online randomized-prediction conclusion assumes queries are chosen before each prediction's fresh randomness.

Exact source hashes identify the reviewed snapshot. The PDF is built from eight TeX files in source/ with three clean pdflatex passes. Build logs and source/PDF checksums are retained. The final build has no warnings or overfull boxes.

The added sharp expectation module proves an arbitrary-prior KL oracle for the ordinary final posterior mean trained on all observations, including conditional sub-Gaussian noise. Its expectation scope is separate from the high-probability results. The Student comparison law gives the stated sharp expected-risk corollaries.
