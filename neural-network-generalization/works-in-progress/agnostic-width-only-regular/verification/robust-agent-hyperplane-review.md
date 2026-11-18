# Independent mathematical review of the hyperplane compiler

Reviewed on 18 November 2026 by a separate research agent working on the path-prior theorem. This is a conventional mathematical review, not a Lean formalization.

No substantive gap was found in the hyperplane anti-concentration compiler. The review checked:

- The layerwise hyperplane-arrangement count and disjoint full-dimensional activation cells. Identically zero preactivations use a fixed convention, avoiding duplicate sign-pattern cells.
- Removing inequalities strictly satisfied throughout the cube preserves support of each gate there. A gate can be positive only inside its cell, and it is zero on shared facets; at most one gate is positive at every input in the cube.
- Capping the affine output slope changes its saturation only in the stated slab of width 1/B. Constant replacements for extreme offsets are valid.
- The two-ReLU mask is zero at gate value zero, equals the desired output at gate value one, and has absolute value no greater than the gate. Summing the cell masks therefore remains bounded by one.
- The slab union bound, the factor-four squared-loss conversion, and the explicit choices of delta and B.
- The four-hidden-layer implementation, its constant-wire convention, its width count, and the stated first-layer and propagated mixed path budgets.
- The stated sphere examples: alpha=1 in ambient dimension at least three, and alpha=1/2 for the circle.

The final statistical corollary uses the Gaussian oracle and certificate-selection results in the rest of the manuscript. This review independently checked the compiler and its resource substitution, but does not replace the separate audit of those oracle proofs.
