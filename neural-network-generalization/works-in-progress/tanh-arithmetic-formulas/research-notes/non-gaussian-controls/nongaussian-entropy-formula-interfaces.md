# Entropy tilts: stronger anchor transport and a one-dimensional formula interface

25 October 2026. Scratch research, not a proof of a general critical PNC1 ceiling. The original unrestricted Boolean-depth question remains open.

## 1. Conditional Gaussian transport improves the anchor replacement estimate

Let (A,X) have a Gaussian reference law, with conditional distribution

    X | A=a ~ N(m(a), r),

where r>=0 is independent of a. Let P be any absolutely continuous tilt, and let P' keep the P-marginal of A but use the reference conditional Gaussian law of X given A. Write

    delta = E_(A~P_A) KL(P_(X|A) || N(m(A),r)).

There is a coupling (A,X,X') with its displayed marginals, the same A on both sides, and

    E (X-X')^2 <= 2r delta.

For r>0 this is the one-dimensional Gaussian quadratic-transport inequality applied conditionally, followed by integration. Conditional monotone-quantile coupling is jointly measurable. When r=0, absolute continuity forces X=X'=m(A), so the conclusion still holds. Finite entropy gives finite conditional second moments and makes the application legitimate. The same statement holds for a vector Gaussian conditional with covariance Sigma, with the upper bound 2||Sigma||op delta.

Consequently, for any 1-Lipschitz activation phi,

    E [phi(X)-phi(X')]^2 <= 2r delta.

In the canonical anchor metric d_T, the shared anchor coordinates are literally unchanged. The distance between each query's projection and its aligned residual norm is at most the L2 distance in any coupling with shared anchors. Hence

    d_T <= sqrt(2 Q delta)

whenever the conditional Gaussian query variance is at most Q. This replaces the Pinsker-based O(delta^(1/4)) estimate in the existing anchor proof. It is a one-query coupling statement; it does not claim a common coupling preserving all query-query covariances.

For a succession of replacements, let a_j be the subsequent deterministic Lipschitz amplification. The accumulated error is at most

    sum_j a_j sqrt(2 Q_j delta_j).

If common bounds Q_j<=Q and a_j<=G suffice, choosing

    delta <= eta^2 / (2 H^2 Q G^2)

gives error eta. The greedy anchor count A/delta therefore has quadratic, rather than fourth-power, dependence on inverse accuracy in this part of the construction. This quantitative improvement does not by itself change the established circuit-complexity class.

## 2. Covariance control is dimension-free, but does not make the tilt Gaussian

If rho is a tilt of a standard K-dimensional Gaussian of relative entropy D, Gaussian Talagrand transport gives a coupling

    g=Z+b(Z),       E||b(Z)||^2 <= 2D,

using an optimal deterministic transport map when appropriate. The operator from u to b(Z) dot u, from R^K to L2 of the Gaussian Z, has Hilbert--Schmidt norm at most sqrt(2D). This is an exact dimension-free linear perturbation of the Gaussian first-chaos embedding.

The nonlinear error

    tanh(Z dot u+b(Z) dot u)-tanh(Z dot u)

is the unresolved step. Direct sampled-Z scalar evaluation introduces a dimension factor through the cost of the dense linear form Z dot u. General b can have infinite higher moments and arbitrarily high Gaussian-chaos complexity. Neither a cheap scalar-coordinate formula nor a Gaussian Fock transformation for this error follows merely from the HS bound.

## 3. A sharp one-dimensional entropy/Sobolev estimate

Let rho be a law on R of relative entropy D with respect to N(0,1), let q>0, and choose a fixed smooth cutoff chi supported in [-3,3] and equal to one on [-2,2]. Define the L2(rho)-valued curve

    R_q(a)(z)=chi(a)[tanh(sqrt(q) z a)-sqrt(q) z a]/sqrt(q).

Then

    ||R_q||_(H^(3/2)(R; L2(rho)))^2 <= C(q^2+D).       (1)

The constant depends only on chi and the Fourier normalization.

For a fixed v=sqrt(q)z, the scalar cutoff curve F_v(a)=chi(a)[tanh(va)-va] satisfies

    ||F_v||_(H^(3/2))^2 <= C min(v^6,v^2).             (2)

For |v|<=1, its L2, first and second derivative norms are O(|v|^3), and interpolation proves the first bound. For |v|>=1, the cutoff linear term has H^(3/2) norm O(|v|). For the tanh term, its derivative is chi' tanh(va)+v chi sech^2(va). The former term has bounded H^(1/2) norm plus an O(|v|) contribution by interpolation. The homogeneous H^(1/2) norm of v sech^2(va) is exactly |v| times that of sech^2, by scaling; multiplication by the fixed smooth cutoff is bounded on H^(1/2). Thus the squared H^(3/2) norm is O(v^2), proving (2).

After division by q, put W_q(z)=C min(q^2 z^6,z^2). It dominates the scalar squared norm in (1). Since W_q(z)<=C z^2 and also W_q(z)<=C q^2 z^6, a fixed small c>0 gives

    log E_gamma exp(c W_q(Z)) <= C' q^2.

Indeed exp(cW)-1<=cW exp(cW)<=C q^2 Z^6 exp(cC Z^2), whose Gaussian expectation is finite for small c. Entropy duality gives E_rho W_q<=C(D+q^2). Hilbert-valued Fubini/Plancherel now proves (1).

The same proof gives H^(1+alpha) for every 0<alpha<=1/2. It does not give H^s uniformly from entropy alone for s>3/2: steep tanh transitions have H^s squared norm of order |v|^(2s-1), and rho need not have moments above two.

## 4. Why the Sobolev estimate alone does not yet give the desired formula theorem

For a scalar oracle X of mean a and bounded second moment V, a Poisson estimator for exp(i omega a) has variance O(1), expected complex-formula size O((1+omega^2 V)T), where T is the child size. All internal real/imaginary projections can be retained until the final fixed-seed complex-to-real balancing step.

Optimized Fourier importance sampling for a scalar function f normally gives the work-times-second-moment bound

    C T [integral |fhat(omega)| sqrt(1+omega^2 V) d omega]^2.

A generic H^s estimate controls this integral only for s>3/2. At s=3/2, truncating frequencies at Lambda incurs a sqrt(log Lambda) factor in the integral, and a log Lambda factor in its square. Therefore (1) alone does not establish a polynomial-size arithmetic-formula compiler when the cumulative curvature budget is logarithmic in the ambient resources. It may yield a quasipolynomial refinement, but no such full path theorem is asserted here.

## 5. A stronger direct scalar factory retains the entropy cap

For each fixed z, the curve in the previous section has a more economical factory than a generic Sobolev argument. On |a|<=1, use the scalar residual Fourier--Poisson construction when s^2=q z^2 is small, and the ordinary tanh construction minus the linear term when s^2 is large. For a child oracle of second moment bounded by an absolute constant, its optimized expected complex work times second moment obeys

    C T min(q^2 z^6,z^2).                            (3)

For small s this is the sixth-order residual moment bound with bounded Poisson work. For large s, the ordinary tanh factory for phi_s(a)=tanh(sa)/s has work-times-moment bounded uniformly in s, and multiplying by z and subtracting z a costs O(z^2 T). Sparsifying an expensive call to a prescribed common expected-work cap increases its second moment by the reciprocal probability and preserves this product bound. Thus (3) can be integrated over rho, with total cost-moment bounded by C T(q^2+D).

This gives a promising interface for continuous direct-integral feature coordinates indexed by z. It is not already a coordinate formula for an arbitrary orthonormal basis of L2(rho): changing from pointwise z coordinates to that basis can destroy the inexpensive linear-copy operation. Likewise, for a rank-one tilt followed by Gaussian orthogonal coordinates, mixed shifted-Hermite coefficients require an additional argument; the scalar factory cannot simply be substituted for those coefficients.

## 6. Entropy does not supply the missing high moments

Let rho_M=(1-p)N(0,1)+(p/2)N(M,1)+(p/2)N(-M,1), with p=D0/M^2 and M large. Convexity of relative entropy gives

    KL(rho_M || N(0,1)) <= p M^2/2 = D0/2.

For every r>2, E_rho_M |Z|^r grows as D0 M^(r-2). Thus no uniform higher-moment estimate can follow from D alone. At q=M^-2 the normalized tanh residual has a tail contribution of order D0 to its second moment, showing why the sqrt(D) term in residual-size estimates cannot generally acquire a factor q.

Similarly, bounded high-frequency density tilts proportional to 1+eta cos(kZ) have entropy O(eta^2) but unbounded Fisher information as k grows. Any Fisher-information or transport-derivative hypothesis would be an additional restriction, not a consequence of the current posterior action bound.

These examples invalidate particular shortcuts; they do not disprove a PNC1 upper bound or establish an exponential-depth learning lower bound.
