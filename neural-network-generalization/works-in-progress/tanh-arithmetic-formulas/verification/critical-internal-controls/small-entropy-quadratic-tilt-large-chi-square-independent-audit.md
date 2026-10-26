# Independent audit: small entropy with large density second moment

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `d482b9bac780ec0ef27d5c7906401c189673b3371f761f64f0b3983b1774d4fb`, including the equal-diagonal four-input augmented-cube variant.

The cubic-canceling tanh difference has the stated exact expression, bounded square and sixth-order behavior. Its Gaussian-envelope threshold has a compact nonzero maximizing set. The endpoint partition-function upper bound and a sqrt(q)-radius neighborhood of any maximizer give enough tilted tail probability without requiring a nondegenerate Hessian. Continuity and monotone likelihood ratios then give the exact q^2 event mass.

On the complement of that event, the critical exponent has a strict negative gap away from zero and quadratic Gaussian decay near zero. The displayed O(q^3) weighted moment bound follows, giving KL upper O(q); binary relative entropy gives the matching lower bound. Cauchy--Schwarz on the rare event proves the exponential chi-square lower bound. The log density is exactly a quadratic combination of the constrained feature covariances, so the information-projection identity and uniqueness are exact.

The normalization and second-moment estimates show matched variance q+O(q^2), while the nonlinear weak-mode mass is Theta(q^2) under the tilt and O(q^3) under its matched Gaussian. The final wording correctly states an enhancement of at least order 1/q.

In the equal-diagonal variant, the parity combination has leading term -2z0z1z2. The same envelope construction in three Gaussian coordinates gives endpoint event probability at least c q^(3/2), which still exceeds q^2. All Gaussian tail, entropy, covariance and weak-mode estimates transfer with fixed dimensional constants. Its covariance is exactly the scaled augmented d=2 cube covariance, corresponding to first-layer prefactor t^2=2q.

The scope is correctly local. Neither transition optimality nor the scaled input observation proves occurrence in a globally optimal critical t=1 Boolean path. This note invalidates an entropy/local-optimality shortcut to bounded density or chi-square, not polynomial-depth learning itself.

## Rank-one normalized-costate clarification

**PASS** for the expanded source at SHA256 `88bbdc20a343c435a6537f1f493efaaf3002cad9097064a38b5ad60e467c5933`. The potential lambda(c^T F)^2 has positive rank-one quadratic costate T=2 lambda c c^T. Hence the covariance-normalized nuclear norm is exactly tr(Q T)=2 lambda E(c^T F)^2. The already proved lambda<=A_*/q, reference weak moment O(q^3), and tilted weak moment O(q^2) give O(q^2) and O(q), respectively. Thus rank-one costate structure and either of these small normalized nuclear norms do not imply a controlled density second moment. This remains an exact local transition example, without a global-path optimality claim.
