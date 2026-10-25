# Global polar coordinates remove the normalized coefficient sum

25 October 2026. New extension of the normalized-ridge-difference compiler.
This note concerns the represented quadratic class, not arbitrary internal
row laws. It changes the resource bound within that class: a uniform small
bound on the represented coefficient mass suffices, and the accumulated
cost is charged to actual entropy.

## 1. Statement

Use the normalized ridge/difference functions and notation of
normalized-ridge-difference-tilt-compiler.md:

    psi_i(g)=tanh(g.w_i)/||w_i||

or

    psi_i(g)=[tanh(g.w_i)-tanh(g.z_i)]/||w_i-z_i||.

All nonzero denominators are permitted. Anchors have squared norm at most
q<=2. Let

    V(g)=(1/2) sum_ik S_ik psi_i(g) psi_k(g),
    t=sum_ik |S_ik|<=t0,
    rho=exp(V) gamma/Z,
    D=KL(rho||gamma).

For a sufficiently small universal t0, the exact scalar-formula compiler
has local work/moment growth

    1+C(q+sqrt(D)+D).                                   (1)

The coefficient mass t need not be summed over layers. Consequently the
global formula-size bound has exponent C sum_j(q_j+sqrt(D_j)+D_j), even
when all normalized-ridge layers are charged by their actual entropies.
The class still requires a representation with t<=t0 at each layer; a
covariance-normalized HS bound alone does not supply such a representation.

The only changes to the previous proof are (a) use raw fixed-order
component moments, not component entropy, in nonlinear factories; and
(b) polar-normalize the whole mixture's linear feature map at once.

## 2. The positive mixture and weighted raw moments

The earlier exact construction uses a trace-one P>=0 and Q=t g.Pg/2,
with |V|<=Q. Write

    C_Q=(I+tP)^(-1),     g=C_Q^(1/2) xi,     xi~standard Gaussian.

Pairs I are sampled with probabilities |S_ik|/t. The nonnegative factors
h_I obey

    0<=h_I<=(A_i²+A_k²)/2,

where A_i,A_k are Gaussian linear forms of variance at most one in xi.
For K~Pois(1),

    w_omega=product_{l=1}^K(1+t h_{I_l}),
    Z_omega=E_gammaQ w_omega>=1,
    rho_omega=w_omega gammaQ/Z_omega,
    pi(domega)=Z_omega P(domega)/Zbar.

Here Zbar>=1 and rho is exactly the mixture of rho_omega under pi.
Each component changes a Gaussian block of rank r_omega<=4K.
Let z_omega be its orthogonal block coordinates in xi space.

For every fixed A>1 and integer m>=0 there is t0(A,m)>0 such that

    E_pi A^K E_rhoomega ||z_omega||^m <= C_(A,m).         (2)

This statement remains valid with any fixed polynomial in K inserted.
It is uniform over the changing component subspaces and over small
anchor denominators.

Proof: cancel Z_omega against the mixture weight, and upper-bound each
factor by 1+t(A_i²+A_k²)/2. Expand a chosen set of l factors. For any
chosen Gaussian linear forms L_1,...,L_l of variances <=1,
Cauchy--Schwarz followed by Gaussian Holder gives

    E ||z_omega||^m product_a L_a²
      <= (E||z_omega||^(2m))^(1/2)
         (E product_a L_a^4)^(1/2)
      <= C_m(K+1)^(m/2) [(4l-1)!!]^(1/2)
      <= C_m(K+1)^(m/2) C^l (2l-1)!!.

For l=0 use the convention (-1)!!=1. Averaging the two choices from
each quadratic factor does not change the bound. Summing subsets, then
K with its Poisson weight, gives, without the polynomial in K,

    E_K A^K sum_{l<=K} binom(K,l)(Ct)^l (2l-1)!!
       =exp(A-1) E_{Z~N(0,1)} exp(CAt Z²).

A slightly larger fixed exponential weight absorbs the polynomial in K.
The last Gaussian exponential is finite for t small, proving (2).
This avoids any false dimension bound on ||xi|| or an invalid exponential
moment of a quartic Gaussian polynomial.

## 3. Uncapped component factories

Let h be the incoming normalized state, ||h(x)||<=1, with the existing
coordinate trace and separate total-norm scalar oracle. The physical
preactivation is sqrt(q) g.h. In the component Fock representation put

    F_omega(h)=tanh(sqrt(q) g.h)/sqrt(q),
    L_omega h=g.h,
    R_omega=F_omega-L_omega.

Here L_omega is a map into the component feature Hilbert space; it
includes the change g=C_Q^(1/2)xi.

The existing block factory proof before entropy capping gives, for some
fixed integers p,m, vector residual trace and degree-weighted trace at most

    C(1+K)^p q²(1+||z_omega||^m),                       (3)

and a factory for the squared-norm increment

    E_rhoomega [tanh²(sqrt(q)g.h)/q-(g.h)²]

whose moment is bounded by the same expression after increasing p,m.
The degree weights also absorb scalar formula work and the projections
used below.

For clarity, the degree-zero residual uses the uncapped cubic estimate
q²||z||^6; the degree-one residual uses q² times a fixed fourth moment;
the scalar norm residual uses the fourth-order tanh² remainder and hence
q² times a fixed eighth moment. Higher Gaussian tensor degrees are summed
after their damping cancels the true perpendicular norm, leaving only
fixed Gaussian block moments. No degree-dependent moment order in z
is introduced. Multiplying by a block coordinate for a later adjoint adds
at most two to the moment order.

The helpers C_Q^(1/2)h are formed inside these correction factories.
They cost a constant factor in work/moment, since C_Q^(1/2)-I has HS
norm O(t) and bounded operator norm. There is no preliminary C_Q update
to the old-state copy and therefore no per-layer O(t) charge.

Integrating (3) with (2) gives residual trace and scalar norm-residual
moment O(q²), at common work O(T). Importance sampling/averaging balances
the fixed rank-dependent costs exactly as in the preceding block proof.

## 4. The global linear map and its polar isometry

Use the direct-integral feature Hilbert space with measure pi and put

    Lh=(L_omega h)_omega,       Sigma=L*L=E_rho gg*.

The quadratic envelope gives uniform positive bounds

    c I <= Sigma <= C I.                                (4)

For example, Z is between exp(-t/2) and E_gamma exp(Q)<=exp(Ct), and
the lower quadratic comparison integrates against gamma_Q. Its covariance
is at least (1+t)^(-1)I. The analogous upper comparison gives the upper
bound. These estimates also apply to isonormal Gaussian spaces by
finite-dimensional approximation.

Gaussian maximum entropy at fixed uncentered second moment gives

    (1/2)tr(Sigma-I-log Sigma)<=D.

The scalar inequality (sqrt(s)-1)²<=s-1-log s yields

    ||Sigma^(1/2)-I||_HS²<=2D.                          (5)

Define the common isometry

    J=L Sigma^(-1/2),       J*J=I.

The exact isometric embedding y -> (J*y,(I-JJ*)y) sends F=Lh+R to

    (Sigma^(1/2)h+J*R, (I-JJ*)R).                       (6)

Thus the old state is copied literally, plus the usual HS correction
(Sigma^(1/2)-I)h and nonlinear residuals whose moments are O(q²).
By (4)--(5), Sigma^(-1/2)-I also has HS norm O(sqrt(D)).

## 5. Scalar realization of both projections

It is not enough to invoke an abstract isometry; its scalar coordinate
operations must have the needed trace/work bounds. Let A_omega denote
the isometric embedding of the changed block in xi space and let
P_omega=I-A_omega A_omega*. If a component vector R is represented in
its Gaussian-perpendicular Fock coordinates R_0(z), R_1(z),..., then

    L_omega* R
      = C_Q^(1/2) [
           A_omega E_{rhoomega,z}(z R_0(z))
           + P_omega E_{rhoomega,z} R_1(z) ].           (7)

Only degrees zero and one contribute. Block projections use the
rank-polynomial scalar helpers of the existing proof. Multiplication by
z in (7) increases only a fixed moment order. Equations (2)--(3)
therefore give an oracle for the mixture average L*R with trace O(q²)
and common work O(T). Multiplication by Sigma^(-1/2), using its identity
plus HS representation and (4)--(5), gives J*R with the same bounds.

For Jb=L Sigma^(-1/2)b, apply the analogous degree-zero and degree-one
formulas forward. Their integrated second moments and scalar work are
bounded by the same weighted fixed-order moments. This gives scalar
oracles for JJ*R, hence (I-JJ*)R, with trace O(q²) and common work O(T).
Coordinate integrations are sampled with normalized squared densities
as before; no lower eigenvalue beyond the universal (4), no anchor
distance floor, and no finite ambient-dimension factor is used.

In particular, the potentially expensive maps L, J and their adjoints
are used only on corrections. They do not multiply the old-state
coordinate cost by a fixed factor at each layer.

## 6. Norm oracle, resets, and finite bits

The linear part Sigma^(1/2)h is handled by the established HS vector
and squared-norm calculus. Its cost is 1+O(sqrt(D)+D).

The additional squared-norm correction is exactly

    E_rho [tanh²(sqrt(q)g.h)/q-(g.h)²].

Section 3 provides its independent scalar oracle of moment O(q²).
Thus the old scalar norm is also copied, with rare nonlinear correction.
Creating the nonlinear vector and scalar corrections with probability
proportional to q gives work/moment increments O(q); creating the HS
correction with its usual probability adds O(sqrt(D)+D).

The physical common-scale normalization is charged using the actual
one-dimensional entropy retention bound, so it costs the same
q+sqrt(D)+D. Large values of this budget are handled by the existing
large-stage reset; the displayed bound (1) has its customary
exponential form in that case.

All new nodes are linear HS/projection helpers, sampled component
integrals, and existing residual factories. Their integrated trace and
common-work bounds have been proved above. The moment-floor and
conditional-RMS argument therefore yields the same finite-bit
realizations. Identically zero corrections are omitted before any
division. No coefficient-size assumption, efficient density evaluator,
or efficient sampler is asserted.

## 7. Remaining gap

This strengthens the earlier theorem from a small accumulated normalized
coefficient budget to a uniformly small per-layer representation bound.
It may therefore be useful even when sum_j t_j is large but the actual
entropy action is small. It does not show that optimal arbitrary
critical row laws admit this representation, nor that a normalized
costate HS bound implies it. Those remain substantive open questions.
