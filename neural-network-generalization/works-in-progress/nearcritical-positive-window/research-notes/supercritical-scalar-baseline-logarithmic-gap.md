# A logarithmically enhanced supercritical scalar-baseline deficit

26 October 2026. Scratch theorem for exact tanh with a common Gaussian
prefactor `t=1+delta>1`. This is a scalar variational comparison, not a
finite-width posterior theorem, and it is outside the original canonical
range `t<=1`.

## 1. Scalar definitions and conclusion

For q>0, a finite scalar path starts at q_0=q, chooses probability laws
eta_j on the real line, and has states

    q_j = integral tanh²(z) d eta_j(z).

At prefactor t its action, including the actual readout prefactor t, is

    A_t = sum_(j=1)^m KL(eta_j || N(0,t² q_(j-1)))
                         + 1/(8t² q_m).

Length-zero paths are allowed. Let V_t(q) be the infimum over all such
finite paths. Write V=V_1 and V_* for the established critical limit.

**Theorem.** There are universal constants C and delta_0>0 such that
the finite limit

    V_t^* = lim_(q downarrow 0) V_t(q)

exists for every t>=1, and, for t=1+delta with 0<delta<=delta_0,

    V_t^* <= V_* - delta log(1/delta) + C delta.              (1)

In particular the supercritical scalar baseline is strictly smaller than
the critical one for all sufficiently small positive delta. The coefficient
one in (1) is a proved upper-bound coefficient; no optimal asymptotic
coefficient is asserted here.

## 2. Existence of the boundary value

For each fixed t>0, V_t is nonincreasing in its starting variance. Given
a path started at q and a larger starting state q', rescale its first
preactivation law by sqrt(q'/q). Its relative entropy from the new
reference Gaussian is unchanged. The next state increases because
|tanh z| increases with |z|. Repeat this rescaling at every later step.
The final state does not decrease, and hence its readout cost does not
increase. Taking infima proves monotonicity.

For t>=1, moreover V_t(q)<=V(q). To see this, start with any critical
path with states q_j and construct an actual t-path with states p_j,
p_0=q_0=q. At stage j, multiply the critical preactivation law by

    lambda_j = t sqrt(p_(j-1)/q_(j-1)).

The critical reference N(0,q_(j-1)) is thereby sent exactly to the actual
reference N(0,t² p_(j-1)), so relative entropy is unchanged. Inductively
p_j>=q_j, since lambda_j>=1. The actual final readout cost is no greater
than the critical one. This proves the comparison after taking infima.

Since V(q)<2 is already established and actions are nonnegative,
monotonicity yields the finite limit V_t^*<=V_*<2 for every t>=1.
Thus (1) can be stated for a genuine limit, rather than only a limsup.

## 3. Free growth reaches variance of order delta at zero entropy

Put F(u)=E tanh²(sqrt(u)Z), Z~N(0,1). The free actual-reference update is

    q -> F(t²q),

and its KL cost is zero. The elementary bound

    F(u)>=u/(1+3u)

follows from tanh²(z)>=z²/(1+z²) and Cauchy--Schwarz. Also F(u)<=u.
Take delta small enough that t²<=2. If 0<q<=delta/12, then

    F(t²q)/q >= t²/(1+3t²q)
               >= (1+2delta)/(1+delta/2) >= 1+delta.

Consequently, from every q_0<delta/12, the free recursion reaches
delta/12 after finitely many steps. At its first crossing the state p
satisfies

    delta/12 <= p <= delta/6,                               (2)

because its last update is at most t² times the preceding state. This
prefix costs exactly zero entropy. Its length may diverge as q_0 tends
to zero; that is permitted in the scalar value, which infimizes over all
finite lengths. No fixed-depth conclusion is drawn from this prefix.

For orientation, the positive free fixed point is of the same order.
Indeed F(u)/u is strictly decreasing, because tanh(y)/y is strictly
decreasing for y>0. Hence F(t²q)/q decreases from t²>1 to zero and has
a unique positive fixed point q_t. The compact-interval bound
F(u)<=u-c u², together with (2), gives q_t comparable to delta.
The expansion F(u)=u-2u²+O(u³) then gives

    q_t = (t²-1)/(2t^4)+O(delta²) = delta+O(delta²).

This fixed-point expansion is not needed for the action comparison.

## 4. The critical short increasing suffix

We use the established critical scalar facts from
`works-in-progress/critical-depth/source/critical-rate-foundations.tex`
and `critical-scalar-paths.tex`:

* V is nonincreasing, `1<V_*<2`, and `0<=V_*-V(q)<=17q` for q<=1/128.
* A critical step with pre-state q<=1 has entropy at least
  `q_next-q+c q²`, with a universal c>0.
* Nonincreasing steps can be deleted by rescaling later controls, without
  increasing their total action.

These facts give the following concrete consequence. For each sufficiently
small p>0, there is a strictly increasing critical path from p with

    A_1 <= V(p)+p <= V_*+p,
    m <= C/p,
    q_m >= 1/24.                                           (3)

Here is the short-path argument, to specify the imported quantitative
dependence. Choose a finite path within p of V(p) and delete all
nonincreasing steps. Its suffix from q_i costs at least V(q_i), so its
prefix entropy is at most V_*-V(q_i)+p. In a dyadic band [u,2u) with
2u<=1/128 and u>=p, all but at most one exiting transition have total
prefix entropy at most 34u+p<=35u. Each such increasing transition
costs at least c u². Thus O(1/u) transitions start in that band.
Above a fixed small positive variance, the total cost, less than three,
and the same dissipation bound permit only O(1) further transitions.
Summing the geometric band counts gives m<=C/p. Finally the readout
term alone, 1/(8q_m), is below three, yielding q_m>1/24.

## 5. Exact change of Gaussian reference and the deficit

Apply the critical suffix (3) from the free endpoint p in (2), but now
evaluate the SAME scalar laws and states at the actual reference t.
Set

    b=1-t^(-2),
    c_t=[t^(-2)-1+2log t]/2=log t-b/2,
    M_j=(integral z² d eta_j(z))/q_(j-1).

Finite critical relative entropy implies that every M_j is finite.
The Gaussian density ratio gives the exact identity

    KL(eta_j || N(0,t²q_(j-1)))
      = KL(eta_j || N(0,q_(j-1)))
          + c_t - (b/2)(M_j-1).                            (4)

Since tanh²z<=z²,

    M_j >= q_j/q_(j-1),
    M_j-1 >= log(q_j/q_(j-1)).

The latter uses r-1>=log r for r>0; the increasing-path condition also
ensures that each displayed ratio exceeds one. Summing telescopes:

    sum_j(M_j-1) >= log(q_m/p).                             (5)

The actual readout term is no greater than the critical readout term.
Combining (3)--(5), the actual action of the suffix is at most

    V_*+p + m c_t - (b/2) log(q_m/p).                       (6)

For t=1+delta,

    0<=c_t<=C delta²,       b/2=delta+O(delta²).

By (2)--(3), `p=O(delta)`, `m c_t=O(delta²/p)=O(delta)`, and

    log(q_m/p) >= log(1/delta)-log4.

Therefore (6) is at most

    V_* - delta log(1/delta) + C delta,

where the term O(delta² log(1/delta)) is absorbed in C delta. Prepending
the zero-entropy free prefix proves this bound for V_t(q_0), uniformly
over all 0<q_0<delta/12. Taking q_0 down to zero and using Section 2
proves (1).

The result uses exact Gaussian reference changes and known critical
scalar estimates. It has no numerical premise. It does not by itself
construct a vector target path, control the finite-width prior mass, or
derive a posterior confidence lower or upper bound. It also does not
resolve the canonical t=1 Boolean-depth problem.
