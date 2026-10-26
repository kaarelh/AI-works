# Positive target mass just above the critical tanh prefactor

26 October 2026. Exact tanh, original independent Gaussian width powers,
and the original all-cube margin event. This is a finite-width target-mass
theorem, not only a variational construction. It extends the critical
scalar-channel construction by keeping the uncontrolled perpendicular
Gaussian variance at its actual value.

## 1. Statement

Let H be the number of hidden layers, d>=1, and f:{-1,1}^d->{-1,1}.
Write

    AF(f)=sum_T |fhat(T)|,
    R0=(d+H+2) AF(f),
    S=1+log R0.

The prior mu_(N,t) has variances t²/d in the first layer, t²/N in later
hidden layers, and t²/N² in the readout. Put t=1+delta.

There are universal positive constants delta0,C0,C1,C2 such that, for
0<=delta<=delta0 and H>=C0 S, at EVERY integer width

    N>=exp[C1(S+delta H)],

the actual raw probability satisfies

    mu_(N,t){ f(x)z_W(x)>1/2 for every cube input x }
      >=exp{-N[V_*+C2(S+delta H)^2/H]}.                (1)

Here V_* is the unrestricted critical scalar tanh baseline, with
terminal cost 1/(8q). It is not a supercritical or Gaussian-restricted
baseline.

In particular the critical target-mass scale persists when
delta H=O(S). Combining (1) with the separately audited positive-gain
theorem in nearcritical-supercritical-positive-gain.md gives the same
polynomial resource regime when this relation holds. This note proves
the target-mass input to that consequence.

The proof uses the existing exact Fourier seed and finite-channel
probability lemma in critical-analytic-target-mass.md, specialized to
tanh. All changes needed for t>1 are proved below. No Gaussian reference
is rescaled simultaneously in all row-space dimensions.

## 2. A uniform seed and free cooling above the variance floor

The Fourier seed construction gives iid score/feature pairs with

    E b_1²=1,
    E[b_1 h_1(x)]=sqrt(v_1) f(x),
    D_1<=1/H,
    v_1>=exp(-CS),      |b_1|<=exp(CS),

and constant feature diagonal. It works uniformly for 1<=t<=1+delta0.
Indeed every shifted first-row Gaussian uses the actual covariance
t² I/d. Its shift KL is no larger than at t=1, and its preactivation
noise variance is at most 2t², a fixed constant. The saturated threshold
detectors, cube-translation parity projection, and Fourier mixture
therefore have the same polynomial bounds with uniform constants.
The reference uses the same Bernoulli tag but zero mean shifts; its
weight marginal remains exactly the actual prior.

Let F(q)=E tanh²(sqrt(q)Z). There are universal c,C>0 such that

    q-F(t²q)>=c q² whenever K delta<=q<=1,              (2)

for a sufficiently large fixed K. To see this, the critical free
cooling estimate gives q-F(q)>=c0 q² on this interval. Also F is
1-Lipschitz: differentiating by the heat equation gives
F'(q)=E[sech^4-2 tanh² sech²]<=1; monotonicity follows directly
from tanh² increasing in absolute value. Hence

    F(t²q)-F(q)<=(t²-1)q<=C delta q,

which proves (2).

Choose a cooling threshold Delta>=K delta, sufficiently small.
Free supercritical layers cool to the first q<=Delta in O(1/Delta)
steps, and the first value lies in [Delta/2,Delta]. The latter follows
from F(t²q_prev)>=F(Delta)>=Delta/(1+3Delta).

If Q>=v ff* has constant diagonal q, the free next component can be
tracked at

    v_next=t²v [1-F(t²q)]².

Its component/diagonal ratio is multiplied by

    [t²q(1-F(t²q))²]/F(t²q)=1+O(q²)

near zero, with a positive uniform compact-interval lower bound.
Equation (2) bounds the sum of q² before the threshold by a universal
constant. Thus free cooling retains component at least c Delta v_1.
If the initial diagonal is already below Delta, cooling is omitted.
One may reduce the tracked component exactly to

    v_0=Delta exp(-C3 S)

using the same independent-sign score mixture as in the critical proof.

## 3. Holding and growth with the actual perpendicular variance

Suppose Q=v ff*+R, with R>=0 and constant diagonal r<=Delta.
Keep the perpendicular Gaussian covariance at its ACTUAL value t²R.
Choose the target scalar preactivation variance a v. The controlled
preactivation covariance is then

    a v ff*+t²R.

Its charged entropy is at most the one-dimensional latent cost

    d_t(a)=(1/2)[a/t²-1-log(a/t²)].                    (3)

This allows a<t²; it is not restricted to inflation relative to the
supercritical reference.

Write psi_s(z)=E tanh(z+sqrt(s)Z). The full conditional-mean component is

    v'(a)=E psi_(t²r)(sqrt(a v)Z)².

It is continuous and increasing in a. At a=1 it is at most v by the
unit Lipschitz bound. The first-Hermite estimate gives

    v'(a)>=a v [1-F(a v+t²r)]²
           >=a v[1-2(a v+t²r)].                       (4)

Therefore a in [1,1+C(Delta+v)] can hold v exactly, or realize the
prescribed growth

    v_next=min{p, v[1+c1(Delta+v)]},

for a fixed small c1 and sufficiently small Delta+v.
In both holding and growth, choose a so the FULL conditional-mean component v'(a) equals the prescribed next component. There is no score downgrade whose discarded variance would have to be added to the residual barrier.
Since Delta>=K delta, (3) is bounded by C(Delta+v)².

The residual need not be nonincreasing at every small value, but has
the invariant upper bound Delta. Conditional Gaussian Poincare gives

    r'<=t²r E sech^4(sqrt(a v+t²r)Z).

For small u, E sech^4(sqrt(u)Z)<=1-c u. Consequently

    r'<=t²r(1-c t²r).

This last upper bound is increasing for 0<=r<=Delta, and is at most
Delta at r=Delta if K is large enough. Thus r'<=Delta throughout,
including arbitrarily long holding intervals.

The critical telescoping estimates now apply with unchanged orders:

    holding cost <=C H Delta²,
    growth length <=C S/Delta,
    growth cost <=C[p+S Delta],
    growth square-root cost <=C[S+log(p/Delta)+1].

The growth sequence and its length are fixed before the holding
interval is inserted.

## 4. Purification and the scalar suffix

At v=p>=Delta, choose a=1+O(p) to hold the target component exactly.
For r<=Delta, the same derivative Poincare estimate yields

    r'<=t²r(1-cp)<=(1-c'p)r

provided p>=K' delta. Every such step has cost O(p²).
After T=ceil[C log(H+2)/p] steps the residual is at most

    r_0<=Delta(H+2)^(-4),

at cost O(p log(H+2)) and square-root cost O(log(H+2)).

Choose a strictly increasing critical scalar path from p, of cost
at most V(p)+p, length m<=C/p, and square-root entropy sum
O(log(2/p)). Such paths are established in the critical scalar
foundations. For one of its transitions eta from variance q to q',
q'>q and tanh²z<=z² give E_eta Z²/q>=1. The exact change of reference is

    KL(eta||N(0,t²q))
      =KL(eta||N(0,q))+log t
          -(1-t^(-2)) E_eta Z²/(2q)
      <=KL(eta||N(0,q))+C delta².                      (5)

Lift this scalar law along the tracked target direction, rescaling
by sqrt(v/q), and leave the Gaussian residual at covariance t²R.
The entropy charge is bounded by (5). The residual obeys r_next<=t²r,
so along m<=C/p steps,

    max r_j<=r_0 t^(2m)<=C r_0,

because delta/p is bounded. The critical tanh heat-convolution estimate
therefore preserves the scalar target component up to multiplicative
loss exp[-C sum r_j]=1-O(m r_0). Its extra readout cost is O(m r_0).
The actual readout coefficient 1/(8t²v_final) is no larger than the
critical one used for this comparison.

The extra hidden cost of the suffix is O(delta²/p), and its extra
square-root cost is O(delta/p). The residual is never artificially
contracted in the perpendicular row space.

## 5. Exact-depth action and program resources

Put U=S+delta H and choose fixed sufficiently large B1,B2 with B2>=B1:

    Delta=B1 U/H,          p=B2 U/H.

Take delta0 sufficiently small and H>=C0 S sufficiently large so both
scales lie in all required small-variance intervals. They exceed the
required multiples of delta.

Cooling, prescribed growth, purification and the chosen scalar suffix
use at most H-1 layers if B1 and then B2 are large enough. Fill exactly
the remaining layers by holding v_0 before growth. All subsequent
stage lengths are fixed independently of that holding time.

The resulting scalar-channel program has action and square-root cost

    A=sum_j D_j+1/(8t²v_H)
      <=V_*+C[1/H+H Delta²+S Delta
               +p+p log(H+2)+delta²/p+H^(-4)]
      <=V_*+C U²/H,

    K=sum_(j>=2) sqrt(D_j)<=C U.                       (6)

Explicitly, the square-root budget is bounded by C[H Delta+S+log(H+2)+log(2/p)+delta/p], which is O(U).
For the final inequality use S>=1+log(H+2), U>=S and delta H<=U.
In particular delta²/p <=C U/H<=C U²/H.
Every positive tracked component is at least exp(-CU), and all scores
are bounded by B<=exp(CU). The exact ideal moment identities remain

    E b_j²=1,
    E[b_j h_j(x)]=sqrt(v_j) f(x),
    E h_j(x)²=v_j+r_j.

## 6. Finite width and raw probability

The scalar-channel finite-width proof transfers with one explicit
change. For empirical score coefficients a_i=b_i/(N sqrt(M)), put
u=sqrt(N)a, so ||u||=1, and draw an incoming row as

    w=[Z u+t(I-u u*)xi]/sqrt(N),                       (7)

where the prescribed scalar law for Z has reference N(0,t²), and xi
is independent standard Gaussian. Under that reference the weight
marginal in (7) is exactly N(0,t² I/N), conditional on every preceding
history. Its KL is at most the prescribed scalar charge D_j.
First-layer tags likewise preserve the exact original reference law.

The one-query empirical comparison is now

    c_hat(x) Z+t s_hat(x) G

versus its ideal counterpart. Gaussian entropy duality gives
E Z²<=t² exp(2sqrt(D_j)). Consequently the component-metric error
recursion has gain t exp(sqrt(D_j)), and the total error is bounded by

    8H exp[K+H log t] sqrt(alpha).                     (8)

The earlier conditional Hoeffding and stopping construction is
unchanged: the observables b², bh(x), h(x)² are bounded, and no
simultaneous comparison of residual correlations is required.
The readout noise has variance at most t²/N, a fixed multiple of the
critical bound, and its mean-shift KL is divided by t².

It follows by the same explicit choices of error and failure budgets
that for any tau>0 the raw target mass is at least exp[-N(A+tau)] if

    N>=C B^4 H^4 exp[4K+4H log t] (A+1)^6(1+tau^(-1))^4
       [log(2^(d+1))+log(H+A+tau^(-1)+3)].              (9)

The constant is uniform for 1<=t<=1+delta0. To spell out the last step,
the controlled process has good-event probability at least 1-kappa
and KL at most N(A+3A kappa), with
kappa=min{1/4,tau/[32(A+1)]}. Binary entropy yields

    -(1/N)log mu_(N,t)(E_f)
       <=[A+3A kappa+N^(-1)log2]/(1-kappa)<=A+tau.

Equation (9) also enforces N>=8/tau. The reference is the actual prior
at every stage, not a dimension-dependent covariance replacement.

Set tau=1/H. By (6), B<=exp(CU), H log t<=delta H<=U,
and H,d,A+1,tau^(-1)<=exp(CU). Every factor in (9) is therefore at
most exp(CU). This proves (1) at every N above the stated threshold.

## 7. Scope

The positive window is delta H=O(S). For Fourier variation polynomial
in d+H, including every parity, S=O(log(d+H)); thus the supercritical
departure may be as large as a constant times log(d+H)/H while the
target-mass resources stay polynomial. A fixed positive delta instead
gives exp(O(delta H)) resources; no polynomial-depth assertion is made
in that case.

The argument does not classify all prior scalings, nor prove a
width-independent polynomial-depth theorem for arbitrary deep
soft-intermediate tanh teachers. It supplies an actual finite-width
target witness for a positive crossover next to the critical prefactor.
