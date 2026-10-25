# Fresh audit: fixed supercritical prefactor finite-width lower bound

25 October 2026. Conventional mathematical audit, not Lean verification.
This concerns fixed `t>1`, outside the canonical `0<t<=1` depth question.

## Verdict

I independently read the complete final assembly in
`supercritical-empirical-transport.md` and the six component proofs below.
I found no substantive mathematical error. The resulting statement is an
actual finite-width confidence lower bound, rather than merely equality of
limiting actions:

For fixed `t>1`, suitable constants `p>4,K,c>0`, and large `d`, let
`N=ceil(2^(pd))` and `H=ceil(K(d+1))`. Every pair of full-cube strict
signed-margin orthant probabilities has ratio at most `1+exp(-cd)`.
Consequently every unseen cube input has posterior correct-label probability
close to one half after exact conditioning and global-margin conditioning.
Under the uniform cube law, reducing confidence failure below one half
requires more than `2^(d-1)=exp(Omega_t(H))` examples, even for the constant
function. This does not establish a deterministic majority-error lower bound
at threshold exactly one half.

## Actual all-label margin mass

Reviewed `supercritical-finite-target-mass.md` end to end.

The free covariance map has dimension-independent local Frobenius contraction
at `q_* I`. Its diagonal-to-off-diagonal derivative terms are controlled by
the maximum off-diagonal row Euclidean norm, bounded by the operator distance
to `q_* I`. Entrywise Hoeffding then keeps an arbitrarily long free prefix
near white at width `exp(C_t(d+1)) log(H+2)`.

The final controlled schedule doubles a common rank-one component from
`Omega_t(1/m)` to a constant in `O_t(d+1)` steps, where `m=2^d`. Residual
eigenvalues can be exponentially small in `d`; the width threshold pays for
this. Pulling each desired Gaussian covariance back onto the actual empirical
feature span is legitimate on every surviving history. The relative
Frobenius error makes trace/log-determinant cancellation cost only `O_t(1)`
per row, despite the dimension `m`.

The stopped adaptive construction depends only on the past and reverts to
the prior upon failure, so the chain-rule entropy cost is deterministically
`O_t(N(d+1))`. The readout shift has cost
`N f^T Qhat^{-1} f/(2t²)=O_t(N)`. Binary relative entropy therefore proves
`w_f>=exp(-K_t N(d+1))`, with `K_t` independent of the large ratio `H/d`.
That last independence is essential to the final parameter choice.

## Uniform empirical scalar and pair estimates

Reviewed `supercritical-empirical-scalar-pair-quality.md` end to end.

The divided-difference compactification correctly handles vanishing feature
norms and almost proportional pairs. Linear/cubic Taylor coefficients separate
the first two basis functions; testing the third against the independent
Gaussian coordinate provides a uniform lower bound. This gives the required
fourth-to-second moment bound without an invalid positive exponential moment
for a cubic Gaussian limit.

Truncation at `v^(-1/4)` plus the VC bound gives multiplicative PSD loss
`O_t(v^(1/4))`. The final assembly correctly propagates this weaker rate,
using `zeta(v)=v^(1/4)+v`, instead of retaining an unsupported square-root
rate.

The rare-set VC estimate is only for sets containing at least half the sample.
The ghost sample of size `ceil(N/p)` and hypergeometric argument support its
stated exponent; it does not assert a false relative-entropy uniform law for
arbitrarily tiny sets containing one observation. The conservative VC bound
`O(m^4)` yields the stated floor `tau=K_t m^4 log(eN)/N`.

Conditional Gaussian strip estimates cancel the entering variance against
actual empirical normalization, giving large-quality pair-gap loss
`exp(-C_t v)` relative to the entering gap. Countable separability and
full-parameter event definitions justify measurability and exact orthogonal
invariance.

## Matrix quality and local contraction

Reviewed `supercritical-empirical-matrix-quality.md` end to end.

The derivative dual variable is a product of dimension-independent
subGaussian norms. Poincare controls the mean of `||M h||`; the Frobenius
normalization is crucial. Finite parameter nets and polynomial Gaussian
envelopes give log cardinality `O(m² log N)`, absorbed by the larger pair
quality floor.

The explicit horizontal factor path and Sylvester lift preserve a
`1+O(epsilon)` metric comparison. A fixed-factor norm equivalence could destroy
contraction, but is not used. After empirical diagonal normalization, the
safe common spectral error is `O(zeta(v))`; the assembly uses precisely this.

## Occupation and exact finite-network coupling

Reviewed `supercritical-turnpike.md`,
`supercritical-scalar-pair-occupation.md`, and their empirical adaptation in
Sections 4--6 of the assembly.

Scalar and pair potentials are maxima, so they do not sum losses over all
cube inputs. The normalized Hermite argument separately bounds
`X=lambda_max(C)-1` and `Y=1-lambda_min(C)`. The latter is not inferred from
an upper eigenvalue bound. Large-quality steps are explicitly charged to
`sum V_j`, while the other perturbations are charged to `sum zeta(V_j)`.
The resulting nonwhite-state count is `O_t(d+1+sum zeta(V_j))`.

Past-measurable optimal Bures factors driven by the same fresh Gaussian array
have the exact conditional finite-width transition laws in both marginals.
This remains valid at the singular initial Gram. No invertible transport of
hidden parameters is required. The quality events hold uniformly in the
factors, so adapted choices do not change the iid quality-budget law.

The budget estimate is sufficiently strong relative to the exponentially
small margin mass. Choose its bad-event exponent above `K_t`; its coefficient
can be fixed independently of the large depth constant `K`. Holder gives
`sum zeta(V_j)=O_t(K^(3/4)d+d)` on the budget event, while contraction provides
`-c_t Kd`. Thus the unnormalized final Bures distance can be made much smaller
than `1/(N d^(3/2))`.

The order of constants is noncircular: choose `p` to exceed both the quality
and target-mass width requirements, then choose the depth multiplier `K`.
The long free-prefix width price is only logarithmic in `H`, so `p` need not
grow with `K`.

## Readout and posterior comparison

Reviewed `finite-width-readout-transport-audit.md` and the assembly's final
conversion.

Feature Procrustes is valid at arbitrary rank. Its measurable orthogonal
choice preserves the fresh isotropic Gaussian readout conditionally on the
features. The only Jacobian is the elementary readout dilation; no hidden-map
smoothness or invertibility is assumed.

Both the hidden bad-event probability and the readout tail have exponents
strictly larger than the raw all-label margin-mass exponent. The dilation cost
is `O_t(N d^(3/2) delta)`, which tends to zero exponentially with the chosen
constants. Pairwise numerical comparisons of orthant masses require no union
bound over all truth tables. Pairing consistent truth tables differing at an
unseen point proves the posterior confidence conclusion for full mixtures.

The constant target witness is width two with every coefficient at most one:
first-layer values are `tanh(1)`, later values are `tanh(2u)`, and the readout
sums the two coordinates. Its margin exceeds one at every depth.

## Scope

Fixed `t>1` corresponds to
`gamma_N=1-2 log(t)/log(N)<1` under the original exponent convention. It is a
natural fixed Gaussian prefactor at the mean-field exponent, but is not a
counterexample for the original canonical `gamma>=1` family. That question
remains open. No complete theorem here has been checked by a proof assistant.
