# Uniform square-root alignment of near-optimal scalar paths to the tilt-two law

26 October 2026. Scratch scalar variational lemma. This is not an
arbitrary controlled-kernel compiler or posterior theorem.

Let V(q), V_* be the critical scalar tanh value and boundary baseline.
Use the published scalar inputs:

    V(q)=V_*-2q+O(q²) for small q;
    log E_N(0,q) exp(2tanh²G)<=2q;
    D_j>=q_j-q_(j-1)+c q_(j-1)²;

and the increasing-path reduction. These are in the critical-depth
scalar foundations and `unrestricted-critical-scalar-expansion.tex`.
Define the canonical scalar tilt

    nu_q(dz)=exp[2tanh²z-K(q)] N(0,q)(dz),
    K(q)=log E_N(0,q) exp(2tanh²G).

## Lemma

For every sufficiently small p>0 there is a finite strictly increasing
critical scalar path from p with action at most V(p)+p² and

    sum_j sqrt(KL(eta_j||nu_(q_(j-1))))<=C,             (1)

where C is universal and does not depend on p or the path length.
In fact every strictly increasing path with this action bound satisfies
(1).

## Proof

Write D_j=KL(eta_j||N(0,q_(j-1))) and define the nonnegative excess

    E_j=D_j-2(q_j-q_(j-1)).

The Gibbs identity gives

    E_j=KL(eta_j||nu_(q_(j-1)))
                  +2q_(j-1)-K(q_(j-1))
        >=KL(eta_j||nu_(q_(j-1)))>=0.                 (2)

Every suffix beginning at q_i has cost at least V(q_i). Therefore, as
long as q_i is below a fixed small threshold q_*, the value expansion
yields

    sum_(j<=i) E_j
       <= V(p)+p²-V(q_i)-2(q_i-p)
       <=C(p²+q_i²).                                  (3)

Partition the small pre-states into dyadic bands [u,2u), u=2^k p.
For a given band, exclude its at most one exiting transition. Every
remaining transition has post-state below2u, so (3) bounds their total
E_j by Cu². The prefix entropy ending at the last such transition is
at most V(p)+p²-V(q_i)<=Cu. Each increasing transition in the band
costs D_j>=c u². Thus the band contains at most C/u nonexiting steps,
and Cauchy--Schwarz gives

    sum_nonexiting sqrt(E_j)<=C sqrt(u).

Summing these bounds over dyadic u up to q_* gives a universal constant.
For an excluded exiting transition with post-state q_j<=q_*, (3) gives
sqrt(E_j)<=Cq_j. The post-state dyadic bands of successive exiting
transitions strictly increase: after an exit lands in one band, the next
exit starts in that band or a later one and must land in a later band.
Hence the sum of these q_j is also bounded by a geometric series.

There is at most one transition crossing above q_*. All later pre-states
are at least q_*, and strict dissipation and total action below3 bound
their number by a universal constant. Their total E_j is at most the
total D_j because states increase, hence below3. The crossing step and
remaining large-state steps therefore contribute O(1) to sum sqrt(E_j).
Combining with (2) proves (1).

A finite path within p² of V(p) exists by definition; deleting its
nonincreasing steps and rescaling subsequent scalar laws cannot increase
action. Thus a path satisfying the lemma exists.

## Interpretation and limits

The ordinary entropies satisfy a square-root budget of order log(1/p)
for the usual short scalar ascent. That logarithm can arise entirely
from following the canonical non-Gaussian tilt nu_q. Relative to this
reference, a p²-nearoptimal increasing scalar path has bounded total
square-root discrepancy.

The statement does not identify full multivariate row laws from one
scalar marginal, and it does not supply scalar coordinate formulas for
those laws. It also concerns an accuracy p² chosen in a scalar variational
infimum, not a claim that every original posterior path has this excess.
No sample-complexity consequence or canonical-depth resolution follows
without additional work.
