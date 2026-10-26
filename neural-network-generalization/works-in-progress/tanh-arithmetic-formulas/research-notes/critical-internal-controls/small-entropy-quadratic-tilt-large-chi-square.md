# Small-entropy quadratic tanh tilts can have exponentially large density second moment

26 October 2026. This is a local row-control obstruction. It does not show that the displayed transition occurs in a globally optimal Boolean hard-margin path.

## 1. An exact two-query quadratic tilt

Let gamma_q=N(0,q), with q tending to zero, and set

    F(z)=(tanh z,tanh(2z)),
    psi(z)=tanh(2z)−2tanh z
          =−2tanh³z/(1+tanh²z),
    X(z)=psi(z)².

Thus 0<=X<1, X(z)=4z^6+O(z^8) at zero, and X is strictly increasing in |z|. Define

    A_*=min_(z!=0) z²/(2X(z)).

The minimum is positive and attained on a compact nonempty set K away from zero: the ratio diverges both at zero and at infinity. The function

    Phi(z)=A_* X(z)−z²/2

is nonpositive everywhere, vanishes at zero and on K, and is strictly negative elsewhere. Let b_*=min_(z in K)X(z)>0, fix b0=b_*/2, and put B={X>=b0}. In particular B={|z|>=r0} for some fixed r0>0.

For lambda>=0 define

    d rho_(q,lambda)/d gamma_q=e^(lambda X)/Z_q(lambda).

**Proposition.** For every sufficiently small q there is lambda_q in [0,A_*/q] such that

    rho_q(B)=q²,                                     (1)
    c q <= D(rho_q||gamma_q) <= C q,                 (2)
    chi²(rho_q||gamma_q)
          >=q⁴ exp(c/q)/2−1.                         (3)

The constants are universal for this fixed choice of psi.

### Existence of the chosen tilt

At lambda=0, gamma_q(B)<=2exp(−r0²/(2q))<q². At lambda=A_*/q,

    Z_q=(2pi q)^(-1/2) integral exp(Phi(z)/q) dz
         <=C/sqrt(q).

For this upper bound, Phi<=0 on a fixed compact interval and Phi<=−z²/4 outside a sufficiently large interval, since X<=1.

Fix z_* in K. Smoothness and the maximum property give Phi(z)>=−C(z−z_*)² near z_*. A window of radius sqrt(q) around z_* lies in B for small q and contributes a positive constant to the unnormalized B integral. Hence at this endpoint rho(B)>=c sqrt(q)>q².

The probability of B under the exponential tilt is continuous and nondecreasing in lambda, because B is an upper level event of X. The intermediate value theorem supplies lambda_q and proves (1).

### Entropy and density second moment

On B^c, the critical action Phi is separated from zero away from the origin: all its nonzero zeros belong to K, where X>=b_*>b0. Near zero, Phi<=−z²/4 and X<=Cz^6. Therefore, uniformly for lambda<=A_*/q,

    E_(gamma_q)[X e^(lambda X) 1_(B^c)] <=Cq³.        (4)

Since Z_q>=1 and X<=1, equations (1) and (4) imply

    E_(rho_q) X <=q²+Cq³,
    D(rho_q||gamma_q)
       =lambda_q E_(rho_q)X−log Z_q
       <=(A_*/q)(q²+Cq³)<=Cq.

For the lower bound, binary entropy on B gives

    D >= q² log(1/gamma_q(B))−h(q²)
       >=c q

for small q, because h(q²)=O(q² log(1/q)). Finally Cauchy--Schwarz on B yields

    E_(gamma_q)(d rho_q/d gamma_q)²
       >=rho_q(B)²/gamma_q(B)
       >=(q⁴/2)exp(r0²/(2q)),

which proves (3).

## 2. This law is already an exact entropy-minimizing kernel transition

The logarithmic density is quadratic in the two tanh features:

    lambda_q X
      =lambda_q [(-2,1) F]^2.

Let K_q=E_(rho_q) F F^T. For any nu with the same full two-query feature covariance and finite relative entropy, the quadratic statistic X has the same expectation under nu and rho_q. Consequently,

    D(nu||gamma_q)
      =D(nu||rho_q)+D(rho_q||gamma_q).                (5)

Thus rho_q is the unique entropy-minimizing law for its induced full kernel transition. Local entropy optimality, an exponential quadratic log density, only two queries, and entropy tending to zero do not imply a dimension-free L² density bound.

The costate is already rank one: in the convention log density=(1/2)F^T T F−log Z, it is T=2lambda_q c c^T with c=(-2,1). For the Gaussian and controlled feature covariances Q_gamma and Q_rho, respectively, its covariance-normalized nuclear masses equal

    ||Q_gamma^(1/2) T Q_gamma^(1/2)||_* =2lambda_q E_gamma X=O(q²),
    ||Q_rho^(1/2) T Q_rho^(1/2)||_* =2lambda_q E_rho X=O(q).

These are traces because the normalized matrices are positive semidefinite. The first bound uses X(z)<=Cz^6 and lambda_q<=A_*/q; the second uses (4) and (1). Thus rank-one structure and a small covariance-normalized nuclear norm also do not imply a bounded density second moment. This does not rule out a direct compiler exploiting those structures without a density-moment reduction.

The input query vectors for this transition can be taken as sqrt(q)e and 2sqrt(q)e. Their maximum preactivation variance is 4q. This is an abstract legitimate covariance transition; it is not asserted to be the augmented-cube initial covariance or part of a globally optimal full-cube path.

## 3. A nonlinear weak mode is enhanced over its matched Gaussian

Equation (4) and the B lower bound give

    b0 q² <=E_(rho_q)psi²<=Cq².                       (6)

The matched centered Gaussian has variance q(1+O(q)). Here is a direct check. First,

    Z_q(1−q²)
       =E_(gamma_q)[e^(lambda_q X)1_(B^c)]
       <=1+(A_*/q)E_(gamma_q)[X e^((A_*/q)X)1_(B^c)]
       <=1+Cq²,

so Z_q=1+O(q²). The same argument with z² inserted shows that the controlled B^c contribution to E z² is q+O(q³), up to exponentially small Gaussian tails. On B within a fixed compact interval its contribution is O(q²) by (1). Outside that interval, Phi<=−z²/4 gives an exponentially small contribution. Thus

    E_(rho_q)z²=q+O(q²).

Symmetry gives zero mean. Under the matched Gaussian, psi(z)²<=Cz^6 globally (use boundedness outside a fixed neighborhood), hence

    E_(matched Gaussian)psi²<=Cq³.                   (7)

This gives an enhancement of at least order 1/q in a nonlinear kernel direction despite vanishing entropy and a covariance change of only relative order q.

## 4. Equal-diagonal augmented-cube variant

The phenomenon does not require unequal query norms. For the four inputs x in {-1,1}², take z=(z0,z1,z2) with law N(0,q I_3), features F_x(z)=tanh(z0+z1 x1+z2 x2), and

    psi(z)=(1/4)sum_x x1 x2 F_x(z)
          =−2 z0 z1 z2+O(||z||^5).

This is a nonzero bounded function with a cubic zero at the origin. All four preactivation variances equal 3q, and their covariance is exactly the scaled augmented Boolean input covariance.

Set X=psi² and A_*=min_(X(z)>0)||z||²/(2X(z)). The ratio diverges as ||z|| tends to zero or infinity, so the minimum is attained on a compact nonzero set K; choose b0 below its minimum X as before. The same critical action Phi=A_*X−||z||²/2 is nonpositive. Its normalizer at lambda=A_*/q is now at most Cq^(−3/2). A radius-sqrt(q) ball around one maximizer contributes at least a positive constant to the B numerator, because its three-dimensional Gaussian normalization is q^(−3/2). Thus the endpoint B probability is at least c q^(3/2), still greater than q² for small q. Continuity again supplies a tilt with B probability exactly q².

All entropy and chi-square estimates in (1)–(3) remain unchanged: near zero X<=C||z||^6, its critical weighted expectation is O(q³), and the Gaussian B probability is at most exp(−c/q). The full four-query covariance is again the exactly optimized moment constraint because X is the square of a fixed linear combination of F_x. Symmetry gives zero mean, and the same compact/tail split yields matched preactivation covariance q I_3+O(q²) in operator norm. Under that matched Gaussian E psi²=O(q³), whereas the tilted expectation is Theta(q²).

In the paper's architecture this scaled covariance is an actual first-row prior at d=2 with prefactor t²=2q. This observation does not place the transition inside a globally optimal critical t=1 internal path.

## 5. Scope

The example does not contradict the regular-anchor lemma: its unstable quadratic statistic is a cubic-canceling difference of two tanh features, whereas a single anchor statistic tanh² has no separated maximizing well at its Gaussian-envelope threshold.

It shows why the original unrestricted critical argument cannot assume bounded density ratios or bounded density second moments merely from small row entropy and local moment-optimality. The example is compatible with a simple finite formula; it is an obstruction to that proposed proof shortcut, not a hardness theorem or a counterexample to polynomial-depth learning.

