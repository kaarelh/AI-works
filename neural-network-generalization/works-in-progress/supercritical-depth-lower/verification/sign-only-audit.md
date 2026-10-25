# Independent audit of the sign-only supercritical depth theorem

25 October 2026. Reviewed `supercritical-sign-only.md` end to end.

Verdict: the finite-width theorem and proof pass conventional mathematical
review. No substantive gap found. It is not Lean verified.

The Gaussian density sandwich in Section 2 is exact. Eigenvalues in
`q[1-epsilon,1+epsilon]` bound both the determinant and inverse quadratic
form. Integrating the resulting isotropic Gaussian densities over an orthant
gives the displayed `2^-m` bounds with multiplicative exponent `O(m epsilon)`.
There is no need to condition on a Gaussian radial cutoff.

The ordinary finite-width concentration estimates are strong enough here.
The first burn-in tolerance has squared size at least `m^-a_t`, since its
length is `O_t(d)`. The later tolerance is `Theta_t(m^-4)`, with squared size
`Theta_t(m^-8)`. Choosing the width exponent after these fixed depth and
burn-in constants makes the total bad probability at most `exp(-m²)`.
On the good event, covariance error `m^-3` gives orthant log error
`O_t(m^-2)`.

The crucial relative-error comparison is explicitly present:
`exp(-m²)` is negligible relative to `2^-m`. Thus the same good covariance
event bounds all numerical truth-table probabilities, without a union bound
over `2^m` labelings. Pairing truth tables at unseen inputs yields the
confidence conclusion for the full posterior.

An arbitrary positive isotropic Gaussian readout scale multiplies the output
covariance by a scalar and therefore leaves its sign distribution unchanged.
The argument consequently covers both readout variance `t²/N²` and `1/N`.

The note correctly restricts conditioning to observed signs with no global
margin. Fixed nonzero training margins would require a new relative-probability
calculation. The result is fixed `t>1` and does not reach the canonical `t<=1`
family or establish exact-majority error hardness.

Follow-up: the strengthened width quantifier also checks. At fixed
`H=ceil(K_t(d+1))`, every larger `N>=ceil(2^(p_t d))` improves concentration,
while the sign-only orthant comparison has no adverse N dependence. More
generally, all `H>=K_t(d+1)` are covered if
`N>=2^(p_t d) log(H+2)`: the logarithmic width factor absorbs the longer
union bound, and the local recurrence preserves the final fine tolerance.
This differs essentially from the globally margined theorem's width window.
