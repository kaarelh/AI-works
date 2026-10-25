# Independent non-Gaussian blocks of bounded rank

25 October 2026. Scratch extension of the independently audited rank-one compiler. The independent non-Gaussian-formula agent has checked this extension; its PASS record is `bounded-rank-independent-tilt-extension-audit.md`.

The rank-one restriction can be relaxed to any fixed finite block rank. The resulting constants depend on that rank. This does not provide a dimension-free compiler for general finite-entropy row laws.

## Statement

Fix r_0. At each layer choose a subspace E of dimension r<=r_0, a law rho on R^r with D=KL(rho||gamma_r), and an independent standard Gaussian on E-perpendicular. The subspaces and the tilted laws may change arbitrarily with the layer. Under the same supplied physical path and initial scalar-oracle assumptions as the rank-one theorem, the arithmetic-formula resource bound is

    initial resources * exp[C_(r_0) sum_j(q_j+sqrt(D_j)+D_j)].

The same finite-bit completion gives a majority of polynomial-bit arithmetic-sign formulas with resources bounded by poly(d+H+1+readout/margin) times the displayed exponential factor, including the ordinary polynomial H factor needed for noise-floor bookkeeping. No uniform assertion about the growth of C_(r_0) is intended here.

## Local reduction

Let a_1,...,a_r be an orthonormal basis of E, A the corresponding isometric inclusion, P=I-AA*, alpha=A*h, and v=Ph. Store the full state and its total squared norm s; use the local perpendicular-norm helper r_perp=s-sum_l alpha_l^2. Every alpha_l is obtained by squared-coordinate importance sampling. For fixed block rank, all local moments and expected costs are bounded by constants depending only on r_0. These helpers are called only inside the residual branches.

For a fixed z, put eta_z=A z/||z|| if z is nonzero. The scalar alpha_z=<eta_z,h> has an unbiased coordinate-importance oracle of second moment at most the old trace, uniformly in z. Thus the entire scalar/Fock construction applies with z alpha replaced by ||z|| alpha_z. Gaussian tensor directions remain v, and the local r_perp oracle is unchanged. In particular the residual caps become

    min(q^2 ||z||^6,||z||^2),
    min(q^2 ||z||^4,q ||z||^2),
    q+min(q ||z||^4,||z||^2).

Relative exponential damping still cancels the true perpendicular-norm exponential. The same child moment and degree-dependent averaging arguments apply.

## Entropy caps

For a fixed dimension r, a sufficiently small absolute c>0 has

    log E_gamma_r exp[c min(q^2||Z||^6,||Z||^2)] <= C_r q^2,
    log E_gamma_r exp[c min(q||Z||^4,||Z||^2)] <= C_r q,

for 0<q<=2. For example exp(cW)-1<=cW exp(c||Z||^2), followed by Gaussian moments, proves both estimates with finite dimension-dependent constants. Entropy duality then gives C_r(q^2+D) and C_r(q+D), respectively. The q-weighted quartic cap is handled identically. Hence vector residual trace and norm-increment moment are bounded by C_r(q^2+D) and C_r(q+sqrt(D)+D)^2.

## Linear embedding and residual projection

Set M=E_rho ZZ*. Finite relative entropy makes M positive definite and implies

    tr(M)-log det(M)-r <= 2D,
    ||sqrt(M)-I||_HS <= sqrt(2D).

The first inequality follows from Gaussian maximum entropy applied to the covariance, which is at most the uncentered second-moment matrix M. The second follows eigenvalue by eigenvalue from (sqrt(lambda)-1)^2<=lambda-1-log lambda.

With xi=M^(-1/2)z, define J by degree-zero output xi*alpha and degree-one output Ph, constant in z. Since E xi xi*=I, J is an isometry. The true linear map is J followed by I+A(sqrt(M)-I)A*. Thus it is an exact copy plus an HS perturbation of size at most sqrt(2D).

For a residual R, the block component of J*R is b_l=E xi_l R_0, and the perpendicular component is P E R_1. Estimate each b_l by sampling from density xi_l^2 relative to rho. Each coordinate has moment bounded by the full degree-zero residual trace; summing over r coordinates costs at most r. Coordinate sampling implements the rank-r projection P with rank-dependent constant trace/work overhead. Reapplying J likewise costs only a rank-dependent constant. Consequently the isometry F -> (J*F,(I-JJ*)F) retains literal old-coordinate copies and only projects the small residual.

No fixed subspace is required at the next layer. The scalar s update is the same squared-norm increment calculation, with the linear correction alpha*(M-I)alpha estimated using independent alpha calls. Its moment is bounded using ||M-I||_HS<=C(sqrt(D)+D).

## Path and precision closure

For small budget b=q+sqrt(D)+D, residual branches and their rank-dependent helper costs produce 1+C_r b trace/work increments. Large steps use polynomial averaging resets, charged at C_r b logarithmic cost. The physical metric-retention bound is dimension-free and charges all normalization gains to b. This gives the stated exponential-in-total-budget bound.

Every correlated Fourier/Taylor primitive remains a multilinear polynomial in independent underlying child samples. The fixed degree-category algebra, independent noise floors, direct-integral importance samplers, and one global arithmetic balancing therefore give the same finite-bit conclusion.

The unresolved step is sufficiently good quantitative dependence on rank. An arbitrary full-dimensional tilt cannot be reduced to bounded-rank independent blocks by the entropy chain rule: its conditional block laws generally depend on the perpendicular Gaussian coordinates. That dependence is precisely excluded here.

## Quantitative entropy constants

The entropy portion of the argument need not lose an exponential in r. For r>=1 choose the dual exponential-moment parameter c=1/(8r). Then

    E_gamma_r exp(c||Z||^2) <= C,
    E_gamma_r ||Z||^(2k) exp(c||Z||^2) <= C_k r^k

for each fixed k. Using exp(cW)-1<=cW exp(c||Z||^2) gives the explicit bounds

    E_rho min(q^2||Z||^6,||Z||^2) <= C(rD+q^2 r^3),
    E_rho min(q||Z||^4,||Z||^2) <= C(rD+q r^2).

The proof is uniform for 0<q<=2. This is a quantitative refinement of the entropy sublemma, not by itself a dimension-free path compiler. The local projection and scalar-oracle constructions also have rank costs; their exact combined polynomial has not been optimized here.
