# Verification record

The final source includes four structural upper bounds: early narrow
cuts, low treewidth, planar/fixed-excluded-minor circuit graphs, and
formulas of bounded Horton–Strahler rank.
All retain the learner-depth padding condition and use the original
globally margined, exact-fit Gaussian posterior.

- [Independent audit of the original structural reductions](depth-sensitive-standard-reductions-independent-audit.md): narrow-cut and treewidth resource accounting.
- [Full assembly audit](structural-boolean-upper-bounds-finite-n-audit.md): heterogeneous Gaussian prefix, analytic transfer, all-width quantifiers, cut and treewidth proofs, and final separator integration.
- [Independent separator audit](geometric-separator-layer-budget-independent-audit.md): weighted boundary balancing, decreasing bag sizes, and on-demand local tables.
- [Formula rank and final assembly audit](strahler-formula-threshold-compiler-independent-audit.md): explicit unary-map composition, suffix parities, layer resources, short-padding quantifiers, rank-one Fourier variation, and the posterior corollaries.
- [Supporting shallow-product audit](rank-two-one-hidden-product-obstruction-finite-n-audit.md): exponential one-hidden-layer product for inner-product parity, with an explicit polynomial-product two-hidden-layer escape. This is not a posterior lower bound.
- [Exact-stage supporting refinement audit](strahler-exact-stage-posterior-refinement-independent-audit.md): one feature stage per formula rank, quantitative cloning at the boundary depth, and the original-posterior bound at every `L≥max{2,r+1}`. This stronger depth condition is in the supporting note; the main PDF was not rebuilt to include it.

The graph separator and balanced-decomposition theorems, Pfaffian/VC
bounds, and uniform intrinsic/scalar-continuation theorems are explicitly
imported. This is mathematical review, not formal verification.

The manuscript builds to ten pages with no undefined references or
overfull boxes. Its first page was visually checked. The build manifest
records the final source and PDF hashes; the checksum inventory covers
the packaged source, PDF, notes, scripts, and audit records. PDF bytes may
change upon rebuilding because TeX includes build timestamps.
