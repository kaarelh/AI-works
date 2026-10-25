# Empirical quality for normalized angular/radial tanh transport

25 October 2026. Companion to `nearcritical-normalized-coupling.md`. The argument below proves its global small-quality empirical transfer with no inverse-epsilon constants, and gives a uniform large-quality bound. The local matrix-derivative transfer is a separate interface described at the end.

Throughout 1<=t<=2, 0<q<=2,

    T(q)=E tanh^2(t sqrt(q)Z),
    phi_q(z)=tanh(t sqrt(q)z)/sqrt(T(q)),
    R_q(z)=q partial_q phi_q(z).

The continuous limits at q=0 are phi_0(z)=z and R_0(z)=0. Let P be standard Gaussian law on R^m and P_N its iid N-sample empirical measure.

## 1. A compact class with direct Gaussian envelopes

For unit vectors u,v in R^m, use the three types of feature

    B_(q,u)(G)=phi_q(u.G),
    A_(q,u,v)(G)=phi'_q(u.G) (v.G),
    R_(q,u)(G)=R_q(u.G).                             (1)

All indices range over compact sets: q in [0,2] and unit direction spheres. Uniformly in these indices,

    |B| <= C|u.G|,
    |A| <= C|v.G|,
    |R| <= C|u.G|.                                  (2)

For B,A this follows from a uniform lower bound on T(q)/q and the boundedness of tanh' and tanh(z)/z. For R, differentiate normalized tanh in log q. The unnormalized term is a fixed bounded multiple of z sech²(t sqrt(q)z); the derivative of the normalization contributes a bounded multiple of phi_q(z), since 0<=qT'(q)/T(q)<=1. Thus (2) holds even though the population L2 norm of R is only O(q).

These functions also have pointwise polynomial envelopes for first derivatives in all compact parameters, including q at zero. One way to check this is to write

    tanh(sqrt(s)z)/sqrt(s)=z b(sz²),
    b(r)=tanh(sqrt(r))/sqrt(r),

whose required derivatives are bounded on [0,infinity). The scalar normalization T(q)/q is smooth and bounded away from zero on [0,2]. Consequently a fixed polynomial C(1+||G||^M), with M independent of m,N,q,t, bounds the parameter Lipschitz constants of every product of two features from (1). Their population parameter Lipschitz constants are dimension independent by Gaussian Holder bounds, as in the pair-quality note.

## 2. Uniform product concentration

Let D be the union of the three feature classes in (1). For every fixed D_1,D_2 in D, the product D_1D_2 is subexponential with a uniform constant. Indeed (2) bounds its absolute value by a fixed multiple of |a.G||b.G| for two unit vectors a,b; Gaussian quadratic exponential moments give the assertion, regardless of their correlation.

Thus Bernstein's inequality gives

    P{|(P_N-P)(D_1D_2)|>C(sqrt(v)+v)} <= 2 exp(-cNv).

For v in [C m log(eN)/N,v_0], uniformize this inequality as follows. Restrict to

    max_j ||G_j|| <= T,   T²=C[m+log(2N)+Nv],

whose failure probability is at most exp(-cNv). A parameter net of mesh sqrt(v)/[C(1+T^M)] changes empirical products by at most sqrt(v); it changes population products by at most the same amount after enlarging C. The parameter dimension is at most 4m+2, so its log cardinality is O(m log(eN)), because T²<=CN and log(1/v)<=C log(eN). A union bound and adjustment of constants prove

    sup_(D_1,D_2 in D) |(P_N-P)(D_1D_2)| <= C sqrt(v) (3)

outside probability C exp(-cNv). This is a compact derivative-product net. No normalization by a possibly tiny cubic-secant population norm, and no unbounded log-scale parameter, is used.

The event (3) is exactly rotation invariant because all direction choices are included. It is measurable by compact parameter continuity. It can be intersected with the existing scalar/matrix/rare-strip quality events while retaining their conservative baseline tau=Cm^4log(eN)/N and tail exp(-cN(v-tau)).

## 3. Integrating derivative products controls mixed secants

Consider two normalized scalar features B_a=phi_q(u.G), B_b=phi_p(w.G), with q,p>0 and u,w unit. Define their geometric distance

    delta²=||u-w||²+[log(q/p)]².

Connect u to w by a shortest spherical arc at fixed q, then q to p by a log-linear scale path at fixed w. The total angular/radial path length is

    L=arccos(u.w)+|log(q/p)| <= C delta.              (4)

At each point the directional derivative, divided by its scalar speed, is a member of the A or R class. The fundamental theorem of calculus, twice, and (3) therefore give

    |(P_N-P)(B_a-B_b)²| <= C sqrt(v) delta².          (5)

Similarly the derivative of B² is twice B times one of these derivative features; hence

    |(P_N-P)(B_a²-B_b²)| <= C sqrt(v) delta.          (6)

Every B has PB²=1, and (3) also gives

    |P_N B²-1| <= C sqrt(v).                         (7)

The path constant in (4) multiplies only the empirical error in (5), not the population covariance contraction or expansion. This distinction is essential near criticality.

For antipodal directions a spherical arc exists when m>=2. The m=1 case can instead handle the two directions directly using oddness; all intended Boolean-cube applications have m=2^d>=2.

## 4. Correct empirical normalization and the global joint metric

Write sigma_a²=P_NB_a², sigma_b²=P_NB_b². The exact identity

    P_N(B_a/sigma_a-B_b/sigma_b)²
      =[P_N(B_a-B_b)²-(sigma_a-sigma_b)²]/(sigma_a sigma_b)

and (5),(7) imply

    P_N(B_a/sigma_a-B_b/sigma_b)²
       <=(1+C sqrt(v)) P(B_a-B_b)²+C sqrt(v)delta².   (8)

Also (6),(7) give

    |log(P_NB_a²)-log(P_NB_b²)| <= C sqrt(v)delta,     (9)

since the population second moments are equal to one. The empirical output variance at input (u,q) is T(q)P_NB_a². Thus (9) is exactly the error in the logarithmic diagonal transition.

For correlation matrices C,C', choose optimal Bures factors with unit rows, and use their common Gaussian array. Sum (8) over rows to upper-bound the output correlation Bures distance. Combine (9) with the scalar log map and the exact population row-coupling estimate from `nearcritical-normalized-coupling.md`. If

    D²=d_B(C,C')²+sum_i[log(q_i/p_i)]²,
    q_max=max_i(q_i,p_i),

the actual same-array transition satisfies

    D_next <=[1+C q_max²+C sqrt(v)]D.                (10)

In particular the q_max² term is O(epsilon²) in the nearcritical variance band. All constants remain uniform as any q_i or p_i tends to zero.

## 5. Large-quality global bound

For quality v>=v_0, the existing all-quality scalar estimate and the empirical Gaussian covariance bound give, simultaneously for all q,u,

    exp(-Cv) <= P_N phi_q(u.G)² <= exp(Cv),
    ||P_N GG^T||op <= C(1+v).                        (11)

The constants absorb additive ones because v>=v_0>0. By (2), the empirical L2 norms of B and every unit angular/radial derivative are at most C sqrt(1+v). Divide each feature by its empirical norm. The derivative of this normalization is bounded by twice the unnormalized derivative norm divided by the feature norm. From (11), the empirical unit-sphere feature map consequently has derivative norm at most exp(Cv) in every angular/log-radial direction.

The derivative of log(P_NB²) is bounded by twice the derivative norm divided by the feature norm, also exp(Cv). Integrating along the path from Section3, using that the scalar log T map is 1-Lipschitz, yields

    D_next <=exp(Cv)D.                              (12)

No factor epsilon^-1 occurs. Taking the logarithm and combining (10),(12) gives the uniform all-quality global log gain

    log(D_next/D) <= C q_max²+C(sqrt(v)+v).          (13)

The bounds in (11) must hold along the entire angular/log-radial path; their uniform feature indexing ensures this.

## 6. Local matrix covariance and derivative quality

Fix a constant white operator ball ||C-I||op<=rho<1/4, and let B be any row-unit factor of C. Put

    h(G)_i=phi_(q_i)((BG)_i),
    F=P hh^T,    K=P_N hh^T,

with all q_i in [0,2]. In this section every displayed derivative is evaluated along paths whose rows of B stay unit length, so diag(F)=1 identically. The covariance and raw derivative classes nonetheless allow arbitrary perturbation matrices when taking their uniform bounds.

The dimension-free covariance estimate is

    ||K-F||op<=C sqrt(v).                            (14)

For a unit vector u, u^T h is centered and Gaussian-Lipschitz with constant at most C||B||op; hence its square is uniformly subexponential. The usual parameter net (B,q,u), of dimension O(m²), proves (14).

For the derivative estimate, let E be an angular factor perturbation and r a logarithmic scale perturbation. Then

    dot h_i=phi'_(q_i)((BG)_i)(EG)_i+r_i R_(q_i)((BG)_i).

For symmetric M with ||M||F=1, the covariance derivative paired with M is

    Y=2(Mh)^T dot h.                                 (15)

The angular part has absolute value at most C||Mh|| ||EG||. Gaussian Poincare and the uniform coordinate Lipschitz property of h give

    E||Mh||²<=C||M||F²,

and ||Mh|| is Gaussian-Lipschitz with constant C||M||op||B||op. Thus it is subGaussian with scale C||M||F. Also ||EG|| is subGaussian with scale C||E||F.

For the radial part, the vector diag(r)R_q(BG) has subGaussian norm with scale C||r||2. To verify this, R_q(z) is odd and uniformly Lipschitz in z. Differentiating its explicit log-scale formula proves the latter: the only potentially unbounded factors have the forms x sech²(x) or x sech²(x)tanh(x), both bounded on the real line; all normalization factors are uniformly bounded on q in [0,2]. Gaussian Poincare gives mean squared norm at most C||r||2², and its Lipschitz constant is at most C||diag(r)B||op<=C||r||2. Therefore the radial part of (15) is also subexponential with scale C||M||F||r||2.

Bernstein followed by the same cutoff net as before, now over B,q,M,E,r with Frobenius/Euclidean unit tangent norms, proves

    ||(P_N-P)(dot h h^T+h dot h^T)||F
       <=C sqrt(v)(||E||F+||r||2).                  (16)

The parameter dimension is O(m²), radius polynomial in m, and parameter derivatives have fixed polynomial Gaussian envelopes, including at q=0. The threshold Cm²log(eN)/N is sufficient; the existing conservative Cm^4log(eN)/N quality floor dominates it. Rotating the Gaussian coordinates preserves the full indexed class exactly.

## 7. Empirical correlation normalization preserves derivative accuracy

Write A=K-F and D_N=diag(K)=I+diag(A). The empirical output correlation is

    K_normalized=D_N^(-1/2)(F+A)D_N^(-1/2).

By (14), ||A||op<=eta=C sqrt(v), so all diagonal normalization factors are within 1+Ceta of one. Define the normalized error

    E_normalized=K_normalized-F.

It has operator norm at most Ceta. Along a row-unit factor path, diag(dot F)=0. Hence (16) also gives

    ||dot D_N||F=||diag(dot A)||2
       <=Ceta(||dot B||F+||dot log q||2).

Differentiate the displayed normalization formula. Terms involving dot A are bounded by (16). Terms involving dot D_N are bounded by its Frobenius norm times the bounded operator norms of F,A and the normalizing diagonals. The remaining terms contain dot F multiplied by a normalization factor minus the identity; they cost at most Ceta||dot F||F. The population version of the dual estimate (15) gives ||dot F||F<=C(||dot B||F+||dot log q||2). Consequently

    ||dot E_normalized||F
       <=Ceta(||dot B||F+||dot log q||2).             (17)

The empirical logarithmic output-variance error is log diag(K), since the physical population output variance is T(q_i). Its derivative has the same Euclidean bound, by the diagonal estimate above.

Given two input correlation matrices in the fixed white ball, interpolate C_s=(1-s)C+sC', take the canonical roots B_s=sqrt(C_s), and interpolate log q linearly. The path remains in the white correlation ball and its rows remain unit length. The standard positive-definite square-root derivative estimate gives

    integral ||dot B_s||F ds <=C||C-C'||F<=C d_B(C,C').

The constants here multiply only the empirical error. Integrating (17) proves

    ||E_normalized(C,q)-E_normalized(C',p)||F
       <=C sqrt(v) D((C,q),(C',p)),                  (18)

and the analogous bound for the log-diagonal error. Together with the operator bound, these are precisely the local empirical-error estimates required in Section5 of `nearcritical-normalized-coupling.md`.

Its population local contraction, plus the common-additive-error Bures comparison on a fixed positive-definite operator ball, now yields

    D_next<=[1-c epsilon²+C sqrt(v)]D                 (19)

for the canonical-root same-array coupling in the nearcritical variance band. In particular v<=c epsilon^4 gives strict contraction. The scalar quality estimates ensure all empirical normalizations are valid, and the matrix qualities are uniform over all path factors and tangents. Switching past-measurably between this local coupling and the global optimal-factor coupling preserves both exact Gaussian transition marginals.

## 8. Scope

The note supplies the global and local uniform empirical estimates and their exponential failure scales. They can all be included in one independent-array quality with baseline Cm^4log(eN)/N and exponential tail exp(-cN(v-tau)). It does not by itself prove the proposed posterior flattening theorem: one must also combine scalar/spectral occupation, the all-label mass witness, the total quality budget, and the final rare-margin readout probability comparison.
