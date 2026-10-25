# Normalized near-critical covariance transport

25 October 2026. New derivation for audit. This supplies population global and local transport estimates, including unequal coordinate variances. The local white radius is an absolute relative operator radius, rather than a radius of order epsilon squared. The finite-array transfer is stated explicitly in Section5; it uses the same uniform covariance/derivative quality bounds as the existing finite-width argument. This note makes no new assertion about the canonical t<=1 model.

## 1. Definitions and scalar estimates

Write t=1+epsilon with0<epsilon<=epsilon0. Let

    F(u)=E tanh^2(sqrt(u)Z), T(q)=F(t^2q),
    phi_q(z)=tanh(t sqrt(q)z)/sqrt(T(q)).

Thus E phi_q(Z)^2=1. Let a_k(q) be its coefficients in the orthonormal probabilists' Hermite basis. Only odd indices occur. For q in[0,b epsilon], with b fixed, the following bounds hold with absolute constants depending only on b:

    sum_k a_k(q)^2=1,
    J(q):=sum_k k a_k(q)^2
          =t^2q E sech^4(t sqrt(q)Z)/T(q)
          =1+O(q^2),
    a_1(q)^2=1-(2/3)t^4q^2+O(q^3),
    ||partial_q phi_q||_(L2)<=C.                      (1)

On q in[a epsilon,b epsilon], a>0 fixed, the logarithmic scalar derivative satisfies

    0 < q T'(q)/T(q) <= 1-c epsilon.                  (2)

On the larger interval0<q<=b epsilon it is at most one. These follow from

    F(u)=u-2u^2+(17/3)u^3+O(u^4),
    u E sech^4(sqrt(u)Z)/F(u)=1+(4/3)u^2+O(u^3).

The L2 derivative bound in(1) can be checked without termwise asymptotics. Put h_u(z)=tanh(sqrt(u)z)/sqrt(u). Then

    |partial_u h_u(z)|<=C|z|^3,

because |v sech^2(v)-tanh(v)|<=C|v|^3. Also F(u)/u=E h_u^2 is bounded away from zero and has bounded derivative on the compact interval. Differentiating phi=h_u/sqrt(E h_u^2) gives the bound. Its logarithmic derivative has the stronger pointwise bound

    |partial_(log q) phi_q(z)|<=C|z|,                 (3)

although its L2 norm is O(q). The normalized activation itself is uniformly Lipschitz in z.

For later use set M_k=sup_{q in[a epsilon,b epsilon]}|a_k(q)|. The one-dimensional fundamental theorem of calculus, Cauchy--Schwarz, and(1) imply

    sum_(k>=3) M_k^2 <= C epsilon^2.                  (4)

Indeed compare every a_k to its value at one fixed q in the interval, sum the squared increments, and bound them by the interval length times the integral of sum_k |a_k'(q)|^2. Both terms are O(epsilon squared).

## 2. A joint distance with exact population global gain

Write a covariance as Q=D_q^(1/2) C D_q^(1/2), where C is a correlation matrix and q is its positive diagonal. Define

    D((C,q),(C',p))^2
       = d_B(C,C')^2 + sum_i [log(q_i/p_i)]^2.        (5)

Here d_B is the unnormalized Bures distance. The normalized population covariance transition is

    K_q(C)_(ij)=sum_(k odd) a_k(q_i)a_k(q_j) C_ij^k,

and the diagonal transition is q_i -> T(q_i).

Choose optimal factors R,S for C,C', so all rows have norm one and ||R-S||_F=d_B(C,C'). A common standard Gaussian G supplies feature factors phi_{q_i}(R_i G) and phi_{p_i}(S_i G). Write c=R_i dot S_i. Orthogonality of Hermite chaoses gives the exact identity

    E[phi_q(R_i G)-phi_p(S_i G)]^2
      = sum_k[a_k(q)-a_k(p)]^2
         +2 sum_k a_k(q)a_k(p)(1-c^k).               (6)

For odd k and -1<=c<=1, 0<=1-c^k<=k(1-c). Bound the second term using absolute coefficient products and Cauchy--Schwarz. Equation(1) bounds the first term by C(q-p)^2. Thus

    E[feature difference]^2
       <=(1+C epsilon^2)||R_i-S_i||^2
          +C epsilon^2[log(q/p)]^2                 (7)

whenever0<q,p<=b epsilon. The mean-value inequality |q-p|<=b epsilon |log(q/p)| was used here. Summing the chosen feature coupling gives a Bures upper bound. The scalar log map is1-Lipschitz, so

    D(population next states)^2
       <=(1+C epsilon^2) D(input states)^2.          (8)

There is no angular--radial cross term in this estimate. In particular no epsilon-dependent weight on log variances is needed.

The same proof also gives a useful compact-range version. For arbitrary0<q_i,p_i<=2 and1<=t<=1+epsilon0, let q_max=max_i(q_i,p_i). Continuity on the compact scalar interval, including the expansion at zero, gives J(q)<=1+Cq^2 and a uniform L2 bound on partial_q phi_q. The scalar logarithmic map is still1-Lipschitz because F(u)/u decreases. Hence

    D(population next states)^2
       <=(1+C q_max^2) D(input states)^2.           (8a)

The normalized feature pointwise envelopes in Section5 remain uniform on this larger compact range as well. Thus the global population and small-quality empirical gains can be expressed through q_max squared even before the variances enter the near-critical box.

## 3. Hadamard powers in a constant white operator ball

Fix0<rho<1/4. Suppose C,C' are correlation matrices with

    ||C-I||op, ||C'-I||op <=rho.

For odd k>=3, all off-diagonal entries have magnitude at most rho. Consequently

    ||C^(Hadamard k)-C'^(Hadamard k)||F
       <= k rho^(k-1)||C-C'||F.                    (9)

Every such Hadamard power has eigenvalues in[1-rho^k,1+rho^k]. For example its off-diagonal row sums are bounded by

    rho^(k-2) sum_(j!=i) C_ij^2 <= rho^k,

because ||C-I||op<=rho. Standard square-root/Bures comparison on spectra contained in[1-rho,1+rho] now gives

    d_B(C^(Hadamard k), C'^(Hadamard k))
       <= C k rho^(k-1) d_B(C,C').                 (10)

All constants in(9)--(10) are dimension-independent. The metric-comparison constant multiplies only the nonlinear Hermite terms. It never multiplies the leading k=1 term.

## 4. Population local contraction with unequal variances

Assume q_i,p_i lie in[a epsilon,b epsilon] and C,C' satisfy the constant-radius condition of Section3. For every odd k, choose independently optimal unit-row factors R_k,S_k of C^(Hadamard k), C'^(Hadamard k). The direct sums

    [diag(a_k(q_i)) R_k]_k,
    [diag(a_k(p_i)) S_k]_k

are valid factors of K_q(C), K_p(C'). For each row, the elementary identity

    ||a r-b s||^2 = ab||r-s||^2+(a-b)^2,
         ||r||=||s||=1,

shows that the squared factor distance is at most

    sum_k M_k^2 d_B(C^(Hadamard k),C'^(Hadamard k))^2
       +sum_i sum_k[a_k(q_i)-a_k(p_i)]^2,            (11)

with the k=1 coefficient sharpened to sup_{q,p}a_1(q)a_1(p). Positivity of a_1 is immediate; for other indices absolute products suffice.

The first Hermite coefficient contributes at most(1-c epsilon^2)d_B(C,C')^2. By(4),(10), the higher terms contribute at most C epsilon^2 rho^4 d_B(C,C')^2: for rho<=1/4,

    sup_(k>=3) k^2 rho^(2k-2) <= C rho^4.

The last term in(11) is at most C epsilon^2 sum_i[log(q_i/p_i)]^2 by(1). Therefore

    d_B(K_q(C),K_p(C'))^2
       <=[1-c epsilon^2+C epsilon^2 rho^4]d_B(C,C')^2
          +C epsilon^2 sum_i[log(q_i/p_i)]^2.        (12)

Choose rho sufficiently small, independently of epsilon. Add the scalar squared contraction(2). For epsilon0 sufficiently small,

    D(population next states)^2
       <=(1-c' epsilon^2) D(input states)^2.         (13)

This direct factor proof avoids a possible geometric pitfall: ordinary Bures geodesics between correlation matrices need not remain correlation matrices. No assertion about geodesic convexity of the elliptope is used.

## 5. Empirical transfer and the required quality estimates

The global estimate transfers directly to the same-array empirical map when its uniform normalized mixed-secants quality has error eta=C(sqrt(v)+v). The relevant scalar classes are

    phi_q(u dot G),
    [phi_q(u dot G)-phi_p(w dot G)]
         /sqrt(||u-w||^2+[log(q/p)]^2),

and the analogous normalized difference of their squares. By(3) and the z-Lipschitz bound, the mixed secant is uniformly subGaussian; its square and the square-difference secant are uniformly subexponential. Here the denominator is the geometric angular/log-variance distance, not the possibly much smaller population L2 norm. Population normalization is exactly one.

A convenient way to obtain uniformity without compactifying normalized secants is to use directional derivatives. The functions

    phi_q(u dot G),
    phi_q'(u dot G)(v dot G),
    R_q(u dot G), R_q(z)=q partial_q phi_q(z),

with unit u,v and q in[0,2], have direct linear Gaussian envelopes, with R_0=0 and phi_0(z)=z. Products of two such functions are uniformly subexponential. Their parameter derivatives have fixed polynomial Gaussian envelopes, so the ordinary Gaussian-radius cutoff plus parameter-net argument gives uniform Bernstein bounds with the existing conservative m^4 log(eN)/N quality floor. Integrating these product bounds along a shortest sphere arc and a log-variance segment controls the empirical error of squared feature differences. The arc length is at most(pi/2)||u-w||, so only the empirical error receives a universal path-length constant. The exact population identity(6) is retained. Products phi times a directional derivative similarly control differences of empirical normalization errors. The resulting small-quality consequences are

    |empirical mean phi_q^2-1|<=C sqrt(v),
    |empirical mean(phi_q^2-phi_p^2)|
         <=C sqrt(v)*sqrt(||u-w||^2+[log(q/p)]^2),
    empirical mean(feature difference)^2
         <=population mean(feature difference)^2
              +C sqrt(v)*(||u-w||^2+[log(q/p)]^2).

Empirical normalization divides by quantities within1+O(sqrt(v)) of one. Its log-diagonal error is Lipschitz, with constant O(sqrt(v)), in the joint input distance. Using(7) and the scalar log map gives

    D(empirical next states)
       <=[1+C epsilon^2+C sqrt(v)]D(input states)   (14)

for sufficiently small absolute v. For large quality v>=v0, the existing scalar lower-normalization estimate gives empirical mean phi_q^2>=exp(-Cv), uniformly0<q<=2, while the sample Gaussian covariance has operator norm at most C(1+v). The direct Gaussian envelopes then bound normalized feature and log-normalization derivatives by exp(Cv). Integrating them gives joint-distance gain at most exp(Cv), absorbing fixed factors because v>=v0. Consequently the all-quality global logarithmic gain is

    C q_max^2 + C(sqrt(v)+v),

uniformly on0<q_i,p_i<=2. This uses the existing uniform lower-normalization/small-ball quality estimate; it does not infer a lower bound from an upper-tail Bernstein estimate.

For the local transfer one must not assume that the independent optimal Hermite couplings in Section4 arise from a single Gaussian array. They need not. Instead, in the white ball use canonical correlation factors sqrt(C),sqrt(C') for the fresh common array. Their physical factors are diag(sqrt(q_i))sqrt(C) and diag(sqrt(p_i))sqrt(C'). This coupling has the correct Gaussian transition marginals. The existing uniform covariance and derivative quality yields:

* empirical normalized output correlations differ from their population values by O(sqrt(v)) in operator norm;
* the difference between the two empirical errors is at most C sqrt(v)D(input states) in Frobenius norm;
* the empirical log-diagonal error difference is at most C sqrt(v)D(input states).

The constants are uniform as epsilon tends to zero because the normalized activation and its logarithmic radial derivative obey the pointwise Gaussian bounds above. More explicitly, both phi_q and R_q are odd and globally Lipschitz in their scalar argument, with uniform constants for q in[0,2]. For R_q this follows by differentiating

    R_q(z)=(t sqrt(q) z sech^2(t sqrt(q)z))/(2sqrt(T(q)))
                -(q T'(q)/(2T(q)))phi_q(z);

the combinations z sech^2(z) and z sech^2(z)tanh(z) are bounded. Let h_i=phi_{q_i}((BG)_i), with ||B||op bounded, and let M have Frobenius norm one. The norm ||Mh|| is subGaussian with dimension-independent scale, by Gaussian Poincare for its mean-square and Gaussian concentration for its Lipschitz norm. A normalized angular matrix tangent E gives a covariance derivative dual bounded by C||Mh|| ||EG||. A log-diagonal tangent r gives a dual bounded by

    2||Mh|| ||diag(r) R_q(BG)||.

The latter vector norm is subGaussian with scale C||r||_2 by the same Poincare/Lipschitz argument. Hence these Frobenius-dual covariance derivative tests are uniformly subexponential, including variable variances. The existing matrix-parameter net argument applies without an inverse-epsilon factor. Differentiating empirical row normalization adds only products with bounded operator norms and diagonal extraction, which is a Frobenius contraction.

Canonical-root secants are bounded by a constant times Bures distance on the white ball; that harmless constant multiplies only the empirical error.

These three estimates imply

    D(empirical next states)
       <=D(population next states)+C sqrt(v)D(input states)
       <=[1-c epsilon^2+C sqrt(v)]D(input states).  (15)

One detailed metric justification is useful. If population output covariances are P,P' in a fixed white operator ball and empirical errors are E,E', then

    d_B(P+E,P'+E')
       <=(1+C eta)d_B(P,P')+C||E-E'||F

when ||E||op,||E'||op<=eta. Insert P'+E as an intermediate matrix. A common additive E changes the Bures Riemannian metric by at most1+C eta along the ordinary Bures geodesic between P,P'; that geodesic remains in a slightly larger fixed white operator ball. The final difference E'-E is controlled by the usual square-root Lipschitz bound. This argument is on the full positive definite cone, so its geodesic is allowed to have varying diagonal.

Thus v<=c epsilon^4 gives local contraction1-c' epsilon squared on a constant relative white operator ball. The coupling may switch, based only on the past, between optimal Bures correlation factors outside the local ball and canonical correlation square roots inside it. This preserves both marginal empirical transition laws; the quality conditions must be uniform over these factor choices, as in the existing construction.

### Verification status of Section5

Equations(14)--(15) are deterministic consequences of the explicitly listed uniform secant/covariance/derivative quality estimates. The pointwise envelopes and the absence of inverse-epsilon constants are checked here. The full finite-net entropy and rare-event probability bookkeeping are delegated to the companion empirical-quality argument; this note alone does not replace that argument or establish a new finite-N theorem.

## 6. Return to the physical covariance metric

For arbitrary positive diagonals with q_max=max_i(q_i,p_i), choose optimal unit-row factors for C,C'. The same elementary identity gives

    d_B(D_q^(1/2) C D_q^(1/2),
        D_p^(1/2) C' D_p^(1/2))^2
       <= q_max d_B(C,C')^2
            +(q_max/4)sum_i[log(q_i/p_i)]^2
       <= q_max D((C,q),(C',p))^2.                 (16)

Thus a final joint-distance bound supplies the physical feature/readout coupling bound with factor sqrt(q_max). This estimate also does not require a geodesic argument.
