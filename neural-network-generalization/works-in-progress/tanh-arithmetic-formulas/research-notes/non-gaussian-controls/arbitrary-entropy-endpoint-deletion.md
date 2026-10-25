# Removing an arbitrary final entropy tilt by truncating its density

25 October 2026. Root proof. This is a bounded-feature representation lemma,
not an action-preserving replacement or a theorem about internal layers.
It does not require an optimal row law or endpoint KKT conditions.

Let gamma be any probability measure, rho=r gamma with KL(rho||gamma)=D<infinity,
and let F_x be measurable features with |F_x|<=1 for every query x. Suppose
v in L2(rho), ||v||=V>0, has signed outputs

    f(x) E_rho[v F_x] >= eta > 0.

Write R=V/eta. Necessarily R>=1. There is a readout w in L2(gamma)
whose signs agree with f everywhere, with signed margin at least eta/2,
and

    ||w|| <= V exp(12[sqrt(D) R + D R^2]).                 (1)

At D=0 take w=v; the measures coincide and there is no margin loss.
Thus a final arbitrary finite-entropy row law at bounded total action and
fixed positive margin can be removed at bounded representation cost.

## Proof

For M>1, the nonnegative integrand r log r-r+1 gives

    D >= integral_(r>M) (r log r-r+1) dgamma
      >= [log M-1+1/M] rho(r>M).                         (2)

The second inequality uses monotonicity of log r-1+1/r for r>=1.
Put u=D R^2 and s=24(sqrt(u)+u), and take M=e^s. For 0<s<=1,
s-1+e^(-s)>=s^2/3. For s>=1 it is at least s/4: check the value at
one and then its derivative. In either case

    log M-1+1/M >= 4u.

Equation (2) consequently gives rho(r>M)<=1/(4R^2). Define

    w(g)=v(g) r(g) 1_(r(g)<=M).

This is well defined gamma-almost everywhere after choosing any measurable
version of v on {r>0}. Its squared norm is bounded by

    E_gamma w^2 <= M E_rho v^2 = M V^2.

Uniformly over every query, Cauchy--Schwarz and |F_x|<=1 give

    |E_rho vF_x-E_gamma wF_x|
       <= V sqrt(rho(r>M)) <= eta/2.

These inequalities prove the margin assertion and (1). There is no
union bound over queries and no assumption about their number.

## Application to tanh feature paths

For a final controlled tanh layer, take gamma to be its unmodified Gaussian
row law and F_x(g)=tanh(g dot u(x)). If row entropy plus half squared
readout norm is at most A, then D<=A and V^2<=2A. For fixed eta the
readout replacement costs exp(O_eta(A+A^2)), independent of feature
dimension, the number of inputs, and the form of the density.

For a path close to the universal scalar baseline, A is a constant. Thus
any formula compiler for the preceding layers and a free Gaussian final
layer also handles an entirely arbitrary final row tilt, at constant
additional resource cost. This strengthens the earlier endpoint deletion
lemma, which assumed the final row/readout jointly optimized their action.

The replacement does not preserve action and cannot be iterated through
internal layers without a new argument. Its output readout is only
asserted to exist; no effective density or sampling algorithm is needed.
For unbounded activations the uniform bounded-feature step requires
additional assumptions and is not asserted here.
