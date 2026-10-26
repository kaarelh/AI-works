# Verification record

This package is conventionally checked mathematics, not a Lean formalization.

- [Assembled mean-shift theorem audit](finite-width-boolean-mean-shift-assembled-audit.md): fresh independent check of the final new Section 3 and its scope.
- [Independent Gaussian mean-shift audit](finite-width-boolean-circuit-mean-shift-learning-audit.md): all-cube digital propagation with actual constant wires, exact relative entropy, target mass, posterior mixtures, and the layerwise-width comparison.
- [Independent full-manuscript audit](finite-width-posterior-assembly-independent-audit.md): checks the actual-posterior upper, multi-column projective symmetry lower, iid quantifiers, and finite-width monotonicity counterexample. Its final entry reviews source SHA256 `183071b828f5f10045d331709292fe674ffa3b5813428a01851faec86a8db744`.
- [Independent finite-width upper audit](canonical-finite-width-posterior-cover-independent-audit.md): checks cloning at arbitrary `N ≥ C`, the clipped teacher cube, scale-uniform denominator, conditional energy tail, fixed truth-table net, Gibbs-to-confidence conversion, and strong-prior passage. It also records review of the assembled theorem.
- [Projective symmetry audit](projective-symmetry-root-audit.md): checks the exact conditioned-law invariance and the central-binomial lower bound, including the majority-tie caveat.
- [Monotonicity parameter check](finite-width-monotonicity-parameter-check.json): records a numerical sanity check of the explicit example. The manuscript proves its signs and margins with elementary inequalities; the numerical values are not a proof premise or an interval certificate.

The original three results retain their earlier audited proofs. The 26 October update adds the self-contained Gaussian mean-shift theorem for layered Boolean-circuit targets and updates the abstract and scope. The new theorem has its own audit; previous source hashes identify the earlier manuscript versions.

The [build manifest](build-manifest.json) records the compiled source, PDF, selected derivations and audit snapshots. The package [hash manifest](SHA256SUMS.json) covers package files except itself and generated build auxiliaries. Neither file is a formal proof certificate.

The general upper bound depends quadratically on learner width; the new digital-circuit bound is linear at the critical scale above its explicit width threshold and retains a t^-2 factor; the lower is logarithmic in input dimension; the monotonicity example makes no `2/3`-threshold-crossing claim. No exponential-depth lower bound or width-independent teacher-polynomial sample upper is asserted.
