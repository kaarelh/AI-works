# A sharp critical bottleneck from capped variance occupation

26 October 2026. Exact tanh, critical prefactor t=1, arbitrary finite-entropy row controls. This is a variational occupation theorem.

Let a full-cube hard-margin path have H hidden layers, initial maximum variance q_0<=2, maximum variances q_j=max_x Q_j(x,x), and total action

    A=sum_(j=1)^H D_j+readout <=V_*+epsilon,
    0<=epsilon<=1.

The universal scalar estimates give

    q_j−q_(j−1)<=−c q_(j−1)²+C D_j,                 (1)

with fixed positive constants, and every suffix after layer j has action at least V(q_j). For small q,

    V_*−V(q)<=Cq.                                    (2)

## 1. Dyadic-band occupation without monotonicity

Fix sufficiently small u>0. Let j be the LAST hidden-layer index for which q_j<=2u, if one exists. Its entire hidden prefix entropy satisfies

    sum_(i=1)^j D_i <=A−V(q_j)<=epsilon+C u.          (3)

Use the capped potential

    g_u(q)=min(q,2u).

If q<=2u, then g_u(q')−g_u(q)<=q'−q; if q>2u, its change is nonpositive. Equation (1) therefore implies

    g_u(q_i)−g_u(q_(i−1))
       <=−c q_(i−1)² 1_{q_(i−1)<=2u}+C D_i.

Sum through j, use g_u(q_0)<=2u and g_u(q_j)>=0, and apply (3). The number of pre-states q_(i−1) in [u,2u] for i<=j is at most

    C/u+C epsilon/u².

There can be at most one additional pre-state in this band after those counted: q_j itself, when j<H. All later states exceed 2u by definition of j. If no such j exists, only the initial pre-state could contribute. Thus, uniformly without any monotonicity assumption,

    #{0<=i<H : u<=q_i<=2u}
       <=1+C/u+C epsilon/u².                         (4)

Changing endpoints to half-open bands only decreases the count.

## 2. The minimum variance is of order 1/H plus the excess scale

Let p=min_(0<=i<H)q_i. Positive final margin and finite entropy ensure p>0. If p is below a fixed small cutoff u0, cover [p,u0] by the dyadic bands [2^k p,2^(k+1)p]. Sum (4):

    number of pre-states below u0
       <=C/p+C epsilon/p².

The universal quadratic occupation bound from (1) and A<3 gives

    sum_(i=0)^(H−1) q_i²<=C,

so the number of pre-states at least u0 is at most a universal constant. Enlarging constants also handles p>=u0. Consequently

    H<=C/p+C epsilon/p²,

and solving the quadratic inequality yields

    min_(0<=i<H) q_i
       <=C/H+C sqrt(epsilon/H).                      (5)

The same statement on any initial block of length T holds with H replaced by T, provided a full hard-margin continuation still exists after that block: the last-low-layer suffix estimate (3) remains valid. In particular the first half of a path contains a bottleneck obeying (5), up to universal constants.

## 3. Consequences and scope

Together with the joint-growth target-action upper epsilon=O(S_f²/H), this gives a bottleneck of size O((1+S_f)/H) on any qualifying nearbaseline path, provided that excess is at most one (for example H>=C S_f²). It removes a logarithm arising from bounding the minimum by the average variance occupation.

For the first-aligned-crossing argument, one may now take

    E=epsilon+C q_b
      <=C[epsilon+H^(-1)+sqrt(epsilon/H)]

at a bottleneck in the first half. All subsequent signed-alignment and small prefix-entropy statements remain unchanged.

These estimates apply to arbitrary internal row laws; no Gaussian or bounded-density hypothesis is used. They do not supply the missing scalar-feature compiler or a new polynomial learning theorem for arbitrary deep teachers.

## Sources

The maximum-variance drift and quadratic occupation are proved in universal-quadratic-variance-and-diagonal-occupation.md. The scalar suffix comparison and bridge (2) are in critical-depth/source/critical-rate-foundations.tex. This proof uses only the coarse bridge, not the sharper first-order value expansion.

