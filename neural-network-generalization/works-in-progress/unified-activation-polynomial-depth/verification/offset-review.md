# Original-prior, fixed-depth offset extension

Reviewed on 23 October 2026. This is an AI-agent mathematical review and conventional proof extension, not a Lean formalization or human peer review.

The appendix `source/offset-extension.tex` extends the original globally margin-conditioned Gaussian learner, without the main paper's neuron-averaging restriction, from zero-at-zero activations to arbitrary globally Lipschitz activations with bounded offset. It gives one fixed-depth polynomial for every learner width above the specified teacher width and every mean-field-or-stronger scale. Teacher coefficient magnitude is separately counted as B.

## Checks and necessary modifications

- **Actual prior:** unchanged independent centered Gaussian coordinates, with variances t²/d, t²/N and t²/N². Centering activation values is used only for auxiliary capacity counting, never to identify a different Bayesian learner with this one.
- **Capacity:** centered hidden states are divided by sqrt(N) before adding a constant wire. This gives an exact zero-at-zero auxiliary implementation with the sum of squared layer norms at most (1+b²)κ_N+H. Omitting this normalization would introduce a width-dependent bias-column bound. The prior product-norm Rademacher theorem supplies the displayed cardinality estimate.
- **Target mass:** balanced cloning uses all N neurons, so zero-padding the actual nonzero-offset activation is not assumed harmless. The hidden-state recurrence adds b. Perturbation differences still use only the Lipschitz constant, and the constrained Gaussian coordinates/free-bulk annihilation argument is unchanged.
- **Spectral compression:** normalized hidden-state bounds add b, but truncation differences do not. The explicit smaller spectral cutoff has polynomial reciprocal at fixed depth. Gaussian energy and singular-value tails are unchanged.
- **Endpoint atoms:** normalizing with sqrt(1+δ²), rather than δ, retains a bounded activation offset and avoids division by zero. Total atom coefficient mass is at most A+1. The covariance-error bound explicitly retains the offset term and makes it small by taking T≥b/λ.
- **Dummy atoms:** the missing probability in atom sampling uses vector zero together with the identically zero auxiliary activation. Taking φ at zero would add a false constant covariance. Padding likewise uses zero auxiliary activation.
- **Degenerate covariance:** Q=0 has no tail atoms and retains the genuine constant bulk φ(0). The RKHS certificate and covariance-stability statements do not require positive minimum eigenvalues.
- **Conditional Gaussian identity:** Q_s is the raw Gram matrix, not a centered hidden covariance. Nonzero hidden means therefore do not invalidate the exact centered Gaussian preactivation law induced by independent centered weights.
- **Bulk stability:** cutoff/mollification derivatives have the same polynomial orders after T≥b/λ; sparse exponential tilting and normalized Gaussian covariance differentiation have no zero-offset assumption. No reciprocal partition function introduces an exponential loss.
- **Finite implementation:** actual activations are used for the bulk, bounded-offset normalized activations for tail atoms, and polynomial physical weights implement every certificate. The added b in physical feature bounds preserves fixed-depth polynomial recurrences.
- **Scale uniformity:** t and t² factors only decrease reconstructed incoming-weight and covariance upper bounds for t≤1. The same three-case relative-mass proof closes every width and scale through a single counted function class.
- **Statistical convention:** exact noiseless training and the original global absolute margin remain. Average sign error implies the strict >2/3 confidence rule only after replacing ε by ε/3. No noisy-label, efficient computation, or unconditional polynomial-depth result is asserted.

The proof uses established lemmas from the earlier unified Lipschitz paper, with each zero-offset-dependent step replaced explicitly in this appendix. The numerical constants are conservative. The resulting polynomial degree depends on depth; its exact degree is neither optimized nor claimed to be practical.

No new Lean theorem has been added for this appendix. The older theorem's machine verification does not automatically extend to these new hypotheses.
