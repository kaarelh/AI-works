# Positive Poisson rank decomposition for a bounded quadratic tanh tilt

25 October 2026. Scratch research. The exact identity and entropy bounds below are proved. A full arithmetic-formula path compiler is not asserted. This addresses the final-layer KKT family, not arbitrary entropy tilts or backward costates.

## 1. Setup and exact positive mixture

Let G be a standard Gaussian in a finite-dimensional Euclidean space, let X_i=<u_i,G>, and assume ||u_i||²<=q<=2. The index set may be any finite set. Write

    F(G)=sum_i beta_i tanh(X_i),   B=sum_i |beta_i|,
    a=B²/2,
    rho(dG)=exp(F(G)²/2) gamma(dG)/Z.

For B=0 the law is exactly Gaussian, so suppose B>0. Draw K~Poisson(a). Conditional on K draw K independent ordered pairs (I_l,J_l), with each individual index sampled with probability |beta_i|/B. Put sigma_ij=sign(beta_i beta_j) and

    w_omega(G)=product_(l=1)^K [1+sigma_(I_l J_l) tanh(X_(I_l)) tanh(X_(J_l))].

Every factor lies strictly between zero and two, so the product is positive. The elementary Poisson product identity gives, pointwise,

    E_omega w_omega(G)
      =exp(a E_(I,J)[sigma_IJ tanh(X_I)tanh(X_J)])
      =exp(F(G)²/2).

Write Z_omega=E_gamma w_omega and rho_omega=w_omega gamma/Z_omega. Then

    pi(domega)=Z_omega P(domega)/Z,
    rho = integral rho_omega pi(domega).                        (1)

Each rho_omega is a tilt only on the span of at most 2K anchor vectors. On its orthogonal complement it retains an independent standard Gaussian. Thus (1) is a positive mixture of independent finite-rank tilts; no signed feature measure or kernel cancellation is required.

The elementary bounds Z>=1 and Z_omega<=2^K show that pi has exponential moments of every fixed order in K:

    E_pi A^K (K+1)^m <= E_P (2A)^K(K+1)^m < infinity             (2)

for every fixed A>0 and integer m>=0. The constant depends on B,A,m but not the ambient dimension, number of anchors, or q<=2.

## 2. Component entropy is quadratically small on average

Let D_omega=KL(rho_omega||gamma). Then for every fixed A>0 and integer m>=0,

    E_pi A^K(K+1)^m D_omega <= C_(B,A,m) q²,                    (3)
    E_pi A^K(K+1)^m sqrt(D_omega) <= C_(B,A,m) q.               (4)

Here is a direct proof with explicit dimension-free ingredients.

First, the identity

    1+sigma tanh x tanh y = cosh(x+sigma y)/(cosh x cosh y)

and log cosh x<=x²/2 give

    E_gamma log w_omega >= -Kq.

Jensen therefore yields

    Z_omega >= exp(-Kq).                                      (5)

Second, for one pair factor h=1+sigma tanh X_i tanh X_j,

    grad h = sigma[u_i sech²(X_i)tanh(X_j)
                  +u_j sech²(X_j)tanh(X_i)],

so E||grad h||²<=4q². The product rule, the pointwise bound h<=2, Minkowski in L²(gamma), and Gaussian Poincare imply

    Var_gamma(w_omega)
       <=E||grad w_omega||²
       <=K² 4^K q².                                         (6)

The loose factor 4^K is convenient and valid also at K=0. The KL-to-chi-square bound gives

    Z_omega D_omega
       <= Var_gamma(w_omega)/Z_omega
       <= K² (4 exp(q))^K q².                               (7)

Integrating (7) against the Poisson law, using q<=2 and Z>=1, proves (3). Cauchy--Schwarz with (2)--(3) proves (4). In particular the constants remain finite under every fixed exponential rank penalty A^K.

A second elementary bound, useful for controlling rare large K, is

    D_omega <= K(log 2+q),                                  (8)

because log(w_omega/Z_omega)<=K log 2+Kq.

## 3. What this gives and what it does not give

At a genuine minimum hard-margin final readout, the existing KKT calculation gives the precise quadratic tilt in section 1, and ||beta||_1<=4A where A is total action (margin 1/2 convention). For near-baseline paths, A is bounded by an absolute constant. Thus all constants in (2)--(4) are uniform for those endpoint laws.

The fixed-rank compiler already available in the scratch research assumes an independent non-Gaussian block plus Gaussian complement. Equation (1) supplies exactly such blocks with random rank, and (3)--(4) preserve the needed small-variance scale q and q² after any fixed exponential rank penalty. This is better than a Hubbard--Stratonovich mixture into linear exponential tilts, whose components generically have entropy of order q rather than q².

To obtain a complete dimension-free endpoint-layer formula interface, one still must verify that the local fixed-rank coordinate-oracle and projection construction can be integrated over this mixture with at most exponential dependence on rank, preserving the literal old-coordinate copy and the scalar norm oracle. A natural candidate is the direct-integral isometry J=direct_integral J_omega: each J_omega embeds the same old state isometrically; hence J is an isometry. Its adjoint and the projection of the small residual require a quantitative work/trace audit. Merely citing a theorem with an unspecified constant C_r is insufficient.

Even such an endpoint interface would not finish the original critical posterior compiler. The backward optimality potentials need not remain bounded quadratic tanh tilts with bounded coefficient l1 norm. The current naive backward costate estimate is Riccati and can grow rapidly. No claim about those earlier laws is made here.

## 4. General symmetric quadratic costates

The same argument applies to every real symmetric coefficient matrix T with

    b=sum_(i,j) |T_ij| < infinity,
    V(G)=.5 sum_(i,j) T_ij tanh(X_i)tanh(X_j),
    rho_T=e^V gamma/Z_T.

No positivity assumption on T is needed. If b=0, the law is Gaussian. Otherwise draw K~Poisson(b/2), and choose each ordered pair (i,j) with probability |T_ij|/b, using sigma_ij=sign(T_ij). The product weights from section 1 then satisfy

    E_omega w_omega = exp(V),
    rho_T = integral rho_omega pi_T(domega),
    pi_T(domega)=Z_omega P(domega)/Z_T.                       (9)

The factor positivity, rank at most 2K, component entropy estimates, and bounds (5)--(8) are unchanged. Here Z_T need not be at least one, but |V|<=b/2 gives Z_T>=exp(-b/2), which only changes constants depending on b. Jensen and |E tanh(X_i)tanh(X_j)|<=q also give Z_T>=exp(-bq/2). Combining the two bounds yields Z_T>=exp[-b min(q,1)/2].

Consequently, for every fixed A>0,m>=0,

    E_(pi_T) A^K(K+1)^m <= C_(b,A,m),
    E_(pi_T) A^K(K+1)^m D_omega <= C_(b,A,m) q²,
    E_(pi_T) A^K(K+1)^m sqrt(D_omega) <= C_(b,A,m) q.        (10)

Thus a uniform bound on entrywise l1 norm of a quadratic costate is enough for the random-rank local interface. The rank-one terminal costate beta beta^T is the special case b=B². A path with arbitrary changing quadratic costates T_j and uniformly bounded b_j is the natural next restricted class, subject to completing the integrated local compiler. The estimates do not show that actual backward costates have uniformly bounded b_j, and their constants can grow rapidly with b_j.

## 5. Higher entropy powers and an exact joint sampler

The deterministic component bound D_omega<=K(log 2+q) immediately strengthens (10): for every fixed p>=1, A>0 and integer m>=0,

    E_(pi_T) A^K(K+1)^m D_omega^p <= C_(b,A,m,p) q².

Indeed D^p<=[K(log 2+2)]^(p-1)D and one applies (10), increasing the polynomial rank weight (or bounding a noninteger power by the next integer). This includes the D² term required by the scalar squared-norm residual factory.

The independent audit also supplies an exact sampler for the joint mixture law. Propose K~Poisson(b), use the same signed pair marks, draw G~gamma, and accept with probability w_omega(G)/2^K. Relative to the original marked Poisson law of mean b/2, the proposal density is exp(-b/2)2^K. Thus the accepted joint law has density proportional to P(domega)gamma(dG)w_omega(G), giving omega~pi_T and G~rho_T. Its acceptance probability is exp(-b/2)Z_T>=exp(-b). No component normalizer needs to be computed. This is a sampling observation, not an efficient bit-complexity or coordinate-oracle theorem.

The local factory constants obtained by integrating a fixed polynomial/exponential penalty in K have the quantitative form polynomial(b+1) exp(Cb), with a fixed universal C after the underlying local factory is fixed. A bounded b is therefore sufficient for a constant local compiler parameter; entropy alone does not bound b. The two-query weak-direction construction in `backward-costate-action-bound-obstruction.md` shows why the bounded-b assumption cannot simply be inferred from bounded total action for arbitrary incoming kernels.
