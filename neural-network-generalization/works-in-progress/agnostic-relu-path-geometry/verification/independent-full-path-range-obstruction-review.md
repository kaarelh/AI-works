# Independent full-path range-obstruction audit

18 November 2026 — agnostic_proof_audit. Deterministic mathematical review, not a Bayesian learning lower bound or formal verification.

The exact four-point argument passes.

The weighted-curvature bound RG1 is valid for every shallow ReLU representation: an interior hinge at t=-b/a contributes curvature mass v|a|, whose weighted absolute magnitude is exactly |v|sqrt(a²+b²). Constants and atoms with knots outside the interval contribute no interior curvature; cancellations can only reduce variation. Taking the infimum over representations preserves the lower bound.

The explicit competitor uses two negative hinge atoms and one positive constant atom. Its four prescribed values are exact, and its norm cost is [(r-t_0)+2sqrt(1+t_0²)]/delta=(r+sqrt(3))/delta. Its central plateau is (r-t_0)/delta.

Choose a fixed ell>0 small enough that ell<r and 2sqrt(1+(r-ell)²)>r+sqrt(3). Existence follows from sqrt(7)>3sqrt(3)/2. The reflected triangular hats have disjoint support inside (-1,1), and their sum is pointwise bounded by the curvature weight. Distributional integration by parts gives exactly -2a/delta+a[f(-r+ell)+f(r-ell)]/ell. Taking the negative of this signed integral and bounding the two function values by the supremum gives RG3. Comparison with the explicit competitor produces the positive constant c/delta for every minimum-path-norm interpolant.

The final attainment clarification is sufficient: signed unit-direction ridge evaluation vectors on the four inputs form a compact set, bounded-mass prediction sets are compact, and optimal representations can be reduced to at most four atoms by linear dependence without increasing mass. Thus the example concerns actual global minimum-norm interpolants, not just an inexpensive nonoptimal candidate.

The scope is correctly restricted. The fixed four-point geometry has close pairs and a macroscopic unsampled gap; the argument is a barrier to deterministic range preservation. It does not establish an IID or posterior-risk lower bound, nor does it analyze the regularization levels of the frozen Gaussian learning theorem. No frozen manuscript was changed for this audit.
