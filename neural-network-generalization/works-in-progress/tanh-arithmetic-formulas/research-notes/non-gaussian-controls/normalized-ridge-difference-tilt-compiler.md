# A compiler for quadratic tilts in normalized ridge differences

25 October 2026. Candidate theorem for independent audit. This removes the raw entrywise coefficient norm from a nontrivial family of quadratic controls, including arbitrarily large coefficients caused by nearly identical ridge features. It is still a restricted representation condition, not a theorem for every normalized covariance costate.

## 1. The normalized features

Let the Gaussian reference row g lie in a finite-dimensional Euclidean space. Every query and anchor vector has squared norm at most q<=2. Allow either of the following odd scalar anchor features, omitting zero denominators:

    psi_i(g)=tanh(g.w_i)/||w_i||,

or

    psi_i(g)=[tanh(g.w_i)-tanh(g.v_i)]/||w_i-v_i||.

Associated with each feature is a unit vector a_i: respectively w_i/||w_i|| or (w_i-v_i)/||w_i-v_i||. The unit Lipschitz constant of tanh and the derivative bound for sech-squared give

    |psi_i(g)|<=|g.a_i|,
    ||grad psi_i(g)||<=1+C|g.a_i|,                     (1)

with a universal C because ||w_i||,||v_i||<=sqrt(2). For the difference, write its gradient as

    a_i sech^2(g.w_i)
       +v_i[sech^2(g.w_i)-sech^2(g.v_i)]/||w_i-v_i||.

This proves (1) uniformly even when the denominator is arbitrarily small.

Let S be any finite symmetric coefficient matrix and define

    V(g)=.5 sum_(i,j) S_ij psi_i(g)psi_j(g),
    t=sum_(i,j)|S_ij|,
    rho(dg)=exp(V(g)) gamma(dg)/Z.

There is a universal small t_0>0 for which the construction below applies whenever t<=t_0. The number and span of the anchors are unrestricted. If t=0 the layer is free Gaussian.

**Local conclusion.** Given the scalar vector/norm oracle invariant of the fixed-rank compiler, this controlled tanh layer has scalar expected-work and moment growth 1+C(q+t), with all physical rescalings charged. The means and entire feature kernel are preserved exactly. The actual row entropy is at most Ct^2. Along a path of such controls, interspersed with the previously compiled layers, the resource exponent gains sum_j(q_j+t_j), rather than the raw coefficient sum obtained by expanding the small denominators. The existing finite-bit completion applies without a lower bound on those denominators.

## 2. Shift the reference by a Gaussian envelope

Put A_i=g.a_i and

    P=(1/(2t))sum_(i,j)|S_ij|(a_i a_i*+a_j a_j*),
    Q(g)=(t/2)g*Pg.

Then P is positive semidefinite with trace one and |V(g)|<=Q(g). Let gamma_Q be the Gaussian measure proportional to exp(-Q)gamma, with covariance C_Q=(I+tP)^(-1). This linear reference change has HS distance O(t) from the identity and Gaussian relative entropy O(t^2).

Choose a pair I=(i,j) with probability |S_ij|/t and write sigma_I=sign(S_ij). Define

    h_I(g)=[A_i^2+A_j^2+2sigma_I psi_i(g)psi_j(g)]/4.

By (1),

    0<=h_I(g)<= (A_i^2+A_j^2)/2,
    H(g):=E_I h_I(g),
    V(g)+Q(g)=tH(g),
    H(g)<=g*Pg.                                        (2)

Each h_I depends on at most four original anchor directions. In whitened gamma_Q coordinates it still depends on at most four directions; the perpendicular coordinates remain independent Gaussian.

## 3. An exact positive Poisson mixture with unbounded factors

Draw K~Poisson(1) and K independent pairs I_1,...,I_K. Set

    w_omega(g)=product_(l=1)^K[1+t h_(I_l)(g)],
    Z_omega=E_(gamma_Q) w_omega,
    rho_omega=w_omega gamma_Q/Z_omega.

Every factor is at least one, so Z_omega>=1. The Poisson product identity gives

    E_omega w_omega=exp(tH)=exp(V+Q).

Consequently rho is exactly the mixture of rho_omega under weights

    pi(domega)=Z_omega P(domega)/Zbar,
    Zbar=E_(gamma_Q)exp(tH)>=1.                         (3)

Each component is an independent block tilt of rank at most 4K relative to gamma_Q. This is a genuine positive mixture, not a signed expansion.

For one fixed A>1, choose t_0 small enough that 2At_0<1/2. Then

    E_pi A^K
      =exp(A-1) E_(gamma_Q)exp(AtH)/Zbar <= C_A.        (4)

Indeed H<=g*Pg, tr P=1, and the Gaussian quadratic exponential moment is uniformly bounded at those parameters. The same argument bounds every fixed polynomial moment of K. One such A>1 is sufficient because the local block compiler's rank dependence is polynomial.

## 4. Weighted component entropies: use logarithmic Sobolev

Let D_omega=KL(rho_omega||gamma_Q). For the same fixed A>1,

    E_pi A^K D_omega <= C_A t^2,
    E_pi A^K D_omega^2 <= C_A t^2.                    (5)

The first bound requires an argument different from the bounded-factor case. Averaging a chi-square/Poincare bound for w_omega^2 introduces a positive quartic exponential and can diverge. Instead use the Gaussian logarithmic Sobolev inequality. Since C_Q<=I,

    Z_omega D_omega
        <=.5 E_(gamma_Q) [||grad w_omega||^2/w_omega].

With f_I=1+t h_I, Cauchy--Schwarz in the sum of K logarithmic derivatives gives

    ||grad w||^2/w
       <= Kt^2 sum_l ||grad h_(I_l)||^2
                     product_(m!=l) f_(I_m),          (6)

where the remaining denominator f_(I_l)>=1 was dropped. Let

    G(g)=E_I ||grad h_I(g)||^2.

Poisson Palm summation applied to (6) yields

    E_P A^K [||grad w||^2/w]
      <= t^2 A G[1+A(1+tH)] exp[A-1+AtH].             (7)

For completeness, the selected factor contributes A; writing K=1+K_rest gives the bracket 1+A E f. The remaining Poisson product has expectation exp(A E f-1).

Equation (1) bounds ||grad h_I||^2 by a universal constant times

    A_i^2+A_j^2+A_i^2 A_j^2.

The Gaussian reference in (7), further reweighted by exp(At g*Pg), has covariance operator norm bounded by a universal constant and a bounded normalizing factor. All displayed fixed-degree moments are therefore uniformly bounded, independently of dimension or number of pairs. The factor H in (7) is handled by one additional fixed Gaussian moment. Integrating proves the first bound in (5).

For the second, w>=1 and Z_omega>=1 imply

    D_omega<=E_(rho_omega) log w,
    D_omega^2<=E_(rho_omega)(log w)^2
       <=t^2 E_(rho_omega)(sum_l h_(I_l))^2.

Write H_s(g)=E_I h_I(g)^s. An exact Palm identity is

    E_P A^K w(sum_l h_(I_l))^2
      =exp[A-1+AtH]
         { A(H_2+tH_3)+A^2(H+tH_2)^2 }.              (8)

Every term is a fixed-degree Gaussian moment under the same small quadratic reweighting, by (2). Products of pair averages are bounded by introducing independent pair indices or by Jensen. Thus (8), after integration and division by Zbar>=1, proves the second bound in (5). No deterministic component-entropy bound, higher moment of an arbitrary entropy tilt, or exponential-in-component-entropy reset is used.

If a rank polynomial (K+1)^p is also needed, use (4)--(5) at a slightly larger fixed A and absorb that polynomial into the exponential. The threshold t_0 is chosen after fixing this A. No threshold depends on the number or geometry of the anchor vectors.

## 5. Integration into the scalar compiler

Apply the Gaussian covariance change C_Q^(1/2) to the incoming state using the existing HS scalar/norm interface. It costs 1+O(t) and does not increase anchor or query norms. Denominators in the normalized ridges remain the original ones, and (1) remains valid after this contraction.

The local block residual factories have common-work bounds

    poly(1+r)(q^2+D_omega),
    poly(1+r)(q^2+D_omega+D_omega^2)

for vector trace and scalar norm increments, respectively. Balance their work before integrating components. Equations (4)--(5) and r<=4K make both integrated bounds O(q^2+t^2).

Let J_omega be the component's normalized linear isometry and S_omega-I its HS linear correction. On the direct integral under pi, define

    Jh=(J_omega h)_omega,
    Rtilde_omega=R_omega+J_omega(S_omega-I)h.

Then J*J=I, and the extra linear residual has integrated HS squared norm at most 2E_pi D_omega=O(t^2). The exact embedding

    F -> (h+J*Rtilde,(I-JJ*)Rtilde)

preserves all kernels and restores literal old coordinates. Component adjoints, reapplication, and mixture integration cost only another fixed rank polynomial. The total-norm scalar uses the averaged component increment. Thus both residual moments are O(q^2+t^2).

Rare creation with probability proportional to q+t and ordinary averaging resets give the claimed local 1+C(q+t) work and moment growth. Large q+t within its bounded range is handled by a fixed reset cost.

The actual entropy also obeys D(rho||gamma)<=Ct^2. One direct proof uses logarithmic Sobolev on the density exp(V)/Z. From (1), ||grad V||^2 has expectation O(t^2) under rho, because |V|<=Q and the small Gaussian quadratic envelope bounds the necessary fixed moments. Also Z>=exp(E_gamma V)>=exp(-t/2), so normalization is uniformly controlled. Therefore

    D(rho||gamma)<=.5 E_rho||grad V||^2<=Ct^2.

The norm-retention theorem now charges physical normalization by C(q+t). The existing independent-noise, multilinear-category, and direct-integral finite-bit proofs apply to the component scalar factories. They require neither an efficient sampler for pi nor a lower bound on ||w_i-v_i||. Only a finite collection of coefficients appears in a chosen good seed.

## 6. What this achieves

A term (t/2)[tanh(g.w)-tanh(g.v)]^2/||w-v||^2 has raw coefficients of order t/||w-v||^2, yet is covered at cost O(q+t), uniformly as w approaches v. More general signed quadratic combinations are covered whenever they have the displayed normalized-ridge representation with small total coefficient mass.

Ordinary bounded raw coefficients are included: write tanh(g.w_i)=||w_i|| psi_i, so t=sum|T_ij|||w_i||||w_j||<=q sum|T_ij|. The new condition also captures cancellations between nearly identical anchors that this weighted absolute sum misses.

The result does not show that every covariance-normalized costate Q^(1/2)TQ^(1/2) with bounded HS norm admits such a representation at comparable t. A dense normalized feature direction can be a complicated linear combination of many tanh ridges, rather than a bounded-support ridge difference. That representation problem remains open and is the distinction between this theorem and a full normalized-costate compiler.
