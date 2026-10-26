# Quantitative scalar decrease and signed-feature alignment near the critical baseline

26 October 2026. This note concerns the unrestricted critical tanh row-control variational problem, with hard margin 1/2 on the entire Boolean cube. It does not assume Gaussian internal controls. It does not by itself prove a polynomial-depth sample bound or a circuit compiler.

## 1. Scalar value decreases quantitatively away from zero

Let V(q) be the unrestricted scalar Bellman value, with transition q' = E_eta tanh² Z, reference N(0,q), and terminal cost 1/(8q). The scalar foundations prove:

- V is nonincreasing and V(q)<2.
- Nearoptimal paths may be chosen strictly increasing.
- Each scalar transition obeys D >= q'−q+c q².
- V(q)=V_*−2q+O(q²) as q tends to zero.

The first three facts are in critical-rate-foundations.tex; the fourth is in the published critical-depth/source/unrestricted-critical-scalar-expansion.tex.

**Proposition.** For every a in (0,1), there is c_a>0 such that

    V(v)−V(q) >= c_a(q−v),   a<=v<=q<=1.               (1)

One can take c_a >= exp(−C/a³), after increasing a universal C.

**Proof.** Take a strictly increasing scalar path from v with total cost at most V(v)+eta<3. Since every state is at least a and at most one, summing scalar dissipation shows its number m of hidden transitions is at most C/a². Each individual transition law has relative entropy at most three with respect to a Gaussian of variance at most one. Gaussian entropy duality with parameter 1/4 therefore gives

    E_eta Z² <= 4D+2log2 <=14.

Its next output variance is at least a. Put r=sqrt(a)/2 and R=sqrt(56/a). The contribution to E tanh² Z from |Z|<r is at most a/4; from |Z|>R it is at most P(|Z|>R)<=a/4. Hence the annulus r<=|Z|<=R has probability at least a/2.

For 1<=s<=1/a, differentiation under the finite-second-moment integral gives

    d/ds E_eta tanh²(sqrt(s) Z)
       = E_eta [(Z/sqrt(s)) tanh(sqrt(s) Z)
                               sech²(sqrt(s) Z)]
       >= k_a,

where k_a may be chosen as c a³ exp(−C/a), and reduced to lie in (0,1). The annulus proves the lower bound: on it the three nonnegative factors are bounded below by a/2, c sqrt(a), and c exp(−C/a), respectively, and the annulus probability is at least a/2.

Now start the same control sequence at the larger variance q. At each stage scale its preactivation control by the square root of the ratio of the new preceding state to the original preceding state. Relative entropy is unchanged. All state ratios lie in [1,1/a]. If the difference between the two preceding states is Delta, then the rescaling ratio differs from one by Delta divided by the original state, hence by at least Delta. The next state difference is therefore at least k_a Delta.

The final state difference is at least k_a^m(q−v). The saved terminal cost is at least one eighth of this difference, since both final variances are at most one. Thus

    V(q) <= V(v)+eta−(k_a^(C/a²)/8)(q−v).

Let eta decrease to zero. The stated exponential lower bound for c_a follows. The length-zero case satisfies the same inequality directly. This proves (1).

This proof needs no differentiability of V and no existence of an optimal finite scalar path.

## 2. A nearbaseline hard-margin path has nearly aligned signed features

Consider any full-cube critical row-control path with total action at most V_*+epsilon and outputs satisfying f(x)z(x)>=1/2. Suppose layer b is a bottleneck whose maximum feature variance is at most q_b. At a later layer j, let u_x be a Hilbert feature realization of its covariance, and put

    q=max_x ||u_x||².
    Choose x_* attaining q.
    w_x=f(x)u_x,       w_*=f(x_*)u_(x_*).
    v_x=||(w_x+w_*)/2||².
    E=epsilon+C q_b.

Every v_x is positive: finite entropy preserves a zero signed-pair variance through subsequent odd tanh layers, which would contradict the stipulated final signed pair margin. Thus V(v_x) is always evaluated on its positive domain.
Here C is the universal small-state Bellman bridge constant; assume q_b is in its stated small-variance range.

The scalar comparison for the fixed anchor x_* bounds the action between b and j below by

    V(q_b)−V(q).

This uses the actual variance of x_* at b, which is at most q_b, and monotonicity. The signed-pair scalar comparison bounds the remaining action, including the readout, below by V(v_x). Earlier action is nonnegative. Consequently, for every cube input x simultaneously,

    0 <= V(v_x)−V(q) <= E.                            (2)

Also,

    q−v_x = (q−||u_x||²)/2+||w_x−w_*||²/4
           >= ||w_x−w_*||²/4.                         (3)

Thus the nearbaseline action is a direct global signed-feature alignment constraint.

### Small-variance range

For q below the universal range of the scalar expansion, use v_x<=q and the expansion at both arguments:

    V(v_x)−V(q) >= 2(q−v_x)−Cq².

Equations (2)–(3) give

    ||w_x−w_*||² <= C(E+q²),
    ||w_x−w_*||²/q <= C(E/q+q).                       (4)

No uniformity over the number of inputs is lost.

### Fixed positive variance range

Fix any q0>0. If q>=q0 and E is smaller than the fixed positive gap V(q0/2)−V(q0), then (2) forces v_x>=q0/2. Apply (1), with a=q0/2, to obtain

    ||w_x−w_*||² <= (4/c_(q0/2)) E.                  (5)

The constant is universal once q0 is fixed, although the elementary proof gives poor dependence on q0.

### One uniform qualitative consequence

For every prescribed radius eta>0 there are fixed constants K_eta and E_eta>0 such that, whenever E<=E_eta and q>=K_eta E, every signed normalized feature lies within eta of the maximum-norm anchor:

    sup_x ||w_x−w_*||/sqrt(q) <= eta.                (6)

Indeed choose q0 sufficiently small in (4), then K_eta sufficiently large, and finally use (5) above q0. This is an exact variational statement for arbitrary finite-entropy internal row laws.

## 3. What this does and does not resolve

The conclusion applies at every post-bottleneck layer whose variance exceeds a sufficiently large constant times the total excess E. It does not assert that those variances are monotone or that the feature law is a ridge tilt. The low-variance prefix may still contain task-dependent directions that are later amplified.

In particular, (6) locates the full hard-margin path inside a signed rank-one neighborhood after its variance has grown enough, but it does not supply a scalar-formula representation of the small residual or a stable replacement by scalar Bellman-optimal ridge laws. Those remain the original polynomial-depth learning gap.

