# Small scalar entropy gives a regular anchor-ridge reference

26 October 2026. This note supplies an exact uniform regularity fact for scalar moment-matching I-projections. It does not infer bounded scalar tilt coefficients from the scalar Bellman value expansion.

## 1. Uniform scalar tilt estimate

For q in (0,2], let gamma be N(0,1) and define

    X_q(z)=tanh²(sqrt(q) z)/q.
    Lambda_q(theta)=log E_gamma exp(theta X_q).
    d rho_(q,theta)/d gamma=exp(theta X_q−Lambda_q(theta)).

For any finite theta this density is well-defined when q>0, since X_q is bounded. The relevant uniform range of theta below is fixed and small.

**Lemma.** There are universal d0,C,theta0>0 such that

    D(rho_(q,theta)||gamma) <= d0
       implies |theta| <= C sqrt(D(rho_(q,theta)||gamma))
                         <= theta0.                 (1)

This holds uniformly over q in (0,2]. In particular the coefficient theta, not theta/q, is controlled by entropy.

**Proof.** Extend X_q continuously at q=0 by X_0(z)=z². For all q in [0,2], 0<=X_q(z)<=z². On any fixed |theta|<=theta0<1/4, dominated Gaussian exponential moments show that Lambda_q and its first two theta derivatives depend continuously on (q,theta), including q=0.

Moreover

    Lambda_q''(theta)=Var_(rho_(q,theta))(X_q)>0

at every point: X_q is a nonconstant function and the tilted measure is equivalent to gamma. Compactness gives positive finite universal lower and upper bounds on this variance for q in [0,2], |theta|<=theta0.

Writing D_q(theta)=theta Lambda_q'(theta)−Lambda_q(theta), one has D_q'(theta)=theta Lambda_q''(theta). Consequently c theta²<=D_q(theta)<=C theta² on this compact range. For q>0, D_q is increasing as theta moves away from zero in either direction, because its derivative has the sign of theta. Thus D_q(theta)>=c theta0² whenever |theta|>=theta0. Choose d0 below that constant and apply the local quadratic estimate. This proves (1).

The proof neither assumes nor establishes theta/q→2.

## 2. Exact full-row anchor projection

Let rho be any full row law of finite entropy D relative to a centered Gaussian reference on a finite query span. Fix an anchor with positive preactivation variance q<=2, and let q' in (0,1) be its controlled next feature variance. There is a unique finite lambda such that

    d bar_rho/d gamma_full
        = exp[lambda tanh²(G_anchor)−log Z_lambda]    (2)

has anchor next variance q'. Existence and uniqueness follow from the strict monotonicity of the mean of the bounded statistic tanh²(G_anchor), whose essential range is (0,1).

The scalar information projection and the entropy chain identity give

    I:=D(bar_rho||gamma_full) <= D,
    D(rho||bar_rho)=D−I.                              (3)

Indeed log(d bar_rho/d gamma_full) is affine in the constrained statistic, so it has equal expectations under rho and bar_rho.

Set theta=lambda q. If D<=d0, (1) yields

    |lambda| q <= C sqrt(I) <= C sqrt(D).             (4)

Thus (2) is a normalized single-ridge quadratic tilt with coefficient absolute mass at most 2C sqrt(D). Its perpendicular Gaussian reference is unchanged.

For sufficiently small d0 it also has a uniform Gaussian quadratic envelope. With Z=G_anchor/sqrt(q), the inequalities X_q<=Z² and Jensen's inequality for the normalizer give, for example,

    d bar_rho/d gamma_full
       <= exp[C sqrt(D)] exp[C sqrt(D) Z²].          (5)

The reverse pointwise bound follows by the same estimates with the sign reversed. In particular every fixed moment of any fixed finite collection of unit linear Gaussian projections under bar_rho is bounded by a constant depending only on the moment and collection size, independent of the query dimension, q, and lambda separately. This does not bound the unnormalized full row norm independently of its dimension.

## 3. Application to a first aligned crossing

Apply the previous note critical-first-aligned-crossing.md. At the first post-bottleneck crossing q_j>K E, the ENTIRE prefix satisfies sum_(i<=j)D_i<=C_K E. Fix an anchor attaining q_j and project every earlier row onto its next scalar variance.

For E small enough, every individual row obeys D_i<=d0. Equations (3)–(5) therefore provide regular ridge reference laws at every prefix stage, with exact conditional-excess budget

    sum_(i<=j) D(rho_i||bar_rho_i)
       =sum_(i<=j)(D_i−I_i)
       <=C_K E,                                    (6)

and each normalized ridge mass at most C sqrt(D_i). This statement includes the high-variance early stages before the bottleneck.

The ridge laws in (6) are references on the ACTUAL incoming query state. Replacing all actual laws simultaneously changes subsequent query states, so (6) is not yet a theorem that the complete path is close to a ridge-controlled path. A stable sequential perturbation or compiler theorem is still required. The uniform quadratic envelopes remove one regularity obstacle to such a theorem without imposing an extra prior-support restriction.

