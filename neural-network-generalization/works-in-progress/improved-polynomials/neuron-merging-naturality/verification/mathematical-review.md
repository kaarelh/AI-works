# Independent audit of signed, unequal-population compression

Research audit, 22 October 2026 (UTC). The following refinements of the
quadratic population-averaging theorem check mathematically. They have
not been formalized in Lean.

## Exact mass-normalized quotient coordinates

Fix signed partitions with q nonempty groups at each stage. Their sizes
may be arbitrary. Write p_(s,a)=k_(s,a)/N and sigma_i for each neuron's
fixed sign. The usual quotient parameters are

    A_1[a,j] = (1/k_(1,a)) sum_{i in a} sigma_i W_1[i,j],
    A_s[a,b] = (1/k_(s,a)) sum_{i in a,j in b} sigma_i W_s[i,j] sigma_j,
    vquot[b] = sum_{j in b} sigma_j v[j].

For the original independent Gaussian prior their variances are

    t^2/(d k_(1,a)),
    t^2 k_(s-1,b)/(N k_(s,a)),
    t^2 k_(H,b)/N^2.

They are mutually independent for each fixed partition/gauge: different
quotient coordinates sum disjoint original coordinates, and all layers
were independent. Adaptive selection of a partition is handled later by
a union bound; it does not preserve this Gaussian claim conditionally on
the selected partition.

Normalize states and coefficients by

    g_(s,a)=sqrt(p_(s,a)) hquot_(s,a),
    B_1[a,j]=sqrt(p_(1,a)) A_1[a,j],
    B_s[a,b]=sqrt(p_(s,a)/p_(s-1,b)) A_s[a,b],
    b[a]=vquot[a]/sqrt(p_(H,a)).

Then every coordinate of `sqrt(d) B_1`, each `B_s`, and `b` has exactly
variance `t^2/N`, regardless of group sizes. The normalized energy

    J(w)=d||B_1||_F^2 + sum_s ||B_s||_F^2 + ||b||^2

is therefore `(t^2/N)` times a chi-square variable with
`P_q=q(d+2)+(H-1)q^2` degrees of freedom. No lower bound on group masses
is needed.

## Perspective tanh decoder and the zero-scale edge case

The quotient computation becomes

    g_(s,a)=phi_(sqrt(p_(s,a)))((B_s g_(s-1))_a),
    phi_a(u)=a tanh(u/a),   a>0,
    phi_0(u)=0.

This decoder computes precisely the population-averaged original network.
Its output is `b^T g_H`. The decoder's activation family is auxiliary;
the Bayesian learner itself remains an ordinary tanh network.

For a>0, the derivatives satisfy

    |partial_u phi_a(u)| <= 1,
    |partial_a phi_a(u)| = |tanh(v)-v sech^2(v)| <= 1,
    v=u/a.

For v>=0 the latter expression increases from zero to one, since its
derivative is `2v sech^2(v) tanh(v)>=0`; oddness covers negative v.
The extension at a=0 is continuous because |phi_a(u)|<=a. Integrating
the separate Lipschitz bounds, including this endpoint, gives

    |phi_a(u)-phi_b(v)| <= |u-v|+|a-b|

for a,b in [0,1]. Thus very small populations introduce no hidden inverse
mass factor into a finite grid approximation.

If all weights are bounded by R-1 and coefficients and scales are rounded
with error at most zeta, keeping scales in [0,1], the coordinate error obeys

    e_1 <= (d+2) zeta,
    e_s <= qR e_(s-1) + (q+1) zeta,
    output error <= qR e_H + q zeta.

Hence an exponentially fine-in-depth grid gives only polynomial-in-depth
description length, as in the earlier coding argument. The number of
additional activation-scale parameters is Hq, so the total remains
`O(dq+Lq^2)`.

To use one class for every q<=Q, pad to width Q with zero rows, zero
outgoing coefficients, and activation scale zero. Such added neurons are
identically zero even if their input argument is nonzero. The endpoint
scale is therefore both well-defined and adequate for padding. Rounding
an actual positive scale down to zero also respects the displayed error
bound.

## Gaussian union bound and width independence

For each q, the number of ordered partitions and gauges is at most
`(2q)^(HN)`. This counts arbitrary assignments and so overcounts nonempty
partitions, which is harmless. A union bound over q<=min(N,Q) handles
the adaptively selected grouping and its signs.

The parameter count obeys

    P_q/N <= d+2+(H-1)Q

because q<=N and q<=Q. Thus the same posterior denominator and Gaussian
tail argument as before give an N-independent bound on normalized energy
for every qualifying quotient. Sign choices add only H log 2 to the
normalized logarithmic cost.

This proves that balance is unnecessary for the quadratic coding rate.
The bounded normalized parameters and perspective activations replace
the former lower bound on population sizes.

## Readout-scale-invariant population budget

Let `M_infty=max_x |z_w(x)|`. Replace the previous constraint `q<=1+E_v`
by the division-free constraint

    (q-1) M_infty^2 <= 4 E_v.

It is invariant under multiplying the entire readout by a nonzero scalar.
The expression is Borel because the input domain is finite. At M_infty=0
it places no extra restriction on q, but those networks cannot satisfy
a nonempty exact-margin training sample.

Whenever at least one training example is fitted with signed margin
strictly above 1/2, M_infty>1/2, and the budget implies

    q < 1+16 E_v.

Therefore the existing posterior readout tail still yields a bounded
population count, with only a constant-factor change in the cutoff Q.

For the established robust Boolean target cylinder,

    sqrt(E_v) >= a sqrt(C/2)-rho >= (5/8)a sqrt(C),
    M_infty <= a+rho <= 5a/4,

where a>=4, rho<=1/4, and C>=1. Consequently

    4 E_v/M_infty^2 >= C,

so its C clone groups satisfy the new population budget. The target
probability estimate and resulting quadratic teacher-width exponent are
preserved.

This normalization removes the trivial way to increase the permitted
population count by amplifying the readout. It does not make the entire
prior scale-invariant: the likelihood and clipped prediction convention
still fix absolute output margins. Nor does it prove that ordinary trained
networks admit useful small population quotients.

## Weight-only alternative budget

The same proof works if the denominator is `A_1=sum_i |v_i|` instead of
M_infty: impose `(q-1) A_1^2 <= 4 E_v`. Since M_infty<=A_1, this condition
is stronger. Nonempty exact-margin training gives A_1>1/2, so again
q<1+16E_v. The target cylinder has A_1<=a+rho, and the sharper center
bound above proves membership at the same constant 4. Both budgets are
invariant under nonzero readout rescaling and hidden sign gauges.

The weight-only variant has an important naturality limitation. If
`n_eff=A_1^2/||v||_2^2` is the effective number of nonnegligible readout
coefficients, its budget is `q<=1+4N/n_eff`. Roughly equal-magnitude dense
readouts have n_eff approximately N, permitting only about five populations.
The Boolean clone construction instead concentrates readout on the output
wire's approximately N/C clones, making n_eff approximately N/C and the
allowed population count proportional to C. Thus this easy-to-check
variant is not automatically plausible for ordinary dense-readout trained
networks.

## Final standalone source audit

The standalone source
`/workspace/population-naturality-2026-10-22/conditions/signed-unbalanced-merging.tex`
was independently checked on 22 October 2026, including its target-cylinder
appendix. The displayed theorem and proof pass this mathematical review.
This is an independent human-readable mathematical audit, not Lean
verification.

Audited source SHA-256:
`687317bac44449f83d100bc6f3b4a27a1dd3edf167b5ef91917471c86c6bf1ce`.
Corresponding PDF SHA-256:
`e0e146531bea2f0db52895df66f4557e97df70687d5ef895f49f926e37473c53`.

The final source also permits different group counts at different layers.
For `q=max_s q_s`, the exact dimension is
`P=q_1(d+1)+sum_{s=2}^H q_s q_(s-1)+q_H` and satisfies
`P/N<=d+2+(H-1)Q` whenever `q_s<=min(N,Q)`. Counting at most
`Q^H(2Q)^(HN)` signed partition tuples yields exactly the two logarithmic
partition terms included in the displayed energy cutoff J. The Gaussian
claim is used only for fixed witnesses before this union bound. Thus there
is no conditional-Gaussian assumption concerning an adaptively selected
partition.

The finite class has `Q(d+2)+(H-1)Q^2+HQ` parameters, including its
perspective scales, and is independent of N and t. The grid error at most
1/32 combines with the support comparison 1/16 to give 3/32. Consequently
the ramp thresholds 11/32 and 13/32 correctly separate the test margin
1/4 from the training margin 1/2. The two discarded posterior masses are
each at most epsilon/4; the stated sample size makes the finite-class risk
at most epsilon/2. This proves the simultaneous N,t quantifiers on one
sample event.

The appendix's robust cylinder maps into itself under its unsigned clone
projections, because the teacher rows agree within groups, scalar coordinate
intervals are convex, and the unconstrained Gaussian bulk annihilates the
preceding population space. Both original and projected outputs have signed
margin greater than one, so their clipped comparison holds exactly. The
stronger energy lower bound and readout l1 upper bound above justify the
normalized population budget with constant 4, including C=1.

The local operator certificate is also valid. The merged trajectory can be
realized as the original network plus postactivation errors, whose total
RMS norm is at most the square root of the sum of the squared displayed
defects. The final readout is unchanged on the last projected state. On the
cylinder the row-constant teacher and annihilating bulk leave only the
constrained coordinate errors, giving exactly the displayed defect bounds.
The smaller radius therefore gives a positive-mass sufficient condition;
its extra logarithmic cost does not change the width exponent.

Finally, the literal degree-nine envelope is justified. For a single-output
fanin-two teacher, prune unused ancestors at each stage and retain any
needed constant wire. The resulting width C' is at most C and at most
`2^(H-1)+1`, so `log C'=O(L)`. Put
`S=2+d+L+c+log(4/epsilon)`. Then, with absolute constants,

    A,a = O(S),               log(1/rho) = O(S),
    D_* = O(C' S^3),          Q = O(C' S^3),
    J = O(C' S^4),            D_Q = O(C'^2 S^7),
    log(3+4R/zeta) = O(S^2).

Thus the sample budget is bounded by an absolute constant times
`[C^2 S^9+log(1/delta)]/epsilon`. Using the pruned target is legitimate:
the support event does not depend on its width, and all requested learner
widths N>=C also satisfy N>=C'. For the local-certificate version, adding
`c^(-1)` to S bounds the additional logarithmic radius cost and gives the
same degree. The scale parameters contribute only HQ and do not increase
that degree.

No claim follows that the support condition is prevalent in ordinarily
trained networks. Ordinary dropout stability is specifically not established:
the paper's Gaussian-bulk calculation correctly shows why the existing
target cylinder does not give that property automatically at mean field.
