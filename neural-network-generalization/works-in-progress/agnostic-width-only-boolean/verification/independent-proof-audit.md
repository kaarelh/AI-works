# Independent review: Boolean-domain arbitrary-coefficient compiler

The exact compiler.tex and constant-depth.tex sources pass independent mathematical review on 18 November 2026. This is not a Lean verification.

Checked in detail: full-rank feasible-polyhedron vertex extraction; integer threshold and bounded-RHS rational Cramer bounds; affine clipping accuracy; bounded-fan-in arithmetic and readout coefficients; lifting preactivations to independent path coefficients multiplying Boolean conjunction features; exact recursive activation decisions; the explicitly imported unweighted-majority TC^0 iterated-multiplication theorem; the product identity reducing addition to multiplication; majority-gate ReLU implementation; and all depth, width and path-resource estimates.

The compilation does not assume bounded precision for the original real network weights. Independent lifted path coefficients need not factor into those weights. Its nonuniform, existential scope and potentially exponential construction time are stated correctly. The constant-depth theorem achieves H_* <= b(h+1), width <= (K+t+2)^b, and path variation <= (K+t+2)^{b(h+1)}, with K=4(d+1)(C+1)^h and t logarithmic in inverse approximation accuracy. No gap found.
