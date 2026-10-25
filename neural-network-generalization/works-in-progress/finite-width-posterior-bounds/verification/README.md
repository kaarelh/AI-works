# Verification record

This package is conventionally checked mathematics, not a Lean formalization.

- [Independent full-manuscript audit](finite-width-posterior-assembly-independent-audit.md): checks the actual-posterior upper, multi-column projective symmetry lower, iid quantifiers, and finite-width monotonicity counterexample. Its final entry reviews source SHA256 `183071b828f5f10045d331709292fe674ffa3b5813428a01851faec86a8db744`.
- [Independent finite-width upper audit](canonical-finite-width-posterior-cover-independent-audit.md): checks cloning at arbitrary `N ≥ C`, the clipped teacher cube, scale-uniform denominator, conditional energy tail, fixed truth-table net, Gibbs-to-confidence conversion, and strong-prior passage. It also records review of the assembled theorem.
- [Projective symmetry audit](projective-symmetry-root-audit.md): checks the exact conditioned-law invariance and the central-binomial lower bound, including the majority-tie caveat.
- [Monotonicity parameter check](finite-width-monotonicity-parameter-check.json): records a numerical sanity check of the explicit example. The manuscript proves its signs and margins with elementary inequalities; the numerical values are not a proof premise or an interval certificate.

The final source differs from the initially assembled audited snapshot only by explicitly requiring positive probability of the conditioning event in its general odd-activation/prior extension. This is automatic in the Gaussian tanh setting of the main theorems, and the full-manuscript auditor approved the final snapshot.

The [build manifest](build-manifest.json) records the compiled source, PDF, selected derivations and audit snapshots. The package [hash manifest](SHA256SUMS.json) covers package files except itself and generated build auxiliaries. Neither file is a formal proof certificate.

The upper bound depends quadratically on learner width; the lower is logarithmic in input dimension; the monotonicity example makes no `2/3`-threshold-crossing claim. No exponential-depth lower bound or width-independent teacher-polynomial sample upper is asserted.
