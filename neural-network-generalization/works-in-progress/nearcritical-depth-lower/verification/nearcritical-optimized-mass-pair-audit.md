# Independent audit: cheap nearcritical mass and square-root pair quality

25 October 2026. Reviewed `nearcritical-cheap-all-label-mass.md` and
`nearcritical-pair-square-root-quality.md`.

Verdict: PASS, with the free-prefix width improvement supplied by the separately
reviewed `nearcritical-bures-free-prefix.md`. None of these claims alone is a
posterior-flattening theorem.

For the mass witness, checked the compound-symmetric Gaussian covariance
control and rank-one KL cost; the weak seed w~epsilon^2/m; the phase-one
q_*+O(epsilon^2) invariant and w growth at rate1+c epsilon^2; its total
O(epsilon^2 D) row cost; and the phase-two reciprocal-w bootstrap, residual
bound r=O(epsilon), summable squared-q cost, and residual eigenvalue floor
exp(-CD). The empirical relative-Frobenius correction identity is valid
without commuting covariances. Its cross term is at most C delta ||E||op,
so choosing ||E||F=O(epsilon^2) preserves the O(epsilon^4) phase-one row cost.
The last readout shift has O(N) KL cost once Qhat>=p ff^T/2. Conditional
Hoeffding and entropy-to-probability conversion give the claimed actual
finite-N lower mass exp[-CN(1+epsilon^2 D)].

For the pair-quality theorem, checked the continuous divided-difference
compactification through zero scales, equal scales, and collinear vectors.
The first two basis functions are independent from their linear/cubic Taylor
coefficients; E[U k]=E sech^2 supplies the third direction uniformly. This
proves a uniformly positive Gram matrix on the compact parameter set.
The degree-ten squared-feature continuity envelope, dimension-independent L2
parameter continuity, and ambient covering dimension2m+6 are correct.

The fixed-feature one-sided Chernoff bound uses only the fourth moment via
exp(-x)<=1-x+x^2/2. It does not invoke an invalid positive exponential moment
for a cubic Gaussian feature squared. The Gaussian radius cutoff and the
parameter net give entropy O(m logN) and failure exp(-cNv), yielding relative
PSD lower error C sqrt(v). Combining scalar upper control with the PSD bound
correctly gives the multiplicative pair-gap estimate. A single nested quality
statistic is obtained by intersecting the small-quality event with the
large-quality event at v0 below that threshold, and dropping the former above
it. If large-quality losses are expressed relative to entering correlation,
the bounded feature-norm condition makes free and entering gaps comparable by
a fixed constant; this constant is absorbed at v>=v0.

These are independent AI-agent mathematical checks, not Lean verification.
