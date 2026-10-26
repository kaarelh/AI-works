# Rational-formula completion of centered Gaussian quadratic occupation

26 October 2026. Supporting corollary to
`gaussian-diagonal-defect-quadratic-occupation.md`, whose real-oracle
recurrences independently passed in
`gaussian-diagonal-defect-quadratic-occupation-independent-audit.md`.
The precision interface independently passed in
`gaussian-diagonal-defect-finite-bit-audit.md`. The conclusion is
nonuniform representation, not a posterior learning theorem.

## Statement

Use the centered Gaussian path, compatible coordinates, bounded initial
variance, and positive lower envelope s_min,0 from the real-formula note.
Let S=sum||K_j||HS, L=sum log_+(1/sigma_min A_j), t=1+delta, and
0<=delta<=delta0. On the Boolean cube take the usual normalized signed Boolean
coordinates, or initial coordinate/defect oracles already satisfying the
finite-bit moment-floor interface with resource T0. Let a linear readout have physical signed margin at least
m>0 and norm ||v||. There is a majority of rational arithmetic-sign
formulas for its Boolean truth table whose total size and coefficient
bit lengths are polynomial in

    H+d+T0+(1+||v||/m)
       + exp{C[1+S+L+log(1/s_min,0)+delta²H]}.           (1)

In particular, if all ordinary resources are polynomial in R and

    S+L+log(1/s_min,0)+delta²H=O(log R),                 (2)

the construction has size polynomial in R and arithmetic-formula depth
O(log R). When R is itself polynomial in the Boolean input length, the
family lies in nonuniform PNC1, under the same audited arithmetic-sign-
formula/PNC1 theorem used by the Gaussian companion.
The original augmented Boolean input has constant squared norm and
s_min,0=1. Its bounded algebraic normalizations are rounded only in the
final fixed expression; they are not asserted to be exact rational
arithmetic constants.

## Why no new precision assumption is needed

The existing moment-floor construction injects independent zero-mean
noise of inverse-polynomial strength, for example O((H+1)^(-2)), after
potentially cancelling primitives. It preserves all means and changes
the maintained variance envelopes by a bounded total factor. Its
additional syntactic work is polynomial in H.

The new control update uses a convex random choice between the old defect
oracle and a bounded quadratic oracle. If each child satisfies the
pointwise noise floor Var X_i(x)>=gamma a_i², with a_i its cube RMS,
then the mixture satisfies the same floor by conditional variance.
After normalized representation, the selected child-to-parent RMS ratio
has squared expectation one. Thus a tiny mixture probability is not a
large arithmetic coefficient forced into every fixed-seed formula.

The remaining control residual has coefficient c/p=O(1). Its quadratic
matrix is the single normalized tensor (A*A-I)/(4kappa), with bounded
Hilbert--Schmidt norm. The free defect function is evaluated only after
cancelling its q Delta factor, giving a uniformly bounded H³ helper.
Consequently no separately rounded division by kappa, Delta, Delta',
or q Delta is performed.

The coefficient factories are ordinary Fourier--Poisson transforms, so
the conditional-product noise-floor proof applies. Orthogonal tensor
creation uses the existing Fock normalization proof. Countable-coordinate
and conditional-mixture coefficient ratios are controlled by their
second moments and the expected primitive-call count. Choose a seed
having polynomial total work, polynomial logarithmic coefficient bounds,
and a correct all-input majority with margin slack; this intersection has
positive probability. The usual arithmetic-tree sensitivity estimate
then permits polynomial-bit dyadic rounding while retaining that majority.
No efficient sampler for the real controls or Fourier coefficients is
asserted or required for this existence statement.

For the final signs, use the normalized direction u_H directly. Since a
hidden tanh step gives ||h_H(x)||<=1, a physical signed margin m implies
signed readout margin at least m on u_H. Hence no final query-norm square
root is necessary. The readout norm and inverse margin remain explicit
in (1). The trivial H=0 case is handled directly by its input formulas.

Arbitrary non-Gaussian controls and the actual margin-conditioned
posterior are not included. In particular (2) does not establish an
actual posterior delta²H learning window or settle the original
canonical Boolean depth problem.
