# Ordinary-tanh support ingredients: exact Lean coverage

Checked with Lean 4.32.0 and the repository's pinned mathlib revision on 2026-11-08.

The following modules build without `sorry` or added axioms:

- `OnlineLowerTanhAlgebra.lean`: quantitative midpoint concavity, characterized by nonnegative square roots and their polynomial equations.
- `OnlineLowerTanhSupport.lean`: actual square-root midpoint gap; fourth-moment slice estimate; finite weighted square-root Jensen; weighted bias-transfer gap; support bound with coefficient `max 2 (288*w^2)`.
- `OnlineLowerTanhParity.lean`: actual normalized full-parity coefficient of `Real.tanh` on `ConcreteModel.Cube`; bias symmetry for odd degree; exact transfer of an affine bias into one incoming coordinate; the corresponding intrinsic-bound-to-square-root-mean implication.
- `OnlineLowerTanhMoments.lean`: actual cube-coordinate splitting, exact second and fourth moments of an affine Rademacher sum, and the factor-three fourth-moment estimate.

`CheckOnlineLowerTanh.lean` checks the endpoint dependency axioms. Its output contains only `propext`, `Classical.choice`, and `Quot.sound`.

The definition `IntrinsicParityBound n w` is a proposition about the actual tanh coefficient. It is an explicit hypothesis of `intrinsic_bound_biasTransfer`; its eventual validity at optimized balanced weights is **not** proved by these modules. No axiom supplies it. The finite weighted support theorem likewise explicitly requires the square-root transfer inequality and the one-coordinate coefficient bound. The concrete second/fourth moments and bias-transfer identity are proved, but the complete affine support theorem is not yet assembled into one endpoint.

In particular, these files do not constitute a Lean formalization of the sharp eventual intrinsic-parity theorem, code localization/absorption, the full tanh online theorem, or its resource exponent. Those analytic and global dependencies remain separate work.
